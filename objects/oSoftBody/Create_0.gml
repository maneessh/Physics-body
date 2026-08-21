//Create event of SoftBody



width = sprite_width;
height = sprite_height;

radius = width * 0.5;




iterations = 4;
frictions = 0.98;
bounciness = 0.5;

//For oBall
point_count = 12;




grav = new Vector2(0 , 0.2);


//1.
InitSoftBox(self.id , 200 , 200 );
//InitSoftBall(self.id , x , y , radius);
//2.
DrawSoftBodyImage(self.id,sprite_index);

var _launch_vx = 8;
var _launch_vy = 0;
for (var i = 0; i < ds_list_size(points); i++) {
    var _p = points[| i];
    _p.oldx = _p.x - _launch_vx;
    _p.oldy = _p.y - _launch_vy;
}