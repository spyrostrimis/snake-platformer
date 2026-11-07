// Her slammed tail hurts this PC's snake (online too: both PCs see the same frame).
if (obj_game.state == "play") tail_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play") exit;

var _g = obj_game;
if (!active)
{
    image_index = (_g.frame div 24) mod 2;
    vy = min(vy + gravity_pull, 9);
    entity_move();
    exit;
}
var _angry = hp <= hp_max / 2;   // quicker, more venom, a second shockwave
timer--;

// Every hit: she rears back with her hood spiky, then answers with a quick tail slam.
if (hp < last_hp)
{
    last_hp = hp;
    hurt_t = max(hurt_t, 70);
    state = "recoil";
    timer = 34;
    vx = 0;
    _g.play_sfx(_g.sfx.hiss);
}

switch (state)
{
    case "sway":
        // Sways on her coils, tongue flicking, sliding to keep a good distance.
        var _d = face_player();
        image_index = (_g.frame div 20) mod 2;
        var _sp = _angry ? 1.1 : 0.7;
        if (_d > 230) vx = facing * _sp;
        else if (_d < 110) vx = -facing * _sp;
        else vx = 0;
        if (timer <= 0)
        {
            vx = 0;
            var _slam = (_d < 210) ? irandom(9) < 7 : irandom(9) < 3;
            if (_slam) { state = "raise"; timer = _angry ? 30 : 42; _g.play_sfx(_g.sfx.hiss); }
            else { state = "rear"; timer = _angry ? 24 : 34; _g.play_sfx(_g.sfx.growl); }
        }
        break;

    case "raise":
        // The tail goes up over her head: the slam is coming.
        vx = 0;
        image_index = 2;
        x += irandom_range(-1, 1);
        if (timer <= 0)
        {
            state = "slam";
            timer = 34;
            image_index = 3;
            _g.play_sfx(_g.sfx.smash);
            _g.shake(14);
            var _tip = x + facing * 160;
            part_particles_create(_g.ps, _tip, y + hh - 4, _g.pt_rock, 12);
            part_particles_create(_g.ps, _tip, y + hh - 4, _g.pt_dust, 6);
            var _w = shoot(spr_shockwave, x + facing * 186, y + hh - 8, facing * (_angry ? 5 : 4.2), 0, 0);
            _w.spin = false;
            _w.image_angle = 0;
            _w.life = 150;
            if (_angry)
            {
                // Angry: a second wave runs back behind her as well.
                var _w2 = shoot(spr_shockwave, x - facing * 40, y + hh - 8, -facing * 4.2, 0, 0);
                _w2.spin = false;
                _w2.image_angle = 0;
                _w2.life = 150;
            }
        }
        break;

    case "slam":
        vx = 0;
        image_index = 3;
        if (timer <= 0) { state = "sway"; timer = _angry ? 60 : 85; }
        break;

    case "rear":
        // She rears up, hood wide, jaws open...
        vx = 0;
        face_player();
        image_index = 4;
        if (timer <= 0) { state = "spit"; spits_left = _angry ? 5 : 3; timer = 0; }
        break;

    case "spit":
        // ...and spits venom globs one after another at the nearest snake.
        vx = 0;
        image_index = 4;
        if (timer <= 0)
        {
            var _p = instance_nearest(x, y, obj_player);
            if (_p != noone)
            {
                face_player();
                spit_at(_p, random_range(-0.7, 0.7));
                _g.play_sfx(_g.sfx.slurp);
            }
            spits_left--;
            timer = _angry ? 11 : 15;
            if (spits_left <= 0) { state = "sway"; timer = _angry ? 70 : 95; }
        }
        break;

    case "recoil":
        vx = 0;
        image_index = 5;
        if (timer <= 0) { face_player(); state = "raise"; timer = 22; }
        break;
}

vy = min(vy + gravity_pull, 9);
entity_move();
