/// THE SLINGSHOT, a two-player super move: Peto (green) is the bow, Sockee (red) the arrow.
///
///  1. Peto presses Roll + Tongue (Shift + X). A quick tap is a call: "SLING!" shows over
///     his head on both screens, so Sockee knows. Held, Peto rears up into a bow on the spot,
///     his tongue strung as the bowstring, for up to 5 seconds (a bar under the bubble shows
///     the time left). It first aims back towards Sockee's side (the arrow is shot back the
///     way it came in); Left / Right turn the aim round (all the way over, from one side to
///     the other) and Up (Jump) / Down raise and lower it.
///  2. Sockee holds Roll and presses Boost (Shift + C) towards Peto: his dashing ball shoots
///     into the string (from either side) and sits there as the arrow. (Just rolling in isn't
///     enough.)
///  3. The longer Peto keeps holding, the further the string is drawn: the SLINGSHOT meter at
///     the bottom of the screen fills through three levels. When Peto lets go (or the 5
///     seconds run out), Sockee flies like an arrow: level 1 is one hit, level 2 two hits
///     (as much as SNUG-ATTACK), level 3 three hits. It knocks out every creature it touches,
///     skeletons too, and bounces off a boss.
///  4. Unlike SNUG-ATTACK's ball, the arrow only hurts creatures: it doesn't break cracked
///     walls or crates, and boss projectiles and boulders don't stop it.
///
/// The functions run on obj_player (called from its events). Online each PC runs its own
/// snake: Sockee's PC sees Peto's bow and nocks; Peto's PC sees Sockee nocked and draws;
/// Sockee's PC sees Peto let go and flies.

#macro SLING_TAP 10             // frames: a shorter press is only a call, a longer one draws the bow
#macro SLING_TIME 300           // frames (5 s) Peto can stay a bow
#macro SLING_CALL 90            // frames the "SLING!" call shows
#macro SLING_LEVEL 60           // frames of drawing per strength level (1 s)
#macro SLING_NOCK 28            // how close Sockee's ball must reach the middle of the string (px)
#macro SLING_GRAVITY 0.2        // the arrow falls gently, not like a jump
#macro SLING_FLIGHT 75          // frames before the arrow is just a snake again
#macro SLING_BOW_R 26           // half the bow's length

/// The states, in the order the snake packets number them.
function sling_states() { return ["", "call", "bow", "loose", "nocked", "flying"]; }

/// The strength level (1 to 3) for _draw frames of drawing.
function sling_level_for(_draw) { return clamp(1 + (_draw div SLING_LEVEL), 1, 3); }

/// How far the string is drawn (0 to 1) for _draw frames.
function sling_pull_for(_draw) { return clamp(_draw / (SLING_LEVEL * 3), 0, 1); }

/// What a boss loses from a level _lv arrow: one, two (as much as SNUG-ATTACK) or three hits,
/// a hit being a sixth of its health bar.
function sling_boss_damage(_lv, _hp_max)
{
    switch (_lv)
    {
        case 1:  return max(1, round(_hp_max / 6));
        case 2:  return max(2, ceil(_hp_max / 3));
        default: return max(3, ceil(_hp_max / 2));
    }
}

/// The bow's aim as an angle in degrees (sling_elev above flat, on the sling_side side).
function sling_angle(_p) { return (_p.sling_side >= 0) ? _p.sling_elev : 180 - _p.sling_elev; }

/// The middle of the bow, where the arrow sits.
function sling_nock_x(_p) { return _p.x; }
function sling_nock_y(_p) { return _p.y - 18; }

/// Leaves the Slingshot and is an ordinary snake again.
function sling_end()
{
    sling = "";
    sling_t = 0;
    sling_hold = -1;
    sling_draw = 0;
    sling_cd = 20;
    ball = false;
    reset_body();
}

