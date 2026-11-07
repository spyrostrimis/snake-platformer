/// The Slingshot, a two-player super move: Peto (green) is the bow, Sockee (red) the arrow.
///
///  1. Peto jumps straight up (no Left / Right) and presses Jump again in the air: he hovers
///     upright as a vertical helicopter, his tail spinning over his head (about 2.5 s;
///     Down drops out). It only works with Sockee close by.
///  2. Sockee rolls (hold Roll) towards Peto and, at full rolling speed, presses Boost: it
///     leaps as a ball.
///  3. If the ball hits Peto in his middle, it pushes his middle back and Peto bends into a
///     C around it; the two fall together. (Head or tail: no catch.)
///  4. When Peto lands he flings Sockee forward, back the way it came. Sockee unrolls into a
///     straight arrow, and whatever it hits takes two hits (a boss loses two health
///     points). It knocks out creatures on the way and bounces off a boss.
///
/// The functions run on obj_player (called from its events). Online, each PC runs its own
/// snake and reads the other's state from the snake packets: Peto's PC sees Sockee caught
/// and bends; Sockee's PC sees Peto throw and flies.

#macro SLING_HOVER 150          // frames Peto can hover
#macro SLING_NEAR 420           // Sockee must be this close (px) for Peto to hover
#macro SLING_LEAP 13            // Sockee's leap (upward speed)
#macro SLING_MID 14             // how far from Peto's middle the ball may hit (px, up or down)
#macro SLING_THROW_SPEED 16
#macro SLING_THROW_LIFT 3
#macro SLING_GRAVITY 0.2        // the arrow falls gently, not like a jump
#macro SLING_FLIGHT 75          // frames before the arrow is just a snake again
#macro SLING_BOSS_DAMAGE 2      // two of a boss's health points (8 for Big Cheese)

/// The slingshot states, in the order the snake packets number them.
function sling_states() { return ["", "heli", "bent", "throw", "leap", "caught", "flying"]; }

/// True when two snakes are playing (split screen or online): the only time it works.
function sling_available()
{
    return array_length(obj_game.pl) == 2;
}

/// The other snake (local, or the other PC's copy), or noone.
function sling_partner()
{
    var _me = id;
    var _r = noone;
    with (obj_player) if (id != _me && pid != _me.pid) _r = id;
    return _r;
}

/// Peto's middle, where the ball must hit (he hovers upright: head up, tail down).
function sling_mid_y(_p) { return _p.y + 2; }

/// Leaves the slingshot and is an ordinary snake again.
function sling_end()
{
    sling = "";
    sling_t = 0;
    sling_cd = 30;
    ball = false;
    reset_body();
}

