



#region Soft Body

function InitSoftBox(_sb, _x , _y , _iterations = 4)
{
    with (_sb ) {
        
        shape = "box";
        
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

function InitSoftBall(_sb, _x , _y , _radius, _point_count = 12 , _iterations = 6)
{
    with (_sb) {
        
        shape = "ball";
    	//Create the soft_ball data
        points = ds_list_create();
        sticks = ds_list_create();
        iterations = _iterations;
        
        //Create point around the circle
        for (var i = 0; i < _point_count; i++) 
        {
            var _angle = ( i / _point_count) * 2 * pi;
            
            //px = center_x + radius
            //py = center_y
            var _px = _x + cos(_angle) * _radius;
            var _py = _y + sin(_angle) * _radius;
            
            AddSoftPoint(self.id , _px , _py);
        	
        }
        
        //Connect the neighboring points
        
        for (var i = 0; i < _point_count; i++) 
        {
            var _next = ( i + 1) mod _point_count;
            
            var _p1 = points[|i];
            var _p2 = points[|_next];
            
            AddSoftStick(self.id, _p1 , _p2);
        }
        
        //Internal Support
        for (var i = 0; i < _point_count / 2; i++) 
        {
            var _opposite = ( i + _point_count / 2) mod _point_count;
            var _p1 = points[|i];
            var _p2 = points[|_opposite];
            
            var _brace = AddSoftStick(self.id, _p1 , _p2);

        	
        }
        
        
        
        
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
            var _vx = (_p.x - _p.oldx) ;
            var _vy = (_p.y - _p.oldy) ;
            //Old pos
            _p.oldx = _p.x;
            _p.oldy = _p.y;
            _p.x += _vx;
            _p.y += _vy + ( grav.y * _dt);
            
            if (_p.x > room_width)
            {
                _p.x = room_width;
                _p.oldx = _p.x + _vx;
            }
            else if (_p.x < 0)
            {
                _p.x = 0;
                _p.oldx = _p.x + _vx;   // fixed: was _p.y in your JS
            }

            if (_p.y > room_height)
            {
                _p.y = room_height;
                _p.oldy = _p.y + _vy;
            }
            else if (_p.y < 0)
            {
                _p.y = 0;
                _p.oldy = _p.y + _vy;
            }
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
        var _floor_y = room_height +  32;
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
        
        
        //var _p1 = points[|0];
        //var _p2 = points[|1];
        //x = _p1.x;
        //y = _p1.y;
        //image_angle = point_direction(_p1.x, _p1.y,_p2.x,_p2.y);
        
        UpdateSoftBodyTransform(self.id);
        
        
        
    }
    
    
}

function DestroySoftBody(_sb)
{
    with (_sb) {
        ds_list_destroy(points);
        ds_list_destroy(sticks);
    }
}

function UpdateSoftBodyTransform(_sb)
{
    with (_sb)
    {
        var _p0 = points[| 0]; // top-left
        var _p1 = points[| 1]; // top-right
        var _p3 = points[| 3]; // bottom-left

        var _w = point_distance(_p0.x, _p0.y, _p1.x, _p1.y);
        var _h = point_distance(_p0.x, _p0.y, _p3.x, _p3.y);

        x = _p0.x;
        y = _p0.y;
        
        image_angle    = point_direction(_p0.x, _p0.y, _p1.x, _p1.y);
        image_xscale   = _w / sprite_width;
        image_yscale   = _h / sprite_height;
    }
}



#endregion

function DrawSoftBody(_sb)
{
    with (_sb)
    {
        // Draw ONLY the sticks
        for (var i = 0; i < ds_list_size(sticks); i++)
        {
            var _s = sticks[| i];

            if (!_s.visible)
                continue;

            draw_line(
                _s.point1.x,
                _s.point1.y,
                _s.point2.x,
                _s.point2.y
            );
        }
    }
}

function DrawSoftBodys()
{
    
        // Draw ONLY the sticks
        for (var i = 0; i < ds_list_size(sticks); i++)
        {
            var _s = sticks[| i];

            

            draw_line(
                _s.point1.x,
                _s.point1.y,
                _s.point2.x,
                _s.point2.y
            );
        }
}