/// SNUG-ATTACK, a two-player super move: Sockee (red) catches, Peto (green) is the ball.
///
///  1. Sockee presses Roll + Tongue (Shift + X). A quick tap is a call: "SNUG!" shows over
///     his head on both screens, so Peto knows. Held, Sockee curls up into a C on the spot,
///     opening towards Peto, ready to catch, for up to 5 seconds.
///  2. Peto rolls (hold Roll) towards Sockee. When the ball rolls into the C, Sockee snugs it
///     for a moment and flings it back the way it came.
///  3. Peto stays a ball and flies on: whatever it hits is knocked out (skeletons and armoured
///     creatures too) and a boss takes a huge hit (a third of its health bar), and the ball
///     bounces off it. Boulders smash, boss projectiles are swatted, puddles stay.
///
/// The functions run on obj_player (called from its events). Online, each PC runs its own
/// snake and reads the other's state from the snake packets: Peto's PC sees Sockee snugging
/// and is caught; Sockee's PC sees Peto caught and flings; Peto's PC sees the fling and flies.

#macro SNUG_TAP 10              // frames: a shorter press is only a call, a longer one snugs
#macro SNUG_TIME 300            // frames (5 s) Sockee can stay snugging
#macro SNUG_CALL 90             // frames the "SNUG!" call shows
#macro SNUG_HOLD 12             // frames Sockee holds the ball before flinging it
#macro SNUG_FLING_SPEED 15
#macro SNUG_FLING_LIFT 4
#macro SNUG_GRAVITY 0.35
#macro SNUG_FLIGHT 90           // frames the flung ball flies and rolls
#macro SNUG_BOSS_DAMAGE 2       // the least a boss loses; it takes a third of its health bar

/// The states, in the order the snake packets number them.
function snug_states() { return ["", "call", "snug", "hold", "fling", "caught", "fired"]; }

/// True when two snakes are playing (split screen or online), or when one player has the
/// partner with them (see scr_buddy): the only times it works.
function snug_available()
{
    return array_length(obj_game.pl) == 2 || instance_exists(obj_buddy);
}

/// The other snake (local, or the other PC's copy), or the one player's partner, or noone.
function snug_partner()
{
    var _me = id;
    var _r = noone;
    with (obj_player) if (id != _me && pid != _me.pid) _r = id;
    if (_r == noone && object_index == obj_player) with (obj_buddy) _r = id;
    if (_r == noone && object_index == obj_buddy) _r = owner;
    return _r;
}

/// The flung ball (moving at _vx) smashes the cracked blocks and speed blocks in its way:
/// the only thing fast enough to break speed blocks. _smash(_tx, _ty) does the smashing.
function snug_smash_ahead(_vx, _smash)
{
    if (abs(_vx) < 1) return;
    var _d = sign(_vx);
    for (var _ahead = hw; _ahead <= hw + abs(_vx) + 4; _ahead += 8)
    {
        for (var _yy = y - hh + 3; _yy <= y + hh - 3; _yy += 9)
        {
            var _t = tile_at(x + _d * _ahead, _yy);
            if (_t == T_CRACK || _t == T_SPEED) _smash(floor((x + _d * _ahead) / TILE), floor(_yy / TILE));
        }
    }
}

/// Leaves the move and is an ordinary snake again.
function snug_end()
{
    snug = "";
    snug_t = 0;
    snug_hold = -1;
    snug_cd = 20;
    ball = false;
    reset_body();
}

/// Keeps the caught ball in the C of Sockee _s (standing on the ground, the C opening the
/// way the ball came from). Online, both PCs pin it to their own Sockee like this.
function snug_hold_ball(_s)
{
    x = _s.x - snug_push * 8;
    y = _s.y - 9;
}