/// One step of the slingshot for this (local) snake. Returns true when it took over the
/// step, so the normal running and jumping don't happen.
function sling_step(_in)
{
    var _g = obj_game;
    if (sling_cd > 0) sling_cd--;
    if (on_ground && sling == "") vjump = false;
    if (!sling_available()) { if (sling != "") sling_end(); return false; }
    var _green = (skin.boost == "up");
    var _mate = sling_partner();

    switch (sling)
    {
        case "":
            // Peto: after a straight-up jump, Jump again in the air starts the hover.
            if (_green && !on_ground && vjump && _in.jump_pressed && sling_cd == 0
                && instance_exists(_mate) && point_distance(x, y, _mate.x, _mate.y) < SLING_NEAR)
            {
                sling = "heli";
                sling_t = 0;
                vx = 0;
                copter = false;
                _g.play_sfx(_g.sfx.copter);
                if (_g.frame >= sling_hint)
                {
                    sling_hint = _g.frame + 900;
                    _g.say(stats.skin.name + " HOVERS! " + _mate.stats.skin.name + ": ROLL AT FULL SPEED, BOOST INTO HIS MIDDLE", 180);
                }
                return true;
            }
            // Sockee: rolling at full speed towards a hovering Peto, Boost leaps instead of dashing.
            if (!_green && ball && on_ground && _in.boost && sling_cd == 0 && instance_exists(_mate) && _mate.sling == "heli"
                && abs(vx) >= ball_max - 0.4 && sign(vx) == sign(_mate.x - x))
            {
                sling = "leap";
                sling_push = sign(vx);
                vy = -SLING_LEAP;
                boost_t = 0;
                _g.play_sfx(_g.sfx.jump);
                _g.burst(x, y + hh, skin.colour, 6);
                return true;
            }
            return false;

        case "heli":
            // Hover in place, tail spinning.
            sling_t++;
            vx = 0;
            vy = approach(vy, 0, 1);
            if (_g.frame mod 8 == 0) _g.play_sfx(_g.sfx.copter);
            entity_move();
            if (instance_exists(_mate) && _mate.sling == "caught")
            {
                // The ball hit his middle: he bends round it.
                sling = "bent";
                sling_push = _mate.sling_push;
                sling_t = 0;
                facing = -sling_push;
                _g.play_sfx(_g.sfx.ball);
            }
            else if (sling_t > SLING_HOVER || on_ground || _in.down) sling_end();
            return true;

        case "bent":
            // Falling together, bent like a C, until he touches the ground.
            sling_t++;
            vx = 0;
            vy = min(vy + gravity_pull * 0.6, fall_max);
            entity_move();
            if (y > _g.lvl_h * TILE + 40) { sling_end(); _g.player_died(id); return true; }
            if (on_ground)
            {
                sling = "throw";
                sling_t = 0;
                _g.play_sfx(_g.sfx.spring);
                part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 8);
            }
            else if (sling_t > 40 && (!instance_exists(_mate) || _mate.sling != "caught")) sling_end();
            return true;

        case "throw":
            // The fling: a moment straightening forward, then an ordinary snake again.
            sling_t++;
            vx = 0;
            vy = min(vy + gravity_pull, fall_max);
            entity_move();
            if (sling_t > 14) sling_end();
            return true;

        case "leap":
            // Sockee in the air as a ball: catch on Peto's middle, or land (a miss).
            ball = true;
            ball_angle -= vx * 4;
            vy = min(vy + gravity_pull, fall_max);
            entity_move();
            if (y > _g.lvl_h * TILE + 40) { sling_end(); _g.player_died(id); return true; }
            if (instance_exists(_mate) && _mate.sling == "heli" && abs(x - _mate.x) < 22 && abs(y - sling_mid_y(_mate)) < SLING_MID)
            {
                sling = "caught";
                sling_t = 0;
                vx = 0;
                vy = 0;
                _g.play_sfx(_g.sfx.ball);
                _g.burst(x, y, c_white, 8);
                sling_hold(_mate);
            }
            else if (on_ground || hit_wall != 0) sling_end();
            return true;

        case "caught":
            // Held in Peto's bend until he throws.
            sling_t++;
            ball = true;
            ball_angle -= 12 * sling_push;
            if (instance_exists(_mate)) sling_hold(_mate);
            if (instance_exists(_mate) && _mate.sling == "throw") sling_launch();
            else if (!instance_exists(_mate) || (sling_t > 40 && _mate.sling != "heli" && _mate.sling != "bent")) { sling_end(); vy = -4; }
            return true;

        case "flying":
            sling_fly();
            return true;
    }
    return false;
}

/// Keeps the caught ball in Peto's bend (his middle, pushed back the way the ball came).
function sling_hold(_p)
{
    x = _p.x + sling_push * 9;     // inside the C (its middle is pushed 22 px back)
    y = sling_mid_y(_p);
}

/// Peto has landed: Sockee shoots forward (back the way it came) as a straight arrow.
function sling_launch()
{
    var _g = obj_game;
    // Start level with Peto's body, clear of the ground he's standing on.
    var _mate = sling_partner();
    if (instance_exists(_mate)) y = _mate.y - 6;
    sling = "flying";
    sling_t = 0;
    ball = false;
    vx = -sling_push * SLING_THROW_SPEED;
    vy = -SLING_THROW_LIFT;
    sling_dir = point_direction(0, 0, vx, vy);
    facing = sign(vx);
    _g.play_sfx(_g.sfx.spring);
    _g.play_sfx(_g.sfx.right);
    _g.burst(x, y, make_colour_rgb(255, 220, 60), 16);
}