/// Puts the sitting arrow in bow _p: its tail on the string (drawn back as far as Peto has
/// drawn it), pointing where the bow aims. Online, both PCs pin it to their own Peto.
function sling_place(_p)
{
    var _a = sling_angle(_p);
    var _back = sling_pull_for(_p.sling_draw) * 20;
    x = sling_nock_x(_p) + lengthdir_x(30 - _back, _a);
    y = sling_nock_y(_p) + lengthdir_y(30 - _back, _a);
    sling_dir = _a;
    facing = (lengthdir_x(1, _a) >= 0) ? 1 : -1;
}

/// One step of the Slingshot for this (local) snake. Returns true when it took over the step,
/// so the normal running and jumping don't happen.
function sling_step(_in)
{
    var _g = obj_game;
    if (sling_cd > 0) sling_cd--;
    if (sling_call > 0) sling_call--;
    if (!snug_available()) { if (sling != "") sling_end(); return false; }
    var _green = (skin.boost == "up");
    var _mate = snug_partner();

    switch (sling)
    {
        case "":
        case "call":
            // Peto: Roll + Tongue calls; held, he becomes the bow.
            if (_green && _in.roll_held && _in.tongue && on_ground && sling_cd == 0)
            {
                sling = "call";
                sling_call = SLING_CALL;
                sling_hold = 0;
                vx = 0;
                ball = false;
                tongue_t = 0;
                tongue_len = 0;
                _g.play_sfx(_g.sfx.select);
                return true;
            }
            if (sling == "call" && sling_hold >= 0)
            {
                if (_in.roll_held && _in.tongue_held && on_ground)
                {
                    sling_hold++;
                    vx = 0;
                    ball = false;
                    vy = min(vy + gravity_pull, fall_max);
                    entity_move();
                    if (sling_hold >= SLING_TAP)
                    {
                        sling = "bow";
                        sling_t = 0;
                        sling_draw = 0;
                        sling_elev = 30;
                        sling_side = instance_exists(_mate) && _mate.x != x ? sign(_mate.x - x) : facing;
                        _g.play_sfx(_g.sfx.ball);
                    }
                    return true;
                }
                sling_hold = -1;    // let go quickly: only the call
            }
            if (sling == "call" && sling_call == 0) sling = "";

            // Sockee: a dashing ball (Roll + Boost) that reaches the middle of Peto's string.
            if (!_green && ball && boost_t > 0 && instance_exists(_mate) && _mate.sling == "bow"
                && point_distance(x, y, sling_nock_x(_mate), sling_nock_y(_mate)) < SLING_NOCK)
            {
                sling = "nocked";
                sling_t = 0;
                boost_t = 0;
                ball = false;
                vx = 0;
                vy = 0;
                tongue_t = 0;
                tongue_len = 0;
                _g.play_sfx(_g.sfx.flag);
                sling_place(_mate);
                return true;
            }
            return false;

        case "bow":
            // Peto, the bow: planted, aiming with Up / Down, drawing while Sockee sits in it.
            sling_t++;
            vx = 0;
            ball = false;
            vy = min(vy + gravity_pull, fall_max);
            entity_move();
            var _nocked = instance_exists(_mate) && _mate.sling == "nocked";
            // The aim: Left / Right turn it round over the top (0 is flat to the right, 180 flat
            // to the left); Up / Down raise it towards straight up or lower it towards flat.
            var _aim = sling_angle(id);
            if (_in.left)  _aim = min(_aim + 1.6, 180);
            if (_in.right) _aim = max(_aim - 1.6, 0);
            if (_in.jump_held) _aim = (_aim < 90) ? min(_aim + 1.2, 90) : max(_aim - 1.2, 90);
            if (_in.down)      _aim = (_aim <= 90) ? max(_aim - 1.2, 0) : min(_aim + 1.2, 180);
            sling_side = (_aim <= 90) ? 1 : -1;
            sling_elev = (_aim <= 90) ? _aim : 180 - _aim;
            facing = sling_side;
            if (_nocked) sling_draw = min(sling_draw + 1, SLING_LEVEL * 3);
            if (!(_in.roll_held && _in.tongue_held) || sling_t > SLING_TIME || !on_ground)
            {
                if (_nocked)
                {
                    // Let go: the arrow flies (Sockee's PC sees "loose").
                    sling = "loose";
                    sling_t = 0;
                    sling_level = sling_level_for(sling_draw);
                    _g.play_sfx(_g.sfx.spring);
                }
                else sling_end();
                return true;
            }
            // Creatures still hurt a bow (and that breaks it).
            var _me = id;
            with (obj_enemy) if (!is_harmless() && abs(x - _me.x) < hw + _me.hw && abs(y - _me.y) < hh + _me.hh && _me.invuln == 0) with (_me) take_hit(sign(x - other.x));
            return true;

        case "loose":
            // The string snaps back; a moment later Peto is an ordinary snake again.
            sling_t++;
            vx = 0;
            vy = min(vy + gravity_pull, fall_max);
            entity_move();
            if (sling_t > 14) sling_end();
            return true;

        case "nocked":
            // Sockee in the string, until Peto lets go (or the bow is gone).
            sling_t++;
            if (!instance_exists(_mate) || (_mate.sling != "bow" && _mate.sling != "loose") || _in.down)
            {
                sling_end();
                vy = -5;
                return true;
            }
            if (_mate.sling == "loose") sling_launch(_mate);
            else sling_place(_mate);
            return true;

        case "flying":
            sling_fly();
            return true;
    }
    return false;
}

