// His arms stretch and snap back, and his swords hurt this PC's snake (online too: both PCs
// see the same frame).
update_arms();
if (obj_game.state == "play") blade_check();
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

// Every hit: he flails (landing on him hurts now), then backs off.
if (hp < last_hp)
{
    last_hp = hp;
    hurt_t = max(hurt_t, 60);
    state = "hurt";
    timer = 24;
    vx = 0;
    combo = false;
    _g.play_sfx(_g.sfx.growl);
}

var _p = instance_nearest(x, y, obj_player);
switch (state)
{
    case "walk":
        // Shuffles about on his arms, never standing still: closes in on the nearest snake,
        // steps back if it's right on top of him, and sways to and fro in between.
        var _d = face_player();
        image_index = (_g.frame div 14) mod 2;
        var _sp = _angry ? 1.7 : 1.3;
        if (_d > 220) vx = facing * _sp;
        else if (_d < 90) vx = -facing * _sp;
        else vx = sin(_g.frame * 0.04) * _sp * 0.7;
        if (timer <= 0)
        {
            vx = 0;
            // A snake up on a plank (or jumping) gets the high slash or a high thrust; one on
            // the floor the low sweep or a low thrust; one far off a thrust.
            var _up = _p != noone && _p.y < y + 20;
            var _r = irandom(99);
            if (_d > 300) attack = "thrust";
            else if (_up) attack = (_r < 55) ? "slash" : "thrust";
            else attack = (_r < 50) ? "sweep" : ((_r < 80) ? "thrust" : "slash");
            thrust_high = _up;
            combo = _angry && attack == "sweep";
            state = "windup";
            timer = _angry ? 20 : 28;
            _g.play_sfx(_g.sfx.charge);
        }
        break;

    case "windup":
        // Swords drawn back: the warning.
        vx = 0;
        if (attack == "thrust") face_player();
        image_index = 2;
        x += irandom_range(-1, 1);
        if (timer <= 0)
        {
            state = "strike";
            timer = 26;
            _g.play_sfx(_g.sfx.throw_);
            _g.play_sfx(_g.sfx.snip);
            if (attack != "thrust") _g.shake(6);
        }
        break;

    case "strike":
        vx = 0;
        if (attack == "thrust") image_index = thrust_high ? 7 : 3;
        else image_index = (attack == "sweep") ? 4 : 5;
        if (timer <= 0)
        {
            if (combo) { combo = false; attack = "slash"; state = "windup"; timer = 12; }
            else { state = "walk"; timer = _angry ? 45 : 65; }
        }
        break;

    case "hurt":
        vx = 0;
        image_index = 6;
        if (timer <= 0) { face_player(); state = "back"; timer = 26; }
        break;

    case "back":
        image_index = (_g.frame div 6) mod 2;
        vx = -facing * (_angry ? 3.2 : 2.6);
        if (timer <= 0 || x <= arena_x1 || x >= arena_x2) { state = "walk"; timer = 40; vx = 0; }
        break;
}

vy = min(vy + gravity_pull, 9);
entity_move();
