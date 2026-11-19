/// A super gem: as good as 10 gems (so it always brings an extra life too). Put somewhere only
/// a combo move gets to: up a ledge for THE SLINGSHOT, or behind speed blocks.
event_inherited();
spin = true;
on_collect = function(_by)
{
    var _g = obj_game;
    var _p = stats_of(_by);
    var _lives_before = _p.gems div 10;
    _p.gems += 10;
    _g.add_score(1000, x, y - 10, _p);
    _p.lives_left = min(_p.lives_left + (_p.gems div 10 - _lives_before), 99);
    _g.play_sfx(_g.sfx.gem);
    _g.play_sfx(_g.sfx.oneup);
    _g.burst(x, y, make_colour_rgb(255, 200, 60), 24);
    _g.burst(x, y, make_colour_rgb(255, 80, 140), 16);
    _g.say("SUPER GEM! +10 GEMS AND AN EXTRA LIFE!", 150, _p);
};
client_fx = function(_by)
{
    obj_game.play_sfx(obj_game.sfx.gem);
    obj_game.play_sfx(obj_game.sfx.oneup);
    obj_game.burst(x, y, make_colour_rgb(255, 200, 60), 24);
};
