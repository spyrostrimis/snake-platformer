/// Draws the level's speed blocks (T_SPEED in the grid), the ones in this view. They glow
/// a little, so they stand out from the ground.
var _g = obj_game;
var _cam = view_camera[view_current];
var _x1 = max(0, floor(camera_get_view_x(_cam) / TILE));
var _y1 = max(0, floor(camera_get_view_y(_cam) / TILE));
var _x2 = min(_g.lvl_w - 1, _x1 + ceil(camera_get_view_width(_cam) / TILE) + 1);
var _y2 = min(_g.lvl_h - 1, _y1 + ceil(camera_get_view_height(_cam) / TILE) + 1);
var _glow = 0.75 + 0.25 * sin(_g.frame * 0.12);
for (var _tx = _x1; _tx <= _x2; _tx++)
{
    for (var _ty = _y1; _ty <= _y2; _ty++)
    {
        if (_g.grid[_tx][_ty] == T_SPEED) draw_sprite_ext(spr_speedblock, 0, _tx * TILE, _ty * TILE, 1, 1, 0, merge_colour(c_white, make_colour_rgb(255, 200, 120), 1 - _glow), 1);
    }
}
