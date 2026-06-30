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
    
    
}