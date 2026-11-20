/// A Snake Egg: with two players, a snake that runs out of lives comes back in a giant shiny
/// egg in its own colour (green for Peto, red for Sockee), floating down under a parachute
/// to where it last stood safely; meanwhile it watches its friend's screen. The friend hits
/// it (tongue, stomp, boost or a fast roll) and it hatches: the shell cracks, the top lifts
/// off, the snake's head peeks out, and it jumps out with one life.
/// pid (the snake inside) is set by instance_create_layer, at the spot it lands on. Online
/// both PCs have the egg; the PC of the snake that hits it tells the other, and once it has
/// hatched the host brings the snake back.

hits = 0;
hits_max = 1;
hit_cd = 0;
shake_t = 0;            // frames of wobble after a hit
fall_v = 0;
broken = false;         // online joiner: hatched here, waiting for the host to bring it back
hint_frame = 0;         // when the friend may be told again how to hatch it
image_speed = 0;
land_y = y;             // where it lands
y = land_y - 360;       // it starts high up, under its parachute
landed = false;
chute = 1;              // the parachute: 1 open, shrinking to 0 once it lands
t = 0;
hatching = false;       // cracked open: the snake is coming out
hatch_t = 0;
i_broke = false;        // this PC's snake hit it (so this PC finishes the hatching)
#macro EGG_HATCH 48     // frames from the crack to the snake jumping out

/// The snake that is inside.
skin_of = function() { return obj_game.pl[pid].skin; };

/// Shows a hit (here or reported by the other PC): the egg cracks and starts to hatch.
show_hit = function()
{
    var _g = obj_game;
    shake_t = 14;
    _g.play_sfx(_g.sfx.bonk);
    _g.burst(x, y - 20, make_colour_rgb(255, 255, 255), 10);
    if (hits >= hits_max && !hatching)
    {
        hatching = true;
        hatch_t = 0;
        _g.play_sfx(_g.sfx.smash);
        part_particles_create(_g.ps, x, y - 26, _g.pt_rock, 8);
    }
};

/// Snake _by hit the egg.
hit_by = function(_by)
{
    if (hit_cd > 0 || broken || hatching || !landed) return;
    var _g = obj_game;
    hit_cd = 18;
    hits++;
    i_broke = true;
    show_hit();
    if (_g.net_mode != "") _g.net_event({ t: "ehit", p: pid, n: hits });
};

/// Hatched: the shell flies apart and the snake jumps out.
break_open = function()
{
    var _g = obj_game;
    broken = true;
    _g.play_sfx(_g.sfx.oneup);
    _g.burst(x, y - 20, skin_of().colour, 26);
    _g.burst(x, y - 20, c_white, 14);
    // Online, the host keeps the lives: the joiner asks it to bring the snake back.
    if (_g.net_mode == "client") _g.net_event({ t: "ebreak", p: pid });
    else _g.revive_player(pid, x, y);
};

/// The egg's outline (centre (_cx, _cy)), as [x, y] points round it, top first.
egg_points = function(_cx, _cy)
{
    var _pts = [];
    for (var _i = 0; _i < 32; _i++)
    {
        var _a = _i / 32 * 2 * pi;
        var _c = cos(_a);
        // Narrower at the top, rounder at the bottom.
        var _rx = 24 * (1 - 0.12 * _c);
        array_push(_pts, [_cx + sin(_a) * _rx, _cy - _c * 31]);
    }
    return _pts;
};
