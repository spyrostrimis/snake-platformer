/// THE PARTNER: SNUG-ATTACK and THE SLINGSHOT need two snakes. Playing alone, at a combo spot
/// (obj_combo_spot) the other snake is delivered in a crate under a parachute (obj_crate: red
/// for Sockee, green for Peto). Open it and the partner (obj_buddy) pops out, says what to do
/// and plays the other half of the move:
///
///   THE SLINGSHOT, the player is Peto (the bow): Sockee jumps into the bow and, shot off,
///       flies where it's needed by itself.
///   THE SLINGSHOT, the player is Sockee (the arrow): Peto is the bow, aimed already; dash in.
///   SNUG-ATTACK, the player is Peto (the ball): Sockee curls into the C; roll into it.
///   SNUG-ATTACK, the player is Sockee (the C): Peto rolls in and is flung.
///
/// When the partner is the one thrown, the player's keys rest and the camera follows the
/// partner (obj_game.buddy_focus): it collects what's up there or pulls the switch, and then
/// the camera comes back. When the job is done (the gem taken, the switch pulled, the boss
/// beaten) the partner says goodbye and goes. What it collects goes to the player.
/// The partner only ever exists in a one-player game.

/// A speech bubble with _text, its tail pointing down at (_x, _y), sized to fit.
function speech_bubble(_x, _y, _text, _col)
{
    var _s = 0.26;
    draw_set_font(obj_game.font_hud);
    var _w = string_width(string_upper(_text)) * _s / 2 + 7;
    var _by = _y - 18;
    draw_set_colour(make_colour_rgb(20, 16, 40));
    draw_roundrect(_x - _w - 2, _by - 11, _x + _w + 2, _by + 11, false);
    draw_triangle(_x - 6, _by + 10, _x + 6, _by + 10, _x, _by + 17, false);
    draw_set_colour(c_white);
    draw_roundrect(_x - _w, _by - 9, _x + _w, _by + 9, false);
    draw_triangle(_x - 4, _by + 8, _x + 4, _by + 8, _x, _by + 13, false);
    hud_text(_x, _by - 7, _text, _s, fa_center, _col);
}

/// Simulates THE SLINGSHOT's arrow from (_x, _y) at (_vx, _vy) against the tiles: its gentle
/// flight, then an ordinary fall. Returns { land, x, y (where it came to rest), near (how
/// close it came to the point (_px, _py)), hit (whether it got within _pw, _ph of it on the
/// way, as the arrow's touch does), top (the highest it went) }.
function buddy_sim_arrow(_x, _y, _vx, _vy, _px, _py, _pw = 0, _ph = 0)
{
    var _hit = false;
    var _b = { x: _x, y: _y, vx: _vx, vy: _vy, hw: 10, hh: 12, drop_through: false, on_ground: false, hit_wall: 0, hit_ceiling: false };
    var _move = method(_b, entity_move);
    var _near = point_distance(_x, _y, _px, _py);
    var _top = _y;
    for (var _t = 1; _t <= SLING_FLIGHT + 1; _t++)
    {
        _b.vy = min(_b.vy + SLING_GRAVITY, 9);
        _move();
        _near = min(_near, point_distance(_b.x, _b.y, _px, _py));
        _top = min(_top, _b.y);
        if (abs(_b.x - _px) < _pw && abs(_b.y - _py) < _ph) _hit = true;
        if (_b.hit_wall != 0 || _b.hit_ceiling || _b.on_ground) break;
    }
    var _n = 0;
    while (!_b.on_ground && _n < 200 && _b.y < obj_game.lvl_h * TILE + 40)
    {
        _b.vx = clamp(_b.vx, -3.3, 3.3);
        _b.vy = min(_b.vy + 0.45, 9);
        _move();
        _n++;
    }
    return { land: _b.on_ground, x: _b.x, y: _b.y, near: _near, top: _top, hit: _hit };
}

/// How well a simulated shot _r does at goal _g (smaller is better; 1 or more: it misses).
/// _g: { kind: "land", x1, x2, top } (come to rest on that ledge) or { kind: "hit", x, y, w, h }
/// (touch the box of half size w, h round that point).
/// A shot that stays in sight (below the top of the level) is better.
function buddy_goal_score(_r, _g)
{
    var _high = max(0, -_r.top) / 2000;
    if (_g.kind == "hit") return _r.hit ? _r.near / 1000 + _high : 1000 + _r.near;
    if (_r.land && _r.x >= _g.x1 && _r.x <= _g.x2 && abs(_r.y + 12 - _g.top) < 3) return abs(_r.x - (_g.x1 + _g.x2) / 2) / 10000 + _high;
    return 1000;
}

