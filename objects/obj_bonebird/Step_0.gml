// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play" && _g.state != "title" && _g.state != "credits") exit;
t += 0.025;
if (rest > 0) rest--;

switch (state)
{
    case "patrol":
        // Back and forth around its home, bobbing.
        image_index = (_g.frame div 6) mod 2;
        var _nx = home_x + sin(t) * 70;
        var _ny = home_y + sin(t * 2.3) * 10;
        if (_nx != x) facing = (_nx > x) ? 1 : -1;
        x = lerp(x, _nx, 0.2);
        y = lerp(y, _ny, 0.2);
        if (_g.state == "play" && rest == 0)
        {
            // A snake below and not far ahead: dive at it.
            var _tgt = noone;
            with (obj_player) if (!hidden && y > other.y + 20 && y - other.y < 280 && abs(x - other.x) < 170) _tgt = id;
            if (_tgt != noone)
            {
                state = "dive";
                dive_x = _tgt.x;
                dive_y = _tgt.y;
                timer = 80;
                _g.play_sfx(_g.sfx.flap);
            }
        }
        break;

    case "dive":
        image_index = 2;
        timer--;
        var _d = point_distance(x, y, dive_x, dive_y);
        var _dir = point_direction(x, y, dive_x, dive_y);
        facing = (dive_x >= x) ? 1 : -1;
        x += lengthdir_x(min(4.2, _d), _dir);
        y += lengthdir_y(min(4.2, _d), _dir);
        // Pulls up at the spot, at the floor, or after a while.
        if (_d < 4 || timer <= 0 || is_blocking(tile_at(x, y + hh + 2))) { state = "rise"; }
        break;

    case "rise":
        image_index = (_g.frame div 4) mod 2;
        var _hx = home_x + sin(t) * 70;
        var _d2 = point_distance(x, y, _hx, home_y);
        var _b = point_direction(x, y, _hx, home_y);
        facing = (_hx >= x) ? 1 : -1;
        x += lengthdir_x(min(2.2, _d2), _b);
        y += lengthdir_y(min(2.2, _d2), _b);
        if (_d2 < 4) { state = "patrol"; rest = 90; }
        break;
}
