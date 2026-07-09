

//The Threshold for sleeping . If motion is below this value, the object is put to sleep
#macro Sleep 0.1


//for updating the motion component
//0 bias -> makes the qual to the new value on each update
//1 bias -> ignores the new motion's value

#macro Motion 0.65 


//Enum
enum Shape {
	RECT,
    RECT_ROTATED,
    CIRCLE
}

