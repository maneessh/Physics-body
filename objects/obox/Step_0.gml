if (keyboard_check(vk_right))
{
    for (var i = 0; i < ds_list_size(points); i++)
    {
        var p = points[| i];

        p.x += 2;
        p.oldx += 2;
    }
}

if (keyboard_check(vk_left))
{
    for (var i = 0; i < ds_list_size(points); i++)
    {
        var p = points[| i];

        p.x -= 2;
        p.oldx -= 2;
    }
}
 