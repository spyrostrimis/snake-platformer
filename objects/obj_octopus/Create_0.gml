/// Octopus: bobs about its home in the water. When a snake comes near it puffs up and squirts a
/// blob of ink at it: the ink hurts, and blots that snake's screen for a few seconds.
/// Like any creature, the tongue, a boost or a stomp knocks it out, and touching it hurts.
/// Frames: idle A, idle B, puffed up (about to squirt).
event_inherited();
hw = 16;
hh = 16;
points = 250;
image_speed = 0;
home_x = x;
home_y = y;
t = random(10);
state = "idle";         // idle | puff
timer = 60 + irandom(60);
facing = -1;
glow = 0.6;             // dark levels: a little light around it
