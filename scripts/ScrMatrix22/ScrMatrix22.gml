function Matrix22(_angle = -1) constructor {

    //The 2x2 matrix
    //[a,b] -> [a,b,c,d]
    //[c,d]
    
    data = array_create(4);
    
    #region Setters/Getters
    
    //Converts an angle into rotation matrix
    static setRotation = function (_angle){ 
        
        data[0] = dcos(_angle);
        data[2] = dsin(_angle);
        data[1] = -data[2];
        data[3] = data[0];
        
    }
    
    #endregion
    
    
    static getByIndex = function ( _i, _j){
        _i = floor(clamp(_i, 1, 2));
        _j = floor(clamp(_j, 1, 2));
        
        //Return value
        if (_i == 1) {
        	if (_j == 1) return data[0];
                else return data[1];
        }else {
        	if(_j == 1) return data[3];
                else return data[4];
        }
    }
    
    
   //Set data
    if (_angle != -1) setRotation(_angle);
}