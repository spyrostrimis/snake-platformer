/// Hissandra, the cobra queen of the dark hollow. She sways on her coils and keeps her
/// distance, and has two attacks:
/// Tail slam: she lifts her tail high over her head, then smashes it down in front of her;
/// the tail hurts where it lands and sends a shockwave along the floor (jump it).
/// Poison spit: she rears up and spits venom globs in arcs at you; each leaves a poison
/// puddle on the floor for a few seconds.
/// Stomp her head to hurt her. Every hit makes her rear back, her hood spiky for a moment
/// (land on her again too soon and it's you who gets hurt), and she answers with a quick slam.
event_inherited();
boss_name = "HISSANDRA";
hw = 28;
hh = 60;
hp_max = 12;
hp = hp_max;
points = 15000;
music = "music_04.ogg";
orb_dy = 116;           // her letter bubble floats above her raised head
state = "sway";
timer = 90;
last_hp = hp;
spits_left = 0;
slam_hit = false;

// Just after a hit, landing on her hurts the snake instead (it stops stomp after stomp).
spiky_back = function() { return hurt_t > 0; };

/// Snakes on this PC caught by the slammed tail (the slam frame, in front of her) get hurt.
/// It only uses x, facing and image_index, so online each PC checks its own snake.
tail_check = function()
{
    if (floor(image_index) != 3) return;
    var _a = x + facing * 40;
    var _b = x + facing * 180;
    var _l = min(_a, _b);
    var _r = max(_a, _b);
    var _top = y + hh - 34;
    var _bot = y + hh;
    var _f = facing;
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _top && y - hh < _bot) take_hit(_f);
    }
};

/// Spits one venom glob from her mouth in an arc that comes down on snake _p.
spit_at = function(_p, _spread)
{
    var _mx = x + facing * 58;
    var _my = y - 74;
    var _vy = -4.6 - random(1);
    var _gr = 0.3;
    var _drop = max(10, (_p.y + 6) - _my);
    var _t = (-_vy + sqrt(_vy * _vy + 2 * _gr * _drop)) / _gr;     // frames until it comes down
    var _vx = clamp((_p.x - _mx) / _t + _spread, -8, 8);
    var _h = shoot(spr_venom, _mx, _my, _vx, _vy, _gr);
    _h.spin = false;
    _h.image_angle = 0;
    _h.life = 300;
};
