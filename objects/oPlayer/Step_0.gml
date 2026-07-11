moveInput.x = keyboard_check(vk_right) - keyboard_check(vk_left);
moveInput.y = keyboard_check(ord("w")) - keyboard_check(ord("s"));

moveInput.normalize();
moveInput.scale(moveStrength);

//ADD force
AddforceVector(self.id, moveInput);