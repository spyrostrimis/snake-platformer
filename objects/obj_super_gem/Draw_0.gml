/// A golden glow and twinkles round it, then the gem, spinning like the little ones.
var _g = obj_game;
var _pulse = 0.5 + 0.5 * sin(_g.frame * 0.1);
draw_set_colour(make_colour_rgb(255, 210, 90));
draw_set_alpha(0.18 + 0.14 * _pulse);
draw_circle(x, y, 22 + _pulse * 4, false);
draw_set_alpha(1);
for (var _k = 0; _k < 3; _k++)
{
    var _a = _g.frame * 2 + _k * 120;
    var _tx = x + lengthdir_x(20, _a);
    var _ty = y + lengthdir_y(20, _a);
    draw_set_colour(c_white);
    draw_line_width(_tx - 3, _ty, _tx + 3, _ty, 1.5);
    draw_line_width(_tx, _ty - 3, _tx, _ty + 3, 1.5);
}
draw_sprite_ext(sprite_index, 0, x, y, cos(bob * 1.5), 1, 0, c_white, 1);
