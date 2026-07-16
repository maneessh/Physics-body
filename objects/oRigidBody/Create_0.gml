//@desc Rigid Body

#region Body properties 

//Used in accleration calculations, accleration = force x inverse mass
//(inverseMass = 0 => infinite mass, doesn't move in collisions).
//The higher the inverse mass, the 'lighter' the body
inverseMass = 1;


//Shape ? Default is RECT
shape = Shape.RECT;


//How bouncy the object is during collisions (0 = no bounce , 1 = max bounce)
bounciness = 1;


// A rotation matrix representing the body's orientattion in computer coordinates ( +y for down, +x for right)
// When changing the angle of the rigid body, using nbpSetAngle(rb,Angle) to automatically update the matrix.
orientation = new Matrix22( -image_angle);


//Rigid bodies can be put to sleep to avoid integration/Collision functions.
isAwake = true;

//Used to prevent specific  bodies from being put to sleep, such as player
canSleep = true;

#endregion

#region Environment Propertiess

//Applies a costant force (or gravity) to the body
grav = new Vector2();

//Applies general friction, slowing down body(0 = max friction, 1 = no friction)
damping = 0.995;

/*
Used for collision checks, this is the layer where the body 'lives'. There are 8 potential layers, or
bits and can be set using nbpSetBitmask(rb, bits). Collisions will only occur between bodies having at
least one similar bit, or layer, with each other.
The default mask is 1 => 10000000.
*/
bitmask = 1;
bitmaskString = "10000000";		// Updates everytime the bitmask is changed. Used for reference.

/*
Used for collision checks, this is the layer the body 'checks' for collisions. There are 8 potential
layers, or bits and can be set using nbpSetBitmask(rb, bits). Collisions will only occur between bodies
having at least one similar bit, or layer, with each other.
The default mask is 1 => 10000000.
*/
collisionBitmask = 1;
collisionBitmaskString = "10000000";		// Updates everytime the bitmask is changed. Used for reference.

/*
Holds all contacts generated this frame.
*/
contacts = [];
#endregion


#region Movement Vectors

velocity = new Vector2();       //Updates the position every frame, velocity = distance / time
acceleration = new Vector2();   //Updates the velocity every frame, acceleration = velocity / time
force = new Vector2();          //Used to calculate accleration every frame, forece = maxx x accleration
prev_force = new Vector2();     //Storing previous force.

#endregion

#region Physics Generator

/*
Holds registered contact generators that will be applied to the body by a physics world
To add a contact generator, use nbpAddContactGen(rb, cg).
*/
contactGens = [];

#endregion
#region Debug

// Draw
color = #ffff55;	// The color of body when drawn (default color for rect is yellow)
outlines = true;	// If true, shows all of the possible shape's outlines (circle, rotated rect, rect)
funcDrawShape = DrawRect;

#endregion
