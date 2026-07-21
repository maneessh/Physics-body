function create_verlet_stick(_point1, _point2, _sticks_list) {
    var _stick = {
        point1: _point1,
        point2: _point2,
        length: point_distance(_point1.x, _point1.y, _point2.x, _point2.y)
    };
    
    ds_list_add(_sticks_list, _stick);
    
    return _stick;
}