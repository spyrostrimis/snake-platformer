/// The super egg, two players only. The first snake to touch it (or tongue it) hatches it;
/// after that only the OTHER snake can eat it, and it fills all of that snake's hearts.
/// Online the host's word on who hatched it wins, and the eating goes through the host
/// like any other item.
event_inherited();
hatched = false;
hatcher = -1;           // pid of the snake that hatched it
hint_frame = 0;         // when the hatcher may be reminded again

/// Cracks the egg open for the snake with pid _pid.
hatch = function(_pid)
{
    var _g = obj_game;
    hatched = true;
    hatcher = _pid;
    grabbed = false;
    grabber = noone;
    x = xstart;
    base_y = ystart;
    _g.play_sfx(_g.sfx.smash);
    _g.play_sfx(_g.sfx.right);
    _g.burst(x, y, make_colour_rgb(255, 220, 90), 22);
    // The host (or an offline game) announces it; online it reaches the joiner too.
    if (_g.net_mode != "client" && array_length(_g.pl) == 2)
    {
        _g.say(_g.pl[_pid].skin.name + " HATCHED A SUPER EGG!", 150);
        _g.say("ONLY " + _g.pl[1 - _pid].skin.name + " CAN EAT IT", 150);
    }
};

on_collect = function(_by)
{
    var _g = obj_game;
    var _p = stats_of(_by);
    _p.hearts = 5;
    _g.add_score(500, x, y - 16, _p);
    _g.play_sfx(_g.sfx.gulp);
    _g.burst(x, y, make_colour_rgb(255, 90, 130), 24);
    _g.say("SUPER EGG! ALL HEARTS FULL", 120, _p);
    if (instance_exists(_by)) _by.gulp_t = 45;
};
client_fx = function(_by)
{
    obj_game.play_sfx(obj_game.sfx.gulp);
    obj_game.burst(x, y, make_colour_rgb(255, 90, 130), 24);
    if (instance_exists(_by)) _by.gulp_t = 45;
};

/// Touched (or tongued in) by snake _by.
collect_now = function(_by)
{
    var _g = obj_game;
    if (!instance_exists(_by)) return;
    var _pid = _by.pid;
    if (!hatched)
    {
        hatch(_pid);
        if (_g.net_mode != "") _g.net_event({ t: "shatch", i: net_id, by: _pid });
        return;
    }
    if (_pid == hatcher)
    {
        // The snake that hatched it can't eat it: back it goes, with a reminder.
        grabbed = false;
        grabber = noone;
        x = xstart;
        base_y = ystart;
        if (_g.frame >= hint_frame)
        {
            hint_frame = _g.frame + 150;
            _g.say("LEAVE IT FOR YOUR PARTNER!", 90, _by.stats);
        }
        return;
    }
    // The other snake eats it.
    if (_g.net_mode == "client")
    {
        client_fx(_by);
        _g.net_event({ t: "collect", i: net_id });
        instance_destroy();
        return;
    }
    on_collect(_by);
    if (_g.net_mode == "host") _g.net_event({ t: "took", i: net_id });
    instance_destroy();
};
