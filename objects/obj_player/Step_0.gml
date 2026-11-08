/// Moves, jumps (green: jump again in the air to tail-spin, red: jump again in the air), lashes the
/// tongue, rolls, boosts (green rockets up, red dashes ahead) and drops through logs.
/// The keys depend on the player: see read_controls() in scr_util.

var _g = obj_game;
// Online: the other PC's snake only follows what that PC reports.
if (remote) { mirror_step(); exit; }
if (_g.state != "play") exit;
if (hidden) exit;

// Online, each PC plays one snake with the one-player keys (or any gamepad).
var _in = read_controls(pid, (_g.net_mode != "") ? 1 : _g.players_n);
var _left  = _in.left;
var _right = _in.right;
var _down  = _in.down;
var _jump_pressed = _in.jump_pressed;
var _jump_held    = _in.jump_held;
var _tongue = _in.tongue;
var _roll_held = _in.roll_held;
var _boost_key = _in.boost;

if (invuln > 0) invuln--;
if (gulp_t > 0) gulp_t--;
if (blink > 0) blink--; else if (irandom(180) == 0) blink = 8;

// ---------- The Slingshot (two players): as the bow or the arrow, it runs this step ----------
if (sling_step(_in))
{
    image_index = (invuln > 90) ? 3 : ((blink > 0) ? 1 : 0);
    exit;
}

// ---------- Roll (hold Shift) and boost (press C) ----------
// A roll is just fast travel: it can't hurt creatures and creatures hurt it.
// A boost is a short burst that knocks out anything it touches. One boost per jump.
// The green rocket only launches from the ground; the red dash also works in mid-air.
if (boost_cd > 0) boost_cd--;
if (on_ground && boost_t == 0) boost_ready = true;
if (_boost_key && tongue_t == 0 && boost_t == 0 && boost_cd == 0 && boost_ready && (skin.boost != "up" || on_ground))
{
    boost_ready = false;
    if (skin.boost == "up")
    {
        boost_t = 36;
        vy = -11;
    }
    else
    {
        boost_t = 20;
        boost_dir = facing;
        vx = boost_dir * boost_speed;
        vy = 0;
    }
    _g.play_sfx(_g.sfx.spring);
    _g.burst(x, y, skin.colour, 10);
}
var _was_ball = ball;
ball = boost_t > 0 || (_roll_held && tongue_t == 0);
if (ball != _was_ball) _g.play_sfx(_g.sfx.ball);
if (boost_t > 0)
{
    if (--boost_t == 0) boost_cd = 20;
    if (_g.frame mod 3 == 0) _g.burst(x, y, skin.colour, 2);
}
var _dashing = boost_t > 0 && skin.boost == "dash";

// ---------- Run ----------
var _dir = _right - _left;
if (_dir != 0 && !on_ground) vjump = false;     // steering in the air: not straight up any more
var _max = _dashing ? boost_speed : (ball ? ball_max : run_max);
if (_dir != 0)
{
    vx += _dir * (ball ? 0.25 : run_accel) * (on_ground ? 1 : 0.7);
    if (tongue_t == 0) facing = _dir;
}
else if (on_ground)
{
    vx = ball ? vx * 0.985 : approach(vx, 0, 0.4);
}
vx = clamp(vx, -_max, _max);
if (_dashing) vx = boost_dir * boost_speed;
if (ball) ball_angle -= vx * 4;

// ---------- Water: swimming at the surface ----------
// In water the snake is held up (it floats with its head out), swims a little slower and
// can jump out from the surface as if from the ground.
var _swim = water_at(x, y);
var _surface = _swim && !water_at(x, y - 14);
if (_swim)
{
    if (!_dashing)
    {
        vx = clamp(vx, -2.6, 2.6);
        if (_dir == 0) vx = approach(vx, 0, 0.12);
    }
    if (_surface) coyote = 6;
    air_jump_ready = true;
    copter_arm = false;
    if (!was_swim && vy > 2)
    {
        _g.burst(x, y - 4, make_colour_rgb(170, 230, 255), 12);
        _g.play_sfx(_g.sfx.splash);
    }
}
was_swim = _swim;

