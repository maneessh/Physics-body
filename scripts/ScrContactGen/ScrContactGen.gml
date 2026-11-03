/// @func	Contact(rb1, rb2);
///	@param	{Id.Instance}	rb1	The first rigid body.
///	@param	{Id.Instance}	rb2	The second rigid body.
///	@desc	Holds contact data between two rigid bodies. Resolves through the removal of
///			interpenetration and then applying sufficient impulse to keep apart.
function Contact(_rb1=undefined, _rb2=undefined) constructor
{
	rb1 = _rb1;						// The first body involved. Undefined == infinite mass/environment.
	rb2 = _rb2;						// The second body involved.
	restitution = 1;				// How quickly bodies separate (1 = bounce apart, 0 = stick together).
	normal = new Vector2();			// The contact normal from the perspective of the first body.
    point = new Vector2();
	penetration = 0;				// How much the bodies are intersecting.
	rb1Movement = new Vector2();	// How much the first body moved during interpenetration resolution.
	rb2Movement = new Vector2();	// How much the second body moved during interpenetration resolution.
	
	///	@func	cleanup();
	///	@desc	Cleans up the contact data.
	static cleanup = function()
	{
		// Vectors
		delete normal;
		delete rb1Movement;
		delete rb2Movement;
        delete point;
	}
	
	///	@func	resolve(dt);
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Resolves the contact, both for separating velocity and interpenetration.
	static resolve = function(_dt)
	{
		// Return if first rigid body is undefined
		if (!instance_exists(rb1)) return;
		
		// Resolve
		resolveVelocity(_dt);
		resolveInterpenetration(_dt);
	}
	
	///	@func	calculateSeparatingVelocity();
	///	@return	{real}	The separating velocity.
	///	@desc	Returns the velocity magnitude required to separate the contact. Positive values mean
	///			the bodies are already separating, negative means otherwise.
	static calculateSeparatingVelocity = function()
	{
	//// Get first body's velocity
		//var _relativeVel = new Vector2(rb1.velocity.x, rb1.velocity.y);
		//
		//// Subtract second body's velocity if it exists
		//if (instance_exists(rb2)) _relativeVel.add(-rb2.velocity.x, -rb2.velocity.y);
//
		//
		//// Return the dot product between relative velocity and normal
		//return _relativeVel.dotProductVector(normal);
        
        
        // r = contact point - center of mass
        var _r1x = point.x - rb1.position.x;
        var _r1y = point.y - rb1.position.y;
        ///----Linear----////
        var _relativeVel = new Vector2(
            rb1.velocity.x - rb1.angularVelocity * _r1y,
            rb1.velocity.y + rb1.angularVelocity * _r1x
        );
        
        if (instance_exists(rb2)) {
        	var _r2x = point.x - rb2.position.x;
            var _r2y = point.y - rb2.position.y;
            
            var _vel2x = rb2.velocity.x - rb2.angularVelocity * _r2y;
            var _vel2y = rb2.velocity.y + rb2.angularVelocity * _r2x;
            _relativeVel.add(-_vel2x,-_vel2y);
        }
        
        
        return _relativeVel.dotProductVector(normal);
	}
    
    
	
	///	@func	resolveVelocity(dt);
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Handles impluses for the collision.
	static resolveVelocity = function(_dt)
	{
		// Get separating velocity
		var _sepVel = calculateSeparatingVelocity();
		
		// Return if no separating velocity (either separating or stationary - no impulse required!)
		if (_sepVel > 0) return;
		
		// Calculate new separating velocity
		var _newSepVel = -_sepVel * restitution;
		
		// Store if other rigid body exists
		var _rb2Exists = instance_exists(rb2);
		
		// Check velocity buildup due to acceleration
		var _accelCausedVel = new Vector2(rb1.acceleration.x, rb1.acceleration.y);
		if (_rb2Exists) _accelCausedVel.add(-rb2.acceleration.x, -rb2.acceleration.y);
		var _accelCausedSepVel = _accelCausedVel.dotProduct(normal.x * _dt, normal.y * _dt);
		
		// If closing velocity due to acceleration buildup
		if (_accelCausedSepVel < 0)
		{
			// Remove it from new separating velocity
			_newSepVel += _accelCausedSepVel * restitution;
			
			// Make sure we don't remove what wasn't there
			if (_newSepVel < 0) _newSepVel = 0;
		}
		
		// Get change in velocity
		var _deltaVel = _newSepVel - _sepVel;
        
        
      
		// Apply change in velocity propotional to inverse mass
		var _totalIMass = rb1.inverseMass;
        
		if (_rb2Exists) _totalIMass += rb2.inverseMass;

    

		// Return if infinite mass
		if (_totalIMass <= 0) return;
		
		// Calculate impulse
		var _impulse = _deltaVel / _totalIMass;
		
		// Calculate impulse per unit inverse mass
		var _impulsePerIMass = new Vector2(normal.x * _impulse, normal.y * _impulse);
		
		// Apply impulse to first body ( linear)
		rb1.velocity.set(rb1.velocity.x + _impulsePerIMass.x * rb1.inverseMass,
			rb1.velocity.y + _impulsePerIMass.y * rb1.inverseMass);
        
		
		// Apply impulse to second body
		if (_rb2Exists)
		{
			rb2.velocity.set(rb2.velocity.x - _impulsePerIMass.x * rb2.inverseMass,
				rb2.velocity.y - _impulsePerIMass.y * rb2.inverseMass);
            
		}
	}
	
	///	@func	resolveInterpenetration(dt);
	///	@param	{real}	dt	The change in time of the simulation.
	///	@desc	Handles interpenetration resolution for the collision.
	static resolveInterpenetration = function(_dt)
	{
		// Return if no penetration
		if (penetration <= 0) return;
		
		// Store if the second rigid body is moveable
		var _rb2Moveable = false;
		if (instance_exists(rb2) && rb2.inverseMass > 0) _rb2Moveable = true;
		
		// Movement is based on inverse mass, so get total
		var _totalIMass = rb1.inverseMass;
		if (_rb2Moveable) _totalIMass += rb2.inverseMass;
		
		// Return if both infinite mass
		if (_totalIMass <= 0) return;
		
		// Find penetration per inverse mass
		var _movePerIMass = normal.getCopy();
		_movePerIMass.scale(penetration / _totalIMass);
		
		// Calculate movements
		rb1Movement.setScaledVector(_movePerIMass, rb1.inverseMass);
		if (_rb2Moveable) rb2Movement.setScaledVector(_movePerIMass, -rb2.inverseMass);
		else rb2Movement.set();
		
		// Apply penetration resolution for bodies
		rb1.x += rb1Movement.x;
		rb1.y += rb1Movement.y;
		if (_rb2Moveable)
		{
			rb2.x += rb2Movement.x;
			rb2.y += rb2Movement.y;
		}
	}
	
	///	@func	clear();
	///	@desc	Clears the data in the contact for reuse.
	static clear = function()
	{
		rb1 = undefined;
		rb2 = undefined;
		restitution = 1;
		normal.set();
		penetration = 0;
		rb1Movement.set();
		rb2Movement.set();
        point.set();
	}
	
	///	@func	matchAwakeState();
	///	@desc	Matches awake states between bodies. Called whenever a collision is about to be resolved.
	static matchAwakeState = function()
	{
		// Return if world collision
		if (!instance_exists(rb2)) return;
		
		// Wake up only the sleeping body
		if (rb1.isAwake ^ rb2.isAwake)
		{
			if (rb1.isAwake) SetAwake(rb2, true);
			else SetAwake(rb1, true);
		}
	}
	
	///	@func	toString();
	static toString = function()
	{
		return string("[{0},{1}]=>[{2},{3}]", rb1, rb2, normal, penetration);
	}
    
    
    
}

