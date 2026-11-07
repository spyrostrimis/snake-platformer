/// Cave bat: hangs upside down under the cavern ceiling, asleep, until a snake passes close
/// below it. Then it swoops at that snake for a few seconds and flutters back to its roost.
/// Like every creature, the tongue, a boost or a stomp knocks it out, and touching it hurts.
event_inherited();
hw = 12;
hh = 10;
points = 250;
roost_x = x;
roost_y = y;
state = "hang";
timer = 0;
rest = 0;               // after flying back, a short nap before it can wake again
target = noone;
t = random(10);
image_speed = 0;
image_index = 0;
facing = 1;
