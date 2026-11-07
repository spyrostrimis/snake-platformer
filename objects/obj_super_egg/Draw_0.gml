/// A warm glow, then the golden egg (giving a little wobble now and then) or, once hatched,
/// the open shell with its heart and a label saying which player may eat it.
var _g = obj_game;
gpu_set_blendmode(bm_add);
draw_set_colour(hatched ? make_colour_rgb(255, 80, 120) : make_colour_rgb(255, 200, 60));
draw_set_alpha(0.28 + 0.12 * sin(bob * 2));
draw_circle(x, y - 4, 24, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

var _wobble = (!hatched && sin(_g.frame * 0.03) > 0.6) ? sin(_g.frame * 0.5) * 9 : 0;
draw_sprite_ext(sprite_index, hatched ? 1 : 0, x, y, 1, 1, _wobble, c_white, 1);

if (hatched && hatcher >= 0 && array_length(_g.pl) == 2)
{
    var _for = 1 - hatcher;
    hud_text(x, y - 44, "P" + string(_for + 1), 0.4, fa_center, _g.pl[_for].skin.colour);
}
