// Inherit the parent event
event_inherited();

//Gravity
grav.y = 15;

//Friction 
damping = 0.1;

rotSpeed = 1;


//Shape
SetShape(self.id, Shape.RECT_ROTATED);
