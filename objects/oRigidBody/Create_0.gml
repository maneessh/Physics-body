//@desc Rigid Body

#region Body properties 

//Used in accleration calculations, accleration = force x inverse mass
//(inverseMass = 0 => infinite mass, doesn't move in collisions).
//The higher the inverse mass, the 'lighter' the body
inverseMass = 1;

//How bouncy the object is during collisions (0 = no bounce , 1 = max bounce)
bounciness = 1;

// A rotation matrix representing the body's orientattion in computer coordinates ( +y for down, +x for right)
// When changing the angle of the rigid body, using nbpSetAngle(rb,Angle) to automatically update the matrix.

orientation = new Matrix22( -image_angle);


#endregion

#region Environment Properties

//Applies a costant force (or gravity) to the body
grav = new Vector2();

//Applies general friction, slowing down body(0 = max friction, 1 = no friction)
damping = 0.995;


#endregion


#region Movement Vectors

velocity = new Vector2();       //Updates the position every frame, velocity = distance / time
acceleration = new Vector2();   //Updates the velocity every frame, acceleration = velocity / time
force = new Vector2();          //Used to calculate accleration every frame, forece = maxx x accleration
prev_force = new Vector2();     //Storing previous force.


#endregion