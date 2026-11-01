
   function TileContactGen(_layerName, _bounciness = 1) : ContactGen() constructor {

    name = "Tile";
    bounciness = _bounciness;
    layerName = _layerName;
    tilemap = -1;
    
    //Stores Four corners of the tile rectangle
    tileVerts   = [{x:0,y:0}, {x:0,y:0}, {x:0,y:0}, {x:0,y:0}];
    //Stores the four outward-facing directions
    tileNormals = [{x:0,y:-1}, {x:1,y:0}, {x:0,y:1}, {x:-1,y:0}];   // outward, never change
    //Tells SAT which tile faces should be ignored because they are internal edges.
    tileSkip    = [false, false, false, false]; 
    
    //Does this grid cell contain a solid tile ?
    static isSolid = function(_cx, _cy) {
        return tilemap_get(tilemap, _cx, _cy) > 0;
    };
    
    
    // ---------------- broad phase (any shape) ----------------
    static addContact = function(_rb, _pw, _limit) {
        
        if (_rb.inverseMass == 0) return 0;
        
        //Retrieve the tilemap
        if (tilemap == -1) {
            tilemap = layer_tilemap_get_id(layer_get_id(layerName));
            if (tilemap == -1) return 0;
        }
        //Deter,ine the Body's shape
        var _isPoly = array_length(_rb.localVertices) >= 3;
        var _verts, _normals;
        var _minX, _maxX, _minY, _maxY;

        if (_isPoly) {
            _verts   = polygon_get_world_vertices(_rb);
            _normals = polygon_get_face_normals(_verts);
            _minX = infinity;  _minY = infinity;  _maxX = -infinity;  _maxY = -infinity;
            for (var i = 0; i < array_length(_verts); i++) {
                _minX = min(_minX, _verts[i].x);  _maxX = max(_maxX, _verts[i].x);
                _minY = min(_minY, _verts[i].y);  _maxY = max(_maxY, _verts[i].y);
            }
        } else {
            var _r = _rb.radius;                     // rename if your circle uses another field
            _minX = _rb.position.x - _r;  _maxX = _rb.position.x + _r;
            _minY = _rb.position.y - _r;  _maxY = _rb.position.y + _r;
        }
        
        

        var _tw = tilemap_get_tile_width(tilemap);
        var _th = tilemap_get_tile_height(tilemap);
        //Tilemap origin in world coorrdinates
        var _ox = tilemap_get_x(tilemap);
        var _oy = tilemap_get_y(tilemap);
        //Calculates the tile-coordinate range:
        var _cx0 = max(0, floor((_minX - _ox) / _tw));
        var _cx1 = min(tilemap_get_width(tilemap)  - 1, floor((_maxX - _ox) / _tw));
        var _cy0 = max(0, floor((_minY - _oy) / _th));
        var _cy1 = min(tilemap_get_height(tilemap) - 1, floor((_maxY - _oy) / _th));
        
        //Protect the contact buffer
        var _used = 0; //Counts how many contacts this particular genertor has created
        var _idx  = _pw.nextContactIdx; // The index where the next contact will be written
        var _cap  = array_length(_pw.contacts); // The total number of contact slots available in physic world's array
        
            
        for (var cy = _cy0; cy <= _cy1; cy++) {
            for (var cx = _cx0; cx <= _cx1; cx++) {
                if (!isSolid(cx, cy)) continue;
                //Prevents Writing beyond the contact array
                var _room = _limit - _used;
                if (_room < 1 || _idx >= _cap) return _used;
                //Reserves contact slots before calling collision
                var _c1 = _pw.contacts[_idx];
                var _c2 = (_room >= 2 && _idx + 1 < _cap) ? _pw.contacts[_idx + 1] : undefined;
                var _n;

                if (_isPoly) {
                    // Each vertical run of solid tiles is handled once, as one tall tile
                    if (cy > _cy0 && isSolid(cx, cy - 1)) continue;
                    var _top = cy;  while (isSolid(cx, _top - 1)) _top--;
                    var _bot = cy;  while (isSolid(cx, _bot + 1)) _bot++;

                    _n = PolyTile(_rb, _verts, _normals, cx, _top, _bot,
                                  _ox + cx * _tw, _oy + _top * _th, _tw, (_bot - _top + 1) * _th, _c1, _c2);
                } else {
                    _n = CircleTile(_rb, cx, cy, _ox + cx * _tw, _oy + cy * _th, _tw, _th, _c1);
                }

                _used += _n;
                _idx  += _n;
            }
        }
        if (_used >= _limit) show_debug_message("TILE LIMIT HIT: " + string(_used) + " / " + string(_limit));
        return _used;
        
    };

    // ---------------- polygon (any convex) vs one tile ----------------
    static PolyTile = function(_rb, _vertsA, _normalsA, _cx, _top,_bot, _tx, _ty, _tw, _th, _c1, _c2) {

            // Fill the tile polygon: TL, TR, BR, BL
        tileVerts[0].x = _tx;       tileVerts[0].y = _ty;
        tileVerts[1].x = _tx + _tw; tileVerts[1].y = _ty;
        tileVerts[2].x = _tx + _tw; tileVerts[2].y = _ty + _th;
        tileVerts[3].x = _tx;       tileVerts[3].y = _ty + _th;
    
        // Top and bottom of a run are exposed by definition.
        // Left/right are internal only if the neighbor column is solid along the whole run.
        tileSkip[0] = false;
        tileSkip[2] = false;
        tileSkip[1] = true;
        tileSkip[3] = true;
        for (var r = _top; r <= _bot; r++) {
            if (!isSolid(_cx + 1, r)) tileSkip[1] = false;
            if (!isSolid(_cx - 1, r)) tileSkip[3] = false;
        }

        // A = body, B = tile. Normal points B -> A (tile -> body), same as PolyPoly
        var _r = satOverlap(_normalsA, tileNormals, _vertsA, tileVerts , tileSkip , true, 0.5);
        if (_r.separating) return 0;
            
        var _normal = _r.normal;
        //identiifiesthe relevant face selected by the SAT helper
        var _fi = _r.faceIndex;
        //identifies which polygon supplied the refrence face.
        var _refVerts, _refNormals, _incVerts, _incNormals;
        //Choose the refreence face and incident face
        if (_r.refIsA) {
            _refVerts = _vertsA;     _refNormals = _normalsA;
            _incVerts = tileVerts;   _incNormals = tileNormals;
        } else {
            _refVerts = tileVerts;   _refNormals = tileNormals;
            _incVerts = _vertsA;     _incNormals = _normalsA;

        }
        
        
        var _refFace = {
            a : _refVerts[_fi],
            b : _refVerts[(_fi + 1) mod array_length(_refVerts)],
            normal : _refNormals[_fi]
        };
        var _incFace = GetPolygonFace(_incVerts, _incNormals, _refFace.normal, false);
        
        var _ex = _refFace.b.x - _refFace.a.x;
        var _ey = _refFace.b.y - _refFace.a.y;
        var _len = sqrt(_ex * _ex + _ey * _ey);
        if (_len <= 0.00001) return 0;
        _ex /= _len;  _ey /= _len;
        //Calculate contact points using clipping
        var _faceOffset = dot_product(_refFace.normal.x, _refFace.normal.y, _refFace.a.x, _refFace.a.y);
        var _rest = (_rb.bounciness + bounciness) * 0.5;
        
        var _pts = [];
        if (_r.refIsA) {
            // Body face is the reference: the tile's corners are the incident points. Clip as before.
            var _side1 = { x : -_ex, y : -_ey };
            var _side2 = { x :  _ex, y :  _ey };
            var _clip = ClipSegmentToLine(_incFace.a, _incFace.b, _side1, dot_product(_side1.x, _side1.y, _refFace.a.x, _refFace.a.y));
            if (array_length(_clip) < 2) return 0;
            _clip = ClipSegmentToLine(_clip[0], _clip[1], _side2, dot_product(_side2.x, _side2.y, _refFace.b.x, _refFace.b.y));
            if (array_length(_clip) < 2) return 0;
            _pts = _clip;
        } else {
    // back-of-tile limit: run height for top/bottom faces, tile width for side faces
    var _back = (abs(_refFace.normal.y) > 0.5) ? _th : _tw;

    // 1. Body vertices that lie inside this column
    for (var k = 0; k < array_length(_vertsA); k++) {
        var _vx = _vertsA[k].x, _vy = _vertsA[k].y;
        var _s = (_vx - _refFace.a.x) * _ex + (_vy - _refFace.a.y) * _ey;
        if (_s < 0 || _s >= _len) continue;

        var _d = dot_product(_refFace.normal.x, _refFace.normal.y, _vx, _vy) - _faceOffset;
        if (_d > 0.5 || _d < -_back) continue;
        array_push(_pts, _vertsA[k]);
    }

    // 2. No vertex here, but a body edge may still cross the column (tilted triangle)
    if (array_length(_pts) == 0) {
        var _clip = ClipSegmentToLine(_incFace.a, _incFace.b, { x : -_ex, y : -_ey },
            dot_product(-_ex, -_ey, _refFace.a.x, _refFace.a.y));
        if (array_length(_clip) >= 2) {
            _clip = ClipSegmentToLine(_clip[0], _clip[1], { x : _ex, y : _ey },
                dot_product(_ex, _ey, _refFace.b.x, _refFace.b.y));
        }
        if (array_length(_clip) >= 2) {
            var _bestD = infinity, _bestP = undefined;
            for (var c = 0; c < 2; c++) {
                var _dc = dot_product(_refFace.normal.x, _refFace.normal.y, _clip[c].x, _clip[c].y) - _faceOffset;
                if (_dc < _bestD) { _bestD = _dc; _bestP = _clip[c]; }
            }
            if (_bestP != undefined && _bestD < -1) array_push(_pts, _bestP);
        }
    }
}
        //Create the contact objects
        var _created = 0;
        
        for (var i = 0; i < array_length(_pts); i++) {
            var _p = _pts[i];
            var _sep = dot_product(_refFace.normal.x, _refFace.normal.y, _p.x, _p.y) - _faceOffset;
            if (_sep > 0.5) continue;
        
            var _pen = -_sep;                                         // can be slightly negative (speculative)
            if (_pen < 0.001 && abs(_normal.y) < 0.5) continue;       // walls: only real overlap, or you drag on them
        
            var _con = (_created == 0) ? _c1 : _c2;
            if (_con == undefined) break;
        
            _con.clear();
            _con.rb1 = _rb;
            _con.rb2 = undefined;
            _con.restitution = _rest;
            _con.normal.set(_normal.x, _normal.y);
            _con.penetration = max(0, _pen);
            _con.point.set(_p.x, _p.y);
            _created++;
        }
        // Fallback: a protruding tile corner poking into a body edge (no body vertex inside)
        if (_created == 0) {
            var _nA = array_length(_vertsA);
            for (var k = 0; k < 4; k++) {
                if (_created >= 2) break;

                // Only real protruding corners: no solid neighbor sideways at that corner's row
                var _exposed;
                if (k == 0)      _exposed = !isSolid(_cx - 1, _top);
                else if (k == 1) _exposed = !isSolid(_cx + 1, _top);
                else if (k == 2) _exposed = !isSolid(_cx + 1, _bot);
                else             _exposed = !isSolid(_cx - 1, _bot);
                if (!_exposed) continue;

                var _px = tileVerts[k].x, _py = tileVerts[k].y;

                var _minDepth = infinity, _bi = -1, _inside = true;
                for (var f = 0; f < _nA; f++) {
                    var _a = _vertsA[f];
                    var _dd = dot_product(_normalsA[f].x, _normalsA[f].y, _px - _a.x, _py - _a.y);
                    if (_dd > 0) { _inside = false; break; }
                    if (-_dd < _minDepth) { _minDepth = -_dd; _bi = f; }
                }
                if (!_inside) continue;

                var _con2 = (_created == 0) ? _c1 : _c2;
                if (_con2 == undefined) break;

                _con2.clear();
                _con2.rb1 = _rb;
                _con2.rb2 = undefined;
                _con2.restitution = _rest;
                _con2.normal.set(-_normalsA[_bi].x, -_normalsA[_bi].y);
                _con2.penetration = _minDepth;
                //_con2.frictions = sqrt(_rb.frictions * 0.1);   // 0.6 = floor material
                _con2.point.set(_px, _py);
                _created++;
            }
        }
        return _created;
    };


    // ---------------- circle vs one tile ----------------
    static CircleTile = function(_rb, _cx, _cy, _tx, _ty, _tw, _th, _c) {
        var _px = _rb.position.x, _py = _rb.position.y, _r = _rb.radius;

        // Closest point on the tile to the circle center
        var _qx = clamp(_px, _tx, _tx + _tw);
        var _qy = clamp(_py, _ty, _ty + _th);
        var _dx = _px - _qx, _dy = _py - _qy;
        var _d2 = _dx * _dx + _dy * _dy;
        if (_d2 >= _r * _r) return 0;

        var _nx, _ny, _pen;
        if (_d2 > 0.000001) {
            var _d = sqrt(_d2);
            _nx = _dx / _d;  _ny = _dy / _d;
            _pen = _r - _d;
        } else {
            // Center is inside the tile: leave through the nearest face
            var _l = _px - _tx, _rt = _tx + _tw - _px, _t = _py - _ty, _b = _ty + _th - _py;
            var _m = min(_l, _rt, _t, _b);
            _nx = 0;  _ny = 0;
            if (_m == _l) _nx = -1; else if (_m == _rt) _nx = 1; else if (_m == _t) _ny = -1; else _ny = 1;
            _pen = _r + _m;
            _qx = _px;  _qy = _py;
        }

        // Seam skip: face hit and the neighbor on that side is solid
        if ((abs(_nx) > 0.999 || abs(_ny) > 0.999) && isSolid(_cx + round(_nx), _cy + round(_ny))) return 0;

        _c.clear();
        _c.rb1 = _rb;
        _c.rb2 = undefined;
        _c.restitution = (_rb.bounciness + bounciness) * 0.5;
        _c.normal.set(_nx, _ny);        // tile -> circle
        _c.penetration = _pen;
        //_c.frictions = sqrt(_rb.frictions * 0.6);   // 0.6 = floor material
        _c.point.set(_qx, _qy);
        return 1;
    };
}