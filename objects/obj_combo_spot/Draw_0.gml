/// A glowing mark on the ground with arrows the way the move throws, and its name.
if (done) exit;
var _g = obj_game;
var _pulse = 0.5 + 0.5 * sin(_g.frame * 0.08);
var _col = (type == "sling") ? make_colour_rgb(255, 210, 70) : make_colour_rgb(120, 220, 255);
draw_set_alpha(0.25 + 0.25 * _pulse);
draw_set_colour(_col);
draw_ellipse(x - 26, y - 6, x + 26, y + 4, false);
draw_set_alpha(0.8);
for (var _k = 0; _k < 3; _k++)
{
    var _ax = x + dir * (34 + _k * 12 + _pulse * 4);
    draw_line_width(_ax - dir * 5, y - 8, _ax + dir * 2, y - 3, 2);
    draw_line_width(_ax + dir * 2, y - 3, _ax - dir * 5, y + 2, 2);
}
draw_set_alpha(1);
hud_text(x, y + 6, (type == "sling") ? "SLINGSHOT" : "SNUG-ATTACK", 0.2, fa_center, _col, 0.8);
draw_set_colour(c_white);
