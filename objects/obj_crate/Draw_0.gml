/// The crate, and above it the parachute: a dome striped in the partner's colour, on strings.
if (chute > 0)
{
    var _cx = x + sin(t * 0.05 + 0.6) * 4;
    var _w = 46 * chute;
    var _cy = y - 32 - 52 * chute;
    var _h = 26 * chute;
    // Strings to the crate's top corners.
    draw_set_colour(make_colour_rgb(60, 40, 30));
    draw_line_width(_cx - _w, _cy, x - 16, y - 30, 1);
    draw_line_width(_cx - _w * 0.4, _cy + 2, x - 6, y - 30, 1);
    draw_line_width(_cx + _w * 0.4, _cy + 2, x + 6, y - 30, 1);
    draw_line_width(_cx + _w, _cy, x + 16, y - 30, 1);
    // The canopy: six panels, the snake's colour and white in turn.
    var _n = 6;
    for (var _k = 0; _k < _n; _k++)
    {
        var _a0 = 180 - _k * 180 / _n;
        var _a1 = 180 - (_k + 1) * 180 / _n;
        draw_set_colour((_k mod 2 == 0) ? skin.colour : c_white);
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(_cx, _cy);
        for (var _s = 0; _s <= 4; _s++)
        {
            var _a = lerp(_a0, _a1, _s / 4);
            draw_vertex(_cx + lengthdir_x(_w, _a), _cy + lengthdir_y(_h, _a));
        }
        draw_primitive_end();
    }
    draw_set_colour(make_colour_rgb(40, 24, 30));
    for (var _s = 0; _s < 18; _s++)
    {
        var _a = 180 - _s * 10;
        var _b = 180 - (_s + 1) * 10;
        draw_line_width(_cx + lengthdir_x(_w, _a), _cy + lengthdir_y(_h, _a), _cx + lengthdir_x(_w, _b), _cy + lengthdir_y(_h, _b), 1.5);
    }
    draw_line_width(_cx - _w, _cy, _cx + _w, _cy, 1.5);
    draw_set_colour(c_white);
}
draw_sprite(sprite_index, 0, x, y);
// The snake inside, peeking out of the stencil hole: a hint who's coming.
draw_sprite_ext(skin.head, 1, x, y - 17, 0.45, 0.45, 0, c_white, 1);
