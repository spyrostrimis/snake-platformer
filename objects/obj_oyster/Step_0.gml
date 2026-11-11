// The shell is armour while it's shut (both PCs work this out from the frame).
boost_only = armoured();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") { image_index = 0; exit; }
timer--;
var _p = instance_nearest(x, y, obj_player);
var _near = _p != noone && !_p.hidden && abs(_p.x - x) < 260 && abs(_p.y - y) < 140;
if (_p != noone) facing = (_p.x >= x) ? 1 : -1;

switch (state)
{
    case "shut":
        image_index = 0;
        if (timer <= 0 && _near) { state = "peek"; timer = 16; }
        else if (timer <= 0) timer = 20;
        break;

    case "peek":
        image_index = 1;
        if (timer <= 0) { state = "open"; timer = 34; }
        break;

    case "open":
        // The pearl shows: the moment to strike.
        image_index = 2;
        if (timer <= 0)
        {
            // Spits the pearl in an arc that comes down near the snake.
            var _tx = (_p != noone) ? _p.x : x + facing * 120;
            var _dx = clamp(_tx - x, -220, 220);
            var _h = instance_create_layer(x, y - 6, "Instances", obj_hazard);
            _h.sprite_index = spr_pearl;
            _h.vx = _dx / 42;
            _h.vy = -6.3;
            _h.grav = 0.3;
            _h.life = 160;
            _h.net_id = _g.net_next_id++;
            _g.play_sfx(_g.sfx.throw_);
            state = "spat";
            timer = 40;
        }
        break;

    case "spat":
        image_index = 3;
        if (timer <= 0) { state = "snap"; timer = 14; _g.play_sfx(_g.sfx.snap); }
        break;

    case "snap":
        image_index = 4;
        if (timer <= 0) { state = "shut"; timer = 90 + irandom(60); }
        break;
}

// A snake walking right up to it on the sand makes it snap shut at once (one dropping onto
// it from above still gets its stomp in).
if ((state == "peek" || state == "open" || state == "spat") && _p != noone && _p.on_ground && abs(_p.x - x) < 30 && abs(_p.y - y) < 24)
{
    state = "snap";
    timer = 20;
    _g.play_sfx(_g.sfx.snap);
}
