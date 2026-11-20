/// Queen Voltella, the giant jellyfish who guards the sunken ship. She floats above the snakes
/// (her long tentacles sting: don't swim under her) and has three attacks:
/// Spark nova: she charges up, glowing, then bursts electric sparks out, a different way each
/// time: a ring, a spiral of sparks curving round, a fan aimed at a snake, or two rings one
/// after the other (angry: more, faster, and more often). While she's charged with
/// electricity (charging or bursting) she can't be hurt: hits only crackle off her, and
/// landing on her stings.
/// Dive: she rises, then plunges at a snake, and drifts back up.
/// Brood: she lets out little jellyfish that drift after the snakes.
/// Stomp her bell from above, boost or lash her with the tongue to hurt her. Right after a hit
/// she crackles: landing on her then hurts.
/// Frames: drifting, pulse, charging, zap, diving, hurt.
event_inherited();
boss_name = "QUEEN VOLTELLA";
hw = 72;
hh = 48;
hp_max = 12;
hp = hp_max;
points = 30000;
music = "music_09.ogg";
state = "drift";        // drift | charge | nova | rise | dive | recover | brood | recoil
timer = 100;
last_hp = hp;
dive_dx = 0;
dive_dy = 0;
floor_y = -1;           // the sea floor under her arena (found on her first step)
home_y = y;             // where she floats while asleep (set on her first step)
t = 0;

/// Charged with electricity (charging up or bursting: frames 2 and 3, so both PCs agree).
charged = function() { var _f = floor(image_index); return _f == 2 || _f == 3; };
spiky_back = function() { return hurt_t > 0 || charged(); };

/// While she's charged, hits crackle off her and do nothing.
base_kill = kill;
zap_t = 0;
kill = function(_dmg = 1, _by = noone)
{
    if (active && charged())
    {
        var _g = obj_game;
        if (_g.frame - zap_t > 12)
        {
            zap_t = _g.frame;
            _g.play_sfx(_g.sfx.charge);
            _g.burst(x, y, make_colour_rgb(150, 230, 255), 10);
        }
        return;
    }
    base_kill(_dmg, _by);
};

/// Her trailing tentacles sting this PC's snakes. Only uses x and y, so online each PC
/// checks its own snake.
tentacle_check = function()
{
    var _l = x - 62;
    var _r = x + 62;
    var _t = y + hh;
    var _b = y + hh + 150;
    var _bx = x;
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _t && y - hh < _b) take_hit(sign(x - _bx));
    }
};

/// A ring of _n electric sparks flying out from her bell at speed _sp, starting at angle
/// _off, each turning _curve degrees a step as it flies (0: straight out).
spark_nova = function(_n, _sp, _off = random(360), _curve = 0)
{
    for (var _i = 0; _i < _n; _i++)
    {
        var _a = _off + _i * 360 / _n;
        var _h = shoot(spr_spark, x + lengthdir_x(60, _a), y + lengthdir_y(40, _a), lengthdir_x(_sp, _a), lengthdir_y(_sp, _a), 0);
        _h.spin = true;
        _h.life = 150;
        _h.curve = _curve;
    }
};

/// A fan of _n sparks aimed at snake _p (spread _spread degrees), at speed _sp.
spark_fan = function(_p, _n, _spread, _sp)
{
    var _dir = (_p != noone) ? point_direction(x, y, _p.x, _p.y) : 270;
    for (var _i = 0; _i < _n; _i++)
    {
        var _a = _dir + (_i - (_n - 1) / 2) * _spread / max(1, _n - 1);
        var _h = shoot(spr_spark, x + lengthdir_x(50, _a), y + lengthdir_y(36, _a), lengthdir_x(_sp, _a), lengthdir_y(_sp, _a), 0);
        _h.spin = true;
        _h.life = 150;
    }
};
nova_kind = 0;          // the nova this time: 0 ring, 1 spiral, 2 fan, 3 two rings
nova_off = 0;
