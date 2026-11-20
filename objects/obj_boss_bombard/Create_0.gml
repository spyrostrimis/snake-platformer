/// THE BOMBARD: the pirates' great bronze cannon, up on the deck of their ship off Sunset Shore
/// (the ship that sinks here, and lies in the deep in levels 11 and 12). It lobs bombs at the snakes on the
/// shore (two at a time when angry), and a snake that gets up on the deck gets a point-blank
/// shot. It's far too high to jump to: THE SLINGSHOT gets a snake up there (alone, a partner
/// comes in a crate to help). Once it's beaten the ship sinks and the way to the exit is clear.
/// Frames: ready, firing, hurt. (The art points left, at the shore.)
event_inherited();
boss_name = "THE BOMBARD";
hw = 40;
hh = 26;
hp_max = 12;
hp = hp_max;
points = 50000;
music = "music_05.ogg";
facing = 1;
state = "idle";
timer = 120;
shots = 0;
last_hp = hp;
// The level sets these: the shore's surface and where on it the letter lands.
shore_y = y + hh + 256;
shore_x = x - 640;
cam_lock_y = 0;         // the view rises this high during the fight (see obj_game's End Step)
ready = false;

/// It's in its arena when a snake is on the shore below it (or up on the deck).
snake_in_arena = function(_p)
{
    return instance_exists(_p) && !_p.hidden && _p.x > arena_x1 - 16 && _p.x < arena_x2 + 16 && abs(_p.y - shore_y) < 320;
};

/// The last hit blows it up; its letter lands on the shore, where the snakes can get it.
base_kill = kill;
kill = function(_dmg = 1, _by = noone)
{
    if (active && hurt_t == 0 && hp - _dmg <= 0 && obj_game.net_mode != "client")
    {
        var _g = obj_game;
        _g.burst(x, y, make_colour_rgb(255, 150, 40), 30);
        _g.burst(x, y - 10, make_colour_rgb(90, 90, 90), 20);
        _g.shake(14);
        x = shore_x;
        y = shore_y - 40;
    }
    base_kill(_dmg, _by);
};

/// Lobs a bomb from the muzzle so it comes down on the shore at x _tx after _t steps.
fire_bomb = function(_tx, _t)
{
    var _g = obj_game;
    var _sx = x - 54;
    var _sy = y - 24;
    var _grav = 0.25;
    var _vx = (_tx - _sx) / _t;
    var _vy = (shore_y - 10 - _sy - 0.5 * _grav * _t * _t) / _t;
    var _b = shoot(spr_bomb, _sx, _sy, _vx, _vy, _grav);
    _b.life = 400;
    _g.play_sfx(_g.sfx.smash);
    _g.burst(_sx, _sy, make_colour_rgb(220, 220, 220), 8);
    _g.burst(_sx, _sy, make_colour_rgb(255, 200, 60), 6);
};
