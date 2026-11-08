// His claws hurt this PC's snake (online too: both PCs see the same frame).
if (obj_game.state == "play") claw_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play") exit;

var _g = obj_game;
if (!active)
{
    image_index = (_g.frame div 30) mod 2;
    vy = min(vy + gravity_pull, 9);
    entity_move();
    exit;
}
var _angry = hp <= hp_max / 2;
timer--;

// Every hit: he reels (hot shell: don't land on him), then scuttles away.
if (hp < last_hp)
{
    last_hp = hp;
    hurt_t = max(hurt_t, 70);
    state = "dizzy";
    timer = 26;
    vx = 0;
    _g.play_sfx(_g.sfx.snip);
}

switch (state)
{
    case "walk":
        // Scuttles sideways to keep a little way from the nearest snake.
        var _d = face_player();
        image_index = (_g.frame div 6) mod 2;
        var _sp = _angry ? 2.2 : 1.6;
        if (_d > 230) vx = facing * _sp;
        else if (_d < 140) vx = -facing * _sp;
        else vx = 0;
        if (timer <= 0)
        {
            vx = 0;
            var _r = irandom(99);
            if (_d > 210) { if (_r < 70) state = "aim"; else state = "snapwind"; }
            else if (_r < 45) state = "snapwind";
            else if (_r < 80) state = "smashwind";
            else state = "aim";
            if (state == "aim") { timer = _angry ? 16 : 24; throws_left = _angry ? 2 : 1; }
            else if (state == "snapwind") { timer = _angry ? 12 : 18; _g.play_sfx(_g.sfx.snip); }
            else { timer = _angry ? 20 : 28; _g.play_sfx(_g.sfx.growl); }
        }
        break;

    case "aim":
        // A banknote raised high in the big claw...
        vx = 0;
        face_player();
        image_index = 2;
        if (timer <= 0) { throw_note(); state = "throw"; timer = 18; }
        break;

    case "throw":
        // ...flung like a boomerang.
        vx = 0;
        image_index = 3;
        if (timer <= 0)
        {
            throws_left--;
            if (throws_left > 0) { state = "aim"; timer = 12; }
            else { state = "walk"; timer = _angry ? 50 : 75; }
        }
        break;

    case "snapwind":
        // Claw cocked, trembling: the lunge is coming.
        vx = 0;
        face_player();
        image_index = 0;
        x += irandom_range(-1, 1);
        if (timer <= 0) { state = "snap"; timer = 18; vx = facing * (_angry ? 8 : 7); _g.play_sfx(_g.sfx.snip); }
        break;

    case "snap":
        image_index = 4;
        vx = approach(vx, 0, 0.25);
        if (timer <= 0) { state = "walk"; timer = _angry ? 45 : 65; vx = 0; }
        break;

    case "smashwind":
        vx = 0;
        image_index = 5;
        x += irandom_range(-1, 1);
        if (timer <= 0)
        {
            // Both claws slam into the sand: the cave shakes, shockwaves run both ways.
            state = "smash";
            timer = 30;
            _g.play_sfx(_g.sfx.smash);
            _g.shake(16);
            for (var _s = -1; _s <= 1; _s += 2)
            {
                part_particles_create(_g.ps, x + _s * 90, y + hh - 4, _g.pt_dust, 8);
                var _w = shoot(spr_shockwave, x + _s * 136, y + hh - 8, _s * (_angry ? 5 : 4.2), 0, 0);
                _w.spin = false;
                _w.image_angle = 0;
                _w.life = 140;
            }
        }
        break;

    case "smash":
        vx = 0;
        image_index = 6;
        if (timer <= 0) { state = "walk"; timer = _angry ? 50 : 70; }
        break;

    case "dizzy":
        vx = 0;
        image_index = 7;
        if (timer <= 0) { face_player(); state = "flee"; timer = 34; }
        break;

    case "flee":
        // Scuttles away from the snake that hit him.
        image_index = (_g.frame div 4) mod 2;
        vx = -facing * (_angry ? 4.5 : 3.6);
        if (timer <= 0 || x <= arena_x1 || x >= arena_x2) { state = "walk"; timer = 40; vx = 0; }
        break;
}

vy = min(vy + gravity_pull, 9);
entity_move();
