// Inherit the parent event
event_inherited();

grav.y = 20;
moveInput = new Vector2();
moveStrength = 5;

//SetAwake(self.id, true);
//canSleep = false;

//Set Shape
SetShape(self.id,Shape.RECT_ROTATED);

//Friction
damping = 0.1;
