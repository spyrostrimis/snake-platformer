/// Count Skeeterfang: a huge, blood-mad mosquito with a missile launcher strapped to its tail.
/// It flies over the beach and:
/// Missile salvo: fires missiles straight up from its tail; they come straight down on the
/// snakes a moment later (a red mark on the sand shows where). 3 at a time, 5 when angry.
/// Dash: stops, stares (eyes blazing) and rockets at a snake needle first, crashing down onto
/// the sand. There it's dazed for a while: stomp it, lash it with the tongue, boost into it.
/// Up high, bounce off an umbrella to stomp it.
/// Frames: wings up, wings down, launching, dashing, dazed, aiming.
event_inherited();
boss_name = "COUNT SKEETERFANG";
hw = 56;
hh = 38;
hp_max = 12;
hp = hp_max;
points = 45000;
facing = -1;
state = "hover";        // hover | launch | aim | dash | dazed | rise | recoil
timer = 80;
last_hp = hp;
shots = 0;
dash_vx = 0;
dash_vy = 0;
dashes = 0;             // angry: two dashes in a row
t = 0;
ready = false;          // its flying height is worked out on the first step
ground_y = y + hh;
hover_y = y - 150;

/// Fires one missile up out of the launcher, and drops one straight down at snake _p.
fire_missile = function(_p, _spread)
{
    var _g = obj_game;
    var _tx = x - facing * 80;
    var _up = shoot(spr_missile, _tx, y - 40, 0, -9, 0);
    _up.spin = false;
    _up.image_angle = 90;
    _up.life = 34;
    var _aim = (_p != noone) ? _p.x : x;
    _aim = clamp(_aim + irandom_range(-_spread, _spread), arena_x1 - 64, arena_x2 + 64);
    var _down = shoot(spr_missile, _aim, 8, 0, 2, 0.22);
    _down.spin = false;
    _down.image_angle = 270;
    _down.life = 400;
    _g.play_sfx(_g.sfx.throw_);
};
