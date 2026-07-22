function create_verlet_point(_x, _y, _points_list) {
    var _point = {
        x: _x,
        y: _y,
        oldx: _x,
        oldy: _y
    };
    
    ds_list_add(_points_list, _point);
    
    return _point;
}

function create_verlet_stick(_point1, _point2, _sticks_list) {
    var _stick = {
        point1: _point1,
        point2: _point2,
        length: point_distance(_point1.x, _point1.y, _point2.x, _point2.y)
    };
    
    ds_list_add(_sticks_list, _stick);
    
    return _stick;
}