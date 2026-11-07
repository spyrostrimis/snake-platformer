/// Little mole: a mound creeps along under the floor towards the nearest snake, pops out,
/// scurries after it for a few seconds, digs back in and pops up again somewhere else.
/// Out of the ground it's like any creature (tongue, boost or stomp knocks it out; touching
/// it hurts). Under the ground it's only a mound: it can't hurt or be hurt.
/// Frames: walk A, walk B, popping out, digging in, mound.
event_inherited();
hw = 12;
hh = 10;
points = 150;
image_speed = 0;
image_index = 4;
state = "under";        // under | pop | walk | dig
timer = 30 + irandom(40);
walk_speed = 1.3;
facing = -1;

is_harmless = function() { var _f = floor(image_index); return _f == 3 || _f == 4; };

/// True if there's floor to stand on one step ahead (_dir) and no wall in the way.
floor_ahead = function(_dir)
{
    var _ax = x + _dir * (hw + 2);
    var _t = tile_at(_ax, y + hh + 6);
    return (is_blocking(_t) || _t == T_ONEWAY) && !col_blocked(_ax, y - hh + 1, y + hh - 1);
};
