/// Rests on the ground (falling if the ground under it goes), and is broken by the friend.
var _g = obj_game;
if (_g.state != "play") exit;
if (hit_cd > 0) hit_cd--;
if (shake_t > 0) shake_t--;
if (broken) exit;

// Settle on the floor (logs and spikes count); in water it just floats where it is.
if (!water_at(x, y))
{
    var _t = tile_at(x, y + 13);
    if (!is_blocking(_t) && _t != T_ONEWAY && _t != T_SPIKES)
    {
        fall_v = min(fall_v + 0.45, 8);
        y += fall_v;
        var _t2 = tile_at(x, y + 12);
        if (is_blocking(_t2) || _t2 == T_ONEWAY || _t2 == T_SPIKES)
        {
            y = floor((y + 12) / TILE) * TILE - 12;
            fall_v = 0;
        }
    }
    else fall_v = 0;
}
// Fell out of the level: it waits at the snake's checkpoint instead.
if (y > _g.lvl_h * TILE + 40)
{
    x = _g.pl[pid].checkpoint_x;
    y = _g.pl[pid].checkpoint_y;
    fall_v = 0;
}

// This PC's own snake (never the other PC's copy) breaks it: tongue, stomp, boost, fast roll.
var _e = id;
with (obj_player)
{
    if (remote || hidden || pid == _e.pid) continue;
    var _near = abs(x - _e.x) < hw + 14 && abs(y - _e.y) < hh + 16;
    var _hit = false;
    if (tongue_t > 0 && tongue_t <= 11 && point_segment_distance(_e.x, _e.y - 6, mouth_x(), mouth_y(), mouth_x() + facing * tongue_len, mouth_y()) < 18) _hit = true;
    else if (_near && (boost_t > 0 || snug == "fired"))
    {
        _hit = true;
        if (boost_t > 0) { boost_t = 0; boost_cd = 20; }
        vx = sign(x - _e.x) * 4;
        vy = -4;
    }
    else if (_near && ball && abs(vx) > 2.5)
    {
        _hit = true;
        vx = sign(x - _e.x) * 3;
    }
    else if (_near && vy > 1.5 && y < _e.y - 6)
    {
        _hit = true;
        vy = -7;
    }
    if (_hit && _e.hit_cd == 0) _e.hit_by(id);
    else if (_near && !_hit && _g.frame >= _e.hint_frame)
    {
        _e.hint_frame = _g.frame + 300;
        _g.say("BREAK THE EGG: TONGUE, STOMP OR BOOST IT!", 120, stats);
    }
}
