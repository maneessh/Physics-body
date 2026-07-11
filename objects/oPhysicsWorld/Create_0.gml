//Init

//physics v1.0.4
//Create Event of oPhysicWorld
/*
 * Holds and processes the physic world You can generally house a physics world within any object,
but this one showcases what should be present to simulate it.
 */

//Physics
deltaTime = 1 / game_get_speed(gamespeed_fps);
simulationSpeed = 1;

//Bodies 
rbObject = oRigidBody;



// GetDeltaTime
GetDeltaTime = function (){
    return deltaTime * simulationSpeed;
}
