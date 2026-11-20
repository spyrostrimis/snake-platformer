/// Captain Octavius, the octopus pirate who rules the sunken ship. Eight arms, a cutlass in
/// each, and he fights like a fencer:
/// On guard, his eight blades ring him round like a wall of steel: the tongue, a stomp or a
/// boost only clangs off them (the steel shimmers). Then he attacks with a few of his arms at
/// a time, slowly: they draw back (the warning), stretch out a long way and sweep their blades
/// round, each at its own angle, one after another. Only while those arms are out swinging is
/// he open, and only on the side they left: watch which arms go, dodge the blade tips, and hit
/// him from that side.
///   front: three arms sweep down in front of him, high to low (he's open in front)
///   back:  three arms swing over his head from behind (open at the back)
///   top:   two arms rise and slam down on both sides (open on top: stomp him)
///   low:   four arms sweep out along the floor both ways (open low down, on both sides)
/// Angry (half health) he swings faster and attacks more often.
/// Online, image_index carries his pose (both PCs work his arms out from it; see pose_code):
/// 0/1 on guard, 2 hurt, 8 + pattern * 24 + stage * 8 + step for an attack.
event_inherited();
boss_name = "CAPTAIN OCTAVIUS";
hw = 38;
hh = 60;
hp_max = 10;
hp = hp_max;
points = 35000;
music = "music_04.ogg";
drop_through = true;
image_speed = 0;
state = "guard";        // guard | attack | hurt | back
timer = 90;
last_hp = hp;
pat = 0;                // the attack (0 front, 1 back, 2 top, 3 low)
prog = 0;               // its progress: 0..1 drawing back, 1..2 swinging, 2..3 back on guard
clang_t = 0;            // the steel shimmering (an attack that clanged off)
clang_x = 0;
clang_y = 0;
spiky_back = function() { return hurt_t > 0; };    // right after a hit he flails: landing on him hurts
#macro OCTO_REACH 230   // how far an arm stretches when it swings (to the blade's hilt)
#macro OCTO_GUARD 62    // the radius of his ring of blades on guard

// ---------- His arms. Angles are in degrees as if he faced right (0 = in front, 90 = up). ----------
// Where each arm grows from his lower edge, and the angle it guards (a ring all round him).
arm_bx = [20, 14, -14, -20, -26, -10, 10, 26];
arm_by = [24, 30, 30, 24, 30, 36, 36, 30];
arm_guard = [22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5];
// The attacks: for each arm that swings, [arm, start angle, end angle, lag (when it starts,
// 0..0.3 of the swing)]. Arms not in an attack stay on guard.
patterns = [
    [[1, 105, -12, 0], [0, 82, -22, 0.15], [7, 60, -30, 0.3]],                  // front
    [[3, 200, 25, 0], [2, 178, 8, 0.15], [4, 215, 40, 0.3]],                     // back
    [[1, 92, -15, 0], [2, 88, 195, 0]],                                          // top
    [[6, 285, 355, 0], [5, 255, 185, 0], [7, 320, 360, 0.15], [4, 220, 180, 0.15]] // low
];

/// The attack's length in steps: drawing back, swinging, back on guard.
stage_len = function(_stage)
{
    var _angry = hp <= hp_max / 2;
    if (_stage == 0) return _angry ? 34 : 46;
    if (_stage == 1) return _angry ? 120 : 165;
    return 36;
};

/// The pose as one number for image_index (see the top): both PCs read his arms from it.
pose_code = function()
{
    if (state == "attack") return 8 + pat * 24 + floor(prog) * 8 + clamp(floor(frac(prog) * 8), 0, 7);
    if (state == "hurt") return 2;
    return (obj_game.frame div 30) mod 2;
};

/// The swing's own progress (0..1) for arm entry _e of the attack.
arm_swing = function(_e)
{
    var _s = clamp(prog - 1, 0, 1);
    return clamp((_s - _e[3]) / 0.7, 0, 1);
};

