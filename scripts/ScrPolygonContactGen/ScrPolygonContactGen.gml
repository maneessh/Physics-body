
//@func Polygon Collision
function PolyPolyContactGen(_bounciness) : ContactGen() constructor {

    name = "Polygon";
    bounciness = _bounciness;

    //_limit : Maximum number of contacts this function is allowed to create
    static addContact = function (_rb, _pw, _limit) {

        
        
        //Store Contact Count
        var _used = 0;
        
        //loop through the potential collisions 
        var _contactIdx = _pw.nextContactIdx;//Create Event of Physic world
        
        var _count = instance_number(_pw.rbObject);

        for (var i = 0; i < _count; i++)
        {
            var _inst = instance_find(_pw.rbObject, i);
        
            if (_inst == _rb.id)
                continue;
            if (_inst <= _rb.id) 
                continue;
        
            if (!instance_exists(_inst) || !HasLayerCollision(_rb.collisionBitmask, _inst.bitmask)) continue;
        
            if (_rb.inverseMass == 0 && _inst.inverseMass == 0)
                continue;
        
            if (array_length(_rb.localVertices) < 3 ||
                array_length(_inst.localVertices) < 3)
                continue;
            //Calculate the limit of the room 
            var _room = min(
    _limit - _used,
    array_length(_pw.contacts) - _contactIdx
);

if (_room <= 0)
    break;

var _firstContact = _pw.contacts[_contactIdx];

var _secondContact = undefined;

if (_room >= 2)
{
    _secondContact = _pw.contacts[_contactIdx + 1];
}
            
            var _result = PolyPoly(
                _rb , _inst, _firstContact , _secondContact
            );
                _used += _result;
                _contactIdx += _result;
            
        }
    
      



        return _used;
    };

    static getCollisionRestitution = function(_rb1 , _rb2)
    {
        if (instance_exists(_rb2)) return (_rb1.bounciness + _rb2.bounciness) / 2;
            return _rb1.bounciness;
    }

    static PolyPoly = function ( _rb1, _rb2 ,_firstContact,_secondContact) {

        

        // Circles / unset shapes have no vertices
        if (array_length(_rb1.localVertices) < 3 ||
            array_length(_rb2.localVertices) < 3) return 0;
        
        

        //1. World-space vertices of both polygons
        var _vertsA = polygon_get_world_vertices(_rb1);
        var _vertsB = polygon_get_world_vertices(_rb2);

        //2. Outward face normals (one per edge)
        var _normalsA = polygon_get_face_normals(_vertsA);
        var _normalsB = polygon_get_face_normals(_vertsB);

        ////3. SAT axes = A's normals first, then B's normals
        ////   axis index < countA  -> axis belongs to A
        ////   axis index >= countA -> axis belongs to B
        //var _countA = array_length(_normalsA);
        //var _axes = [];
        //
        ////A's face normals
        //for (var i = 0; i < _countA; i++)
            //array_push(_axes, _normalsA[i]);
        ////B's face normals
        //for (var i = 0; i < array_length(_normalsB); i++)
            //array_push(_axes, _normalsB[i]);
//
        ////4. SAT test (reuses satOverlap / projectCorners - vertices are just corners)
        //var _result = satOverlap(_axes, _vertsA, _vertsB);
        //if (_result.separating) return 0;
            //
   //
        ////5. Collision normal
        //var _normal = {
            //x : _result.minAxis.x,
            //y : _result.minAxis.y
        //};
        //
  //
        //
        ////7. Which polygon owns the reference face?
        //var _refIsA = (_result.minAxisIndex < _countA);
//
        //// Outward direction of the reference face (points at the other body)
        //var _refNormal;
        //
        //if (_refIsA) {
        	//
            ////Reference = A
            //
            //_refNormal = {
                //x : -_normal.x,
                //y : -_normal.y
            //};
        //}else {
        	////Refrence = b
            //
            //_refNormal = {
                //x : _normal.x,
                //y : _normal.y
            //};
        //}
        //
        //
        //var _refVerts;
        //var _refNormals;
        //var _incVerts;
        //var _incNormals;
//
        //if (_refIsA)
        //{
            //_refVerts   = _vertsA;
            //_refNormals = _normalsA;
            //_incVerts   = _vertsB;
            //_incNormals = _normalsB;
        //}
        //else
        //{
            //_refVerts   = _vertsB;
            //_refNormals = _normalsB;
            //_incVerts   = _vertsA;
            //_incNormals = _normalsA;
        //}
//
        ////8. Reference face = edge most ALONG the reference normal
        ////   Incident face  = edge most AGAINST the reference normal
        ////   (picked by direction, not by axis index, so duplicate +/- axes can't pick the wrong side)
        //var _referenceFace = GetPolygonFace(_refVerts, _refNormals, _refNormal, true);
        //var _incidentFace  = GetPolygonFace(_incVerts, _incNormals, _refNormal, false);
        
        
        var _r = satOverlap(_normalsA, _normalsB, _vertsA, _vertsB);
        if (_r.separating) return 0;
        var _normal = _r.normal; //points B -> A
        
        //Prepare reference and incident Polygons (generating and actual contact)
        var _refVerts , _refNormals, _incVerts, _incNormals;
        if (_r.refIsA) { _refVerts = _vertsA; 
            _refNormals = _normalsA; 
            _incVerts = _vertsB; 
            _incNormals = _normalsB;} else {
            	_refVerts = _vertsB;
                _refNormals = _normalsB;
            _incNormals = _vertsA;
            _incVerts = _vertsA;
            _incNormals = _normalsA;
            };
        
        //Reference polygon
//
              //face 0
           //┌─────────┐
       //face3         face1
           //└─────────┘
              //face2
        //Get the reference face index
        var _fi = _r.faceIndex; // Sat that found the face with the smallest penetration
        // Build the reference face 
        //a : first vertex
        //b : Second vertex
        //normal : Face normal
        var _referenceFace = {
            a : _refVerts[_fi],
            b : _refVerts[(_fi + 1) mod array_length(_refVerts)],
            normal : _refNormals[_fi]
        };
        var _incidentFace = GetPolygonFace(_incVerts, _incNormals, _referenceFace.normal, false);
        
        var _edgeX = _referenceFace.b.x - _referenceFace.a.x;
        var _edgeY = _referenceFace.b.y - _referenceFace.a.y;

        var _edgeLength = sqrt(_edgeX * _edgeX + _edgeY * _edgeY);
        if (_edgeLength <= 0.00001) return 0;

        _edgeX /= _edgeLength;
        _edgeY /= _edgeLength;

        //10. Side planes of the reference face
        var _sideNormal1 = { x : -_edgeX, y : -_edgeY };
        var _sideNormal2 = { x :  _edgeX, y :  _edgeY };

        var _offset1 = dot_product(
            _sideNormal1.x, _sideNormal1.y,
            _referenceFace.a.x, _referenceFace.a.y
        );

        var _offset2 = dot_product(
            _sideNormal2.x, _sideNormal2.y,
            _referenceFace.b.x, _referenceFace.b.y
        );

        //11. Clip the incident edge against both side planes
        var _clipPoints = ClipSegmentToLine(
            _incidentFace.a,
            _incidentFace.b,
            _sideNormal1,
            _offset1
        );
        //if (array_length(_clipPoints)) return 0; 

        _clipPoints = ClipSegmentToLine(
            _clipPoints[0],
            _clipPoints[1],
            _sideNormal2,
            _offset2
        );

        //if (array_length(_clipPoints) < 2) return 0;
            //show_debug_message("Clipped points: " + string(array_length(_clipPoints)));

        //12. Keep clipped points that are behind/on the reference face
        var _faceOffset = dot_product(
            _referenceFace.normal.x,
            _referenceFace.normal.y,
            _referenceFace.a.x,
            _referenceFace.a.y
        );

        var _rest = getCollisionRestitution(_rb1, _rb2 );
        var _created = 0;

        for (var i = 0; i < 2; i++) {
        	var _p = _clipPoints[i];
            var _sep = dot_product(_referenceFace.normal.x, _referenceFace.normal.y, _p.x,
                _p.y) - _faceOffset;
            if (_sep > 0.0001) continue;
            
            var _contact = (_created == 0) ? _firstContact : _secondContact;
            if (_contact == undefined) break;
                
            _contact.clear();
            _contact.rb1 = _rb1;
            _contact.rb2 = _rb2;
            _contact.restitution = _rest;
            _contact.friction =  sqrt((_rb1.friction * _rb2.friction))
            _contact.normal.set(_normal.x, _normal.y); //B -> A
            _contact.penetration = max(0, -_sep);
            _contact.point.set(_p.x,_p.y);
            _created ++
        }
        show_debug_message("pen=" + string(max(0, -_sep)) + " n=" + string(_normal.x) + "," + string(_normal.y));
        return _created;
    };
}
