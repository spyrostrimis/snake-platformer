// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") exit;

var _p = instance_nearest(x, y, obj_player);
if (snap_t > 0)
{
    // Claws up, snapping.
    snap_t--;
    vx = 0;
    image_index = 2;
}
else
{
    if (_p != noone && abs(_p.x - x) < 70 && abs(_p.y - y) < 40 && irandom(30) == 0)
    {
        snap_t = 36;
        facing = (_p.x >= x) ? 1 : -1;
        _g.play_sfx(_g.sfx.snap);
    }
    vx = facing * walk_speed;
    image_index = (_g.frame div 7) mod 2;
}
vy = min(vy + 0.4, 8);
entity_move();
if (hit_wall != 0) facing = -facing;
// Turn round rather than walk off the edge.
if (on_ground)
{
    var _ahead = tile_at(x + facing * (hw + 2), y + hh + 6);
    if (!is_blocking(_ahead) && _ahead != T_ONEWAY) facing = -facing;
}
