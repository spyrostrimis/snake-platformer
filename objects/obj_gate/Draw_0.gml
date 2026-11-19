/// The logs, one piece a tile, the sharpened tops on top; slid up by lift once it's open.
if (lift >= rows * TILE + 40) exit;
for (var _k = 0; _k < rows; _k++)
{
    var _py = (top_ty + _k + 1) * TILE - lift;
    draw_sprite(sprite_index, (_k == 0) ? 1 : 0, x, _py);
}
