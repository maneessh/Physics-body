//Step Event of oPhysicWorld

/*
Here I manually set dt to be the 'perfect' time between frames. However, if you want a more accurate
time between frames you can use delta_time / 1000000. Note, however that switching in/out of the game
window will count as delta time, so you may want to cap it to prevent objects going through things.
*/
var _dt = GetDeltaTime();

/*
Runs all of the physics, applying all of the accumulated forces, then resolving contacts after.
This is run in Step so you can add forces in Begin Step and have things follow physics
bodies in End Step.
*/

RunPhysics(self.id , _dt);