/// The pirate ship afloat off Sunset Shore, with THE BOMBARD on its deck. y is the waterline.
/// The level sets hull ([x1, y1, x2, y2] tiles: solid while it floats, so it's a wall in the
/// sea and its deck can be stood on) and door_tx, door_ty (where the exit shows once it sinks).
/// Once the bombard is beaten it sinks, and the way past it to the exit is clear.
image_speed = 0;
sinking = false;
sink_t = 0;
door_made = false;
boss_seen = false;
for (var _tx = hull[0]; _tx <= hull[2]; _tx++)
    for (var _ty = hull[1]; _ty <= hull[3]; _ty++) obj_game.grid[_tx][_ty] = T_SOLID;