/// Arm _k's hand as [x, y, blade angle] in the room (and whether it's swinging, as [3]).
arm_hand = function(_k)
{
    var _g = arm_guard[_k];
    // On guard: round him in a ring, the blades fanned out, swaying a little.
    var _sway = sin(obj_game.frame * 0.05 + _k) * 4;
    var _a = _g + _sway;
    var _r = OCTO_GUARD;
    var _blade = _g + 70;
    var _out = false;
    if (state == "attack")
    {
        var _list = patterns[pat];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (_e[0] != _k) continue;
            if (prog < 1)
            {
                // Drawing back to where the swing starts.
                var _w = prog;
                _a = lerp(_g, _e[1], _w);
                _r = lerp(OCTO_GUARD, 78, _w);
                _blade = lerp(_g + 70, _e[1], _w);
            }
            else if (prog < 2)
            {
                // Out at full stretch, sweeping round, slowly.
                var _s = arm_swing(_e);
                _a = lerp(_e[1], _e[2], _s);
                _r = lerp(78, OCTO_REACH, clamp((prog - 1 - _e[3]) * 6, 0, 1));
                _blade = _a;
                _out = true;
            }
            else
            {
                // Back on guard.
                var _w = prog - 2;
                _a = lerp(_e[2], _g, _w);
                _r = lerp(OCTO_REACH, OCTO_GUARD, min(1, _w * 1.5));
                _blade = lerp(_e[2], _g + 70, _w);
            }
        }
    }
    var _hx = lengthdir_x(_r, _a);
    var _hy = lengthdir_y(_r, _a);
    // A blade swept low slides along the floor instead of going through it.
    _hy = min(_hy, hh - 8);
    if (facing < 0) { _hx = -_hx; _blade = 180 - _blade; }
    return [x + _hx, y + _hy, _blade, _out];
};

/// True if an attack from (_px, _py) gets past his blades: only while arms are out swinging,
/// and only from the side they left (their part of the ring, give or take).
is_open = function(_px, _py)
{
    if (state != "attack" || prog < 1 || prog >= 2.1) return false;
    var _th = point_direction(x, y, _px, _py);
    if (facing < 0) _th = 180 - _th;
    var _list = patterns[pat];
    for (var _i = 0; _i < array_length(_list); _i++)
    {
        if (abs(angle_difference(_th, arm_guard[_list[_i][0]])) < 38) return true;
    }
    return false;
};

/// An attack from snake _by clanged off his blades: the steel shimmers where it hit.
clang_off = function(_by)
{
    var _g = obj_game;
    var _a = point_direction(x, y, _by.x, _by.y);
    clang_x = x + lengthdir_x(OCTO_GUARD, _a);
    clang_y = y + lengthdir_y(OCTO_GUARD, _a);
    if (clang_t < 10)
    {
        _g.play_sfx(_g.sfx.clank);
        _g.burst(clang_x, clang_y, c_white, 8);
        _g.burst(clang_x, clang_y, make_colour_rgb(190, 220, 255), 6);
    }
    clang_t = 24;
};

/// A hit only counts where he's open; anywhere else it clangs off his blades.
base_kill = kill;
kill = function(_dmg = 1, _by = noone)
{
    if (active && hurt_t == 0 && instance_exists(_by) && !is_open(_by.x, _by.y)) { clang_off(_by); return; }
    base_kill(_dmg, _by);
};

/// The swinging blades hurt this PC's snakes that they touch (the blade from its hilt out).
/// Only uses what both PCs know (x, facing and his pose), so online each PC checks its own.
blade_check = function()
{
    if (state != "attack" || prog < 1 || prog >= 2) return;
    for (var _k = 0; _k < 8; _k++)
    {
        var _h = arm_hand(_k);
        if (!_h[3]) continue;
        var _tx = _h[0] + lengthdir_x(40, _h[2]);
        var _ty = _h[1] + lengthdir_y(40, _h[2]);
        var _ox = x;
        with (obj_player)
        {
            if (!remote && !hidden && invuln == 0 && point_segment_distance(x, y, _h[0], _h[1], _tx, _ty) < hw + 6) take_hit(sign(x - _ox));
        }
    }
};
