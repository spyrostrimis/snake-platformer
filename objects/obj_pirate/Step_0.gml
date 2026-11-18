// His cutlass hurts this PC's snake while he slashes (online too: both PCs see the frame).
if (obj_game.state == "play") sword_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") exit;
timer--;
if (leap_cd > 0) leap_cd--;

var _p = instance_nearest(x, y, obj_player);
var _seen = _p != noone && !_p.hidden;
var _dx = _seen ? _p.x - x : 0;
var _dy = _seen ? _p.y - y : 0;

switch (state)
{
    case "hide":
        image_index = 5;
        vx = 0;
        if (_seen && abs(_dx) < 170 && abs(_dy) < 110) { state = "peek"; timer = 22; facing = sign(_dx); if (facing == 0) facing = 1; _g.play_sfx(_g.sfx.flap); }
        else if (timer <= 0) { state = "peek"; timer = 40; }      // just a look round
        break;

    case "peek":
        image_index = 4;
        if (timer <= 0)
        {
            if (_seen && abs(_dx) < 200 && abs(_dy) < 120)
            {
                // Out he jumps!
                facing = (_dx >= 0) ? 1 : -1;
                vx = facing * clamp(abs(_dx) / 22, 1.5, 3.4);
                vy = -8.5;
                state = "air";
                _g.play_sfx(_g.sfx.charge);
                _g.burst(x, y + 10, make_colour_rgb(70, 170, 70), 10);
            }
            else { state = "hide"; timer = 120 + irandom(120); }
        }
        break;

    case "air":
        image_index = 2;
        if (on_ground && vy >= 0) { state = "walk"; timer = 20; vx = 0; }
        break;

    case "walk":
        image_index = (_g.frame div 8) mod 2;
        if (_seen && abs(_dx) > 4) facing = sign(_dx);
        vx = facing * 1.5;
        // He won't walk off a ledge (he leaps instead).
        if (on_ground && !is_blocking(tile_at(x + facing * (hw + 6), y + hh + 6))) vx = 0;
        if (_seen && abs(_dx) < 44 && abs(_dy) < 30 && timer <= 0)
        {
            state = "slash";
            timer = 18;
            vx = 0;
            _g.play_sfx(_g.sfx.snip);
        }
        else if (_seen && on_ground && leap_cd <= 0 && abs(_dx) > 70 && abs(_dx) < 190 && abs(_dy) < 140)
        {
            vx = facing * clamp(abs(_dx) / 24, 2, 3.6);
            vy = -8 - max(0, -_dy) / 20;
            state = "air";
            leap_cd = 110 + irandom(60);
        }
        break;

    case "slash":
        image_index = 3;
        vx = 0;
        if (timer <= 0) { state = "walk"; timer = 24; }
        break;
}

if (state != "hide" && state != "peek")
{
    vy = min(vy + 0.45, 9);
    var _keep = vx;
    entity_move();
    if (state == "air") vx = _keep;
    if (y > _g.lvl_h * TILE + 64) instance_destroy();
}
