var _g = obj_game;
if (_g.state != "play" || _g.net_mode == "client") exit;
if (instance_exists(child)) exit;
if (--timer > 0) exit;
// Never right on top of a snake: wait until none is close.
var _close = false;
with (obj_player) if (!hidden && point_distance(x, y, other.x, other.y) < 100) _close = true;
if (_close) { timer = 30; exit; }

if (kind == "bat") child = instance_create_layer(x, y + 16, "Instances", obj_bat);
else child = instance_create_layer(x, y - 10, "Instances", obj_mole_kin);
child.net_id = _g.net_next_id++;
part_particles_create(_g.ps, x, y + ((kind == "bat") ? 6 : -4), _g.pt_dust, 4);
timer = regrow;
