var _g = obj_game;
var _cam = view_camera[view_current];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);
var _t = _g.frame;

// ---------- Water cells ----------
var _tx1 = max(0, floor(_cx / TILE));
var _tx2 = min(_g.lvl_w - 1, floor((_cx + _cw) / TILE));
var _ty1 = max(0, floor(_cy / TILE));
var _ty2 = min(_g.lvl_h - 1, floor((_cy + _ch) / TILE));
var _deep = make_colour_rgb(20, 90, 140);
var _shallow = make_colour_rgb(60, 170, 210);
for (var _x = _tx1; _x <= _tx2; _x++)
{
    for (var _y = _ty1; _y <= _ty2; _y++)
    {
        if (!_g.water[_x][_y] || is_blocking(_g.grid[_x][_y])) continue;
        var _px = _x * TILE;
        var _py = _y * TILE;
        var _top = _y == 0 || !_g.water[_x][_y - 1];
        if (_top)
        {
            // The surface: a wave line and a light band.
            var _w1 = sin((_px) * 0.09 + _t * 0.07) * 2;
            var _w2 = sin((_px + 32) * 0.09 + _t * 0.07) * 2;
            draw_set_alpha(0.45);
            draw_triangle_colour(_px, _py + 4 + _w1, _px + 32, _py + 4 + _w2, _px, _py + 32, _shallow, _shallow, _deep, false);
            draw_triangle_colour(_px + 32, _py + 4 + _w2, _px + 32, _py + 32, _px, _py + 32, _shallow, _deep, _deep, false);
            draw_set_alpha(0.8);
            draw_line_width_colour(_px, _py + 4 + _w1, _px + 32, _py + 4 + _w2, 2, make_colour_rgb(210, 245, 255), make_colour_rgb(210, 245, 255));
        }
        else
        {
            draw_set_alpha(0.45);
            draw_rectangle_colour(_px, _py, _px + 31, _py + 31, _deep, _deep, _deep, _deep, false);
        }
    }
}

// ---------- Currents ----------
for (var _i = 0; _i < array_length(_g.currents); _i++)
{
    var _k = _g.currents[_i];
    if (_k.x2 < _cx || _k.x1 > _cx + _cw || _k.y2 < _cy || _k.y1 > _cy + _ch) continue;
    var _w = _k.x2 - _k.x1;
    var _h = _k.y2 - _k.y1;
    var _vert = _k.vy != 0;
    // A spout or a waterfall is a column of moving water (where there's no lake already).
    if (_vert)
    {
        draw_set_alpha(0.32);
        draw_rectangle_colour(_k.x1 + 2, _k.y1, _k.x2 - 2, _k.y2, _shallow, _shallow, _deep, _deep, false);
    }
    // Streaks moving with the flow.
    draw_set_alpha(0.55);
    var _n = max(4, round(_w * _h / 700));
    var _spd = _vert ? abs(_k.vy) * 1.6 : abs(_k.vx) * 1.6 + 0.5;
    for (var _s = 0; _s < _n; _s++)
    {
        var _a = (_s * 7919) mod 997 / 997;      // a fixed spread for each streak
        var _b = (_s * 3571) mod 991 / 991;
        if (_vert)
        {
            var _sx = _k.x1 + 4 + _a * (_w - 8);
            var _d = (_b * _h + _t * _spd) mod _h;
            var _sy = (_k.vy < 0) ? _k.y2 - _d : _k.y1 + _d;
            draw_line_width_colour(_sx, _sy, _sx, _sy + sign(_k.vy) * 12, 2, c_white, c_white);
        }
        else
        {
            var _sy = _k.y1 + 8 + _b * (_h - 14);
            var _d = (_a * _w + _t * _spd) mod _w;
            var _sx = (_k.vx > 0) ? _k.x1 + _d : _k.x2 - _d;
            draw_line_width_colour(_sx, _sy, _sx - sign(_k.vx) * 14, _sy, 2, c_white, c_white);
        }
    }
}
draw_set_alpha(1);
