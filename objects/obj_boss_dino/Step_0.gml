// His lashing tail hurts this PC's snake (online too: both PCs see the same frame).
if (obj_game.state == "play") tail_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play") exit;

var _g = obj_game;
if (!active)
{
    image_index = 0;
    vy = min(vy + gravity_pull, 9);
    entity_move();
    exit;
}
var _angry = hp <= hp_max / 2;
timer--;

// Every hit: a roar, then another long jump at once.
if (hp < last_hp)
{
    last_hp = hp;
    hurt_t = max(hurt_t, 60);
    state = "roar";
    timer = 32;
    vx = 0;
    _g.play_sfx(_g.sfx.growl);
}

switch (state)
{
    case "stalk":
        // Stomps towards the nearest snake.
        var _d = face_player();
        image_index = (_g.frame div 12) mod 2;
        vx = (_d > 120) ? facing * (_angry ? 1.8 : 1.2) : 0;
        if (timer <= 0)
        {
            vx = 0;
            var _p = instance_nearest(x, y, obj_player);
            if (_p != noone && _d < 230 && irandom(9) < 6)
            {
                // Close: turn his back on the snake and whip his tail at it.
                facing = (_p.x >= x) ? -1 : 1;
                state = "turn";
                timer = _angry ? 18 : 26;
                whips_left = _angry ? 2 : 1;
                _g.play_sfx(_g.sfx.growl);
            }
            else { state = "crouch"; timer = _angry ? 22 : 32; }
        }
        break;

    case "turn":
        // Back turned, tail twitching: the whip is coming.
        vx = 0;
        image_index = 0;
        x += irandom_range(-1, 1);
        if (timer <= 0)
        {
            state = "whip";
            timer = 26;
            _g.play_sfx(_g.sfx.throw_);
            _g.play_sfx(_g.sfx.rattle);
            part_particles_create(_g.ps, x - facing * 140, y + hh - 4, _g.pt_dust, 6);
        }
        break;

    case "whip":
        vx = 0;
        image_index = 4;
        if (timer <= 0)
        {
            whips_left--;
            if (whips_left > 0)
            {
                // Angry: spins round and lashes the other side too.
                facing = -facing;
                state = "turn";
                timer = 10;
            }
            else { state = "stalk"; timer = _angry ? 60 : 85; }
        }
        break;

    case "crouch":
        // Squats down, bones creaking...
        vx = 0;
        face_player();
        image_index = 2;
        x += irandom_range(-1, 1);
        if (timer <= 0 && on_ground)
        {
            // ...and the long jump: aimed to come down where the snake is.
            var _p = instance_nearest(x, y, obj_player);
            var _vy = _angry ? -12.5 : -11.5;
            var _air = -2 * _vy / gravity_pull;
            var _dx = (_p != noone) ? (_p.x - x) : facing * 200;
            if (abs(_dx) < 120) _dx = facing * 260;        // too close: leap right over the snake
            vy = _vy;
            vx = clamp(_dx / _air, -7.5, 7.5);
            facing = (vx >= 0) ? 1 : -1;
            state = "leap";
            was_airborne = false;
            _g.play_sfx(_g.sfx.jump);
        }
        break;

    case "leap":
        image_index = 3;
        if (!on_ground) was_airborne = true;
        else if (was_airborne)
        {
            // The landing: the cave shakes, shockwaves both ways, rocks off the roof.
            vx = 0;
            state = "land";
            timer = _angry ? 46 : 64;           // a long pause after landing: boost him now
            _g.play_sfx(_g.sfx.smash);
            _g.shake(22);
            part_particles_create(_g.ps, x, y + hh, _g.pt_rock, 14);
            for (var _s = -1; _s <= 1; _s += 2)
            {
                var _w = shoot(spr_shockwave, x + _s * hw, y + hh - 8, _s * (_angry ? 4.8 : 4), 0, 0);
                _w.spin = false;
                _w.image_angle = 0;
                _w.life = 140;
            }
            var _n = _angry ? 4 : 2;
            for (var _k = 0; _k < _n; _k++)
            {
                var _rx = random_range(arena_x1, arena_x2);
                shoot(spr_rock, _rx, roof_y(_rx, y), 0, random_range(0, 1.5), 0.3);
            }
        }
        break;

    case "land":
        vx = 0;
        image_index = 2;
        if (timer <= 0) { state = "stalk"; timer = _angry ? 50 : 70; }
        break;

    case "roar":
        vx = 0;
        image_index = 5;
        if (timer <= 0) { face_player(); state = "crouch"; timer = 34; }
        break;
}

vy = min(vy + gravity_pull, 9);
entity_move();
