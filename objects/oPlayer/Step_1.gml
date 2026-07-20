//Begin Step event of oPlayer
moveInput.x = keyboard_check(vk_right) - keyboard_check(vk_left);
moveInput.y = keyboard_check(vk_down) - keyboard_check(vk_up);

moveInput.normalize();
moveInput.scale(moveStrength);


//ADD force
AddforceVector(self.id, moveInput);

