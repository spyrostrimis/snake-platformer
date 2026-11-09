/// Jellyfish: drifts up and down in slow pulses. Every few seconds it flickers, then
/// electrifies the water around it: while it's lit up, anything close to it gets a shock.
/// Like any creature, the tongue, a boost or a stomp knocks it out, and touching it hurts.
/// The jellyfish queen also lets out little ones that drift towards the snakes (seeker).
/// Frames: pulse A, pulse B, electrified, charging (the harmless flicker before it lights up).
event_inherited();
hw = 14;
hh = 14;
points = 250;
image_speed = 0;
home_x = x;
home_y = y;
t = random(10);
state = "calm";         // calm | flicker | zap
timer = 90 + irandom(90);
facing = 1;
seeker = false;
glow = 0.8;             // dark levels: it glows

/// While it's electrified (frame 2), snakes on this PC within its spark ring get a shock.
/// Only uses x, y and image_index, so online each PC checks its own snake.
zap_check = function()
{
    if (floor(image_index) != 2) return;
    var _zx = x;
    var _zy = y + 10;
    with (obj_player)
    {
        if (!remote && !hidden && invuln == 0 && point_distance(x, y, _zx, _zy) < 54) take_hit(sign(x - _zx));
    }
};