// ---------- Jump, coyote time, jump buffer, drop through logs ----------
if (on_ground) coyote = 6; else if (coyote > 0) coyote--;
if (_jump_pressed) jump_buffer = 6; else if (jump_buffer > 0) jump_buffer--;
drop_through = false;
var _jumped = false;
if (jump_buffer > 0 && coyote > 0)
{
    if (_down && on_ground && row_oneway(y + hh + 2, x - hw + 1, x + hw - 1) && !row_blocked(y + hh + 2, x - hw + 1, x + hw - 1))
    {
        drop_through = true;
        y += 2;
    }
    else
    {
        vy = -jump_speed * (ball ? 1.08 : 1);
        vjump = (_dir == 0 && abs(vx) < 1);     // straight up (for the Slingshot)
        _jumped = true;
        _g.play_sfx(_g.sfx.jump);
        part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 4);
    }
    jump_buffer = 0;
    coyote = 0;
}
// Red snake: one extra jump in mid-air, refilled on landing.
else if (skin.double_jump && _jump_pressed && !on_ground && air_jump_ready)
{
    air_jump_ready = false;
    jump_buffer = 0;
    vy = -jump_speed * 0.85;
    _g.play_sfx(_g.sfx.jump);
    part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 6);
}
if (on_ground) air_jump_ready = true;
// Green snake: the helicopter needs a second press of Jump in the air (holding the jump
// that took off isn't enough); after that, holding Jump keeps it going.
if (on_ground) copter_arm = false;
else if (_jump_pressed && !_jumped && !skin.double_jump) copter_arm = true;
// Let go early for a shorter jump (but never cut a rocket boost or a spring launch short).
if (vy >= 0) sprung = false;
if (!_jump_held && vy < -3 && !sprung && !(boost_t > 0 && skin.boost == "up")) vy *= 0.6;

// ---------- Gravity and the tail-spin glide (green snake only) ----------
vy = min(vy + gravity_pull, fall_max);
// The red dash flies straight ahead, holding its height.
if (_dashing) vy = 0;
if (_swim && !_jumped)
{
    vy -= gravity_pull;                                  // the water holds the snake up...
    if (!_surface) { if (vy > -3) vy = max(vy - 0.4, -3); }  // ...under: it floats up
    else if (vy > 0) vy *= 0.7;                          // at the surface it bobs to rest
    if (vy > 3) vy = lerp(vy, 3, 0.3);                   // diving in: the water slows the fall
}
copter = !skin.double_jump && !ball && !on_ground && !_swim && copter_arm && _jump_held && vy > 0;
if (copter)
{
    vy = min(vy, 1.2);
    if (_g.frame mod 8 == 0) _g.play_sfx(_g.sfx.copter);
}

// ---------- A rolling ball smashes cracked blocks ----------
if (ball)
{
    var _ahead = x + sign(vx) * (hw + 6);
    for (var _yy = y - hh + 2; _yy <= y + hh - 2; _yy += 10)
    {
        if (abs(vx) > 2.5 && tile_at(_ahead, _yy) == T_CRACK) smash(floor(_ahead / TILE), floor(_yy / TILE));
    }
    if (vy > 2) for (var _xx = x - hw + 2; _xx <= x + hw - 2; _xx += 9) if (tile_at(_xx, y + hh + 4) == T_CRACK) smash(floor(_xx / TILE), floor((y + hh + 4) / TILE));
}

// ---------- Currents drag the snake along (sideways in a lake, up a spout, down a fall) ----------
var _cur = current_at(x, y);
var _own_vx = vx;
if (!is_undefined(_cur))
{
    vx += _cur.vx;
    if (_cur.vy != 0) vy = approach(vy, _cur.vy, 0.8);
}

// ---------- Move ----------
var _was_air = !on_ground;
var _fall_speed = vy;
entity_move();
// The drag isn't the snake's own speed: it keeps only its own (unless a wall stopped it).
if (!is_undefined(_cur) && hit_wall == 0) vx = _own_vx;
if (on_ground && _was_air && _fall_speed > 4) part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 5);
if (ball && hit_wall != 0)
{
    vx = -hit_wall * 2;
    _g.play_sfx(_g.sfx.ball);
    // A dash ends when it hits a wall.
    if (_dashing) { boost_t = 0; boost_cd = 20; }
}

// The level's bottom is a bottomless pit.
if (y > _g.lvl_h * TILE + 40)
{
    _g.player_died(id);
    exit;
}
if (touching_spikes() && invuln == 0)
{
    vy = -7;
    take_hit();
}

