/// Granitor, a hulking living boulder from the volcano's crater, magma glowing in its cracks.
/// Fast and hard to catch:
///   Hops: bounces about the summit after the snakes.
///   Roll: curls into a ball and rolls across the summit, bouncing off the edges (it can't
///         be hurt like that, and it hurts).
///   Quake: raises its fists and slams the ground: the mountain shakes, shockwaves run along
///         the ground both ways (jump them) and glowing rocks rain down.
///   Throw: hurls glowing rocks at a snake.
/// A hit while it's moving sends it rolling away at once. But Mango the monkey, hiding by the
/// fight, throws honey at it: stuck in honey it can't move (and is safe to touch) for a while,
/// the time to hit it. It doesn't hold the last letter this time: Mango gives that to the
/// snakes when it's beaten.
/// Frames: standing, slamming, throwing, rolling, stuck in honey, hurt.
event_inherited();
boss_name = "GRANITOR";
hw = 50;
hh = 48;
hp_max = 12;
hp = hp_max;
points = 60000;
music = "music_09.ogg";
facing = -1;
image_speed = 0;
state = "hop";          // hop | roll | slam | quake | throw | stuck
timer = 60;
last_hp = hp;
stuck_t = 0;
shots = 0;
told = false;

/// Rolling (frame 3) it's armoured; just after a hit it's bristling.
spiky_back = function() { return hurt_t > 0 || floor(image_index) == 3; };
/// Stuck in honey (frame 4): touching it doesn't hurt.
touch_safe = function() { return floor(image_index) == 4; };

/// Hit by Mango's honey: stuck where it stands for a while.
honey_stick = function()
{
    var _g = obj_game;
    state = "stuck";
    stuck_t = 220;
    vx = 0;
    _g.play_sfx(_g.sfx.slurp);
    _g.burst(x, y - 30, make_colour_rgb(255, 190, 40), 16);
    if (!told) { told = true; _g.say("MANGO STUCK GRANITOR IN HONEY! HIT IT NOW!", 150); }
};

/// Rolling, hits bounce off it. Its last hit: it crumbles, and no letter comes out (Mango has
/// it; see obj_monkey).
base_kill = kill;
kill = function(_dmg = 1, _by = noone)
{
    var _g = obj_game;
    if (active && floor(image_index) == 3)
    {
        if (_g.frame mod 6 == 0) { _g.play_sfx(_g.sfx.clank); _g.burst(x, y, c_white, 6); }
        return;
    }
    if (_g.net_mode != "client" && active && hurt_t == 0 && hp - _dmg <= 0)
    {
        hp = 0;
        _g.play_sfx(_g.sfx.boss_hit);
        _g.burst(x, y - 10, make_colour_rgb(255, 120, 40), 40);
        _g.burst(x, y - 10, make_colour_rgb(120, 100, 90), 30);
        part_particles_create(_g.ps, x, y, _g.pt_rock, 24);
        _g.shake(16);
        _g.add_score(points, x, y - 50, stats_of(_by));
        _g.play_sfx(_g.sfx.boss_win);
        _g.play_music(_g.lvl.music);
        _g.clear_messages();
        _g.say(boss_name + " CRUMBLES! LOOK, MANGO IS COMING OUT...", 180);
        var _ch = ch;
        with (obj_monkey) start_thanks(_ch);
        if (_g.net_mode == "host") _g.net_event({ t: "kill", i: net_id });
        instance_destroy();
        return;
    }
    base_kill(_dmg, _by);
};

/// Hurls a glowing rock so it comes down on snake _p.
throw_rock = function(_p)
{
    var _g = obj_game;
    var _sx = x + facing * 60;
    var _sy = y - 40;
    var _t = 46;
    var _grav = 0.35;
    var _tx = (_p != noone) ? _p.x + _p.vx * 20 : x + facing * 200;
    var _ty = (_p != noone) ? _p.y : y;
    var _r = shoot(spr_lavarock, _sx, _sy, (_tx - _sx) / _t, (_ty - _sy - 0.5 * _grav * _t * _t) / _t, _grav);
    _r.life = 200;
    _g.play_sfx(_g.sfx.throw_);
};
