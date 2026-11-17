/// A Box Snake Egg: with two players, a snake that runs out of lives curls up into one where
/// it last stood safely, and watches its friend's screen. The friend breaks it open (three
/// hits: tongue, stomp, boost or a fast roll) and the snake comes back with one life.
/// pid (the snake inside) is set by instance_create_layer. Online both PCs have the egg; the
/// PC of the snake doing the hitting counts the hits, and the host brings the snake back.

hits = 0;
hits_max = 3;
hit_cd = 0;             // frames before the next hit counts (one per tongue lash)
shake_t = 0;            // frames of wobble after a hit
fall_v = 0;
broken = false;         // online joiner: broken here, waiting for the host to bring it back
hint_frame = 0;         // when the friend may be told again how to break it
image_speed = 0;

/// The snake that is inside.
skin_of = function() { return obj_game.pl[pid].skin; };

/// Shows a hit (here or reported by the other PC): wobble, crack, sparkle.
show_hit = function()
{
    var _g = obj_game;
    shake_t = 14;
    _g.play_sfx(_g.sfx.bonk);
    _g.burst(x, y - 8, make_colour_rgb(255, 240, 200), 8);
    part_particles_create(_g.ps, x, y - 6, _g.pt_rock, 4);
};

/// Snake _by hit the egg.
hit_by = function(_by)
{
    if (hit_cd > 0 || broken) return;
    var _g = obj_game;
    hit_cd = 18;
    hits++;
    show_hit();
    if (_g.net_mode != "") _g.net_event({ t: "ehit", p: pid, n: hits });
    if (hits >= hits_max) break_open();
    else _g.say(string(hits_max - hits) + " MORE HIT" + ((hits_max - hits == 1) ? "" : "S") + "!", 60, _by.stats);
};

/// The last hit: the shell flies apart and the snake comes back.
break_open = function()
{
    var _g = obj_game;
    broken = true;
    _g.play_sfx(_g.sfx.smash);
    _g.burst(x, y - 8, skin_of().colour, 26);
    part_particles_create(_g.ps, x, y - 8, _g.pt_rock, 14);
    // Online, the host keeps the lives: the joiner asks it to bring the snake back.
    if (_g.net_mode == "client") _g.net_event({ t: "ebreak", p: pid });
    else _g.revive_player(pid, x, y);
};
