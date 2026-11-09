// Its electric ring hurts this PC's snake (online too: both PCs see the same frame).
if (obj_game.state == "play") zap_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") { image_index = 0; exit; }
t += 0.035;
timer--;

// Drifting: a pulse up, a slow sink, round its home (a seeker drifts towards the snakes).
if (seeker)
{
    var _p = instance_nearest(x, y, obj_player);
    if (_p != noone) { home_x = approach(home_x, _p.x, 0.5); home_y = approach(home_y, _p.y, 0.4); }
}
var _nx = home_x + sin(t * 0.7) * 24;
var _ny = home_y + sin(t) * 40;
if (!is_blocking(tile_at(_nx, _ny))) { x = lerp(x, _nx, 0.08); y = lerp(y, _ny, 0.08); }

switch (state)
{
    case "calm":
        image_index = ((_g.frame div 20) mod 2);
        if (timer <= 0) { state = "flicker"; timer = 36; }
        break;

    case "flicker":
        // A warning: it flickers (the charging frame doesn't shock yet) before it lights up.
        image_index = ((_g.frame div 4) mod 2 == 0) ? 0 : 3;
        if (timer <= 0) { state = "zap"; timer = 70; _g.play_sfx(_g.sfx.charge); }
        break;

    case "zap":
        image_index = 2;
        if (_g.frame mod 6 == 0) _g.burst(x + irandom_range(-30, 30), y + irandom_range(-20, 40), make_colour_rgb(255, 240, 120), 2);
        if (timer <= 0) { state = "calm"; timer = 110 + irandom(80); }
        break;
}
