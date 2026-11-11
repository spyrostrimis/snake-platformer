/// Captain Octavius, the octopus pirate who rules the sunken ship. Eight arms, a cutlass in
/// each, and he can stretch them out a long way. After drawing his swords back (the warning):
/// Thrust: three swords shoot out far ahead of him at every height (get behind him, or out of
/// reach).
/// Low sweep: swords swept along the floor on both sides (jump, or stand on a plank).
/// High slash: swords slashed out at head height on both sides (stay down on the floor).
/// Angry (half health), he follows a sweep straight up with a slash.
/// Stomp his hat, boost or lash him with the tongue to hurt him. Right after a hit he's all
/// flailing blades: landing on him then hurts, and he backs off.
/// Frames: idle A, idle B, wind-up, thrust, low sweep, high slash, hurt.
event_inherited();
boss_name = "CAPTAIN OCTAVIUS";
hw = 75;
hh = 120;
hp_max = 12;
hp = hp_max;
points = 35000;
music = "music_04.ogg";
drop_through = true;
state = "walk";         // walk | windup | strike | hurt | back
timer = 90;
last_hp = hp;
attack = "thrust";      // the attack the wind-up leads to: thrust | sweep | slash
combo = false;          // angry: a sweep followed by a slash

spiky_back = function() { return hurt_t > 0; };

/// This PC's snakes inside the box (_x1.._x2, _y1.._y2) get hurt, pushed towards _dir.
blade_zone = function(_x1, _x2, _y1, _y2, _dir)
{
    var _l = min(_x1, _x2);
    var _r = max(_x1, _x2);
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _y1 && y - hh < _y2) take_hit(_dir);
    }
};

/// The swords hurt while they're out (frames 3, 4, 5). Only uses x, facing and image_index,
/// so online each PC checks its own snake.
blade_check = function()
{
    var _f = floor(image_index);
    if (_f == 3) blade_zone(x + facing * 70, x + facing * 275, y - 95, y + 90, facing);
    else if (_f == 4)
    {
        blade_zone(x + 60, x + 262, y + 80, y + hh, 1);
        blade_zone(x - 262, x - 60, y + 80, y + hh, -1);
    }
    else if (_f == 5)
    {
        blade_zone(x + 70, x + 255, y - 130, y + 5, 1);
        blade_zone(x - 255, x - 70, y - 130, y + 5, -1);
    }
};
