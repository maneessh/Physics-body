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
    
   //Set data
    if (_angle != -1) setRotation(_angle);
}