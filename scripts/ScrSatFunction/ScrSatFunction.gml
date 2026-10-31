
function obb_create(_x, _y, _w, _h, _angle) {
    return {
        x: _x,
        y: _y,
        hx: _w / 2,
        hy: _h / 2,
        angle: _angle
    };
}


function get_axes(_obb) {
    var cos_a = cos(_obb.angle);
    var sin_a = sin(_obb.angle);
    return [
        { x: cos_a, y: sin_a },    // box's local X axis, rotated into world space
        { x: -sin_a, y: cos_a }    // box's local Y axis, rotated into world space
    ];
}



function obb_get_corners(_obb) {
    var axes = get_axes(_obb);
    var ax = axes[0], ay = axes[1];
    return [
        { x: _obb.x - ax.x*_obb.hx - ay.x*_obb.hy, y: _obb.y - ax.y*_obb.hx - ay.y*_obb.hy },
        { x: _obb.x + ax.x*_obb.hx - ay.x*_obb.hy, y: _obb.y + ax.y*_obb.hx - ay.y*_obb.hy },
        { x: _obb.x + ax.x*_obb.hx + ay.x*_obb.hy, y: _obb.y + ax.y*_obb.hx + ay.y*_obb.hy },
        { x: _obb.x - ax.x*_obb.hx + ay.x*_obb.hy, y: _obb.y - ax.y*_obb.hx + ay.y*_obb.hy }
    ];
}

    //
    //Function	Job
    //projectCorners()	Project a shape onto an axis
    //satOverlap()	Determine collision + penetration axis/depth
    //deepestCorner()	Find a candidate contact corner
    //addContact()	Actually create the physics contact
    //Contact solver	Apply impulses and resolve collision
    
    
/// @func projectCorners Take the polygon and preject it onto one axis
function projectCorners(_corners, _axis)
{
    var _min = infinity;
    var _max = -infinity;

    for (var i = 0; i < array_length(_corners); i++) {
        var _p = dot_product(_corners[i].x, _corners[i].y, _axis.x, _axis.y);
        _min = min(_min, _p);
        _max = max(_max, _p);
    }

    return { min_value: _min, max_value: _max };
}
/// @func satOverlap(axes, verticesA, verticesB) It checks all face normals of A and B, 
/// finds the shallowest penetration, and chooses which polygon should be the reference polygon for contact generation. (good for the polypoly collision)
/// //@param {real} _normalsA _normals/Axes of polygon A
/// //@param {real} _vertA world vertices of A
function satOverlap(_normalsA, _normalsB, _vertsA, _vertsB, _skipB = undefined, _preferB = false, _margin = 0)
{
    var _bestA = infinity, _idxA = -1;
    var _bestB = infinity, _idxB = -1;
    var _bestAny = infinity, _idxAny = -1;   // best tile face ignoring _skipB

    for (var i = 0; i < array_length(_normalsA); i++) {
        var _n  = _normalsA[i];
        var _pA = polygon_project(_vertsA, _n);
        var _pB = polygon_project(_vertsB, _n);
        var _ov = _pA.max - _pB.min;
        if (_ov <= -_margin) return { separating: true };
        if (_ov < _bestA) { _bestA = _ov; _idxA = i; }
    }

    for (var i = 0; i < array_length(_normalsB); i++) {
        var _n  = _normalsB[i];
        var _pA = polygon_project(_vertsA, _n);
        var _pB = polygon_project(_vertsB, _n);
        var _ov = _pB.max - _pA.min;
        if (_ov <= -_margin) return { separating: true };      // was: _ov <= 0
        if (_ov < _bestAny) { _bestAny = _ov; _idxAny = i; }
        if (_skipB != undefined && _skipB[i]) continue;
        if (_ov < _bestB) { _bestB = _ov; _idxB = i; }
    }

    var _refIsA;
    if (_preferB) {
        // Tiles: a tile face is always the contact face. Body axes only decide separation.
        if (_idxB == -1) { _idxB = _idxAny; _bestB = _bestAny; }
        _refIsA = false;
    } else {
        _refIsA = !(_bestB < _bestA * 0.95 - 0.01);
    }

    var _nrm = _refIsA ? _normalsA[_idxA] : _normalsB[_idxB];
    return {
        separating: false,
        refIsA:     _refIsA,
        faceIndex:  _refIsA ? _idxA : _idxB,
        depth:      _refIsA ? _bestA : _bestB,
        normal:     _refIsA ? { x: -_nrm.x, y: -_nrm.y } : { x: _nrm.x, y: _nrm.y }
    };
}


