// Inherit the parent event
event_inherited();


InitSoftBall(self.id , x , y , radius);



var _launch_vx = 6;
var _launch_vy = 6;
for (var i = 0; i < ds_list_size(points); i++) {
    var _p = points[| i];
    _p.oldx = _p.x - _launch_vx;
    _p.oldy = _p.y - _launch_vy;
}