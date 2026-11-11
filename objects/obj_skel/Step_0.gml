// Its sword hurts this PC's snake (online too: both PCs see the same frame).
if (obj_game.state == "play") sword_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play" && _g.state != "title" && _g.state != "credits") { exit; }
timer--;

switch (state)
{
    case "walk":
        image_index = (_g.frame div 10) mod 2;
        // A snake close in front (or just behind): turn and raise the sword.
        var _p = instance_nearest(x, y, obj_player);
        // A pirate leaps at a snake a little way off (or up on a ledge) and lands on it.
        if (pirate && _g.state == "play" && timer <= 0 && on_ground && _p != noone && !_p.hidden
            && abs(_p.x - x) > 60 && abs(_p.x - x) < 190 && _p.y - y < 40 && y - _p.y < 130)
        {
            facing = (_p.x >= x) ? 1 : -1;
            state = "leap";
            vy = -9 - clamp((y - _p.y) / 40, 0, 2.5);
            vx = clamp((_p.x - x) / 36, -4, 4);
            was_airborne = false;
            _g.play_sfx(_g.sfx.jump);
            break;
        }
        if (_g.state == "play" && timer <= 0 && _p != noone && !_p.hidden && abs(_p.y - y) < 40 && abs(_p.x - x) < 80)
        {
            facing = (_p.x >= x) ? 1 : -1;
            state = "raise";
            timer = 26;
            vx = 0;
            _g.play_sfx(_g.sfx.rattle);
            break;
        }
        vx = facing * walk_speed;
        break;

    case "raise":
        vx = 0;
        image_index = 2;
        if (timer <= 0) { state = "slash"; timer = 14; _g.play_sfx(_g.sfx.throw_); }
        break;

    case "slash":
        vx = 0;
        image_index = 3;
        if (timer <= 0) { state = "walk"; timer = pirate ? 60 : 45; }
        break;

    case "leap":
        // Sword up in the air; it slashes as it lands.
        image_index = 2;
        if (!on_ground) was_airborne = true;
        else if (was_airborne && vy >= 0)
        {
            vx = 0;
            state = "slash";
            timer = 16;
            _g.play_sfx(_g.sfx.throw_);
            part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 4);
        }
        break;
}

vy = min(vy + 0.4, 8);
entity_move();
if (state == "walk")
{
    if (hit_wall != 0) facing = -facing;
    // Turn round rather than walk off the edge.
    if (on_ground)
    {
        var _ahead = tile_at(x + facing * (hw + 2), y + hh + 6);
        if (!is_blocking(_ahead) && _ahead != T_ONEWAY) facing = -facing;
    }
}