/// One step of SNUG-ATTACK for this (local) snake. Returns true when it took over the step,
/// so the normal running and jumping don't happen.
function snug_step(_in)
{
    var _g = obj_game;
    if (snug_cd > 0) snug_cd--;
    if (snug_call > 0) snug_call--;
    if (!snug_available()) { if (snug != "") snug_end(); return false; }
    var _red = (skin.boost == "dash");
    var _mate = snug_partner();

    switch (snug)
    {
        case "":
        case "call":
            // Sockee: Roll + Tongue calls; held, he snugs.
            if (_red && _in.roll_held && _in.tongue && on_ground && snug_cd == 0)
            {
                snug = "call";
                snug_call = SNUG_CALL;
                snug_hold = 0;
                vx = 0;
                ball = false;
                tongue_t = 0;
                tongue_len = 0;
                _g.play_sfx(_g.sfx.select);
                return true;
            }
            if (snug == "call" && snug_hold >= 0)
            {
                if (_in.roll_held && _in.tongue_held && on_ground)
                {
                    // Still held: standing still, and after a moment, the C.
                    snug_hold++;
                    vx = 0;
                    ball = false;
                    vy = min(vy + gravity_pull, fall_max);
                    entity_move();
                    if (snug_hold >= SNUG_TAP)
                    {
                        snug = "snug";
                        snug_t = 0;
                        _g.play_sfx(_g.sfx.ball);
                    }
                    return true;
                }
                snug_hold = -1;     // let go quickly: only the call
            }
            if (snug == "call" && snug_call == 0) snug = "";

            // Peto: a rolling ball that reaches a snugging Sockee is caught in his C.
            if (!_red && ball && instance_exists(_mate) && _mate.snug == "snug" && abs(vx) > 1.5
                && sign(vx) == sign(_mate.x - x) && abs(x - _mate.x) < 26 && abs(y - _mate.y) < 22)
            {
                snug = "caught";
                snug_push = sign(vx);
                snug_t = 0;
                vx = 0;
                vy = 0;
                boost_t = 0;
                _g.play_sfx(_g.sfx.ball);
                _g.burst(x, y, c_white, 8);
                snug_hold_ball(_mate);
                return true;
            }
            return false;

        case "snug":
            // Sockee curled up, the C opening towards Peto, while both keys are held.
            snug_t++;
            vx = 0;
            ball = false;
            vy = min(vy + gravity_pull, fall_max);
            entity_move();
            if (instance_exists(_mate) && _mate.x != x) facing = sign(_mate.x - x);
            if (instance_exists(_mate) && _mate.snug == "caught")
            {
                snug = "hold";
                snug_t = 0;
                snug_push = _mate.snug_push;
                facing = -snug_push;
                return true;
            }
            if (!(_in.roll_held && _in.tongue_held) || snug_t > SNUG_TIME || !on_ground) { snug_end(); return false; }
            // Creatures still hurt him (and that breaks the C).
            var _me = id;
            with (obj_enemy) if (!is_harmless() && abs(x - _me.x) < hw + _me.hw && abs(y - _me.y) < hh + _me.hh && _me.invuln == 0) with (_me) take_hit(sign(x - other.x));
            return true;

        case "hold":
            // A moment snugging the ball, then the fling.
            snug_t++;
            vx = 0;
            vy = min(vy + gravity_pull, fall_max);
            entity_move();
            if (snug_t >= SNUG_HOLD)
            {
                snug = "fling";
                snug_t = 0;
                _g.play_sfx(_g.sfx.spring);
                _g.burst(x - snug_push * 10, y - 10, make_colour_rgb(255, 220, 60), 12);
            }
            return true;

        case "fling":
            // Straightening as he throws, then an ordinary snake again.
            snug_t++;
            vx = 0;
            vy = min(vy + gravity_pull, fall_max);
            entity_move();
            if (snug_t > 14) snug_end();
            return true;

        case "caught":
            // Peto, held in Sockee's C until he flings.
            snug_t++;
            ball = true;
            ball_angle -= 12 * snug_push;
            if (instance_exists(_mate)) snug_hold_ball(_mate);
            if (instance_exists(_mate) && _mate.snug == "fling") snug_launch();
            else if (!instance_exists(_mate) || (snug_t > 45 && _mate.snug != "snug" && _mate.snug != "hold")) { snug_end(); vy = -4; }
            return true;

        case "fired":
            snug_fly();
            return true;
    }
    return false;
}

/// Sockee has flung the ball: Peto shoots back the way he came, still a ball.
function snug_launch()
{
    var _g = obj_game;
    var _mate = snug_partner();
    if (instance_exists(_mate)) { x = _mate.x - snug_push * 14; y = _mate.y - 9; }
    snug = "fired";
    snug_t = 0;
    ball = true;
    vx = -snug_push * SNUG_FLING_SPEED;
    vy = -SNUG_FLING_LIFT;
    _g.play_sfx(_g.sfx.right);
    _g.burst(x, y, make_colour_rgb(255, 220, 60), 16);
}

