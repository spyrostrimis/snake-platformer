/// A tunnel in the cave wall that sends boulders rolling out to the left while a snake is
/// on the way towards it. A boulder rolls on until it drops off a cliff (or smashes into a
/// wall). Jump over them, or boost into one to smash it. Not a creature.
/// The boulders are projectiles (obj_hazard with roll = true), so online the joiner sees
/// the host's. The tunnel itself is drawn behind everything, on the decoration layer.
image_speed = 0;
timer = 40;
period = 190;           // frames between boulders
rumble = 0;             // the warning before one comes out
roll_speed = 3.2;
var _deco = layer_get_id("Deco");
if (_deco != -1) layer_sprite_create(_deco, x, y, spr_tunnel_mouth);
