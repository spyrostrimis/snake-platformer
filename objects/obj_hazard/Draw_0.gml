// A missile on its way down: a pulsing red mark on the ground below shows where it lands.
if (sprite_index == spr_missile && abs(angle_difference(image_angle, 270)) < 30)
{
    var _fy = y;
    var _n = 0;
    while (_n < 30 && !is_blocking(tile_at(x, _fy))) { _fy += TILE; _n++; }
    if (_n < 30)
    {
        _fy = floor(_fy / TILE) * TILE;
        var _pulse = 0.5 + 0.5 * sin(obj_game.frame * 0.4);
        draw_set_colour(make_colour_rgb(230, 30, 30));
        draw_set_alpha(0.35 + 0.35 * _pulse);
        draw_ellipse(x - 16, _fy - 5, x + 16, _fy + 3, false);
        draw_set_alpha(1);
        draw_line_width(x - 9, _fy - 6, x + 9, _fy + 4, 2);
        draw_line_width(x + 9, _fy - 6, x - 9, _fy + 4, 2);
        draw_set_colour(c_white);
    }
}
// The whirlwind spins (its frames turn with the game's clock, the same on both PCs).
var _f = (sprite_index == spr_whirl) ? (obj_game.frame div 4) mod 3 : 0;
draw_sprite_ext(sprite_index, _f, x, y, 1, 1, image_angle, c_white, 1);