/// @func deepestCorner(corners, axis, sign)
function deepestCorner(_corners, _axis, _sign)
{
    var _deepest = _corners[0];
    var _deepestProj = dot_product(_corners[0].x, _corners[0].y, _axis.x, _axis.y) * _sign;

    for (var i = 0; i < array_length(_corners); i++) {
        var _p = dot_product(_corners[i].x, _corners[i].y, _axis.x, _axis.y) * _sign;
        if (_p < _deepestProj) {
            _deepestProj = _p;
            _deepest = _corners[i];
        }
    }
    return _deepest;
}

/// @func GetReferenceFace(_obb, _axes, _normal)
/// @desc Analytically builds the reference face (no corner loop needed)
function GetReferenceFace(_obb, _axes, _normal)
{
    var _axis0 = _axes[0];
    var _axis1 = _axes[1];

    var _d0 = dot_product(
        _normal.x,
        _normal.y,
        _axis0.x,
        _axis0.y
    );

    var _d1 = dot_product(
        _normal.x,
        _normal.y,
        _axis1.x,
        _axis1.y
    );

    var _faceAxis;
    var _faceSign;
    var _edgeAxis;
    var _faceHalf;
    var _edgeHalf;


    // Choose the box axis most parallel to the collision normal
    if (abs(_d0) > abs(_d1))
    {
        _faceAxis = _axis0;
        _edgeAxis = _axis1;

        _faceHalf = _obb.hx;
        _edgeHalf = _obb.hy;

        // Face whose outward normal points in direction of _normal
        _faceSign = (_d0 >= 0) ? 1 : -1;
    }
    else
    {
        _faceAxis = _axis1;
        _edgeAxis = _axis0;

        _faceHalf = _obb.hy;
        _edgeHalf = _obb.hx;

        // Face whose outward normal points in direction of _normal
        _faceSign = (_d1 >= 0) ? 1 : -1;
    }


    // Center of selected face
    var _faceCenterX =
        _obb.x +
        _faceAxis.x * _faceHalf * _faceSign;

    var _faceCenterY =
        _obb.y +
        _faceAxis.y * _faceHalf * _faceSign;


    // Half-length along the face
    var _edgeX =
        _edgeAxis.x * _edgeHalf;

    var _edgeY =
        _edgeAxis.y * _edgeHalf;


    return {
        a : {
            x : _faceCenterX - _edgeX,
            y : _faceCenterY - _edgeY
        },

        b : {
            x : _faceCenterX + _edgeX,
            y : _faceCenterY + _edgeY
        },

        normal : {
            x : _faceAxis.x * _faceSign,
            y : _faceAxis.y * _faceSign
        }
    };
}

//REFERENCE BOX
//
      //a ●────────────● b
              //↑
       //reference normal
//
//
//INCIDENT BOX
//
      //a ●────────────● b
              //↓
       //incident normal

