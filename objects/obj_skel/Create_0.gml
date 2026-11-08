/// Little skeleton with a sword: marches along its floor and turns at walls and edges. When a
/// snake comes close in front of it, it raises its sword and slashes. Only a boost (or the
/// Slingshot) breaks it; the tongue and stomps just clank off its bones.
/// Frames: walk A, walk B, sword raised, slash.
event_inherited();
hw = 10;
hh = 16;
points = 300;
boost_only = true;
image_speed = 0;
state = "walk";         // walk | raise | slash
timer = 0;
walk_speed = 0.9;
facing = -1;

/// Snakes on this PC caught by the slash (the slash frame, just in front of it) get hurt.
/// It only uses x, y, facing and image_index, so online each PC checks its own snake.
sword_check = function()
{
    if (floor(image_index) != 3) return;
    var _a = x + facing * 8;
    var _b = x + facing * 50;
    var _l = min(_a, _b);
    var _r = max(_a, _b);
    var _t = y - 14;
    var _bt = y + 12;
    var _f = facing;
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _t && y - hh < _bt) take_hit(_f);
    }
};

// Broken by a boost: its bones fly apart.
base_kill = kill;
kill = function(_dmg = 1, _by = noone)
{
    obj_game.burst(x, y, make_colour_rgb(240, 228, 200), 14);
    obj_game.play_sfx(obj_game.sfx.rattle);
    base_kill(_dmg, _by);
};
