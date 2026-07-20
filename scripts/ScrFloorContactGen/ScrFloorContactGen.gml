function FloorContactGen( _bounciness = 1)   : ContactGen() constructor {

    
    name = "Floor"
    bounciness = _bounciness;
    
    
        //_limit = the number of contacts that can be written here 
    static addContact = function (_rb, _pw, _limit){
        
        if (_limit <= 0) return 0;
            
        
        var _th = global.th; 
        var _tw = global.tw;
        var _tm = global.tm;
        var _mid_x = _rb.x;
        
        if (tilemap_get_at_pixel(_tm ,_mid_x , _rb.bbox_bottom)) {
            
            show_debug_message("Tiles top ")
        	
            var _tileTop = floor(_rb.bbox_bottom / _th) * _th;
            var _pen = _rb.bbox_bottom - _tileTop;
            
            if (_pen > 0) {
            	
                var _contact = _pw.contacts[_pw.nextContactIdx];
                _contact.clear();
                
                
                _contact.rb1 = _rb;
                _contact.rb2 = undefined;
                _contact.normal.set(0,-1);
                _contact.penetration = _pen;
                _contact.restitution = bounciness;
                
                return 1;
                
                
            }
            
        }
        
        
        
        
         return 0;
        
    }
}