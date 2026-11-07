/// Big Diggs: a burly mole in a miner's helmet who rules the cavern.
/// Roll: tucks into a ball and bowls across the cave, bouncing off the walls, then is dizzy.
/// Earthquake: squats, leaps and slams down; the cave shakes, two shockwaves run along the
/// floor (jump over them) and rocks fall from the roof.
/// Curled up he can't be stomped, and every hit makes him curl straight away.
event_inherited();
boss_name = "BIG DIGGS";
hw = 28;
hh = 26;
hp_max = 12;
hp = hp_max;
points = 12000;
music = "music_09.ogg";
state = "walk";
timer = 80;
bounces = 0;
was_airborne = false;
last_hp = hp;

// Frame 2 is the ball (curling and rolling): a spinning ball can't be landed on.
// Both only use what online play shares (image_index, x), so the two PCs agree.
spiky_back = function() { return floor(image_index) == 2; };
draw_angle = function() { return (floor(image_index) == 2) ? -x * 2.4 : 0; };

/// The y just under the cave roof above (_x, _from_y): where his earthquake drops rocks from.
roof_y = function(_x, _from_y)
{
    var _ty = floor(_from_y / TILE);
    while (_ty > 0 && !is_blocking(tile_at(_x, _ty * TILE))) _ty--;
    return (_ty + 1) * TILE + 12;
};
