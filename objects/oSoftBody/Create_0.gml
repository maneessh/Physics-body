//Create event of SoftBody

width = 32;
height = 32; 


points = ds_list_create();
sticks = ds_list_create();

iterations = 4;
frictions = 0.98;
bounciness = 0.5;


grav = new Vector2(0 , 0.5);


InitSoftBody(self.id ,x , y , width , height , iterations);