/// Peto let go: Sockee flies along the bow's aim, faster the further it was drawn.
function sling_launch(_p)
{
    var _g = obj_game;
    var _a = sling_angle(_p);
    sling_level = clamp(_p.sling_level, 1, 3);
    var _speed = 10 + sling_level * 2.5;
    vx = lengthdir_x(_speed, _a);
    vy = lengthdir_y(_speed, _a);
    sling = "flying";
    sling_t = 0;
    sling_dir = _a;
    ball = false;
    _g.play_sfx(_g.sfx.right);
    _g.burst(x, y, make_colour_rgb(255, 220, 60), 6 + sling_level * 5);
}

/// One step of flight: a gentle arc. Creatures it touches are knocked out; a boss takes one,
/// two or three hits and the arrow bounces off; a wall, a ceiling or the ground ends it. It
/// goes past boss projectiles and boulders and breaks nothing.
function sling_fly()
{
    var _g = obj_game;
    sling_t++;
    vy = min(vy + SLING_GRAVITY, fall_max);
    sling_dir = point_direction(0, 0, vx, vy);
    facing = (vx >= 0) ? 1 : -1;
    if (_g.frame mod 2 == 0) _g.burst(x, y, make_colour_rgb(255, 220, 60), sling_level);

    entity_move();
    if (y > _g.lvl_h * TILE + 40) { sling_end(); _g.player_died(id); return; }

    var _me = id;
    var _done = false;
    with (obj_enemy)
    {
        // (A little mole under the ground is only a mound: the arrow flies over it.)
        if (_done || is_harmless() || abs(x - _me.x) >= hw + _me.hw + 4 || abs(y - _me.y) >= hh + _me.hh + 4) continue;
        if (object_is_ancestor(object_index, obj_boss))
        {
            if (active && hurt_t == 0 && _me.sling_level > 1) _g.say((_me.sling_level == 3) ? "TRIPLE HIT!" : "DOUBLE HIT!", 90);
            kill(sling_boss_damage(_me.sling_level, hp_max), _me);
            _me.vx = -sign(_me.vx) * 3;
            _me.vy = -6;
            _done = true;
        }
        else kill(2, _me);      // everything else is knocked out, skeletons and shells too
    }
    if (_done || hit_wall != 0 || hit_ceiling || on_ground || sling_t > SLING_FLIGHT)
    {
        if (!_done) part_particles_create(_g.ps, x, y, _g.pt_dust, 6);
        sling_end();
    }
}

