/// A volcano scorpion: walks to and fro along its ledge, turning at walls and edges. When a
/// snake comes close in front of it, it stops and whips its tail over to sting (a sting also
/// knocks a snake out of the honey). Tongue, stomp or boost it.
/// Frames: walking A, walking B, stinging. (The art faces right.)
event_inherited();
hw = 18;
hh = 12;
walk_speed = 0.9;
points = 300;
image_speed = 0;
sting_t = 0;            // counting down through a sting
sting_cd = 0;

/// Its sting hurts this PC's snakes just in front of it, at the strike. Only uses x, facing and
/// image_index, so online each PC checks its own snake.
sting_check = function()
{
    if (floor(image_index) != 2) return;
    var _x1 = x + facing * 10;
    var _x2 = x + facing * 60;
    var _l = min(_x1, _x2), _r = max(_x1, _x2);
    var _t = y - 26, _b = y + 12;
    var _f = facing;
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _t && y - hh < _b) take_hit(_f);
    }
};
