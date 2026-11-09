// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") { image_index = 0; exit; }
t += 0.04;
timer--;
x = home_x + sin(t) * 18;
y = home_y + sin(t * 1.6) * 10;
var _p = instance_nearest(x, y, obj_player);
if (_p != noone && abs(_p.x - x) > 4) facing = (_p.x >= x) ? 1 : -1;

switch (state)
{
    case "idle":
        image_index = (_g.frame div 16) mod 2;
        if (timer <= 0 && _p != noone && !_p.hidden && point_distance(x, y, _p.x, _p.y) < 260)
        {
            state = "puff";
            timer = 22;
        }
        else if (timer <= 0) timer = 20;
        break;

    case "puff":
        image_index = 2;
        if (timer <= 0)
        {
            // Squirts a blob of ink straight at the snake.
            if (_p != noone)
            {
                var _dir = point_direction(x, y, _p.x, _p.y);
                var _h = instance_create_layer(x + facing * 20, y + 8, "Instances", obj_hazard);
                _h.sprite_index = spr_ink;
                _h.vx = lengthdir_x(3.4, _dir);
                _h.vy = lengthdir_y(3.4, _dir);
                _h.spin = false;
                _h.life = 120;
                _h.net_id = _g.net_next_id++;
                _g.play_sfx(_g.sfx.slurp);
            }
            state = "idle";
            timer = 110 + irandom(50);
        }
        break;
}
