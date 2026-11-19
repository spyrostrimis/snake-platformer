var _g = obj_game;
if (_g.state != "play") exit;
if (open)
{
    lift = min(lift + 4, rows * TILE + 40);
    if (lift < rows * TILE && _g.frame mod 4 == 0) part_particles_create(_g.ps, x + random_range(-18, 18), (bottom_ty + 1) * TILE - 4, _g.pt_dust, 1);
    exit;
}
// A snake walks up to it: "The path is blocked!", and what it takes.
with (obj_player)
{
    if (remote || hidden || abs(x - other.x) > 64 || y < other.top_ty * TILE || _g.frame < other.warn_frame) continue;
    other.warn_frame = _g.frame + 420;
    talk = "THE PATH IS BLOCKED!";
    talk_t = 150;
    _g.say("THE PATH IS BLOCKED!", 120, stats);
    _g.say("SNUG-ATTACK THROUGH THE SPEED BLOCKS AND PULL THE SWITCH!", 240, stats);
}
