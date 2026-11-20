var _g = obj_game;
if (clang_t > 0) clang_t--;
// Online, the joiner works his pose out from image_index (and eases it along), then copies
// the host; his blades hurt this PC's snake on both PCs.
if (net_mirror())
{
    var _c = floor(image_index);
    if (_c >= 8)
    {
        var _np = (_c - 8) div 24;
        var _target = ((_c - 8) mod 24) / 8;
        if (state != "attack" || _np != pat || abs(_target - prog) > 0.5) { state = "attack"; pat = _np; prog = _target; }
        else prog = approach(prog, _target + 0.12, 1 / stage_len(floor(prog)));
    }
    else { state = (_c == 2) ? "hurt" : "guard"; prog = 0; }
    if (_g.state == "play") blade_check();
    mirror_step();
    exit;
}
if (_g.state == "play") blade_check();
event_inherited();
if (_g.state != "play") exit;

if (!active)
{
    state = "guard";
    vy = min(vy + gravity_pull, 9);
    entity_move();
    image_index = pose_code();
    exit;
}
var _angry = hp <= hp_max / 2;
timer--;

// Every hit: his arms snap back and he flails (landing on him hurts now), then backs off.
if (hp < last_hp)
{
    last_hp = hp;
    hurt_t = max(hurt_t, 60);
    state = "hurt";
    timer = 24;
    vx = 0;
    _g.play_sfx(_g.sfx.growl);
}

var _p = instance_nearest(x, y, obj_player);
switch (state)
{
    case "guard":
        // On guard, shuffling on his arms: closes in on the nearest snake, keeps it at a
        // sword's length, sways to and fro.
        var _d = face_player();
        var _sp = _angry ? 1.4 : 1.1;
        if (_d > 200) vx = facing * _sp;
        else if (_d < 110) vx = -facing * _sp;
        else vx = sin(_g.frame * 0.04) * _sp * 0.6;
        if (timer <= 0)
        {
            // A snake above him gets the slam more often; otherwise any attack.
            vx = 0;
            face_player();
            var _r = irandom(99);
            if (_p != noone && _p.y < y - 50 && _r < 45) pat = 2;
            else pat = irandom(3);
            state = "attack";
            prog = 0;
            _g.play_sfx(_g.sfx.charge);
        }
        break;

    case "attack":
        vx = 0;
        var _st = floor(prog);
        var _was = _st;
        prog += 1 / stage_len(_st);
        if (floor(prog) != _was && floor(prog) == 1) { _g.play_sfx(_g.sfx.snip); _g.play_sfx(_g.sfx.throw_); }
        if (prog >= 3) { prog = 0; state = "guard"; timer = _angry ? 45 : 75; }
        break;

    case "hurt":
        vx = 0;
        if (timer <= 0) { face_player(); state = "back"; timer = 24; }
        break;

    case "back":
        vx = -facing * (_angry ? 3 : 2.4);
        if (timer <= 0 || x <= arena_x1 || x >= arena_x2) { state = "guard"; timer = 50; vx = 0; }
        break;
}
image_index = pose_code();
vy = min(vy + gravity_pull, 9);
entity_move();