function GetIncidentFace(_obb, _axes, _normal)
{
        var _d0 = dot_product(
        _normal.x,
        _normal.y,
        _axes[0].x,
        _axes[0].y 
    );

    var _d1 = dot_product(
        _normal.x,
        _normal.y,
        _axes[1].x,
        _axes[1].y
    );


    var _faceAxis;
    var _faceSign;
    var _faceHalf;

    var _edgeAxis;
    var _edgeHalf;


    // Pick the face whose normal points MOST OPPOSITE
    // to the reference normal.

    if (abs(_d0) > abs(_d1))
    {
        _faceAxis = _axes[0];

        _faceSign =
            (_d0 >= 0) ? -1 : 1;

        _faceHalf = _obb.hx;

        _edgeAxis = _axes[1];
        _edgeHalf = _obb.hy;
    }
    else
    {
        _faceAxis = _axes[1];

        _faceSign =
            (_d1 >= 0) ? -1 : 1;

        _faceHalf = _obb.hy;

        _edgeAxis = _axes[0];
        _edgeHalf = _obb.hx;
    }


    var _faceCenterX =
        _obb.x +
        _faceAxis.x *
        _faceHalf *
        _faceSign;

    var _faceCenterY =
        _obb.y +
        _faceAxis.y *
        _faceHalf *
        _faceSign;


    var _edgeX =
        _edgeAxis.x *
        _edgeHalf;

    var _edgeY =
        _edgeAxis.y *
        _edgeHalf;


    return {
        a : {
            x : _faceCenterX - _edgeX,
            y : _faceCenterY - _edgeY
        },

        b : {
            x : _faceCenterX + _edgeX,
            y : _faceCenterY + _edgeY
        },

        normal : {
            x : _faceAxis.x * _faceSign,
            y : _faceAxis.y * _faceSign
        }
    };
}
    //a ─────────── b
    //↑             ↑
//side plane    side plane
function ClipSegmentToLine(_p1, _p2, _normal, _offset)
{
    var _points = [];

    var _d1 = dot_product(
        _normal.x,
        _normal.y,
        _p1.x,
        _p1.y
    ) - _offset;

    var _d2 = dot_product(
        _normal.x,
        _normal.y,
        _p2.x,
        _p2.y
    ) - _offset;

    // P1 is inside
    if (_d1 <= 0) {
        array_push(_points, _p1);
    }

    // P2 is inside
    if (_d2 <= 0) {
        array_push(_points, _p2);
    }

    // Edge crosses the clipping line
    if ((_d1 < 0 && _d2 > 0) ||
        (_d1 > 0 && _d2 < 0))
    {
        var _t = _d1 / (_d1 - _d2);

        var _x = _p1.x + (_p2.x - _p1.x) * _t;
        var _y = _p1.y + (_p2.y - _p1.y) * _t;

        array_push(_points, {
            x : _x,
            y : _y
        });
    }

    return _points;
}

//@func polygon_create shapes
function polygon_create(_vertices)
{
    return {
        localVertices: _vertices
    };
}




/// @func polygon_get_face_normals(vertices)
/// @desc Outward unit normal for every edge. Normal i belongs to the edge
///       vertices[i] -> vertices[(i+1) mod n].
///       Winding must match SetShape's RECT (outward = (ey, -ex)).
///       No zero-length edges allowed.
function polygon_get_face_normals(_vertices)
{
    var _normals = [];
    var _count = array_length(_vertices);

    for (var i = 0; i < _count; i++)
    {
        var _a = _vertices[i];
        var _b = _vertices[(i + 1) mod _count];

        var _ex = _b.x - _a.x;
        var _ey = _b.y - _a.y;
        var _len = sqrt(_ex * _ex + _ey * _ey);

        array_push(_normals, { x: _ey / _len, y: -_ex / _len });
    }

    return _normals;
}


/// @func GetPolygonFace(verts, normals, dir, mostAligned)
/// @desc true  = face whose normal points most ALONG dir   (reference face)
///       false = face whose normal points most AGAINST dir (incident face)
function GetPolygonFace(_verts, _normals, _dir, _mostAligned)
{
    var _best = 0;
    var _bestDot = dot_product(_normals[0].x, _normals[0].y, _dir.x, _dir.y);

    for (var i = 1; i < array_length(_normals); i++)
    {
        var _d = dot_product(_normals[i].x, _normals[i].y, _dir.x, _dir.y);

        if (_mostAligned ? (_d > _bestDot) : (_d < _bestDot))
        {
            _bestDot = _d;
            _best = i;
        }
    }

    return {
        a : _verts[_best],
        b : _verts[(_best + 1) mod array_length(_verts)],
        normal : _normals[_best]
    };
}


