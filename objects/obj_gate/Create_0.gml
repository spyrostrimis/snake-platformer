/// A gate of sharpened logs blocking the way, rows tiles tall (set by the level), standing in
/// the tile column under it with its foot on the floor at y. Walking up to it, the snake says
/// "THE PATH IS BLOCKED!". A switch (obj_switch) opens it: the logs slide up out of the way.
image_speed = 0;
depth = layer_get_depth(layer) + 5;     // behind the snakes (and what they say)
open = false;
lift = 0;               // how far the logs have slid up (pixels)
warn_frame = 0;
gtx = floor(x / TILE);
bottom_ty = floor((y - 1) / TILE);
top_ty = bottom_ty - rows + 1;
for (var _ty = top_ty; _ty <= bottom_ty; _ty++) obj_game.grid[gtx][_ty] = T_SOLID;

/// The switch was pulled: the way is free (the logs slide up).
open_gate = function()
{
    if (open) return;
    open = true;
    var _g = obj_game;
    for (var _ty = top_ty; _ty <= bottom_ty; _ty++) _g.grid[gtx][_ty] = T_EMPTY;
    _g.play_sfx(_g.sfx.smash);
    _g.shake(10);
    _g.say("THE GATE IS OPEN!", 150);
};