///	@func	ContactResolver(iterations);
///	@param	{real}	iterations	The number of iterations that can be used.
///	@desc	The contact resolution routine for contacts. Once can be shared for each physics world.
function ContactResolver(_iterations = 6) constructor
{
	iterations = _iterations;
	iterationsUsed = 0;			// For performance testing
	penetrationEpsilon = 0.1;	// Tolerance for determining what is considered a collision
	velocityIterations = 8;
    positionIterations = 8;
    penetrationSlop = 0.01;
	///	@func	setIterations(iterations);
	///	@param	{real}	iterations	The number of iterations that can be used.
	///	@desc	Sets the iterations the resolver can use.
	static setIterations = function(_iterations){ iterations = _iterations; }
	
	///	@func	getIterationsUsed();
	///	@return	{real}	The number of iterations used.
	///	@desc	Gets the iterations used by the resolver.
	static getIterationsUsed = function(){ return iterationsUsed; }
	
	///	@func	resolveContacts(contacts, contactCount, dt);
	///	@param	{array}	contacts		All of the contacts that need resolving.
	///	@param	{real}	contactCount	How many contacts there are.
	///	@param	{real}	dt				The change in time in the simulation.
	///	@desc	Resolves contacts for both penetration and velocity.
	static resolveContacts = function(_contacts, _count, _dt)
   {
       iterationsUsed = 0;
   
       // PASS 1: velocity. Every contact, every iteration (Gauss-Seidel).
       for (var _it = 0; _it < velocityIterations; _it++)      // e.g. 8
       {
           for (var _i = 0; _i < _count; _i++)
           {
               _contacts[_i].matchAwakeState();
               _contacts[_i].resolveVelocity(_dt);
            
_contacts[_i].resolvefrictions(_dt);
           }
           iterationsUsed++;
       }
   
       // PASS 2: position. Your existing "worst penetration" loop, position only.
       for (var _it = 0; _it < positionIterations; _it++)      // e.g. _count * 2
       {
           var _worst = penetrationSlop;                       // 0.01, not 0.1
           var _maxIdx = _count;
           for (var _i = 0; _i < _count; _i++)
           {
               if (_contacts[_i].penetration > _worst)
               {
                   _worst = _contacts[_i].penetration;
                   _maxIdx = _i;
               }
           }
           if (_maxIdx == _count) break;
   
          
           // ... your existing "update penetrations for other contacts" block unchanged ... 
            _contacts[_maxIdx].resolveInterpenetration(_dt);
            
            var _rb1Movement = _contacts[_maxIdx].rb1Movement, _rb2Movement = _contacts[_maxIdx].rb2Movement;
            for (var _i = 0; _i < _count; _i++)
            {
                if (_contacts[_i].rb1 == _contacts[_maxIdx].rb1)
                    _contacts[_i].penetration -= _rb1Movement.dotProductVector(_contacts[_i].normal);
                else if (_contacts[_i].rb1 == _contacts[_maxIdx].rb2)
                    _contacts[_i].penetration -= _rb2Movement.dotProductVector(_contacts[_i].normal);
            
                if (instance_exists(_contacts[_i].rb2) && _contacts[_i].rb2.inverseMass > 0)
                {
                    if (_contacts[_i].rb2 == _contacts[_maxIdx].rb1)
                        _contacts[_i].penetration += _rb1Movement.dotProductVector(_contacts[_i].normal);
                    else if (_contacts[_i].rb2 == _contacts[_maxIdx].rb2)
                        _contacts[_i].penetration += _rb2Movement.dotProductVector(_contacts[_i].normal);
                }
            }
            iterationsUsed++;
                       
       }
   }
}
///	@func	ContactGen();
///	@desc	Adds contacts applied to registered bodies. Only inherited contact generators will be instanced.
function ContactGen() constructor
{
	name = "contact gen";
	
	///	@func	addContact(rb, pw, limit);
	///	@param	{Id.Instance}	rb	The rigid body.
	///	@param	{Id.Instance}	pw	The physics world.
	///	@param	{real}	limit		The number of contacts that can be written to.
	///	@desc	Fills the contact structure with generated contacts.
	static addContact = function(_rb, _pw, _limit){ return 0; }
	
	///	@func	toString();
	///	@desc	Returns the name of the contact generator.
	static toString = function(){ return name; }
}