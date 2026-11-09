/// Queen Voltella, the giant jellyfish who guards the sunken ship. She floats above the snakes
/// (her long tentacles sting: don't swim under her) and has three attacks:
/// Spark nova: she charges up, glowing, then bursts a ring of electric sparks out in all
/// directions (angry: more and faster).
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

spiky_back = function() { return hurt_t > 0; };

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

/// A ring of _n electric sparks flying out from her bell at speed _sp.
spark_nova = function(_n, _sp)
{
    var _off = random(360);
    for (var _i = 0; _i < _n; _i++)
    {
        var _a = _off + _i * 360 / _n;
        var _h = shoot(spr_spark, x + lengthdir_x(60, _a), y + lengthdir_y(40, _a), lengthdir_x(_sp, _a), lengthdir_y(_sp, _a), 0);
        _h.spin = true;
        _h.life = 150;
    }
};
