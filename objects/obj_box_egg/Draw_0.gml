/// A giant shiny egg in the snake's colour, a glint sliding over it and twinkles round it;
/// under a parachute while it floats down. Hatching, it cracks round the middle, the top lifts
/// off and the snake's head rises out of it.
if (broken) exit;
var _g = obj_game;
var _sk = skin_of();
var _col = _sk.colour;
var _dark = merge_colour(_col, c_black, 0.5);
var _light = merge_colour(_col, c_white, 0.45);

// A wobble now and then (to catch the eye), harder when it's hit or hatching.
var _w = 0;
if (hatching && hatch_t < 12) _w = sin(hatch_t * 2) * 3;
else if (shake_t > 0) _w = sin(shake_t * 1.6) * 3;
else if (landed && (t + pid * 60) mod 140 < 16) _w = sin(t * 0.8) * 1.5;
var _cx = x + _w;
var _cy = y - 20;           // the egg's middle (its bottom rests on the floor)

if (!landed || chute > 0) draw_parachute(_cx + sin(t * 0.05) * 3, _cy - 46 - 40 * chute, 52 * chute + 10, 28 * chute + 4, _cx, _cy - 28, 18, _col);

// Its shadow on the floor.
if (landed)
{
    draw_set_alpha(0.35);
    draw_set_colour(c_black);
    draw_ellipse(x - 22, y + 8, x + 22, y + 15, false);
    draw_set_alpha(1);
}

// The shell, in two parts split at the crack: the bottom stays; the top lifts and tips off
// when it hatches (whole, they meet). Each part is a fan from a point inside it.
var _crack_y = _cy - 8;
var _lift = hatching ? min(1, hatch_t / 20) : 0;
var _pts = egg_points(_cx, _cy);
var _n = array_length(_pts);
var _rot = _lift * 35;
var _ox = _lift * 16;
var _oy = -_lift * 30;
if (hatching)
{
    // The head rises out of the egg as the top comes off.
    var _rise = min(1, max(0, hatch_t - 12) / 20);
    draw_sprite_ext(_sk.head, ((hatch_t div 10) mod 3 == 0) ? 1 : 0, _cx, _crack_y + 8 - _rise * 22, 1, 1, sin(hatch_t * 0.3) * 6, c_white, 1);
}
for (var _part = 0; _part < 2; _part++)
{
    var _fx = _cx - 4;
    var _fy = (_part == 0) ? _cy + 8 : _cy - 18;
    if (_part == 1)
    {
        var _ddx = _fx - _cx, _ddy = _fy - _crack_y;
        _fx = _cx + _ddx * dcos(_rot) + _ddy * dsin(_rot) + _ox;
        _fy = _crack_y - _ddx * dsin(_rot) + _ddy * dcos(_rot) + _oy;
    }
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_fx, _fy, _light, 1);
    for (var _i = 0; _i <= _n; _i++)
    {
        var _p = _pts[_i mod _n];
        var _px = _p[0];
        var _py = (_part == 0) ? max(_p[1], _crack_y) : min(_p[1], _crack_y);
        if (_part == 1)
        {
            var _dx = _px - _cx, _dy = _py - _crack_y;
            _px = _cx + _dx * dcos(_rot) + _dy * dsin(_rot) + _ox;
            _py = _crack_y - _dx * dsin(_rot) + _dy * dcos(_rot) + _oy;
        }
        draw_vertex_colour(_px, _py, (_p[0] < _cx) ? _col : _dark, 1);
    }
    draw_primitive_end();
}
// Outline.
draw_set_colour(_dark);
for (var _i = 0; _i < _n && !hatching; _i++)
{
    var _a = _pts[_i];
    var _b = _pts[(_i + 1) mod _n];
    draw_line_width(_a[0], _a[1], _b[0], _b[1], 2);
}

if (!hatching)
{
    // The shine: a big soft highlight, and a glint sliding across now and then.
    draw_set_alpha(0.55);
    draw_set_colour(c_white);
    draw_ellipse(_cx - 15, _cy - 24, _cx - 4, _cy - 6, false);
    draw_set_alpha(1);
    var _gl = (t mod 120) / 120;
    if (_gl < 0.3)
    {
        var _gx = _cx - 18 + _gl / 0.3 * 36;
        draw_set_alpha(0.7 * sin(_gl / 0.3 * pi));
        draw_line_width(_gx - 4, _cy + 20, _gx + 6, _cy - 22, 3);
        draw_set_alpha(1);
    }
    // Twinkles round it.
    for (var _k = 0; _k < 3; _k++)
    {
        var _a = t * 1.5 + _k * 120;
        var _tx = _cx + lengthdir_x(34, _a);
        var _ty = _cy + lengthdir_y(38, _a);
        var _s = 2 + 2 * abs(sin(t * 0.1 + _k));
        draw_line_width(_tx - _s, _ty, _tx + _s, _ty, 1.5);
        draw_line_width(_tx, _ty - _s, _tx, _ty + _s, 1.5);
    }
    // Who's inside.
    hud_text(_cx, _cy - 52, "P" + string(pid + 1), 0.3, fa_center, _col);
}
else
{
    // The zigzag crack along the broken edge of the bottom half.
    draw_set_colour(_dark);
    for (var _k = -3; _k < 3; _k++) draw_line_width(_cx + _k * 8, _crack_y + ((_k mod 2 == 0) ? 3 : -3), _cx + (_k + 1) * 8, _crack_y + ((_k mod 2 == 0) ? -3 : 3), 2);
}
draw_set_colour(c_white);
