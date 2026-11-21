// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") exit;
if (!active)
{
    image_index = 0;
    vy = min(vy + gravity_pull, 9);
    entity_move();
    exit;
}
var _angry = hp <= hp_max / 2;
timer--;
var _p = instance_nearest(x, y, obj_player);

// Hit while it's moving: it rolls away at once (stuck in honey, it can't).
if (hp < last_hp)
{
    last_hp = hp;
    _g.play_sfx(_g.sfx.growl);
    if (state != "stuck")
    {
        state = "roll";
        timer = _angry ? 80 : 100;
        facing = (_p != noone && _p.x > x) ? -1 : 1;
    }
}

switch (state)
{
    case "hop":
        // Bouncing about after the snakes, quick.
        image_index = 0;
        if (on_ground)
        {
            vx = 0;
            if (timer <= 0)
            {
                var _r = irandom(99);
                if (_r < 34) { state = "roll"; timer = _angry ? 110 : 130; if (_p != noone) facing = sign(_p.x - x + 0.01); }
                else if (_r < 68) { state = "slam"; timer = 34; }
                else { state = "throw"; timer = 20; shots = _angry ? 3 : 2; }
                _g.play_sfx(_g.sfx.charge);
            }
            else if (_g.frame mod 18 == 0)
            {
                if (_p != noone) facing = sign(_p.x - x + 0.01);
                vy = -(8 + random(2.5));
                vx = facing * (_angry ? 5.2 : 4.4) * choose(1, 1, -0.6);
                part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 4);
            }
        }
        break;

    case "roll":
        // A rolling boulder: across the summit and back, bouncing off the edges.
        image_index = 3;
        vx = facing * (_angry ? 10 : 8.5);
        if (hit_wall != 0 || (facing < 0 && x <= arena_x1 + 2) || (facing > 0 && x >= arena_x2 - 2))
        {
            facing = -facing;
            _g.shake(4);
            _g.play_sfx(_g.sfx.bonk);
        }
        if (on_ground && _g.frame mod 4 == 0) part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 2);
        if (timer <= 0) { state = "hop"; timer = 50; vx = 0; }
        break;

    case "slam":
        // Fists raised: the quake is coming (a little jump, and down it comes).
        image_index = 1;
        vx = 0;
        x += irandom_range(-1, 1);
        if (timer == 0) { vy = -6; state = "quake"; timer = 60; }
        break;

    case "quake":
        image_index = 1;
        vx = 0;
        if (on_ground && timer < 56 && timer > 0)
        {
            // The slam: the mountain shakes, shockwaves both ways, rocks rain down.
            timer = -1;
            image_index = 0;
            _g.shake(30);
            _g.play_sfx(_g.sfx.smash);
            _g.play_sfx(_g.sfx.boss_hit);
            part_particles_create(_g.ps, x, y + hh, _g.pt_rock, 18);
            for (var _s = -1; _s <= 1; _s += 2)
            {
                var _w = shoot(spr_shockwave, x + _s * hw, y + hh - 8, _s * (_angry ? 5.2 : 4.4), 0, 0);
                _w.spin = false;
                _w.image_angle = 0;
                _w.life = 160;
            }
            var _n = _angry ? 6 : 4;
            for (var _k = 0; _k < _n; _k++)
            {
                var _rk = shoot(spr_lavarock, random_range(arena_x1, arena_x2), y - 330 - irandom(80), 0, random_range(0.5, 1.5), 0.3);
                _rk.life = 260;
            }
        }
        if (timer < -30) { state = "hop"; timer = 40; }
        if (timer < 0) { timer--; image_index = 0; }
        break;

    case "throw":
        // Rocks hurled at the snakes.
        image_index = 2;
        vx = 0;
        if (_p != noone) facing = sign(_p.x - x + 0.01);
        if (timer <= 0)
        {
            throw_rock(_p);
            shots--;
            timer = 24;
            if (shots <= 0) { state = "hop"; timer = 45; }
        }
        break;

    case "stuck":
        // Stuck in honey: the moment to hit it.
        image_index = 4;
        vx = 0;
        stuck_t--;
        if (_g.frame mod 12 == 0) part_particles_create_colour(_g.ps, x + random_range(-40, 40), y - 20, _g.pt_spark, make_colour_rgb(255, 190, 40), 1);
        if (stuck_t <= 0)
        {
            state = "hop";
            timer = 30;
            _g.burst(x, y - 30, make_colour_rgb(255, 190, 40), 14);
            _g.play_sfx(_g.sfx.growl);
        }
        break;
}
vy = min(vy + gravity_pull, 9);
entity_move();
