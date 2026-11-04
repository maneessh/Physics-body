

function HealthComponent(id, _max_hp) constructor {
    owner = id;
    max_hp = _max_hp;
    hp = _max_hp;
    
    iframes = 0;  //Current invulnerability timer (frames)
    iframes_max = 0;        //Set >0 to enable
    is_dead = false;
    //CallBack function for sound or ....
    on_damage = undefined; //method(owner, function(_amt){})
    on_death = undefined;  //method(owner,fuction(){})
    
    
    static Step = function(){
        if (iframes > 0) iframes --;
    }
    //@param {real} _amt represents how much damage the object should recieve //health.Damage(20);
    static Damage = function (_amt){
        
        if (is_dead || iframes > 0) return false;
        //Calculate the new health && prevents health from becoming negative
        hp = max(0, hp - _amt);
        //Activate invulnerability
        iframes = iframes_max;
        if(on_damage != undefined) on_damage(_amt);
        if (hp <= 0 ) {
        	is_dead = true;
            if(on_death != undefined) on_death();
        }
        return true;
        //return false: Damage was rejected because the object was dead or invulnerable.
        //return true: Damage was successfully applied.
    }
    //Calculate the new health
    static Heal = function(_amt){
        if(!is_dead) hp = min(max_hp, hp + _amt);
    }
    
    
}