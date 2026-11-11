/// The Stinging Hive: a huge wasp nest hanging by a vine from a leaning palm, swinging over the
/// beach. Its colonies attack in different ways, each after a warning (red eyes, wasps pouring
/// out):
/// Wasp arrows: a fan of wasps shot straight at a snake (two fans when angry).
/// Whirlwind: a twister of wasps that spins along the sand (jump it; two when angry, one each way).
/// Swarm: a few wasps that chase the snakes for a while (any attack swats them).
/// Every third turn it sags low on its vine, buzzing, easy to reach for a while.
/// Bounce on an umbrella to stomp it from above, lash it with the tongue from a plank, or boost
/// into it. Touching it stings.
/// Frames: idle A, idle B, wind-up, hurt.
event_inherited();
boss_name = "THE STINGING HIVE";
hw = 50;
hh = 66;
hp_max = 10;
hp = hp_max;
points = 40000;
facing = 1;
state = "hang";         // hang | windup | arrows2 | rest | sag | hurt
timer = 70;
last_hp = hp;
attack = "arrows";      // what the wind-up leads to: arrows | whirl | swarm
turns = 0;              // every third turn it sags low
ready = false;          // the vine's top is worked out on the first step (once the level placed it)
ground_y = y + hh;
anchor_x = x;
anchor_y = y - 200;
rope = 210;             // the vine's length: 210 hanging, 265 sagging low
rope_to = 210;
swing_t = 0;

/// Its last hit drops it onto the sand, so the letter it holds lands where snakes can get it.
base_kill = kill;
kill = function(_dmg = 1, _by = noone)
{
    if (active && hurt_t == 0 && hp - _dmg <= 0 && obj_game.net_mode != "client") y = ground_y - 40;
    base_kill(_dmg, _by);
};

/// Shoots a fan of _n wasp arrows at snake _p.
fire_arrows = function(_p, _n, _speed)
{
    var _g = obj_game;
    var _sx = x;
    var _sy = y + 56;
    var _dir = (_p != noone) ? point_direction(_sx, _sy, _p.x, _p.y) : 270;
    for (var _k = 0; _k < _n; _k++)
    {
        var _d = _dir + (_k - (_n - 1) / 2) * 11;
        var _h = shoot(spr_wasp_arrow, _sx, _sy, lengthdir_x(_speed, _d), lengthdir_y(_speed, _d), 0);
        _h.spin = false;
        _h.image_angle = _d;
        _h.life = 170;
    }
    _g.play_sfx(_g.sfx.throw_);
    _g.play_sfx(_g.sfx.buzz);
};

/// Sends a whirlwind of wasps spinning along the sand towards side _dir.
spin_whirl = function(_dir)
{
    var _h = shoot(spr_whirl, x, ground_y - 50, _dir * 2.4, 0, 0);
    _h.whirl = true;
    _h.spin = false;
    _h.image_angle = 0;
    _h.life = 330;
    _h.wx1 = arena_x1 - 32;
    _h.wx2 = arena_x2 + 32;
};
