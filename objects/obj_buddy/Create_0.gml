/// The partner, one player only (see scr_buddy): the other snake, delivered in a crate at a
/// combo spot. obj_crate sets spot (the obj_combo_spot) and skin_id (which snake it is).
/// It has the snake's own variables (so it's drawn with the snake's own Draw event and the
/// SNUG-ATTACK / SLINGSHOT code treats it as the other snake) and plays its half by itself.
var _g = obj_game;
skin = _g.snakes[skin_id];
owner = _g.pl[0].inst;      // the player's snake
stats = _g.pl[0];           // what it scores and collects goes to the player
pid = -1;
remote = false;
hidden = false;
hw = 10;
hh = 12;
vx = 0;
vy = -6;                    // it pops out of the crate
facing = (instance_exists(owner) && owner.x < x) ? -1 : 1;
on_ground = false;
hit_wall = 0;
hit_ceiling = false;
drop_through = false;
copter = false;
ball = false;
ball_angle = 0;
boost_t = 0;
tongue_t = 0;
tongue_len = 0;
blink = 0;
gulp_t = 0;
invuln = 0;
image_speed = 0;
image_index = 0;
talk = "";
talk_t = 0;

// SNUG-ATTACK and THE SLINGSHOT (the same variables as the snake's; see scr_snug, scr_sling).
snug = "";
snug_t = 0;
snug_push = 1;
snug_hold = -1;
snug_call = 0;
snug_cd = 0;
sling = "";
sling_t = 0;
sling_hold = -1;
sling_call = 0;
sling_elev = 30;
sling_side = 1;
sling_draw = 0;
sling_level = 1;
sling_dir = 0;
sling_cd = 0;

// Its part of the move: Peto is the bow (SLINGSHOT) or the ball (SNUG-ATTACK); Sockee is the
// arrow or the C. Where it waits: the C and the bow on the spot; the arrow behind the
// player's bow; the ball on the far side of the player's C.
var _green = skin.boost == "up";
role = (spot.type == "sling") ? (_green ? "bow" : "arrow") : (_green ? "ball" : "catch");
home_x = spot.x;
if (role == "arrow") home_x = spot.x - spot.dir * 70;
if (role == "ball") home_x = spot.x + spot.dir * 150;
home_y = spot.y - hh;
mode = "pop";               // pop | ready | thrown | task | leave
mode_t = 0;
aim = undefined;            // the bow: { elev, lv, draw }
dash = false;               // the arrow: dashing into the player's bow
dash_t = 0;
rolling = false;            // the ball: rolling into the player's C
shot_check = 0;             // the arrow: when to check again that a shot from the player's bow works
shot_ok = true;
explain_frame = 0;

// The body, as the snake's.
body_len = 5;
seg_gap = 11;
segs = [];
reset_body = function()
{
    segs = [];
    for (var _i = 1; _i <= 14; _i++) array_push(segs, [x - facing * _i * seg_gap, y + 4]);
};
reset_body();
update_body = function()
{
    var _px = x - facing * 9;
    var _py = y + 5;
    for (var _i = 0; _i < body_len; _i++)
    {
        var _s = segs[_i];
        var _r = (_i == body_len - 1) ? 5 : 8;
        _s[@ 1] += 2.2;
        var _t = tile_at(_s[0], _s[1] + _r);
        if (is_blocking(_t) || (_t == T_ONEWAY && _s[1] + _r - 3 < floor((_s[1] + _r) / TILE) * TILE + 4)) _s[@ 1] = floor((_s[1] + _r) / TILE) * TILE - _r;
        var _dx = _s[0] - _px;
        var _dy = _s[1] - _py;
        var _d = point_distance(0, 0, _dx, _dy);
        if (_d > seg_gap)
        {
            _s[@ 0] = _px + _dx / _d * seg_gap;
            _s[@ 1] = _py + _dy / _d * seg_gap;
        }
        _px = _s[0];
        _py = _s[1];
    }
};
mouth_x = function() { return x + facing * 17; };
mouth_y = function() { return y + 6; };