/// One step of flight: a gentle arc; creatures in the way are knocked out, a boss takes two
/// hits and the arrow bounces off it; a wall or the ground ends it.
function sling_fly()
{
    var _g = obj_game;
    sling_t++;
    vy = min(vy + SLING_GRAVITY, fall_max);
    sling_dir = point_direction(0, 0, vx, vy);
    facing = (vx >= 0) ? 1 : -1;
    if (_g.frame mod 2 == 0) _g.burst(x, y, make_colour_rgb(255, 220, 60), 2);

    entity_move();
    if (y > _g.lvl_h * TILE + 40) { sling_end(); _g.player_died(id); return; }

    var _me = id;
    var _done = false;
    with (obj_enemy)
    {
        if (_done || abs(x - _me.x) >= hw + _me.hw + 4 || abs(y - _me.y) >= hh + _me.hh + 4) continue;
        if (object_is_ancestor(object_index, obj_boss))
        {
            if (active && hurt_t == 0) _g.say("DOUBLE HIT!", 90);
            kill(SLING_BOSS_DAMAGE, _me);
            _me.vx = -sign(_me.vx) * 3;
            _me.vy = -6;
            _done = true;
        }
        else kill(2, _me);
    }
    with (obj_hazard) if (point_distance(x, y, _me.x, _me.y) < 20)
    {
        _g.burst(x, y, c_white, 6);
        if (_g.net_mode == "client") { _g.net_gone[$ string(net_id)] = true; _g.net_event({ t: "hazard", i: net_id }); }
        instance_destroy();
    }
    if (_done || hit_wall != 0 || hit_ceiling || on_ground || sling_t > SLING_FLIGHT)
    {
        if (!_done) part_particles_create(_g.ps, x, y, _g.pt_dust, 6);
        sling_end();
    }
}

// ---------- Drawing ----------

/// Peto upright: the body from head (top) to tail (bottom), its middle at _mx (straight
/// when _mx == x, bent like a C when pushed aside); head and tail lean by _end_dx.
function sling_draw_upright(_mx, _end_dx)
{
    var _hx = x + _end_dx, _hy = y - 20;    // head
    var _tx = x + _end_dx, _ty = y + 26;    // tail
    var _cx = 2 * _mx - (_hx + _tx) / 2;    // control point, so the curve passes through _mx
    var _cy = y + 3;
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

/// Peto hovering: upright and straight, his tail whirling over his head like a rotor
/// (two blades turning, seen from the side).
function sling_draw_heli()
{
    var _g = obj_game;
    sling_draw_upright(x, 0);
    var _ry = y - 38;
    var _a = _g.frame * 0.6;
    draw_set_colour(make_colour_rgb(31, 107, 18));
    draw_line_width(x, _ry, x, _ry + 9, 3);
    for (var _b = 0; _b < 2; _b++)
    {
        var _len = 26 * cos(_a + _b * pi / 2);
        draw_set_colour(make_colour_rgb(31, 107, 18));
        draw_line_width(x - _len, _ry, x + _len, _ry, 6);
        draw_set_colour(make_colour_rgb(150, 230, 110));
        draw_line_width(x - _len, _ry, x + _len, _ry, 3);
    }
    draw_set_colour(make_colour_rgb(31, 107, 18));
    draw_circle(x, _ry, 3, false);
}

/// Peto bent like a C round the ball (his middle pushed back the way it came).
function sling_draw_bent() { sling_draw_upright(x + sling_push * 22, -sling_push * 6); }

/// Peto throwing: straightening and leaning forward.
function sling_draw_throw() { sling_draw_upright(x - sling_push * 6, -sling_push * 8); }

/// Sockee as the arrow: a straight, stiff snake along its flight, head first.
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
