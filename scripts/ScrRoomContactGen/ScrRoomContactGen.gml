function RoomContactGen(_height,_bounciness) : ContactGen() constructor {

    
    name = "Room";
    
    
    height = _height;
    bounciness = _bounciness;
    
    
    //_limit = the number of contacts that can be written here 
    static addContact = function (_rb, _pw , _limit)
    {
        
        //Didnn't hit floor
        if (_rb.bbox_bottom  < height) return 0;
            
        
        //Get contact + clear
        var _contact = _pw.contacts[_pw.nextContactIdx];
        _contact.clear();
        
        //Fillout contact data
        _contact.rb1 = _rb;
        _contact.restitution = bounciness;
        _contact.normal = new Vector2(0 , -1); //Normal = First body
        _contact.penetration = _rb.bbox_bottom - height; // penetration = how much body is iteracting
        
        
        //Hit floor
        return 1;
    }
}

