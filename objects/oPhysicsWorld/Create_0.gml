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




// Contact
maxContacts = 32;
calculateIterations = false;
contactResolver = new ContactResolver(64);
contacts = array_create(maxContacts, undefined);
for (var _i = 0; _i < maxContacts; _i++)
{
	contacts[_i] = new Contact();
}
nextContactIdx = 0;
maxSpeedyChecks = 10;	// The max amount of extra collision checks to do per frame for speedy bodies


//Store tile size 
tw = 16;
th = 16;

var Layer_Id = layer_get_id("Tiles_1");
tm = layer_tilemap_get_id(Layer_Id);



// GetDeltaTime
GetDeltaTime = function (){
    return deltaTime * simulationSpeed;
}


