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

//Contact Generator
cgInst = new InstContactGen();//For instances
cgFloor = new FloorContactGen(); //For Floor
cgRoom = new RoomContactGen(room_height - 16 , 1);//Foor Room