/// Smashes a cracked block or a speed block (the flung ball; see snug_smash_ahead).
smash = function(_tx, _ty) { obj_game.smash_tile(_tx, _ty, stats); };

/// Falls and moves against the tiles; out of the level, it pops back to its place.
physics = function()
{
    vy = min(vy + 0.45, 9);
    entity_move();
    if (y > obj_game.lvl_h * TILE + 40) poof_home();
};

/// Walks towards x _tx at speed _sp (hopping up a step in the way). True once it's there.
walk_to = function(_tx, _sp)
{
    var _d = _tx - x;
    if (abs(_d) <= _sp) { vx = 0; physics(); return true; }
    vx = sign(_d) * _sp;
    facing = sign(_d);
    physics();
    if (hit_wall != 0 && on_ground) vy = -11.4;
    return false;
};

/// Says _bubble over its head, and the lines _hud (what to do, with the keys) on the screen,
/// straight away (messages waiting before them are dropped).
speak = function(_bubble, _hud)
{
    talk = _bubble;
    talk_t = 300;
    explain_frame = obj_game.frame + 1200;
    obj_game.clear_messages();
    for (var _k = 0; _k < array_length(_hud); _k++) obj_game.say(((_k == 0) ? skin.name + ": " : "") + _hud[_k], 200);
};

/// What the player has to do for this move.
explain = function()
{
    var _k = obj_game.settings.keys.solo;
    var _roll = keys_text(_k.roll), _tongue = keys_text(_k.tongue), _boost = keys_text(_k.boost);
    var _what = (spot.goal == "gem") ? "A SUPER GEM'S IN THERE!" : ((spot.goal == "switch") ? "THE SWITCH IS IN THERE!" : "LET'S TAKE THAT BOSS DOWN!");
    if (spot.goal == "gem" && spot.type == "sling") _what = "A SUPER GEM'S UP THERE!";
    switch (role)
    {
        case "bow":   speak("RUN THROUGH ME WITH BOOST!", [_what, "I'M THE BOW: DASH IN FROM BEHIND ME!", "HOLD " + _roll + " AND PRESS " + _boost + " TO DASH"]); break;
        case "arrow": speak("BE MY BOW!", [_what, "BE MY BOW: HOLD " + _roll + " + " + _tongue, "I'LL JUMP IN. LET GO TO SHOOT ME!"]); break;
        case "catch": speak("ROLL INTO ME!", [_what, "I'LL CURL UP: ROLL INTO ME FROM THAT SIDE", "HOLD " + _roll + " TO ROLL. I'LL FLING YOU!"]); break;
        case "ball":  speak("HOLD RUN AND WAIT FOR ME!", [_what, "STAND ON THE MARK AND HOLD " + _roll + " + " + _tongue, "WAIT FOR ME: I'LL ROLL INTO YOU!"]); break;
    }
};

/// Pops back to its place (a missed throw, or it fell): a puff here and there.
poof_home = function()
{
    var _g = obj_game;
    _g.burst(x, y, skin.colour, 10);
    x = home_x;
    y = home_y;
    vx = 0;
    vy = 0;
    ball = false;
    boost_t = 0;
    dash = false;
    rolling = false;
    snug = "";
    snug_t = 0;
    sling = "";
    sling_t = 0;
    sling_draw = 0;
    reset_body();
    _g.burst(x, y, skin.colour, 10);
    _g.play_sfx(_g.sfx.pop);
    if (_g.buddy_focus == id) _g.buddy_focus = noone;
    mode = "ready";
    mode_t = 0;
};

/// The job is done: goodbye.
leave = function()
{
    mode = "leave";
    mode_t = 0;
    vx = 0;
    ball = false;
    boost_t = 0;
    snug = "";
    sling = "";
    reset_body();
    talk = "GREAT TEAMWORK! SEE YOU!";
    talk_t = 90;
};
