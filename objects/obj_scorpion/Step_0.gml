// Its sting hurts this PC's snake (online too: both PCs see the same frame).
if (obj_game.state == "play") sting_check();
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
var _g = obj_game;
if (_g.state != "play") exit;

if (sting_cd > 0) sting_cd--;
var _p = instance_nearest(x, y, obj_player);
if (sting_t > 0)
{
    // Tail drawn back (walking frame held), then the strike.
    sting_t--;
    vx = 0;
    image_index = (sting_t < 14) ? 2 : 0;
    if (sting_t == 13) _g.play_sfx(_g.sfx.snip);
}
else
{
    // A snake close in front: sting it.
    if (sting_cd == 0 && _p != noone && !_p.hidden && abs(_p.y - y) < 30 && abs(_p.x - x) < 56 && sign(_p.x - x) == facing)
    {
        sting_t = 30;
        sting_cd = 70;
    }
    vx = facing * walk_speed;
    image_index = (_g.frame div 8) mod 2;
}
vy = min(vy + 0.4, 8);
entity_move();
if (hit_wall != 0) facing = -facing;
// Turn round rather than walk off the edge.
if (on_ground && vx != 0)
{
    var _ahead = tile_at(x + facing * (hw + 2), y + hh + 6);
    if (!is_blocking(_ahead) && _ahead != T_ONEWAY) facing = -facing;
}
// A snake right behind it: it turns round.
if (sting_t == 0 && _p != noone && abs(_p.y - y) < 30 && abs(_p.x - x) < 40 && sign(_p.x - x) == -facing) facing = -facing;
