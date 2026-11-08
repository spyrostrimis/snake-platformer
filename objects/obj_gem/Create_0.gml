/// A spinning red gem: points. Every 10th gem a snake collects gives it an extra life.
event_inherited();
spin = true;
on_collect = function(_by)
{
    var _g = obj_game;
    var _p = stats_of(_by);
    _p.gems++;
    _g.add_score(100, undefined, undefined, _p);
    _g.play_sfx(_g.sfx.gem);
    _g.burst(x, y, make_colour_rgb(255, 80, 120), 6);
    if (_p.gems mod 10 == 0)
    {
        // (Online the joiner's lives and messages travel to its PC with the host's world.)
        _p.lives_left = min(_p.lives_left + 1, 99);
        _g.play_sfx(_g.sfx.oneup);
        _g.burst(x, y, make_colour_rgb(120, 255, 140), 20);
        _g.say("10 GEMS! EXTRA LIFE!", 120, _p);
    }
};
client_fx = function(_by)
{
    obj_game.play_sfx(obj_game.sfx.gem);
    obj_game.burst(x, y, make_colour_rgb(255, 80, 120), 6);
};
