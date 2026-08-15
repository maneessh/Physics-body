



#region Soft Body

function InitSoftBody(_sb, _x , _y , _iterations = 4)
{
    with (_sb ) {
    	points = ds_list_create();
        sticks = ds_list_create();
        iterations = _iterations;
        
        p_tl = AddSoftPoint(self.id, _x , _y );
        p_tr = AddSoftPoint(self.id, _x + width  , _y );
        p_br = AddSoftPoint(self.id, _x + width , _y + height );
        p_bl = AddSoftPoint(self.id, _x , _y + height );
        
        AddSoftStick(self.id, p_tl, p_tr);
        AddSoftStick(self.id, p_tr, p_br);
        AddSoftStick(self.id, p_br, p_bl);
        AddSoftStick(self.id, p_bl, p_tl);
        
        var _brace = AddSoftStick(self.id, p_tl, p_br);
        _brace.visible = false;
    }
}



function AddSoftPoint(_sb, _x , _y)
{
    var _p = { x : _x, y : _y , oldx : _x , oldy : _y };
    ds_list_add(_sb.points, _p);
    return _p;
}

function AddSoftStick(_sb, _p1 , _p2)
{
    var _s = {
        point1 : _p1,
        point2 : _p2,
        length : point_distance(_p1.x , _p1.y, _p2.x , _p2.y),
        visible : true
    };
    ds_list_add(_sb.sticks, _s);
    return _s;
}

function IntergrateSoftBody(_sb, _dt)
{
    with (_sb) {
        //Calculate Velocity
        for (var i = 0; i < ds_list_size(points); i++) {
            var _p = points[| i];
            //Calculate Velocity
            var _vx = (_p.x - _p.oldx) * frictions;
            var _vy = (_p.y - _p.oldy) * frictions;
            //Old pos
            _p.oldx = _p.x;
            _p.oldy = _p.y;
            _p.x += _vx;
            _p.y += _vy + (grav.y * _dt);
        }

        repeat (iterations) {
            for (var i = 0; i < ds_list_size(sticks); i++) {
                var _s = sticks[| i];
                //Direction from point1  to  point2
                var _dx = _s.point2.x - _s.point1.x;
                var _dy = _s.point2.y - _s.point1.y;
                //The current distance 
                var _dist = point_distance(_s.point1.x, _s.point1.y, _s.point2.x, _s.point2.y);
                //How much correction is required ? Why /2 ? moving both points.
                var _diff = (_s.length - _dist) / _dist / 2;
                
                
                _s.point1.x -= _dx * _diff;
                _s.point1.y -= _dy * _diff;
                _s.point2.x += _dx * _diff;
                _s.point2.y += _dy * _diff;
            }
        }
        

        // FLOOR COLLISION — now inside with(_sb), before centroid
        var _floor_y = room_height - 32;
        for (var i = 0; i < ds_list_size(points); i++) {
            var _p = points[| i];
            if (_p.y >= _floor_y) {
                var _vy = (_p.y - _p.oldy) * -bounciness;
                _p.y = _floor_y;
                _p.oldy = _p.y + _vy;
            }
        }

        // Calculate centroid — now sees corrected positions
        x = 0;
        y = 0;
        for (var i = 0; i < ds_list_size(points); i++) {
            var _p = points[| i];
            x += _p.x;
            y += _p.y;
        }
        x /= ds_list_size(points);
        y /= ds_list_size(points);
    }
}

function DestroySoftBody(_sb)
{
    with (_sb) {
        ds_list_destroy(points);
        ds_list_destroy(sticks);
    }
}



#endregion



function DrawSoftBody(_sb)
{
    with (_sb) {
        // Fill using a triangle fan from the first point
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(p_tl.x, p_tl.y);
        draw_vertex(p_tr.x, p_tr.y);
        draw_vertex(p_br.x, p_br.y);
        draw_vertex(p_bl.x, p_bl.y);
        draw_primitive_end();

        // Outline the sticks (skip invisible braces)
        for (var i = 0; i < ds_list_size(sticks); i++) {
            var _s = sticks[| i];
            if (!_s.visible) continue;
            draw_line(_s.point1.x, _s.point1.y, _s.point2.x, _s.point2.y);
        }
    }
}