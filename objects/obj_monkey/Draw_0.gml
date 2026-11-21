/// Mango (his art faces right), with his rock in front of him while he hides behind it, and the
/// heart from his kiss.
var _f = floor(image_index);
var _shake = (_f == 4) ? sin(obj_game.frame * 1.3) * 1.2 : 0;     // trembling with fear
draw_sprite_ext(sprite_index, _f, x + _shake, y, facing, 1, 0, c_white, 1);
if (_f <= 2 || _f == 4) draw_sprite(spr_hide_rock, 0, x + facing * 4, y + 2);
if (_f == 5 && heart_t > 0)
{
    var _a = clamp(1 - (heart_t - 40) / 40, 0, 1);
    var _s = min(1.6, 0.6 + heart_t * 0.03);
    draw_sprite_ext(spr_heart, 0, x + facing * 16 + sin(heart_t * 0.15) * 4, y - 70 - heart_t * 0.7, _s, _s, 0, c_white, _a);
}
