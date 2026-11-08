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
        if (timer <= 0) { state = "walk"; timer = 45; }
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
