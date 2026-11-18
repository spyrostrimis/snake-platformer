// Its flying height, worked out the same way on both PCs.
if (!ready)
{
    ready = true;
    ground_y = y + hh;
    hover_y = ground_y - 165;
    y = hover_y;
}
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play") exit;

var _g = obj_game;
var _wings = (_g.frame div 3) mod 2;
if (!active)
{
    image_index = _wings;
    y = hover_y + sin(_g.frame * 0.05) * 8;
    exit;
}
var _angry = hp <= hp_max / 2;
timer--;
t += 0.02;

// Every hit: knocked back (unless it's lying dazed on the sand).
if (hp < last_hp)
{
    last_hp = hp;
    _g.play_sfx(_g.sfx.growl);
    if (state != "dazed") { state = "recoil"; timer = 20; vx = -facing * 4; }
}

var _p = instance_nearest(x, y, obj_player);
switch (state)
{
    case "hover":
        // Flies to and fro above the nearest snake.
        image_index = _wings;
        if (_p != noone)
        {
            facing = (_p.x >= x) ? 1 : -1;
            var _tx = clamp(_p.x + sin(t * 1.3) * 150, arena_x1 + 40, arena_x2 - 40);
            x = approach(x, _tx, _angry ? 2.8 : 2.1);
        }
        y = approach(y, hover_y + sin(t * 2) * 24, 2);
        if (_g.frame mod 50 == 0) _g.play_sfx(_g.sfx.buzz);
        if (timer <= 0)
        {
            if (irandom(99) < 55) { state = "climb"; shots = _angry ? 5 : 3; timer = 0; _g.play_sfx(_g.sfx.buzz); }
            else { state = "aim"; timer = _angry ? 26 : 36; dashes = _angry ? 2 : 1; _g.play_sfx(_g.sfx.buzz); }
        }
        break;

    case "climb":
        // Zooms straight up and off the top of the screen.
        image_index = _wings;
        y -= 7;
        if (y <= high_y) { y = high_y; state = "bomb"; timer = 30; }
        break;

    case "bomb":
        // Up out of sight, it flies over the snakes, firing straight down. Each missile is aimed
        // a little off, so standing still isn't safe and running isn't either.
        image_index = (timer mod 24 > 16) ? 2 : _wings;
        if (_p != noone)
        {
            var _bx = clamp(_p.x + _p.vx * 30 + sin(t * 5) * 40, arena_x1 - 40, arena_x2 + 40);
            if (abs(_bx - x) > 8) facing = (_bx >= x) ? 1 : -1;
            x = approach(x, _bx, _angry ? 6 : 4.5);
        }
        if (timer <= 0)
        {
            fire_missile();
            shots--;
            timer = _angry ? 20 : 26;
            if (shots <= 0) { state = "return"; timer = 40; }
        }
        break;

    case "return":
        // Waits for its last missile to land, then dives back down to the fight.
        image_index = _wings;
        if (timer <= 0)
        {
            y = approach(y, hover_y, 6);
            if (abs(y - hover_y) < 4) { state = "hover"; timer = _angry ? 50 : 80; _g.play_sfx(_g.sfx.buzz); }
        }
        break;

    case "aim":
        // Stares at a snake, eyes blazing, shaking: the warning before the dash.
        image_index = 5;
        x += irandom_range(-2, 2);
        if (_p != noone)
        {
            facing = (_p.x >= x) ? 1 : -1;
            var _dir = point_direction(x, y, _p.x, _p.y - 10);
            var _sp = _angry ? 10 : 8.5;
            dash_vx = lengthdir_x(_sp, _dir);
            dash_vy = lengthdir_y(_sp, _dir);
        }
        if (timer <= 0) { state = "dash"; timer = 60; _g.play_sfx(_g.sfx.charge); }
        break;

    case "dash":
        // Needle first at the snake, until it crashes into the sand.
        image_index = 3;
        x += dash_vx;
        y += max(dash_vy, 1.5);
        if (y >= ground_y - 50 || is_blocking(tile_at(x + sign(dash_vx) * hw, y)) || is_blocking(tile_at(x, y + hh)))
        {
            y = min(y, ground_y - 50);
            state = "dazed";
            timer = _angry ? 60 : 85;
            _g.shake(5);
            _g.play_sfx(_g.sfx.smash);
            _g.burst(x + facing * 70, y + 30, make_colour_rgb(240, 210, 140), 12);
        }
        else if (timer <= 0 || x <= arena_x1 || x >= arena_x2) { state = "rise"; timer = 0; }
        break;

    case "dazed":
        // Stuck in the sand, seeing stars: the moment to hit it.
        image_index = 4;
        if (timer <= 0)
        {
            dashes--;
            if (dashes > 0) { state = "aim"; timer = 22; }
            else state = "rise";
        }
        break;

    case "rise":
        image_index = _wings;
        y = approach(y, hover_y, 3);
        if (abs(y - hover_y) < 4) { state = "hover"; timer = _angry ? 50 : 75; }
        break;

    case "recoil":
        image_index = 4;
        x += vx;
        vx *= 0.9;
        if (timer <= 0) { vx = 0; state = "rise"; }
        break;
}