// ---------- Tongue: lash out, hold, pull back ----------
if (_tongue && tongue_t == 0 && !ball)
{
    tongue_t = 1;
    _g.play_sfx(_g.sfx.tongue);
}
if (tongue_t > 0)
{
    tongue_t++;
    tongue_len = (tongue_t <= 7) ? tongue_t / 7 * 104 : (tongue_t <= 11 ? 104 : max(0, 104 - (tongue_t - 11) / 8 * 104));
    if (tongue_t > 19) { tongue_t = 0; tongue_len = 0; }
    var _mx = mouth_x();
    var _my = mouth_y();
    var _tip = _mx + facing * tongue_len;
    if (tongue_t <= 11)
    {
        // Anything the tongue touches: creatures are knocked out, items are pulled in.
        with (obj_enemy) if (!is_harmless() && point_segment_distance(x, y, _mx, _my, _tip, _my) < hh + 4)
        {
            if (boost_only) clank();    // a skeleton: the tongue just clanks off its bones
            else kill(1, other.id);
        }
        with (obj_pickup) if (!grabbed && point_segment_distance(x, y, _mx, _my, _tip, _my) < 16) { grabbed = true; grabber = other.id; _g.play_sfx(_g.sfx.slurp); }
        // The tongue also swats a boss's cheese and feathers out of the air (not boulders or puddles).
        with (obj_hazard) if (!lasts() && point_segment_distance(x, y, _mx, _my, _tip, _my) < 12)
        {
            _g.burst(x, y, c_white, 6);
            if (_g.net_mode == "client") { _g.net_gone[$ string(net_id)] = true; _g.net_event({ t: "hazard", i: net_id }); }
            instance_destroy();
        }
    }
}

// ---------- Creatures ----------
with (obj_enemy)
{
    // A little mole under the ground is only a mound: nothing happens.
    if (!is_harmless() && abs(x - other.x) < hw + other.hw && abs(y - other.y) < hh + other.hh)
    {
        var _is_boss = object_is_ancestor(object_index, obj_boss);
        if (other.boost_t > 0)
        {
            // Only a boost knocks creatures out. (A boss loses 1 health; the Slingshot takes 2.)
            kill(1, other.id);
            // A boss is too big to boost through: the ball bounces off it and the boost ends.
            if (_is_boss && instance_exists(id))
            {
                other.vx = sign(other.x - x) * 5;
                other.vy = -5;
                other.boost_t = 0;
                other.boost_cd = 20;
            }
        }
        // A plain roll can't stomp: rolling into a creature always hurts the snake.
        else if (!other.ball && other.vy > 1.5 && other.y < y - 4)
        {
            if (boost_only)
            {
                // A skeleton: the snake bounces off its skull, and nobody gets hurt.
                clank();
                other.vy = -8;
            }
            else if (_is_boss && spiky_back())
            {
                // Bristling fur: landing on it hurts, and throws the snake off.
                other.vy = -8;
                if (other.invuln == 0) with (other) take_hit(sign(x - other.x));
            }
            else
            {
                kill(1, other.id);      // a stomp: a boss loses 1 health (the Slingshot takes 2)
                other.vy = _is_boss ? -10 : -7;
            }
        }
        // Just after a hit a boss can't hurt the snake bouncing off it. The bristling cat stays
        // dangerous for most of that time, so her Fur Storm pounce still counts.
        else if (other.invuln == 0 && !(_is_boss && hurt_t > (spiky_back() ? 78 : 30))) with (other) take_hit(sign(x - other.x));
    }
}

// ---------- Items, springs, the checkpoint and the door ----------
with (obj_pickup) if (!grabbed && abs(x - other.x) < 18 && abs(y - other.y) < 20) collect_now(other.id);
// A spring fires the moment the snake's feet touch its pad from above: landing on it,
// or simply walking onto it. The pad is 32 px wide, so anywhere over it counts.
with (obj_spring)
{
    var _feet = other.y + other.hh;
    if (other.vy >= 0 && abs(x - other.x) < 16 + other.hw - 2 && _feet >= y - 30 && _feet <= y + 1)
    {
        other.vy = -15;     // rises ~240 px: clears 7 tiles
        other.sprung = true;
        squash = 12;
        _g.play_sfx(_g.sfx.spring);
    }
}
with (obj_flag)
{
    // Each snake has its own checkpoint: the last flag it touched.
    if (!reached[other.pid] && abs(x - other.x) < 20 && abs((y - 24) - other.y) < 30)
    {
        reached[other.pid] = true;
        image_index = 1;
        other.stats.checkpoint_x = x;
        other.stats.checkpoint_y = y - 12;
        _g.play_sfx(_g.sfx.flag);
        _g.say("CHECKPOINT!", 90, other.stats);
        if (_g.net_mode == "client") _g.net_event({ t: "flag", x: x, y: y - 12 });
    }
}
with (obj_door)
{
    if (abs(x - other.x) < 16 && abs((y - 30) - other.y) < 34)
    {
        if (open) _g.level_complete();
        else if (hint_cooldown == 0)
        {
            hint_cooldown = 150;
            var _todo = array_length(word_hidden_letters(_g.word, _g.guessed));
            _g.say("LOCKED! " + string(_todo) + " LETTER" + (_todo == 1 ? "" : "S") + " TO GO", 120, other.stats);
        }
    }
}

// ---------- The body follows like a rope ----------
update_body();

// ---------- Face ----------
if (invuln > 90) image_index = 3;
else if (tongue_t > 0) image_index = 2;
else if (blink > 0) image_index = 1;
else image_index = 0;
