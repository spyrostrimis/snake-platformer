// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") { image_index = 2; exit; }

switch (state)
{
    case "swim":
        // Deep water: cruises about its home; chases a snake nearby; lunges when close.
        t += 0.03;
        if (rest > 0) rest--;
        var _p = instance_nearest(x, y, obj_player);
        var _tx = home_x + sin(t) * 60;
        var _ty = home_y + sin(t * 1.7) * 20;
        var _sp = 1.1;
        if (_p != noone && !_p.hidden && point_distance(x, y, _p.x, _p.y) < 230 && point_distance(home_x, home_y, _p.x, _p.y) < 320)
        {
            _tx = _p.x;
            _ty = _p.y;
            _sp = 1.7;
            if (rest == 0 && point_distance(x, y, _p.x, _p.y) < 100)
            {
                state = "lunge";
                lunge_t = 20;
                var _dir = point_direction(x, y, _p.x, _p.y);
                vx = lengthdir_x(5, _dir);
                vy = lengthdir_y(5, _dir);
                _g.play_sfx(_g.sfx.snip);
                break;
            }
        }
        var _d = point_direction(x, y, _tx, _ty);
        var _nx = x + lengthdir_x(_sp, _d);
        var _ny = y + lengthdir_y(_sp, _d);
        if (water_at(_nx, _ny) && !is_blocking(tile_at(_nx, _ny))) { x = _nx; y = _ny; }
        if (abs(_tx - x) > 2) facing = (_tx > x) ? 1 : -1;
        image_index = 0;
        break;

    case "lunge":
        image_index = 1;
        lunge_t--;
        var _lx = x + vx;
        var _ly = y + vy;
        if (water_at(_lx, _ly) && !is_blocking(tile_at(_lx, _ly))) { x = _lx; y = _ly; } else lunge_t = 0;
        if (vx != 0) facing = sign(vx);
        if (lunge_t <= 0) { state = "swim"; rest = 70; }
        break;

    case "under":
        image_index = 2;
        y = home_y + 6;
        timer--;
        var _p = instance_nearest(x, y, obj_player);
        if (_p == noone || _p.hidden || abs(_p.x - x) > 300 || _p.y > home_y + 40) { timer = max(timer, 15); break; }
        // Follows the snake from below, but stays in its lake.
        var _to = (_p.x > x + 4) ? 1 : ((_p.x < x - 4) ? -1 : 0);
        if (_to != 0)
        {
            facing = _to;
            if (water_at(x + _to * 14, home_y + 8)) x += _to * 1.3;
        }
        if (timer <= 0 && abs(_p.x - x) < 110)
        {
            // The leap: high enough to catch a snake jumping over the lake.
            state = "leap";
            vy = -9.5 - random(1.5);
            vx = clamp((_p.x - x) / 30, -2.5, 2.5);
            if (vx != 0) facing = sign(vx);
            _g.burst(x, home_y, make_colour_rgb(170, 230, 255), 8);
            _g.play_sfx(_g.sfx.splash);
        }
        break;

    case "leap":
        x += vx;
        vy += 0.38;
        y += vy;
        // Jaws open while it's near the top of the leap or close to a snake.
        var _q = instance_nearest(x, y, obj_player);
        image_index = (abs(vy) < 3.5 || (_q != noone && point_distance(x, y, _q.x, _q.y) < 50)) ? 1 : 0;
        if (vy > 0 && y >= home_y + 6)
        {
            y = home_y + 6;
            state = "under";
            timer = 60 + irandom(80);
            _g.burst(x, home_y, make_colour_rgb(170, 230, 255), 8);
            _g.play_sfx(_g.sfx.splash);
        }
        break;
}
