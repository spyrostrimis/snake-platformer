// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") { image_index = 2; exit; }

switch (state)
{
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
