// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play" || !active) exit;

var _g = obj_game;
var _angry = hp <= hp_max / 2;   // faster, more rocks and an extra bounce in the second half
timer--;

// Every hit: he curls up at once (and stays safe a moment), then either rolls at you or
// uncurls and stamps out an earthquake.
if (hp < last_hp)
{
    last_hp = hp;
    hurt_t = max(hurt_t, 90);
    state = "curl";
    timer = 14;
    vx = 0;
    after_curl = (irandom(1) == 0) ? "roll" : "quake";
}

switch (state)
{
    case "walk":
        face_player();
        vx = facing * (_angry ? 2 : 1.4);
        image_index = (_g.frame div 9) mod 2;
        if (timer <= 0)
        {
            vx = 0;
            // Mostly the standing jump and earthquake; a roll now and then.
            if (irandom(9) < 3) { state = "curl"; timer = _angry ? 20 : 30; after_curl = "roll"; }
            else { state = "crouch"; timer = _angry ? 18 : 26; }
        }
        break;

    case "curl":
        // Tucks into a ball and spins up on the spot: the roll is coming.
        vx = 0;
        face_player();
        image_index = 2;
        x += irandom_range(-1, 1);
        if (timer <= 0 && after_curl == "quake") { state = "crouch"; timer = _angry ? 14 : 20; }
        else if (timer <= 0)
        {
            state = "roll";
            bounces = _angry ? 3 : 2;
            timer = 260;
            _g.play_sfx(_g.sfx.charge);
        }
        break;

    case "roll":
        image_index = 2;
        vx = facing * (_angry ? 8.5 : 7);
        if (_g.frame mod 3 == 0) part_particles_create(_g.ps, x - facing * 20, y + hh, _g.pt_dust, 1);
        if (hit_wall != 0 || (facing > 0 && x >= arena_x2) || (facing < 0 && x <= arena_x1))
        {
            // Bonk: bounces off the wall and bowls back the other way.
            facing = -facing;
            bounces--;
            _g.play_sfx(_g.sfx.smash);
            _g.shake(8);
            part_particles_create(_g.ps, x - facing * hw, y, _g.pt_rock, 6);
            if (bounces <= 0) { state = "dizzy"; timer = 70; vx = 0; }
        }
        else if (timer <= 0) { state = "dizzy"; timer = 50; vx = 0; }
        break;

    case "crouch":
        // Earthquake wind-up: squats and trembles...
        vx = 0;
        image_index = 4;
        x += irandom_range(-1, 1);
        if (timer <= 0 && on_ground)
        {
            vy = _angry ? -12 : -11;
            state = "leap";
            was_airborne = false;
            _g.play_sfx(_g.sfx.jump);
        }
        break;

    case "leap":
        // ...a huge leap...
        vx = 0;
        image_index = 3;
        if (!on_ground) was_airborne = true;
        else if (was_airborne)
        {
            // ...and the slam: the cave shakes, shockwaves run along the floor, rocks fall.
            state = "slam";
            timer = 45;
            image_index = 4;
            _g.play_sfx(_g.sfx.smash);
            _g.play_sfx(_g.sfx.boss_hit);
            _g.shake(36);
            part_particles_create(_g.ps, x, y + hh, _g.pt_rock, 16);
            for (var _s = -1; _s <= 1; _s += 2)
            {
                var _w = shoot(spr_shockwave, x + _s * hw, y + hh - 8, _s * (_angry ? 5 : 4.2), 0, 0);
                _w.spin = false;
                _w.image_angle = 0;
                _w.life = 160;
            }
            var _n = _angry ? 7 : 5;
            for (var _k = 0; _k < _n; _k++)
            {
                var _rx = random_range(arena_x1, arena_x2);
                shoot(spr_rock, _rx, roof_y(_rx, y), 0, random_range(0, 1.5), 0.3);
            }
        }
        break;

    case "slam":
        vx = 0;
        image_index = 4;
        if (timer <= 0) { state = "walk"; timer = 70; }
        break;

    case "dizzy":
        vx = 0;
        image_index = 5;
        if (_g.frame mod 20 == 0) _g.burst(x, y - hh - 8, make_colour_rgb(255, 240, 120), 3);
        if (timer <= 0) { state = "walk"; timer = 60; }
        break;
}

vy = min(vy + gravity_pull, 9);
entity_move();
