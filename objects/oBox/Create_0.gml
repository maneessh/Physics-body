//create Event
points = ds_list_create();

var x1 = 100;
var y1 = 100;

image_blend = c_red;
image_blend = make_color_hsv(245, 200 , 200);

var _point1 = create_verlet_point( x1 ,y1 , points);
var _point2 = create_verlet_point( x1 + sprite_width, y1 , points);
var _point3 = create_verlet_point(x1 + sprite_width, y1 + sprite_height, points);
var _point4 = create_verlet_point(x1, y1 + sprite_height , points);


sticks = ds_list_create();
create_verlet_point(_point1, _point2, sticks);
create_verlet_point(_point2, _point3, sticks);
create_verlet_point(_point3, _point4, sticks);
create_verlet_point(_point4, _point1, sticks);

var _new_stick = create_verlet_point(_point1, _point3 , sticks);
_new_stick.visible = false;

visible = VERLET_DEBUG_DRAW

#macro VERLET_DEBUG_DRAW false