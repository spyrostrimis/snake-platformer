// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") { image_index = 4; exit; }
timer--;
var _p = instance_nearest(x, y, obj_player);
var _near = _p != noone && !_p.hidden && abs(_p.y - y) < 160;

switch (state)
{
    case "under":
        image_index = 4;
        if (!_near || abs(_p.x - x) > 400) { timer = max(timer, 20); break; }
        // The mound creeps towards the snake...
        var _dir = (_p.x >= x) ? 1 : -1;
        facing = _dir;
        var _can_go = floor_ahead(_dir);
        if (abs(_p.x - x) > 40 && _can_go) x += _dir * 0.9;
        if (_g.frame mod 8 == 0) part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 1);
        // ...and pops out a little way from it (or where it is, if a wall or a drop is in the way).
        if (timer <= 0 && (abs(_p.x - x) < 150 || !_can_go))
        {
            state = "pop";
            timer = 20;
            _g.play_sfx(_g.sfx.flap);
            part_particles_create(_g.ps, x, y + hh, _g.pt_rock, 5);
        }
        break;

    case "pop":
        image_index = 2;
        if (timer <= 0) { state = "walk"; timer = 160 + irandom(100); }
        break;

    case "walk":
        image_index = (_g.frame div 7) mod 2;
        if (_near && abs(_p.x - x) > 6) facing = (_p.x >= x) ? 1 : -1;
        // It won't walk off a ledge: it waits at the edge instead.
        vx = floor_ahead(facing) ? facing * walk_speed : 0;
        vy = min(vy + 0.4, 8);
        entity_move();
        if (timer <= 0) { state = "dig"; timer = 20; vx = 0; }
        break;

    case "dig":
        image_index = 3;
        if (_g.frame mod 4 == 0) part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 1);
        if (timer <= 0) { state = "under"; timer = 70 + irandom(80); }
        break;
}