// ---------- Drawing ----------

/// A little speech bubble with _text over (_bx, _by); with _bar >= 0, a bar under it shows
/// that much time left (0 to 1). Used for the SLING! call.
function sling_bubble(_bx, _by, _text, _col, _bar)
{
    draw_set_colour(make_colour_rgb(20, 16, 40));
    draw_roundrect(_bx - 25, _by - 9, _bx + 25, _by + 9, false);
    draw_triangle(_bx - 5, _by + 8, _bx + 5, _by + 8, _bx, _by + 14, false);
    draw_set_colour(c_white);
    draw_roundrect(_bx - 23, _by - 7, _bx + 23, _by + 7, false);
    draw_triangle(_bx - 3, _by + 6, _bx + 3, _by + 6, _bx, _by + 11, false);
    hud_text(_bx, _by - 7, _text, 0.3, fa_center, _col);
    if (_bar >= 0)
    {
        draw_set_colour(make_colour_rgb(20, 16, 40));
        draw_rectangle(_bx - 23, _by + 16, _bx + 23, _by + 19, false);
        draw_set_colour(_col);
        draw_rectangle(_bx - 23, _by + 16, _bx - 23 + 46 * _bar, _by + 19, false);
    }
}

/// Peto's call (and, as a bow, the time left).
function sling_draw_call()
{
    var _g = obj_game;
    var _bow = (sling == "bow");
    if (_bow && SLING_TIME - sling_t < 60 && (_g.frame div 4) mod 2 == 1) return;   // blinking: time almost up
    sling_bubble(x, y - (_bow ? 66 : 44), "SLING!", skin.colour, _bow ? 1 - sling_t / SLING_TIME : -1);
}

/// Peto as the bow: his body bent into a curve standing on its tail, head at the top tip,
/// his tongue strung between the tips (drawn back by a sitting arrow), and the aim dotted.
function sling_draw_bow()
{
    var _a = sling_angle(id);
    var _dx = lengthdir_x(1, _a);
    var _dy = lengthdir_y(1, _a);
    var _px = -_dy;     // across the bow
    var _py = _dx;
    var _nx = sling_nock_x(id);
    var _ny = sling_nock_y(id);
    // The tips sit across the aim; the wood bulges forward along it.
    var _t1x = _nx - _px * SLING_BOW_R, _t1y = _ny - _py * SLING_BOW_R;
    var _t2x = _nx + _px * SLING_BOW_R, _t2y = _ny + _py * SLING_BOW_R;
    var _cx = _nx + _dx * SLING_BOW_R * 0.9, _cy = _ny + _dy * SLING_BOW_R * 0.9;
    // The upper tip gets the head.
    if (_t2y < _t1y) { var _ox = _t1x, _oy = _t1y; _t1x = _t2x; _t1y = _t2y; _t2x = _ox; _t2y = _oy; }

    // The string (the tongue), drawn back while Sockee sits in it; straight again once loosed.
    var _pull = (sling == "bow") ? sling_pull_for(sling_draw) : 0;
    var _sx = _nx - _dx * _pull * 20, _sy = _ny - _dy * _pull * 20;
    draw_set_colour(make_colour_rgb(140, 10, 40));
    draw_line_width(_t1x, _t1y, _sx, _sy, 3);
    draw_line_width(_sx, _sy, _t2x, _t2y, 3);
    draw_set_colour(make_colour_rgb(255, 90, 130));
    draw_line_width(_t1x, _t1y, _sx, _sy, 1.5);
    draw_line_width(_sx, _sy, _t2x, _t2y, 1.5);

    // The body along the curve, tail at the lower tip.
    var _n = 9;
    for (var _k = _n; _k >= 1; _k--)
    {
        var _t = _k / (_n + 1);
        var _bx = sqr(1 - _t) * _t2x + 2 * (1 - _t) * _t * _cx + sqr(_t) * _t1x;
        var _by = sqr(1 - _t) * _t2y + 2 * (1 - _t) * _t * _cy + sqr(_t) * _t1y;
        if (_k == 1) draw_sprite_ext(skin.tail, 0, _bx, _by, 0.8, 0.8, 0, c_white, 1);
        draw_sprite_ext(skin.body, 0, _bx, _by, 0.85, 0.85, 0, c_white, 1);
    }
    draw_sprite_ext(skin.head, image_index, _t1x, _t1y, facing, 1, 0, c_white, 1);

    // The aim: a short dotted line, so both players can see where it will go.
    if (sling == "bow")
    {
        draw_set_colour(c_white);
        for (var _d = 34; _d <= 82; _d += 12) draw_circle(_nx + _dx * _d, _ny + _dy * _d, 1.6, false);
    }
}

