//@desc Rigid Body

#region Body properties 

//Used in accleration calculations, accleration = force x inverse mass
//(inverseMass = 0 => infinite mass, doesn't move in collisions).
//The higher the inverse mass, the 'lighter' the body
inverseMass = 1;

//How bouncy the object is during collisions (0 = no bounce , 1 = max bounce)
bounciness = 1;


#endregion