/// One step of the flung ball: it flies, lands and rolls on. Creatures it touches are
/// knocked out, a boss takes a huge hit and the ball bounces off; a wall ends it.
function snug_fly()
{
    var _g = obj_game;
    snug_t++;
    ball = true;
    ball_angle -= vx * 4;
    vy = min(vy + SNUG_GRAVITY, fall_max);
    var _vx = vx;
    snug_smash_ahead(vx, smash);
    entity_move();
    if (hit_wall == 0) vx = on_ground ? _vx * 0.985 : _vx;
    if (_g.frame mod 2 == 0) _g.burst(x, y, make_colour_rgb(255, 220, 60), 2);
    if (y > _g.lvl_h * TILE + 40) { snug_end(); _g.player_died(id); return; }

    var _me = id;
    var _done = false;
    with (obj_enemy)
    {
        // (A little mole under the ground is only a mound: the ball rolls over it.)
        if (_done || is_harmless() || abs(x - _me.x) >= hw + _me.hw + 4 || abs(y - _me.y) >= hh + _me.hh + 4) continue;
        if (object_is_ancestor(object_index, obj_boss))
        {
            // A huge hit: a third of the boss's whole health bar.
            if (active && hurt_t == 0) _g.say("HUGE HIT!", 90);
            kill(max(SNUG_BOSS_DAMAGE, ceil(hp_max / 3)), _me);
            _me.vx = -sign(_me.vx) * 3;
            _me.vy = -6;
            _done = true;
        }
        else kill(2, _me);      // everything else is knocked out, skeletons and shells too
    }
    with (obj_hazard)
    {
        // A projectile is swatted away and a rolling boulder bursts into gravel; a poison
        // puddle stays where it is.
        if (!touches(_me) || sprite_index == spr_puddle) continue;
        if (sprite_index == spr_boulder) part_particles_create(_g.ps, x, y, _g.pt_rock, 12);
        else _g.burst(x, y, c_white, 6);
        if (_g.net_mode == "client") { _g.net_gone[$ string(net_id)] = true; _g.net_event({ t: "hazard", i: net_id }); }
        instance_destroy();
    }
    if (_done || hit_wall != 0 || snug_t > SNUG_FLIGHT || (on_ground && abs(vx) < 1)) snug_end();
}

// ---------- Drawing ----------

/// Sockee standing curled: the body from head (top) to tail (on the ground), its middle at
/// _mx (straight when _mx == x, a C when pushed aside); head and tail lean by _end_dx.
function snug_draw_upright(_mx, _end_dx)
{
    var _hx = x + _end_dx, _hy = y - 36;    // head
    var _tx = x + _end_dx, _ty = y + 10;    // tail, on the ground
    var _cx = 2 * _mx - (_hx + _tx) / 2;    // control point, so the curve passes through _mx
    var _cy = y - 13;
    var _n = 7;
    for (var _k = _n; _k >= 1; _k--)
    {
        var _t = _k / (_n + 1);             // 0 at the head, 1 at the tail
        var _bx = sqr(1 - _t) * _hx + 2 * (1 - _t) * _t * _cx + sqr(_t) * _tx;
        var _by = sqr(1 - _t) * _hy + 2 * (1 - _t) * _t * _cy + sqr(_t) * _ty;
        var _s = 1 - _t * 0.35;
        if (_k == _n) draw_sprite_ext(skin.tail, 0, _bx, _by, _s + 0.1, _s + 0.1, 0, c_white, 1);
        else draw_sprite_ext(skin.body, 0, _bx, _by, _s, _s, 0, c_white, 1);
    }
    draw_sprite_ext(skin.head, image_index, _hx, _hy, facing, 1, 0, c_white, 1);
}

/// Sockee curled into the C, opening the way he faces (towards Peto, or where the ball came from).
function snug_draw_c() { snug_draw_upright(x - facing * 20, facing * 6); }

/// Sockee flinging: straightening and leaning into the throw.
function snug_draw_fling() { snug_draw_upright(x + facing * 4, facing * 8); }

/// The call over Sockee's head: a little "SNUG!" bubble. While he snugs, a bar under it
/// shows the time left.
function snug_draw_call()
{
    var _g = obj_game;
    var _upright = (snug == "snug" || snug == "hold");
    var _bx = x;
    var _by = y - (_upright ? 56 : 44);
    var _blink = (snug == "snug" && SNUG_TIME - snug_t < 60) ? ((_g.frame div 4) mod 2 == 0) : true;
    if (!_blink) return;
    draw_set_colour(make_colour_rgb(20, 16, 40));
    draw_roundrect(_bx - 25, _by - 9, _bx + 25, _by + 9, false);
    draw_triangle(_bx - 5, _by + 8, _bx + 5, _by + 8, _bx, _by + 14, false);
    draw_set_colour(c_white);
    draw_roundrect(_bx - 23, _by - 7, _bx + 23, _by + 7, false);
    draw_triangle(_bx - 3, _by + 6, _bx + 3, _by + 6, _bx, _by + 11, false);
    hud_text(_bx, _by - 7, "SNUG!", 0.3, fa_center, skin.colour);
    if (snug == "snug")
    {
        var _left = 1 - snug_t / SNUG_TIME;
        draw_set_colour(make_colour_rgb(20, 16, 40));
        draw_rectangle(_bx - 23, _by + 16, _bx + 23, _by + 19, false);
        draw_set_colour(skin.colour);
        draw_rectangle(_bx - 23, _by + 16, _bx - 23 + 46 * _left, _by + 19, false);
    }
}
