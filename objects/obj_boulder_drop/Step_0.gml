var _g = obj_game;
if (_g.state != "play" || _g.net_mode == "client") exit;

if (rumble > 0)
{
    // A rumble and dust from the tunnel: a boulder is coming.
    rumble--;
    if (_g.frame mod 4 == 0) part_particles_create(_g.ps, x + irandom_range(-26, 26), y - 66 + irandom(8), _g.pt_dust, 1);
    if (rumble == 0)
    {
        var _h = instance_create_layer(x, y - 17, "Instances", obj_hazard);
        _h.sprite_index = spr_boulder;
        _h.roll = true;
        _h.vx = -roll_speed;
        _h.spin = false;
        _h.net_id = _g.net_next_id++;
        _g.play_sfx(_g.sfx.smash);
    }
    exit;
}
if (--timer > 0) exit;
// Only while a snake is in front of the tunnel (to its left), not too far, about level with it.
var _go = false;
with (obj_player) if (!hidden && x < other.x - 90 && other.x - x < 640 && abs(y - other.y) < 220) _go = true;
if (_go)
{
    rumble = 40;
    timer = period + irandom(60);
}
else timer = 15;
