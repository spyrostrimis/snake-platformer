var _g = obj_game;
if (_g.state != "play") exit;
t++;
if (!landed)
{
    // Down it floats, swaying a little, onto the floor at the combo spot.
    y += 1.6;
    x = spot.x + sin(t * 0.05) * 8;
    // (It passes anything above the spot: it lands on the spot's own floor.)
    if (y >= spot.y)
    {
        y = spot.y;
        x = spot.x;
        landed = true;
        _g.play_sfx(_g.sfx.bonk);
        _g.burst(x, y - 4, make_colour_rgb(230, 210, 170), 8);
        _g.say("A CRATE! TOUCH IT TO OPEN IT", 150);
    }
    exit;
}
chute = max(0, chute - 0.04);
// The snake opens it by touching it (or with its tongue).
var _p = _g.pl[0].inst;
if (!instance_exists(_p)) exit;
var _touch = abs(_p.x - x) < _p.hw + 18 && abs(_p.y - (y - 16)) < _p.hh + 16;
if (!_touch && _p.tongue_t > 0 && _p.tongue_t <= 11) _touch = point_segment_distance(x, y - 16, _p.mouth_x(), _p.mouth_y(), _p.mouth_x() + _p.facing * _p.tongue_len, _p.mouth_y()) < 20;
if (_touch)
{
    _g.play_sfx(_g.sfx.smash);
    _g.play_sfx(_g.sfx.oneup);
    _g.burst(x, y - 16, make_colour_rgb(200, 150, 90), 16);
    _g.burst(x, y - 16, skin.colour, 16);
    part_particles_create(_g.ps, x, y - 16, _g.pt_rock, 10);
    instance_create_layer(x, y - 12, "Instances", obj_buddy, { spot: spot, skin_id: skin_id });
    instance_destroy();
}
