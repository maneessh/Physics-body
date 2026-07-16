// Inherit the parent event
event_inherited();

moveInput = new Vector2();
moveStrength = 5;

SetAwake(self.id, true);
canSleep = false;

//Set Shape
SetShape(self.id,Shape.RECT);

//Friction
damping = 0.1;

//Contact Generator
cgInst = new InstContactGen();