/// Sockee as the arrow: a straight, stiff snake along its aim (or flight), head first.
function sling_draw_arrow()
{
    var _dx = lengthdir_x(1, sling_dir);
    var _dy = lengthdir_y(1, sling_dir);
    var _flip = (_dx < 0) ? -1 : 1;     // keep the head the right way up
    for (var _k = 6; _k >= 1; _k--)
    {
        var _bx = x - _dx * _k * 9;
        var _by = y - _dy * _k * 9;
        var _s = 1 - _k * 0.06;
        if (_k == 6) draw_sprite_ext(skin.tail, 0, _bx, _by, _s, _s, 0, c_white, 1);
        else draw_sprite_ext(skin.body, 0, _bx, _by, _s, _s, 0, c_white, 1);
    }
    draw_sprite_ext(skin.head, image_index, x, y - 3, 1, _flip, sling_dir, c_white, 1);
}

/// The SLINGSHOT meter, at the bottom centre of the screen (each half with split screen),
/// while Sockee sits in Peto's bow: how far it's drawn, in three levels. Drawn by the bow
/// (Peto) from his Draw GUI event.
function sling_draw_meter()
{
    var _g = obj_game;
    var _mate = snug_partner();
    if (sling != "bow" || !instance_exists(_mate) || _mate.sling != "nocked") return;
    var _views = _g.split_on ? 2 : 1;
    var _vh = 360 / _views;
    var _fill = sling_pull_for(sling_draw);
    var _lv = sling_level_for(sling_draw);
    var _cols = [make_colour_rgb(255, 230, 90), make_colour_rgb(255, 160, 40), make_colour_rgb(255, 70, 60)];
    matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 2, 2, 1));
    for (var _v = 0; _v < _views; _v++)
    {
        var _w = 168;
        var _x = 320 - _w / 2;
        var _y = (_v + 1) * _vh - 26;
        hud_text(320, _y - 18, "SLINGSHOT  " + string(_lv), 0.32, fa_center, _cols[_lv - 1]);
        draw_set_colour(make_colour_rgb(20, 16, 40));
        draw_roundrect(_x - 3, _y - 3, _x + _w + 3, _y + 13, false);
        for (var _s = 0; _s < 3; _s++)
        {
            // Each third fills in its own colour; the dividers show where a level starts.
            var _part = clamp(_fill * 3 - _s, 0, 1);
            if (_part > 0)
            {
                draw_set_colour(_cols[_s]);
                draw_rectangle(_x + _s * _w / 3, _y + 1, _x + _s * _w / 3 + _part * _w / 3 - 1, _y + 9, false);
            }
        }
        draw_set_colour(c_white);
        draw_line_width(_x + _w / 3, _y - 3, _x + _w / 3, _y + 13, 2);
        draw_line_width(_x + 2 * _w / 3, _y - 3, _x + 2 * _w / 3, _y + 13, 2);
        draw_roundrect(_x - 3, _y - 3, _x + _w + 3, _y + 13, true);
    }
    matrix_set(matrix_world, matrix_build_identity());
}
