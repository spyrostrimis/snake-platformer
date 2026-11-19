/// Plays its half of the move (see scr_buddy). Its "snug" and "sling" states are the same as
/// a snake's, so the player's SNUG-ATTACK / SLINGSHOT code reads them as the other snake's.
var _g = obj_game;
if (_g.state != "play") exit;
if (!instance_exists(owner)) owner = _g.pl[0].inst;
var _p = owner;
mode_t++;
if (talk_t > 0) talk_t--;
if (blink > 0) blink--; else if (irandom(180) == 0) blink = 8;
if (snug_cd > 0) snug_cd--;
if (sling_cd > 0) sling_cd--;

// The job is done (the gem taken, the switch pulled, the boss beaten): goodbye.
if (mode != "leave" && mode != "thrown" && (!instance_exists(spot) || spot.goal_done())) leave();

switch (mode)
{
    case "pop":
        // Out of the crate, onto the ground, and it says what to do.
        vx = 0;
        physics();
        if (on_ground && mode_t > 15) { mode = "ready"; mode_t = 0; explain(); }
        break;

    case "ready":
        if (!instance_exists(_p)) { vx = 0; physics(); break; }
        if (_g.frame >= explain_frame && snug == "" && sling == "") explain();
        switch (role)
        {
            // ---- THE SLINGSHOT: Peto is the bow, already aimed; the player dashes in ----
            case "bow":
                if (sling == "")
                {
                    var _there = walk_to(home_x, 3);
                    if (_there && on_ground && sling_cd == 0 && abs(_p.x - x) < 340 && abs(_p.y - y) < 160)
                    {
                        var _a = buddy_aim_bow(x, y, spot.dir, spot.shot_goal());
                        aim = is_undefined(_a) ? { elev: 55, lv: 2, draw: 90 } : _a;
                        sling = "bow";
                        sling_t = 0;
                        sling_draw = 0;
                        sling_side = spot.dir;
                        sling_elev = aim.elev;
                        facing = sling_side;
                        _g.play_sfx(_g.sfx.ball);
                    }
                }
                else if (sling == "bow")
                {
                    vx = 0;
                    physics();
                    facing = sling_side;
                    sling_t = 0;
                    if (_p.sling == "nocked")
                    {
                        // The player sits in the string: draw it as far as the aim needs (quickly:
                        // the player can't move meanwhile), and let go.
                        sling_draw += 2;
                        if (sling_draw >= aim.draw)
                        {
                            sling = "loose";
                            sling_t = 0;
                            sling_level = aim.lv;
                            _g.play_sfx(_g.sfx.spring);
                        }
                    }
                    else if (abs(_p.x - x) > 440) sling_end();
                }
                else
                {
                    vx = 0;
                    physics();
                    sling_t++;
                    if (sling_t > 14) sling_end();
                }
                break;

            // ---- THE SLINGSHOT: Sockee is the arrow; the player is the bow ----
            case "arrow":
                if (sling == "")
                {
                    if (_p.sling == "bow" && _p.on_ground)
                    {
                        // Can a shot from that bow get there at all? If not: "make it on the mark".
                        if (_g.frame >= shot_check)
                        {
                            shot_check = _g.frame + 60;
                            shot_ok = !is_undefined(buddy_shot(_p.x, _p.y - 30, spot.dir, spot.shot_goal(), 3));
                            if (!shot_ok && talk_t < 200) { talk = "MAKE THE BOW ON THE MARK!"; talk_t = 240; }
                        }
                        // Round behind the bow, then dash into its string.
                        if (!shot_ok) { dash = false; ball = false; walk_to(home_x, 2.5); }
                        else if (!dash)
                        {
                            ball = false;
                            if (walk_to(_p.x - spot.dir * 70, 4) && on_ground) { dash = true; dash_t = 0; }
                        }
                        else
                        {
                            dash_t++;
                            ball = true;
                            boost_t = 10;
                            vx = spot.dir * 9;
                            facing = spot.dir;
                            ball_angle -= vx * 4;
                            physics();
                            if (sign(vx) == _p.sling_side && point_distance(x, y, sling_nock_x(_p), sling_nock_y(_p)) < SLING_NOCK)
                            {
                                sling = "nocked";
                                sling_t = 0;
                                dash = false;
                                ball = false;
                                boost_t = 0;
                                vx = 0;
                                vy = 0;
                                _g.play_sfx(_g.sfx.flag);
                                sling_place(_p);
                            }
                            else if (dash_t > 40 || hit_wall != 0) { dash = false; ball = false; boost_t = 0; }
                        }
                    }
                    else
                    {
                        dash = false;
                        ball = false;
                        boost_t = 0;
                        shot_check = 0;
                        walk_to(home_x, 2.5);
                    }
                }
                else if (sling == "nocked")
                {
                    sling_t++;
                    if (_p.sling == "loose")
                    {
                        // Shot off: it flies where it's needed (whatever the player's aim).
                        var _lv = clamp(_p.sling_level, 1, 3);
                        var _a = sling_angle(_p);
                        var _shot = buddy_shot(x, y, _p.sling_side, spot.shot_goal(), _lv);
                        if (!is_undefined(_shot)) { _a = _shot.a; _lv = _shot.lv; }
                        var _sp = 10 + _lv * 2.5;
                        vx = lengthdir_x(_sp, _a);
                        vy = lengthdir_y(_sp, _a);
                        sling = "flying";
                        sling_t = 0;
                        sling_dir = _a;
                        sling_level = _lv;
                        mode = "thrown";
                        talk_t = 0;
                        mode_t = 0;
                        _g.buddy_focus = id;
                        _g.play_sfx(_g.sfx.right);
                        _g.burst(x, y, make_colour_rgb(255, 220, 60), 6 + _lv * 5);
                    }
                    else if (_p.sling != "bow") { sling_end(); vy = -5; }
                    else sling_place(_p);
                }
                break;

            // ---- SNUG-ATTACK: Sockee curls into the C; the player rolls in ----
            case "catch":
                if (snug == "")
                {
                    var _there = walk_to(home_x, 3);
                    if (_there && on_ground && snug_cd == 0 && sign(_p.x - x) == spot.dir && abs(_p.x - x) < 340 && abs(_p.y - y) < 60)
                    {
                        snug = "snug";
                        snug_t = 0;
                        facing = spot.dir;
                        _g.play_sfx(_g.sfx.ball);
                    }
                }
                else if (snug == "snug")
                {
                    vx = 0;
                    physics();
                    facing = spot.dir;
                    snug_t = 0;
                    if (_p.snug == "caught")
                    {
                        snug = "hold";
                        snug_t = 0;
                        snug_push = _p.snug_push;
                        facing = -snug_push;
                    }
                    else if (sign(_p.x - x) != spot.dir || abs(_p.x - x) > 440) snug_end();
                }
                else if (snug == "hold")
                {
                    vx = 0;
                    physics();
                    snug_t++;
                    if (snug_t >= SNUG_HOLD)
                    {
                        snug = "fling";
                        snug_t = 0;
                        _g.play_sfx(_g.sfx.spring);
                        _g.burst(x - snug_push * 10, y - 10, make_colour_rgb(255, 220, 60), 12);
                    }
                }
                else
                {
                    vx = 0;
                    physics();
                    snug_t++;
                    if (snug_t > 14) snug_end();
                }
                break;

            // ---- SNUG-ATTACK: Peto rolls into the player's C and is flung ----
            case "ball":
                if (snug == "")
                {
                    if (_p.snug == "snug" && abs(_p.x - spot.x) < 400)
                    {
                        // Round to the far side of the C, then roll in.
                        if (!rolling)
                        {
                            ball = false;
                            if (walk_to(_p.x + spot.dir * 150, 4) && on_ground) rolling = true;
                        }
                        else
                        {
                            ball = true;
                            var _d = sign(_p.x - x);
                            if (_d == 0) _d = -spot.dir;
                            vx = approach(vx, _d * 6, 0.5);
                            facing = _d;
                            ball_angle -= vx * 4;
                            physics();
                            if (abs(vx) > 1.5 && sign(vx) == sign(_p.x - x) && abs(x - _p.x) < 26 && abs(y - _p.y) < 22)
                            {
                                snug = "caught";
                                snug_push = sign(vx);
                                snug_t = 0;
                                vx = 0;
                                vy = 0;
                                rolling = false;
                                _g.play_sfx(_g.sfx.ball);
                                _g.burst(x, y, c_white, 8);
                                snug_hold_ball(_p);
                            }
                            else if (hit_wall != 0) rolling = false;
                        }
                    }
                    else
                    {
                        rolling = false;
                        ball = false;
                        walk_to(home_x, 2.5);
                    }
                }
                else if (snug == "caught")
                {
                    snug_t++;
                    ball = true;
                    ball_angle -= 12 * snug_push;
                    snug_hold_ball(_p);
                    if (_p.snug == "fling")
                    {
                        // Flung: it flies on by itself (and the camera follows it).
                        x = _p.x - snug_push * 14;
                        y = _p.y - 9;
                        snug = "fired";
                        snug_t = 0;
                        vx = -snug_push * SNUG_FLING_SPEED;
                        vy = -SNUG_FLING_LIFT;
                        mode = "thrown";
                        talk_t = 0;
                        mode_t = 0;
                        _g.buddy_focus = id;
                        _g.play_sfx(_g.sfx.right);
                        _g.burst(x, y, make_colour_rgb(255, 220, 60), 16);
                    }
                    else if (snug_t > 45 && _p.snug != "snug" && _p.snug != "hold") { snug_end(); vy = -4; }
                }
                break;
        }
        break;

    case "thrown":
        var _me = id;
        var _done = false;
        if (sling == "flying")
        {
            // The arrow: a gentle arc. It knocks out creatures and hits a boss (bouncing off).
            sling_t++;
            vy = min(vy + SLING_GRAVITY, 9);
            sling_dir = point_direction(0, 0, vx, vy);
            facing = (vx >= 0) ? 1 : -1;
            if (_g.frame mod 2 == 0) _g.burst(x, y, make_colour_rgb(255, 220, 60), sling_level);
            entity_move();
            with (obj_enemy)
            {
                if (_done || is_harmless() || abs(x - _me.x) >= hw + _me.hw + 4 || abs(y - _me.y) >= hh + _me.hh + 4) continue;
                if (object_is_ancestor(object_index, obj_boss))
                {
                    if (active && hurt_t == 0 && _me.sling_level > 1) _g.say((_me.sling_level == 3) ? "TRIPLE HIT!" : "DOUBLE HIT!", 90);
                    kill(sling_boss_damage(_me.sling_level, hp_max), _me);
                    _me.vx = -sign(_me.vx) * 3;
                    _me.vy = -6;
                    _done = true;
                }
                else kill(2, _me);
            }
            if (y > _g.lvl_h * TILE + 40) { poof_home(); break; }
            if (_done || hit_wall != 0 || hit_ceiling || on_ground || sling_t > SLING_FLIGHT) { sling_end(); mode = "task"; mode_t = 0; }
        }
        else if (snug == "fired")
        {
            // The ball: it smashes cracked blocks and speed blocks, and knocks out creatures.
            snug_t++;
            ball = true;
            ball_angle -= vx * 4;
            vy = min(vy + SNUG_GRAVITY, 9);
            snug_smash_ahead(vx, smash);
            var _vx = vx;
            entity_move();
            if (hit_wall == 0) vx = on_ground ? _vx * 0.985 : _vx;
            if (_g.frame mod 2 == 0) _g.burst(x, y, make_colour_rgb(255, 220, 60), 2);
            with (obj_enemy)
            {
                if (_done || is_harmless() || abs(x - _me.x) >= hw + _me.hw + 4 || abs(y - _me.y) >= hh + _me.hh + 4) continue;
                if (object_is_ancestor(object_index, obj_boss))
                {
                    if (active && hurt_t == 0) _g.say("HUGE HIT!", 90);
                    kill(max(SNUG_BOSS_DAMAGE, ceil(hp_max / 3)), _me);
                    _me.vx = -sign(_me.vx) * 3;
                    _me.vy = -6;
                    _done = true;
                }
                else kill(2, _me);
            }
            if (y > _g.lvl_h * TILE + 40) { poof_home(); break; }
            if (_done || hit_wall != 0 || snug_t > SNUG_FLIGHT || (on_ground && abs(vx) < 1)) { snug_end(); vx = 0; mode = "task"; mode_t = 0; }
        }
        else { mode = "task"; mode_t = 0; }
        break;

    case "task":
        // Landed: does what's needed there, then goes (or, if it missed, pops back to try again).
        if (spot.goal == "boss")
        {
            vx = 0;
            physics();
            if (_g.buddy_focus == id) _g.buddy_focus = noone;
            if ((on_ground && mode_t > 30) || mode_t > 150) poof_home();
            break;
        }
        if (spot.goal == "gem")
        {
            var _it = noone;
            var _best = 1000000;
            with (obj_pickup)
            {
                if (object_index != obj_gem && object_index != obj_super_gem) continue;
                var _dx = abs(x - other.x);
                if (_dx < 300 && abs(y - other.y) < 90 && _dx < _best) { _best = _dx; _it = id; }
            }
            if (_it != noone && on_ground)
            {
                walk_to(_it.x, 3);
                if (abs(_it.x - x) < 18 && abs(_it.y - y) < 30) with (_it) collect_now(other.id);
            }
            else
            {
                vx = 0;
                physics();
                if (_it == noone && on_ground && mode_t > 40) poof_home();
            }
        }
        else
        {
            var _sw = spot.target;
            if (instance_exists(_sw) && !_sw.pulled && abs(_sw.x - x) < 360 && abs(_sw.y - y) < 80)
            {
                if (on_ground) { if (walk_to(_sw.x, 3)) _sw.pull(true); }
                else { vx = 0; physics(); }
            }
            else
            {
                vx = 0;
                physics();
                if (on_ground && mode_t > 40) poof_home();
            }
        }
        if (mode == "task" && mode_t > 600) poof_home();
        break;

    case "leave":
        vx = 0;
        physics();
        if (mode_t > 70)
        {
            _g.burst(x, y, skin.colour, 18);
            _g.burst(x, y, c_white, 10);
            _g.play_sfx(_g.sfx.pop);
            if (_g.buddy_focus == id) _g.buddy_focus = noone;
            instance_destroy();
            exit;
        }
        break;
}
update_body();
image_index = (blink > 0) ? 1 : 0;
