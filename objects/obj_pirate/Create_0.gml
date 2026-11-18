/// A pirate (a living one) hiding in a bush. Now and then his eyes peek out between the
/// leaves; when a snake comes close he leaps out at it, then chases it, slashes with his
/// cutlass up close and leaps at it again from a few tiles away. The tongue, a stomp or a
/// boost beats him. While hidden he can't touch or be touched.
/// Frames: walk A, walk B, leaping, slashing, peeking out of the bush, hidden (empty).
event_inherited();
hw = 12;
hh = 22;
points = 500;
image_speed = 0;
image_index = 5;
state = "hide";         // hide | peek | air | walk | slash
timer = 60 + irandom(120);
leap_cd = 0;

/// Hidden in the bush (frames 4 and 5): nothing happens. Only uses image_index, so online
/// both PCs agree.
is_harmless = function() { return floor(image_index) >= 4; };

/// While he slashes (frame 3), his cutlass reaches past his body. Only uses x, y, facing and
/// image_index, so online each PC checks its own snake.
sword_check = function()
{
    if (floor(image_index) != 3) return;
    var _x1 = min(x + facing * 8, x + facing * 34);
    var _x2 = max(x + facing * 8, x + facing * 34);
    var _yy = y;
    var _dir = facing;
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && !ball && x + hw > _x1 && x - hw < _x2 && abs(y - _yy) < hh + 12) take_hit(_dir);
    }
};
