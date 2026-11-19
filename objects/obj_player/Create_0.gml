/// The snake hero: runs, jumps, glides with a spinning tail, lashes its tongue and
/// curls into a ball. Its body trails along the path the head has taken.

hw = 10;                // collision box half-width
hh = 12;                // collision box half-height
vx = 0;
vy = 0;
facing = 1;
on_ground = false;
hit_wall = 0;
hit_ceiling = false;
drop_through = false;
coyote = 0;             // frames left to jump after running off a ledge
jump_buffer = 0;        // frames a jump press is remembered before landing
copter = false;         // tail-spin glide (green snake)
copter_arm = false;     // Jump was pressed again in the air: the glide may start
// pid (0 or 1) is set by instance_create_layer before this runs.
stats = obj_game.pl[pid];   // this snake's score, lives, hearts, misses and checkpoint
skin = stats.skin;          // sprites and power of this snake
if (!variable_instance_exists(id, "remote")) remote = false;   // online: the other PC's snake
hidden = false;             // online joiner: fell in a pit, waiting for the host's "come back"
net_tx = x;                 // remote snake: where the other PC last said it was
net_ty = y;
safe_x = x;                 // the last safe spot it stood (or swam): out of lives, its
safe_y = y;                 // Box Snake Egg goes here (see obj_box_egg)
air_jump_ready = false; // red snake: the second jump is still available in this jump
boost_t = 0;            // frames left in a boost (C); only a boost hurts creatures
boost_cd = 0;           // short wait after a boost before the next one
boost_ready = true;     // one boost per jump, refilled on landing
boost_dir = 1;          // red dash direction
boost_speed = 9;        // red dash speed (pixels per frame)
sprung = false;         // rising from a spring: letting go of jump must not cut it short
invuln = 0;
ball = false;
ball_angle = 0;
ball_slow = 0;
tongue_t = 0;           // 0 = tongue in; counts up while it lashes out and back
tongue_len = 0;
blink = 0;
gulp_t = 0;             // counts down while a swallowed egg travels down the body
was_swim = false;       // in water last step (for the splash)
inked = 0;              // hit by an octopus's ink: its screen is blotted for a while
talk = "";              // something the snake says, in a bubble over its head ("THE PATH IS BLOCKED!")
talk_t = 0;             // frames the bubble still shows
image_speed = 0;

// ---------- SNUG-ATTACK (two players): Sockee catches, Peto is the ball ----------
// See scr_snug.
snug = "";              // "" | call | snug | hold | fling (Sockee) | caught | fired (Peto)
snug_t = 0;             // frames in the current state
snug_push = 1;          // the way Peto's ball was rolling when Sockee caught it (-1 or 1)
snug_hold = -1;         // Sockee: frames Roll + Tongue have been held (-1: not counting)
snug_call = 0;          // Sockee: frames the "SNUG!" call still shows
snug_cd = 0;            // a short wait after the move before the next one

// ---------- THE SLINGSHOT (two players): Peto is the bow, Sockee the arrow ----------
// See scr_sling.
sling = "";             // "" | call | bow | loose (Peto) | nocked | flying (Sockee)
sling_t = 0;            // frames in the current state
sling_hold = -1;        // Peto: frames Roll + Tongue have been held (-1: not counting)
sling_call = 0;         // Peto: frames the "SLING!" call still shows
sling_elev = 30;        // Peto: the aim, degrees above flat
sling_side = 1;         // Peto: the side the bow shoots to (away from Sockee), -1 or 1
sling_draw = 0;         // Peto: frames drawn since Sockee sat in the string
sling_level = 1;        // the strength, 1 to 3 (Peto's when he lets go; Sockee's in flight)
sling_dir = 0;          // Sockee as the arrow: the way it points, degrees
sling_cd = 0;           // a short wait after the move before the next one

// Movement tuning (pixels per frame at 60 frames a second).
run_accel = 0.35;
run_max = 3.3;
ball_max = 6.2;
gravity_pull = 0.45;
jump_speed = 11.4;      // rises ~138 px: clears 4 tiles (128 px) with room to spare
fall_max = 9;

// The body is a little rope: each segment keeps a set distance from the one in front,
// falls with gravity and rests on the ground, so it trails, drapes and dangles naturally.
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
        _s[@ 1] += copter && _i == body_len - 1 ? 0.5 : 2.2;
        // Rest on solid ground (and on logs, from above).
        var _t = tile_at(_s[0], _s[1] + _r);
        if (is_blocking(_t) || (_t == T_ONEWAY && _s[1] + _r - 3 < floor((_s[1] + _r) / TILE) * TILE + 4))
        {
            _s[@ 1] = floor((_s[1] + _r) / TILE) * TILE - _r;
        }
        // Keep the set distance from the segment in front.
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

/// Hurt by a creature or spikes: knocked back, blinking and safe for a moment.
take_hit = function(_dir = -facing)
{
    // (One player: while the partner is thrown, the snake can't move, so it can't be hurt.)
    if (instance_exists(obj_game.buddy_focus)) return;
    if (invuln > 0 || snug == "fired" || sling == "flying") return;    // the flung ball and the arrow can't be hurt
    if (sling != "" && sling != "call") sling_end();                    // a hit breaks the bow (or drops the arrow)
    if (snug != "" && snug != "call") snug_end();   // a hit breaks SNUG-ATTACK
    invuln = 110;
    vx = _dir * 3.5;
    vy = -5;
    ball = false;
    boost_t = 0;
    tongue_t = 0;
    tongue_len = 0;
    obj_game.hurt_player(id);
};

/// Breaks the cracked block at tile (_tx, _ty) (see obj_game.smash_tile). Online, the
/// joiner tells the host, which tells nobody else: the host's own smashes go the other way.
smash = function(_tx, _ty)
{
    var _g = obj_game;
    if (grid_type(_tx, _ty) != T_CRACK && grid_type(_tx, _ty) != T_SPEED) return;
    _g.smash_tile(_tx, _ty, stats);
    if (_g.net_mode == "client") _g.net_event({ t: "smash", x: _tx, y: _ty });
};

/// Remembers where it stands now, if that is a safe spot (on the ground or in water, off spikes).
note_safe_spot = function()
{
    if (!hidden && (on_ground || water_at(x, y)) && !touching_spikes() && y < obj_game.lvl_h * TILE)
    {
        safe_x = x;
        safe_y = y;
    }
};

/// Online: the other PC's snake glides to where that PC last said it was.
mirror_step = function()
{
    note_safe_spot();
    // SNUG-ATTACK: a caught ball sits in this PC's own Sockee's C, not where the other PC
    // last saw it (that would trail behind).
    if (snug == "caught")
    {
        var _mate = snug_partner();
        if (instance_exists(_mate)) { snug_hold_ball(_mate); return; }
    }
    // THE SLINGSHOT: likewise, a sitting arrow sits in this PC's own Peto's string.
    if (sling == "nocked")
    {
        var _bow = snug_partner();
        if (instance_exists(_bow)) { sling_place(_bow); return; }
    }
    if (point_distance(x, y, net_tx, net_ty) > 160) { x = net_tx; y = net_ty; reset_body(); }
    else { x = lerp(x, net_tx, 0.45); y = lerp(y, net_ty, 0.45); }
    update_body();
};
