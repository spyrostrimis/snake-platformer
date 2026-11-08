/// Piranha: lurks under the surface of its lake (only its fin shows: it can't hurt or be hurt
/// then), follows a snake from below and leaps out at it in a high arc, then splashes back in.
/// Out of the water it's like any creature (tongue, boost or stomp knocks it out).
/// The level puts it at the water surface. Frames: leaping, biting, just the fin.
event_inherited();
hw = 12;
hh = 9;
points = 200;
image_speed = 0;
image_index = 2;
home_x = x;
home_y = y;             // the water surface
y = home_y + 6;
state = "under";        // under | leap
timer = 40 + irandom(60);
facing = -1;

is_harmless = function() { return floor(image_index) == 2; };
