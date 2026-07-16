#region Rigid Body

#region Setter/Getters

function GetMass(_rb){ //Returns the mass (inverseMass) of the body 
    if (_rb.inverseMass == 0) return infinity ;
    	return 1/_rb.inverseMass;
    
}



function SetMass(_rb, _mass){
    if (_mass == 0) throw ("Set mass error. Mass can't be zero") {
    	_rb.inverseMass = 1 / _mass;
        
    }
}


function GetWidth(_rb){
    if (_rb.shape == Shape.RECT_ROTATED) { // Shape is RECT_ROTATED
    	var _angle = _rb.image_angle;
        _rb.image_angle = 0;
        var _w = _rb.bbox_right - _rb.bbox_left;
        _rb.image_angle = _angle;
        return _w;
    }
    
    return _rb.bbox_right - _rb.bbox_left;
}


function GetHeight(_rb){
    if (_rb.shape == Shape.RECT_ROTATED) { //Shape is RECT_ROTATED
    	var _angle = _rb.image_angle;
        _rb.image_angle = 0;
        var _h = _rb.bbox_bottom - _rb.bbox_top;
        _rb.image_angle = _angle;
        return _h;
    }
    
    return _rb.bbox_bottom - _rb.bbox_top;
}


function GetRadius(_rb){
    var _w = _rb.bbox_right - _rb.bbox_left;
    var _h = _rb.bbox_bottom - _rb.bbox_top;
    if (_w > _h) return _h * 0.5 ;   //Needed smaller dimension for the circle to fits completely inside
    	return _w * 0.5;
    
}


function SetAngle(_rb,_angle){  //How much is the object rotated?
    _rb.image_angle = _angle;
    if (_rb.shape == Shape.RECT_ROTATED) {
    	_rb.orientation.setRotation(_rb.image_angle);
    }
}


function SetShape(_rb,_shape){
    
    _rb.shape = _shape;
    switch (_shape) {
    	
        case Shape.RECT:
            _rb.orientation.setRotation(0);
            
            //Draw
            _rb.funcDrawShape = DrawRect;
            _rb.color = #ffff55;
            show_debug_message("Draw rectangle");
            break;
        case Shape.CIRCLE:
            _rb.orientation.setRotation(0);
            
            //Draw
            _rb.funcDrawShape = DrawCircle;
            _rb.color = #55ff55;
            break;
        case Shape.RECT_ROTATED:
            _rb.orientation.setRotation(-_rb.image_angle);
            
            //Draw
            _rb.funcDrawShape = DrawRotatedRec;
            _rb.color = #ff5555;
            
            break;
    }
}



function SetAwake(_rb, _awake = true){
    with (_rb) {
    	if (_awake) {
        	isAwake = true;
            //Add some motion to avoid immediately sleeping
            motion = Sleep * 2;
            
        }else {
        	//Sleep
            isAwake = false;
            velocity.set();
        }
    }
}



#endregion

#region Properties

//collisionBitmask	The collision bitmask.
//bitmask	The bitmask to check.
//Returns whether or not there is a similarity within the bitmasks.
function HasLayerCollision(_collisionBitmask , _bitmask)
{
    return !((_collisionBitmask & _bitmask) == 0); 
}
#endregion
#region Simulation


function ClearForces(_rb) //Clear the forces acting on the body
{
    _rb.force.set();
}

function AddForces(_rb, _fx, _fy)
{
    _rb.force.add(_fx, _fy);
    //wake
    if (!_rb.isAwake) {
    	SetAwake(_rb,true)
    }
}

function AddforceVector(_rb,_f){
    _rb.force.addVector(_f);
    //wake
    if (!_rb.isAwake) {
    	SetAwake(_rb, true);
    }
}

//_cg contact generator
//Adds a contact generator to the rigid body . Need this function to add a rigid bodies 
function AddContactGen(_rb, _cg)
{
    array_push(_rb.contactGens , _cg);
}



//Heart of the Physic engine
function Integrate(_rb,_dt)
{
    //Making sure body is Awake
    if (_rb.canSleep && !_rb.isAwake) return;
        
    //Make sure time isn't zero
    if (_dt <= 0) throw ("Integration error. Cannot be zero")
        
    with (_rb) {
        
    	//Store previous force
        prev_force.setVector(force);
        
        //Calculate acceleration
        acceleration.setScaledVector(force, inverseMass); //a = F x M
        
        //Add Gravity
        acceleration.addVector(grav);
        
        //Calcuate veocity
        velocity.addScaledVector(acceleration, _dt); 
        
        //Apply velocity damping
         velocity.scale(power(damping,_dt)); //Slows the objects slightly every frame
        
        var _vx = velocity.x;
        var _vy = velocity.y;
        
        
    x += _vx;
    y += _vy;
        
        
    }
    
    show_debug_message(string(force.x) + ", " + string(force.y) + " mass=" + string(inverseMass));
}


#region Physic World


function InitNextphysicsFrame(_pw)
{
    with (_pw.rbObject) {
    	ClearForces(self.id);
    }
}
function RunPhysics(_pw, _dt)
{
    if (_dt <= 0) return; // No movemnet, No Collision
        
    with (_pw.rbObject) {
    	Integrate(self.id, _dt);
    }
    
    
}
#endregion


#endregion
#endregion

#region Debug

function DrawRect(_rb)
{
    with (_rb) {
    	
        //Outlines
        if (outlines)
		{
			image_blend = c_dkgray;
			draw_set_color(c_dkgray);
			draw_self();
			draw_circle(x, y, GetRadius(self.id), true);
		}
        // Rectangle
		draw_set_color(color);
		draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
		
		// Reset color
		draw_set_color(c_white);
    }
}

function DrawRotatedRec(_rb)
{
    with (_rb) {
        
        // Outlines
		if (outlines)
		{
			draw_set_color(c_dkgray);
			draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
			draw_circle(x, y, GetRadius(self.id), true);
		}
		
        
        //Rotated rectangle
        image_blend = color;
        draw_self();
        // Reset color
        draw_set_color(c_white);
    }   
}

function DrawCircle(_rb)
{
    with (_rb) {
    	// Outlines
		if (outlines)
		{
			image_blend = c_dkgray;
			draw_set_color(c_dkgray);
			draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
			draw_self();
		}
    
        draw_set_color(color);
        draw_circle(x, y,GetRadius(self.id), true);
        // Reset color
        draw_set_color(c_white);
    }
}

#endregion
