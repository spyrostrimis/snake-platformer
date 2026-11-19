var _g = obj_game;
if (_g.state != "play" || pulled) exit;
// This PC's snakes: touch it or lash it with the tongue.
var _sw = id;
with (obj_player)
{
    if (remote || hidden || _sw.pulled) continue;
    var _hit = abs(x - _sw.x) < hw + 12 && abs(y - (_sw.y - 20)) < hh + 20;
    if (!_hit && tongue_t > 0 && tongue_t <= 11) _hit = point_segment_distance(_sw.x, _sw.y - 34, mouth_x(), mouth_y(), mouth_x() + facing * tongue_len, mouth_y()) < 16;
    if (_hit) _sw.pull(true);
}
