// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") { image_index = 0; exit; }   // on the title screen they just hang
t += 0.15;

switch (state)
{
    case "hang":
        image_index = 0;
        if (rest > 0) { rest--; break; }
        // Wakes when a snake comes close below it.
        var _near = noone;
        var _best = 9999;
        with (obj_player)
        {
            if (!hidden && y > other.y && y - other.y < 230 && abs(x - other.x) < 130 && abs(x - other.x) < _best)
            {
                _best = abs(x - other.x);
                _near = id;
            }
        }
        if (_near != noone)
        {
            state = "swoop";
            target = _near;
            timer = 160;
            _g.play_sfx(_g.sfx.flap);
        }
        break;

    case "swoop":
        // Dives at the snake in a wobbly line.
        image_index = 1 + (_g.frame div 5) mod 2;
        timer--;
        if (!instance_exists(target) || target.hidden || timer <= 0) { state = "return"; break; }
        var _dir = point_direction(x, y, target.x, target.y - 4);
        x += lengthdir_x(2.7, _dir);
        y += lengthdir_y(2.7, _dir) + sin(t) * 1.2;
        facing = (target.x >= x) ? 1 : -1;
        break;

    case "return":
        image_index = 1 + (_g.frame div 5) mod 2;
        var _d = point_distance(x, y, roost_x, roost_y);
        if (_d < 3)
        {
            x = roost_x;
            y = roost_y;
            state = "hang";
            rest = 90;
            break;
        }
        var _back = point_direction(x, y, roost_x, roost_y);
        x += lengthdir_x(min(2.2, _d), _back);
        y += lengthdir_y(min(2.2, _d), _back);
        facing = (roost_x >= x) ? 1 : -1;
        break;
}
