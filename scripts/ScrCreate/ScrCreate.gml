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