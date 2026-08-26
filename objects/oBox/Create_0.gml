// Inherit the parent event
//Create event oBall
event_inherited();

//1.
InitSoftBox(self.id , 200 , 200 , 12, 0.9);
//InitSoftBall(self.id , x , y , radius);

var _launch_vx = 4;
var _launch_vy = 8;
for (var i = 0; i < ds_list_size(points); i++) {
    var _p = points[| i];
    _p.oldx = _p.x - _launch_vx;
    _p.oldy = _p.y - _launch_vy;
}