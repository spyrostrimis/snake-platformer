/// Captain Octavius, the octopus pirate who rules the sunken ship. Eight arms, a cutlass in
/// each. At rest his arms are an ordinary length; when he strikes they stretch out a very long
/// way (over 10 tiles) and snap back. After drawing his swords back (the warning):
/// Thrust: three arms shoot out ahead of him, low along the floor (jump them) or high at a
/// snake up on a plank (stay down).
/// Low sweep: swords swept along the floor on both sides (jump, or stand on a plank).
/// High slash: swords slashed out at head height on both sides (stay down on the floor).
/// Angry (half health), he follows a sweep straight up with a slash.
/// Stomp his hat, boost or lash him with the tongue to hurt him. Right after a hit he's all
/// flailing blades: landing on him then hurts, and he backs off.
/// image_index (shared online): 0/1 idle, 2 wind-up, 3 low thrust, 4 sweep, 5 slash, 6 hurt,
/// 7 high thrust. The body sprite has a frame for each (idle, angry or hurt); the arms are drawn
/// in code.
event_inherited();
boss_name = "CAPTAIN OCTAVIUS";
hw = 38;
hh = 60;
hp_max = 12;
hp = hp_max;
points = 35000;
music = "music_04.ogg";
drop_through = true;
state = "walk";         // walk | windup | strike | hurt | back
timer = 90;
last_hp = hp;
attack = "thrust";      // the attack the wind-up leads to: thrust | sweep | slash
thrust_high = false;    // a thrust aimed at a snake up high (frame 7) or along the floor (3)
combo = false;          // angry: a sweep followed by a slash
reach = 0;              // how far the striking arms are stretched out (0..1), on both PCs
pose_f = 3;             // the strike the arms are stretched for (kept while they snap back)

spiky_back = function() { return hurt_t > 0; };

// ---------- His arms (relative to his middle, as if facing right; floor at +60) ----------
// Where each arm grows from his lower edge.
arm_bx = [-34, -25, -14, -5, 5, 14, 25, 34];
arm_by = [24, 30, 34, 36, 36, 34, 30, 24];
// At rest: hand x, hand y, sword angle (degrees) for each arm.
pose_idle = [[-58, -6, 140], [-56, 26, 175], [-40, 56, 190], [-16, 58, 200], [16, 58, -20], [40, 56, -10], [56, 26, 5], [58, -6, 40]];
pose_wind = [[-40, -32, 110], [-48, 0, 150], [-44, 40, 200], [-16, 58, 200], [16, 58, -20], [44, 40, -20], [48, 0, 30], [40, -32, 70]];
// Fully stretched, for each strike. Arms not in the strike stay as at rest.
pose_strike = {};
pose_strike[$ "3"] = [undefined, undefined, undefined, undefined, undefined, [300, 34, 0], [330, 46, 0], [348, 54, 0]];
pose_strike[$ "7"] = [undefined, undefined, undefined, undefined, undefined, [300, -18, 0], [330, -34, 0], [348, -50, 0]];
pose_strike[$ "4"] = [[-298, 54, 180], [-250, 54, 180], [-180, 54, 180], [-110, 54, 180], [110, 54, 0], [180, 54, 0], [250, 54, 0], [298, 54, 0]];
pose_strike[$ "5"] = [[-288, -44, 180], [-240, -22, 180], [-180, 0, 180], undefined, undefined, [180, 0, 0], [240, -22, 0], [288, -44, 0]];

/// Arm _k's hand as [x, y, sword angle] in the room, for the current frame and stretch.
arm_hand = function(_k)
{
    var _f = floor(image_index);
    var _rest = pose_idle[_k];
    var _hx = _rest[0];
    var _hy = _rest[1] + ((_k == 0 || _k == 1 || _k == 6 || _k == 7) ? sin(obj_game.frame * 0.09 + _k) * 3 : 0);
    var _a = _rest[2];
    if (_f == 2) { _hx = pose_wind[_k][0]; _hy = pose_wind[_k][1]; _a = pose_wind[_k][2]; }
    var _sf = (_f == 3 || _f == 4 || _f == 5 || _f == 7) ? _f : pose_f;
    var _target = pose_strike[$ string(_sf)][_k];
    if (reach > 0 && !is_undefined(_target))
    {
        // Stretched out in a straight line from where it rests (it bulges a little on the way).
        var _e = reach;
        _hx = lerp(_hx, _target[0], _e);
        _hy = lerp(_hy, _target[1], _e);
        _a = (_e > 0.5) ? _target[2] : _a;
    }
    if (facing < 0) { _hx = -_hx; _a = 180 - _a; }
    return [x + _hx, y + _hy, _a];
};

/// Stretches the striking arms out and lets them snap back. Only uses image_index, so online
/// both PCs agree.
update_arms = function()
{
    var _f = floor(image_index);
    if (_f == 3 || _f == 4 || _f == 5 || _f == 7)
    {
        if (_f != pose_f) reach = 0;
        pose_f = _f;
        reach = min(1, reach + 0.2);
    }
    else reach = max(0, reach - 0.2);
};

/// This PC's snakes inside the box (_x1.._x2, _y1.._y2) get hurt, pushed towards _dir.
blade_zone = function(_x1, _x2, _y1, _y2, _dir)
{
    var _l = min(_x1, _x2);
    var _r = max(_x1, _x2);
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && x + hw > _l && x - hw < _r && y + hh > _y1 && y - hh < _y2) take_hit(_dir);
    }
};

/// The swords hurt while they're out, as far as the arms have stretched. Only uses x, facing,
/// image_index and reach, so online each PC checks its own snake.
blade_check = function()
{
    var _f = floor(image_index);
    if (reach < 0.3) return;
    if (_f == 3) blade_zone(x + facing * 36, x + facing * (36 + 354 * reach), y + 26, y + 62, facing);
    else if (_f == 7) blade_zone(x + facing * 36, x + facing * (36 + 354 * reach), y - 64, y - 14, facing);
    else if (_f == 4)
    {
        blade_zone(x + 36, x + 36 + 304 * reach, y + 38, y + 62, 1);
        blade_zone(x - 36 - 304 * reach, x - 36, y + 38, y + 62, -1);
    }
    else if (_f == 5)
    {
        blade_zone(x + 36, x + 36 + 294 * reach, y - 64, y + 8, 1);
        blade_zone(x - 36 - 294 * reach, x - 36, y - 64, y + 8, -1);
    }
};
