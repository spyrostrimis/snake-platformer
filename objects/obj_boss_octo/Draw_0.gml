/// Eight rubbery arms (stretching out when he strikes), a cutlass in each, then his body.
var _flash = hurt_t > 0 && (hurt_t div 4) mod 2 == 0;
if (_flash) gpu_set_fog(true, c_white, 0, 0);
var _f = floor(image_index);
var _wobble = obj_game.frame * 0.25;
var _hands = [];
for (var _k = 0; _k < 8; _k++)
{
    var _h = arm_hand(_k);
    _hands[_k] = _h;
    var _bx = x + facing * arm_bx[_k];
    var _by = y + arm_by[_k];
    var _len = point_distance(_bx, _by, _h[0], _h[1]);
    // A curve from the base to the hand: it sags a little, and ripples when it's long.
    var _dx = (_h[0] - _bx) / max(1, _len);
    var _dy = (_h[1] - _by) / max(1, _len);
    var _bend = min(16, _len * 0.22);
    var _px = _bx;
    var _py = _by;
    var _steps = clamp(round(_len / 14), 4, 24);
    for (var _s = 1; _s <= _steps; _s++)
    {
        var _t = _s / _steps;
        var _off = sin(_t * pi) * _bend + ((_len > 120) ? sin(_t * 9 - _wobble + _k) * 4 * sin(_t * pi) : 0);
        var _qx = lerp(_bx, _h[0], _t) - _dy * _off * facing;
        var _qy = lerp(_by, _h[1], _t) + abs(_dx) * _off;
        var _w = lerp(9, 6, _t);
        draw_set_colour(make_colour_rgb(42, 8, 20));
        draw_line_width(_px, _py, _qx, _qy, _w + 3);
        draw_circle(_qx, _qy, (_w + 3) / 2, false);
        draw_set_colour(make_colour_rgb(184, 74, 106));
        draw_line_width(_px, _py, _qx, _qy, _w);
        draw_circle(_qx, _qy, _w / 2, false);
        _px = _qx;
        _py = _qy;
    }
}
draw_set_colour(c_white);
for (var _k = 0; _k < 8; _k++) draw_sprite_ext(spr_cutlass, 0, _hands[_k][0], _hands[_k][1], 1, 1, _hands[_k][2], c_white, 1);
draw_sprite_ext(sprite_index, image_index, x, y, facing, 1, 0, c_white, 1);
if (_flash) gpu_set_fog(false, c_white, 0, 0);
