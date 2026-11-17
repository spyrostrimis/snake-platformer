/// A boxy egg in a cream shell with spots in the snake's colour; the snake's sleepy face
/// shows on the front, little Zs float up, and every hit leaves a crack.
if (broken) exit;
var _g = obj_game;
var _sk = skin_of();

// A wobble now and then (to catch the eye), and a harder one after a hit.
var _w = 0;
if (shake_t > 0) _w = sin(shake_t * 1.6) * 3;
else if ((_g.frame + pid * 60) mod 140 < 16) _w = sin(_g.frame * 0.8) * 1.5;
var _cx = x + _w;
var _top = y - 26;
var _bot = y + 12;

// Shadow, shell, outline.
draw_set_alpha(0.35);
draw_set_colour(c_black);
draw_ellipse(x - 16, _bot - 3, x + 16, _bot + 3, false);
draw_set_alpha(1);
var _cream = make_colour_rgb(255, 244, 214);
var _shade = make_colour_rgb(226, 206, 168);
draw_roundrect_colour_ext(_cx - 16, _top, _cx + 16, _bot, 14, 18, _cream, _shade, false);
draw_set_colour(make_colour_rgb(70, 50, 40));
draw_roundrect_ext(_cx - 16, _top, _cx + 16, _bot, 14, 18, true);

// Spots in the snake's colour.
draw_set_colour(_sk.colour);
draw_circle(_cx - 9, _top + 9, 3, false);
draw_circle(_cx + 10, _top + 13, 2.5, false);
draw_circle(_cx - 11, _bot - 9, 2.5, false);
draw_circle(_cx + 9, _bot - 6, 3, false);

// The sleepy face (eyes shut).
draw_sprite_ext(_sk.head, 1, _cx, y - 5, 0.55, 0.55, 0, c_white, 1);

// Cracks: one more for every hit.
draw_set_colour(make_colour_rgb(90, 60, 40));
if (hits >= 1)
{
    draw_line_width(_cx - 4, _top + 1, _cx - 1, _top + 8, 1.5);
    draw_line_width(_cx - 1, _top + 8, _cx - 6, _top + 13, 1.5);
}
if (hits >= 2)
{
    draw_line_width(_cx + 15, y - 4, _cx + 9, y - 1, 1.5);
    draw_line_width(_cx + 9, y - 1, _cx + 12, y + 5, 1.5);
}

// Zs drifting up, and which player is inside.
var _zt = (_g.frame mod 90) / 90;
hud_text(_cx + 10 + _zt * 6, _top - 6 - _zt * 14, "Z", 0.22 + _zt * 0.1, fa_center, c_white, 1 - _zt);
hud_text(_cx, _top - 22, "P" + string(pid + 1), 0.3, fa_center, _sk.colour);
draw_set_colour(c_white);
