// Her tentacles sting this PC's snake (online too: both PCs see her position).
if (obj_game.state == "play") tentacle_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play") exit;

var _g = obj_game;
t += 0.05;
if (floor_y < 0)
{
    // The sea floor below her: she never sinks into it.
    var _ty = floor(y / TILE);
    while (_ty < _g.lvl_h && !is_blocking(grid_type(floor(x / TILE), _ty))) _ty++;
    floor_y = _ty * TILE;
    home_y = y;
}
var _top = 4 * TILE + hh;
var _low = floor_y - hh - 24;
if (!active)
{
    image_index = (_g.frame div 24) mod 2;
    y = home_y + sin(t) * 10;
    exit;
}
var _angry = hp <= hp_max / 2;
timer--;

// Every hit: she reels, crackling (don't land on her now), then drifts on.
if (hp < last_hp)
{
    last_hp = hp;
    hurt_t = max(hurt_t, 70);
    state = "recoil";
    timer = 30;
    _g.play_sfx(_g.sfx.charge);
}

var _p = instance_nearest(x, y, obj_player);
switch (state)
{
    case "drift":
        // Floats to a spot above the nearest snake, bobbing.
        image_index = (_g.frame div 18) mod 2;
        if (_p != noone)
        {
            var _sp = _angry ? 1.7 : 1.2;
            x = approach(x, _p.x, _sp);
            y = approach(y, clamp(_p.y - 190, _top, _low), _sp * 0.8);
        }
        y += sin(t * 2) * 0.6;
        if (timer <= 0)
        {
            var _broods = 0;
            with (obj_jelly) if (seeker) _broods++;
            var _r = irandom(99);
            if (_r < (_angry ? 62 : 52)) { state = "charge"; timer = _angry ? 28 : 40; nova_kind = irandom(3); _g.play_sfx(_g.sfx.charge); }
            else if (_r < 82 || _broods >= 3) { state = "rise"; timer = 18; }
            else { state = "brood"; timer = 30; }
        }
        break;

    case "charge":
        // Glowing, sparks crackling round her: the nova is coming.
        image_index = 2;
        x += irandom_range(-1, 1);
        if (timer <= 0)
        {
            // A different burst each time.
            nova_off = random(360);
            switch (nova_kind)
            {
                case 0: spark_nova(_angry ? 12 : 9, _angry ? 3.6 : 3, nova_off); break;
                case 1: spark_nova(_angry ? 10 : 8, _angry ? 3.4 : 2.9, nova_off, choose(-1.4, 1.4)); break;
                case 2: spark_fan(_p, _angry ? 7 : 5, _angry ? 80 : 60, _angry ? 4.4 : 3.8); break;
                case 3: spark_nova(_angry ? 10 : 8, _angry ? 3.4 : 2.8, nova_off); break;
            }
            _g.play_sfx(_g.sfx.smash);
            _g.shake(10);
            state = "nova";
            timer = 26;
        }
        break;

    case "nova":
        image_index = 3;
        // Two rings: the second one a moment later, its sparks in the gaps of the first.
        if (nova_kind == 3 && timer == 13) { spark_nova(_angry ? 10 : 8, _angry ? 3.4 : 2.8, nova_off + 180 / (_angry ? 10 : 8)); _g.play_sfx(_g.sfx.smash); }
        if (timer <= 0) { state = "drift"; timer = _angry ? 42 : 62; }
        break;

    case "rise":
        // Draws herself up...
        image_index = 1;
        y = max(_top, y - 1.6);
        if (timer <= 0)
        {
            // ...and plunges at the snake.
            var _dir = (_p != noone) ? point_direction(x, y, _p.x, _p.y - 30) : 270;
            var _sp = _angry ? 7.5 : 6.5;
            dive_dx = lengthdir_x(_sp, _dir);
            dive_dy = lengthdir_y(_sp, _dir);
            state = "dive";
            timer = 34;
            _g.play_sfx(_g.sfx.jump);
        }
        break;

    case "dive":
        image_index = 4;
        x += dive_dx;
        y += dive_dy;
        if (y >= _low) { y = _low; timer = 0; }
        if (timer <= 0) { state = "recover"; timer = 40; }
        break;

    case "recover":
        image_index = 0;
        y = max(_top, y - 1.4);
        if (timer <= 0) { state = "drift"; timer = _angry ? 50 : 70; }
        break;

    case "brood":
        // Lets out two little jellyfish that drift after the snakes.
        image_index = 1;
        if (timer == 15)
        {
            for (var _s = -1; _s <= 1; _s += 2)
            {
                var _j = instance_create_layer(x + _s * 40, y + hh + 20, "Instances", obj_jelly);
                _j.seeker = true;
                _j.timer = 60 + irandom(40);
                _j.net_id = _g.net_next_id++;
            }
            _g.play_sfx(_g.sfx.pop);
        }
        if (timer <= 0) { state = "drift"; timer = 70; }
        break;

    case "recoil":
        image_index = 5;
        if (timer <= 0) { state = "drift"; timer = 50; }
        break;
}
y = clamp(y, _top, _low);
