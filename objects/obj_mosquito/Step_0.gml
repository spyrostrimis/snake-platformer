// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") exit;
timer--;
var _p = instance_nearest(x, y, obj_player);
var _seen = _p != noone && !_p.hidden && point_distance(x, y, _p.x, _p.y) < 240;
var _wings = (_g.frame div 2) mod 2;

switch (state)
{
    case "hover":
        t += 0.05;
        x = home_x + sin(t) * 36;
        y = home_y + sin(t * 2.3) * 10;
        image_index = _wings;
        facing = (cos(t) >= 0) ? 1 : -1;
        if (_seen) facing = (_p.x >= x) ? 1 : -1;
        if (timer <= 0 && _seen)
        {
            state = "aim";
            timer = 30;
            _g.play_sfx(_g.sfx.buzz);
        }
        else if (timer <= 0) timer = 20;
        break;

    case "aim":
        // Hangs still, needle pointed: the warning.
        image_index = 2;
        x += irandom_range(-1, 1);
        if (_p != noone) { dive_dir = point_direction(x, y, _p.x, _p.y); facing = (_p.x >= x) ? 1 : -1; }
        if (timer <= 0)
        {
            state = "dive";
            timer = 34;
            vx = lengthdir_x(5, dive_dir);
            vy = lengthdir_y(5, dive_dir);
        }
        break;

    case "dive":
        image_index = 2;
        x += vx;
        y += vy;
        // Stops short of the ground and walls.
        if (timer <= 0 || is_blocking(tile_at(x + sign(vx) * 18, y)) || is_blocking(tile_at(x, y + sign(vy) * 16)))
        {
            state = "back";
            timer = 0;
        }
        break;

    case "back":
        // Flies back to its spot.
        image_index = _wings;
        var _hx = home_x + sin(t) * 36;
        var _d = point_distance(x, y, _hx, home_y);
        facing = (_hx >= x) ? 1 : -1;
        if (_d < 3) { state = "hover"; timer = 70 + irandom(50); }
        else
        {
            var _a = point_direction(x, y, _hx, home_y);
            x += lengthdir_x(min(1.8, _d), _a);
            y += lengthdir_y(min(1.8, _d), _a);
        }
        break;
}
