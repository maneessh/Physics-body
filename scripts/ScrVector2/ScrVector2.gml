function Vector2(_x = 0, _y = 0) constructor {
    
    x = _x; 
    y = _y;
    
    static set = function (_x = 0, _y = 0){
        x = _x;
        y = _y;
        
    }
    
    static setVector = function (_v){ //Instead of using number use another vector.
        
        x = _v.x;
        y = _v.y; 
        
    }
    
    static setScaled = function (_x = 0, _y = 0, _factor = 1) // Velocity = direction * speed;
    {
        x = _x * _factor;
        y = _y * _factor;
    }
    
    static setScaledVector = function (_v, _factor = 1) //
    {
        x = _v.x * _factor;
        y = _v.y * _factor;
    }
    
    
    #region Properties
    
    static magnitude = function (){
        return sqrt(x * x + y * y);
    }
    
    #endregion
    
    
    static scale = function (_factor)
    {
        x *= _factor;
        y *= _factor;
    }
    
    
    static normalize = function (){
        //Get length 
        var _len = magnitude();
        if (_len > 0) {
        	scale(1 / _len);
        }
    }
    
    static add = function (_x, _y)
    {
        x += _x;
        y += _y;
    }
    
    static addVector = function (_v){
        
        x += _v.x;
        y += _v.y;
    }
    
    //Instead of add(x *_factor, y * _factor) it combines both 
    static addScaledVector = function (_v, _factor) 
    {
        x += _v.x * _factor;
        y += _v.y * _factor;
    }
    
    
}