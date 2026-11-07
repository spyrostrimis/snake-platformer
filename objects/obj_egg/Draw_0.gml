/// The egg with its face; its dark outline makes it stand out. Every few seconds it gives
/// a little hop with a wiggle and a twinkle, to catch the eye.
var _g = obj_game;

var _t = (_g.frame + hop_offset) mod 150;
var _hopping = _t < 18;
var _lift = _hopping ? -sin(_t / 18 * pi) * 7 : 0;
var _tilt = _hopping ? sin(_t / 18 * pi * 2) * 10 : 0;
draw_sprite_ext(sprite_index, image_index, x, y + _lift, 1, 1, _tilt, c_white, 1);

// The twinkle: a little white four-point star by its top, growing and fading.
if (_t >= 6 && _t < 30)
{
    var _s = sin((_t - 6) / 24 * pi) * 6;
    var _sx = x + 11;
    var _sy = y - 15 + _lift;
    draw_set_colour(c_white);
    draw_triangle(_sx - _s, _sy, _sx + _s, _sy, _sx, _sy - _s * 0.25, false);
    draw_triangle(_sx - _s, _sy, _sx + _s, _sy, _sx, _sy + _s * 0.25, false);
    draw_triangle(_sx, _sy - _s, _sx, _sy + _s, _sx - _s * 0.25, _sy, false);
    draw_triangle(_sx, _sy - _s, _sx, _sy + _s, _sx + _s * 0.25, _sy, false);
}
