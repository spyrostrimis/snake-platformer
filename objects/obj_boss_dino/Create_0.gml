/// Rex Bonejaw, the dinosaur skeleton at the bottom of the caverns. Only a boost (or the
/// Slingshot) cracks his bones: the tongue and stomps just clank off.
/// Long jump: he crouches, then leaps right across the cave at you; the landing shakes the
/// cave, sends a shockwave both ways and knocks rocks off the roof. (Peto: rocket up into his
/// belly as he flies over you.)
/// Tail whip: he turns his back and lashes his long tail low along the floor (jump it).
/// Angry (half health), he whips it twice, one side then the other.
/// Every hit: he roars, then leaps again at once (right over you if you're close).
event_inherited();
drop_through = true;    // too heavy for the planks: he lands on the floor
boss_name = "REX BONEJAW";
hw = 46;
hh = 48;
hp_max = 9;
hp = hp_max;
points = 20000;
music = "music_09.ogg";
orb_dy = 124;
boost_only = true;
state = "stalk";        // stalk | crouch | leap | land | turn | whip | roar
timer = 90;
last_hp = hp;
whips_left = 0;
was_airborne = false;

/// Snakes on this PC caught by the lashing tail (the whip frame, behind him) get hurt.
/// It only uses x, facing and image_index, so online each PC checks its own snake.
tail_check = function()
{
    if (floor(image_index) != 4) return;
    var _a = x - facing * 30;
    var _b = x - facing * 205;
    var _l = min(_a, _b);
    var _r = max(_a, _b);
    var _t = y - 8;
    var _bt = y + hh;
    var _f = -facing;
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _t && y - hh < _bt) take_hit(_f);
    }
};

/// The y just under the cave roof above (_x, _from_y): where the landing knocks rocks from.
roof_y = function(_x, _from_y)
{
    var _ty = floor(_from_y / TILE);
    while (_ty > 0 && !is_blocking(tile_at(_x, _ty * TILE))) _ty--;
    return (_ty + 1) * TILE + 12;
};
