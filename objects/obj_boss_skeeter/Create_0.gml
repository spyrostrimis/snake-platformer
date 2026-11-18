/// Count Skeeterfang: a huge, blood-mad mosquito with a missile launcher strapped to its tail.
/// It flies over the beach and:
/// Missile run: it zooms straight up and off the top of the screen. Up there, out of reach, it
/// flies over the snakes, firing missiles straight down from its tail launcher (a red mark on
/// the sand shows where each will land): 3 of them, 5 when angry. Then it dives back down.
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
state = "hover";        // hover | climb | bomb | return | aim | dash | dazed | rise | recoil
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
high_y = -110;          // up above the top of the level, off the screen, for its missile run

// It counts as being in its arena while it's up off the screen, too.
snake_in_arena = function(_p)
{
    return instance_exists(_p) && !_p.hidden && _p.x > arena_x1 - 16 && _p.x < arena_x2 + 16 && abs(_p.y - hover_y) < 240;
};

/// Fires one missile straight down out of the launcher on its tail (right under it, as it
/// curls its tail beneath itself up there).
fire_missile = function()
{
    var _g = obj_game;
    var _m = shoot(spr_missile, x, y + 30, 0, 2, 0.22);
    _m.spin = false;
    _m.image_angle = 270;
    _m.life = 400;
    _g.play_sfx(_g.sfx.throw_);
};