/// The bow's aim for a bow standing at (_bx, _by) shooting towards side _side at goal _g:
/// { elev, lv, draw } (draw: how long to draw the string for strength lv), the strongest shot
/// that gets there, or undefined.
function buddy_aim_bow(_bx, _by, _side, _g)
{
    var _gx = (_g.kind == "hit") ? _g.x : 0;
    var _gw = (_g.kind == "hit") ? _g.w : 0;
    var _gh = (_g.kind == "hit") ? _g.h : 0;
    var _gy = (_g.kind == "hit") ? _g.y : 0;
    // At a boss, the strongest shot that hits; onto a ledge, the gentlest that lands there.
    for (var _k = 0; _k < 3; _k++)
    {
        var _lv = (_g.kind == "hit") ? 3 - _k : 1 + _k;
        var _draw = (_lv == 1) ? 30 : ((_lv == 2) ? 90 : 130);
        var _pull = sling_pull_for(_draw);
        var _sp = 10 + _lv * 2.5;
        var _best = undefined;
        var _best_score = 1;
        for (var _e = 80; _e >= 4; _e -= 1)
        {
            var _a = (_side >= 0) ? _e : 180 - _e;
            var _sx = _bx + lengthdir_x(30 - _pull * 20, _a);
            var _sy = _by - 18 + lengthdir_y(30 - _pull * 20, _a);
            var _sc = buddy_goal_score(buddy_sim_arrow(_sx, _sy, lengthdir_x(_sp, _a), lengthdir_y(_sp, _a), _gx, _gy, _gw, _gh), _g);
            if (_sc < _best_score) { _best_score = _sc; _best = { elev: _e, lv: _lv, draw: _draw }; }
        }
        if (!is_undefined(_best)) return _best;
    }
    return undefined;
}

/// A shot for the arrow from (_x, _y) towards side _side at goal _g: { a (angle), lv }, at
/// strength _lv if that can get there, else at another one, or undefined if none can.
function buddy_shot(_x, _y, _side, _g, _lv)
{
    var _order = (_g.kind == "hit") ? [_lv, 3, 2, 1] : [1, 2, 3, _lv];
    for (var _k = 0; _k < 4; _k++)
    {
        var _a = buddy_aim_free(_x, _y, 10 + _order[_k] * 2.5, _side, _g);
        if (!is_undefined(_a)) return { a: _a, lv: _order[_k] };
    }
    return undefined;
}

/// The angle to shoot an arrow from (_x, _y) at speed _sp towards side _side so it reaches
/// goal _g, or undefined.
function buddy_aim_free(_x, _y, _sp, _side, _g)
{
    var _best = undefined;
    var _best_score = 1;
    var _gx = (_g.kind == "hit") ? _g.x : 0;
    var _gw = (_g.kind == "hit") ? _g.w : 0;
    var _gh = (_g.kind == "hit") ? _g.h : 0;
    var _gy = (_g.kind == "hit") ? _g.y : 0;
    for (var _e = 85; _e >= 0; _e -= 1)
    {
        var _a = (_side >= 0) ? _e : 180 - _e;
        var _sc = buddy_goal_score(buddy_sim_arrow(_x, _y, lengthdir_x(_sp, _a), lengthdir_y(_sp, _a), _gx, _gy, _gw, _gh), _g);
        if (_sc < _best_score) { _best_score = _sc; _best = _a; }
    }
    return _best;
}

/// A parachute: a dome (centre (_cx, _cy), half-width _w, height _h) in six panels, colour
/// _col and white in turn, on four strings down to the load at (_lx, _ly), _lw wide each side.
/// Used by the partner's crate and by the egg a snake comes back in.
function draw_parachute(_cx, _cy, _w, _h, _lx, _ly, _lw, _col)
{
    draw_set_colour(make_colour_rgb(60, 40, 30));
    draw_line_width(_cx - _w, _cy, _lx - _lw, _ly, 1);
    draw_line_width(_cx - _w * 0.4, _cy + 2, _lx - _lw * 0.4, _ly, 1);
    draw_line_width(_cx + _w * 0.4, _cy + 2, _lx + _lw * 0.4, _ly, 1);
    draw_line_width(_cx + _w, _cy, _lx + _lw, _ly, 1);
    var _n = 6;
    for (var _k = 0; _k < _n; _k++)
    {
        var _a0 = 180 - _k * 180 / _n;
        var _a1 = 180 - (_k + 1) * 180 / _n;
        draw_set_colour((_k mod 2 == 0) ? _col : c_white);
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