/// @func SetShape(rb, shape)
/// @desc Builds localVertices with the centroid at the body origin,
///       then sets inertia / inverseInertia to match the shape.
///       Vertex order must give outward normals = (ey, -ex) (same as RECT).
function SetShape(_rb, _shape)
{
    _rb.shape = _shape;
    
    

    var _w  = _rb.width;
    var _h  = _rb.height;
    var _hw = _w * 0.5;
    var _hh = _h * 0.5;

    switch (_shape)
    {
        case Shape.RECT:

            _rb.localVertices = [
                {x: -_hw, y: -_hh},
                {x:  _hw, y: -_hh},
                {x:  _hw, y:  _hh},
                {x: -_hw, y:  _hh}
            ];

            // Solid rectangle about its centre
            _rb.inertia = (1 / 12) * _rb.Mass * (_w * _w + _h * _h);

            break;


        case Shape.TRIANGLE:

            // Isosceles, apex up. Centroid is 1/3 of the height above the base,
            // so the apex sits 2/3 of the height above the origin and the base 1/3 below.
            _rb.localVertices = [
                {x: 0,    y: -_hh * 4/3},
                {x: _hw,  y:  _hh * 2/3},
                {x: -_hw, y:  _hh * 2/3}
            ];

            // Isosceles triangle about its centroid
            _rb.inertia = _rb.Mass * (_h * _h / 18 + _w * _w / 24);

            break;


        case Shape.CIRCLE:

            _rb.localVertices = [];

            // Solid disc, radius = half the width
            _rb.inertia = 0.5 * _rb.Mass * _hw * _hw;

            break;
    }

    _rb.inverseInertia = (_rb.inertia > 0) ? 1 / _rb.inertia : 0;
}


function polygon_get_world_vertices(_rb)
{
    var _vertices = [];

    var _c = cos(_rb.rotation);
    var _s = sin(_rb.rotation);

    for (var i = 0; i < array_length(_rb.localVertices); i++)
    {
        var _v = _rb.localVertices[i];

        var _x =
            _v.x * _c -
            _v.y * _s;

        var _y =
            _v.x * _s +
            _v.y * _c;

        array_push(
            _vertices,
            {
                x: _rb.position.x + _x,
                y: _rb.position.y + _y
            }
        );
    }

    return _vertices;
}

function polygon_get_axes(_vertices)
{
    var _axes = [];
    var _count = array_length(_vertices);

    for (var i = 0; i < _count; i++)
    {
        var _a = _vertices[i];
        var _b = _vertices[(i + 1) mod _count];

        var _edge_x = _b.x - _a.x;
        var _edge_y = _b.y - _a.y;

        // Perpendicular
        var _nx = -_edge_y;
        var _ny = _edge_x;

        var _length = sqrt(
            _nx * _nx +
            _ny * _ny
        );

        if (_length > 0)
        {
            _nx /= _length;
            _ny /= _length;

            array_push(
                _axes,
                {
                    x: _nx,
                    y: _ny
                }
            );
        }
    }

    return _axes;
}



function polygon_project(_vertices, _axis)
{
    var _min = _vertices[0].x * _axis.x
             + _vertices[0].y * _axis.y;

    var _max = _min;

    for (var i = 1; i < array_length(_vertices); i++)
    {
        var _value =
            _vertices[i].x * _axis.x +
            _vertices[i].y * _axis.y;

        _min = min(_min, _value);
        _max = max(_max, _value);
    }

    return {
        min: _min,
        max: _max
    };
}