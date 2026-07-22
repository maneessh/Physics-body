//Step event

if (keyboard_check_pressed(ord("B"))) {
	if game_get_speed(gamespeed_fps) == 60{
        game_set_speed(30,gamespeed_fps);
        
    }else {
    	game_set_speed(60, gamespeed_fps);
    }
}

#region update points

for (var i = 0; i < ds_list_size(points); i++) {
	var _points = points [|i];
    with (_points) {
    	//Move_verlet();
        
        var _air_friction = 0.90;
        var _bounce = 0.5;
        var _grav = 1.5;
        

        
        var _vx = (x - oldx) * _air_friction;
        var _vy = (y - oldy) * _air_friction;
        var _new_x = x + _vx;
        var _new_y = y + _vy + _grav;
        oldx = x;
        oldy = y;
        x = _new_x;
        y = _new_y;
        
        
    }
}

#endregion

for (var _update_count  = 0; _update_count < 4; _update_count++; ) {
	#region update sticks
    
    for (var i = 0; i < ds_list_size(sticks); i++) {
    	var _stick = sticks [|i];
        with (_stick) {
        	
            var _dx = point2.x - point1.x;
            var _dy = point2.y - point1.y;
            var _distance = point_distance(point1.x , point1.y , point2.x , point2.y);
            var _difference = length - _distance;
            var _percent = _difference / _distance / 2;
            var _offset_x = _dx * _percent;
            var _offset_y = _dy * _percent;
            
            point1.x -= _offset_x;
            point1.y -= _offset_y;
            point2.x += _offset_x;
            point2.y += _offset_y;
            
        }
    }
    
    #endregion
    #region constrain points

    var _points = points;
    var _bounce = 0.5;
    var _border_width = 32;

    for (var i = 0; i < ds_list_size(_points); i++) {
	   var _current_point = _points[|i];
        with (_current_point) {
    	
            if x < _border_width || room_width - _border_width < x {
        	   var _vx = x - oldx;
                x = clamp(x , _border_width, room_width - _border_width);
                oldx = x + _vx * _bounce;
            
            }
        
            var _floor = room_height - _border_width;
            if y < _border_width || _floor < y {
        	   var _vy = y - oldy;
                y = clamp(y , _border_width, _floor);
                oldy = y + _vy * _bounce;
            }
        }
    }
#endregion
}
var _p1 = points[|0];
var _p2 = points[|1];
x = _p1.x;
y = _p1.y;
image_angle = point_direction(_p1.x, _p1.y,_p2.x,_p2.y);
