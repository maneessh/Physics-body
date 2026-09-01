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
        
        //4 Corners
        var _cosA = cos(_rb.rotation);
        var _sinA = sin(_rb.rotation);
        var _hw = _rb.width / 2;
        var _hh = _rb.height / 2;
        
        var _localCorners = [
            { x: -_hw, y: -_hh},
            { x:  _hw, y: -_hh},
            { x:  _hw, y:  _hh},
            { x: -_hw, y:  _hh}
        ];
        
        
        //Find the lowest(largest y) corner - The actual contact point
        var _lowestY = -infinity;
        var _lowestX = 0;
        
        for (var i = 0; i < 4; i++){
            
            var _wx = _rb.position.x + (_localCorners[i].x * _cosA - _localCorners[i].y * _sinA);
            var _wy = _rb.position.y + (_localCorners[i].x * _sinA - _localCorners[i].y * _cosA);
            if (_wy > _lowestY) {
            	_lowestY = _wy;
                _lowestX = _wx;
            }
            
        }
        
        
        if (tilemap_get_at_pixel(_tm , _lowestX, _lowestY)) {
            
            
        	
            var _tileTop = floor(_lowestY / _th) * _th;
            var _pen = _lowestY - _tileTop;
            show_debug_message(" Tiletouched...............")
            
            if (_pen > 0) {
            	
                var _contact = _pw.contacts[_pw.nextContactIdx];
                _contact.clear();
                
                
                _contact.rb1 = _rb;
                _contact.rb2 = undefined;
                _contact.normal.set(0,-1);
                _contact.penetration = _pen;
                _contact.restitution = bounciness;
                
                _contact.point.set(_lowestX, _lowestY);
                return 1;
                
                
            }
            
        }
        
        
        
        
         return 0;
        
    }
}