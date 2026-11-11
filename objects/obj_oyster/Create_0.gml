/// A giant oyster on the sand. Shut, its shell is armour: the tongue and stomps clank off it
/// (a boost still breaks it). When a snake comes near it opens up, shows its pearl and spits it
/// in an arc at the snake; while it's open the tongue or a stomp beats it. Touching it bites.
/// Frames: shut, peeking, open with the pearl, open (pearl spat), snapping shut.
event_inherited();
hw = 22;
hh = 16;
points = 400;
image_speed = 0;
state = "shut";
timer = 60 + irandom(60);

/// Shut (frame 0) or snapping (frame 4): only a boost gets through. Only uses image_index, so
/// online both PCs agree.
armoured = function()
{
    var _f = floor(image_index);
    return _f == 0 || _f == 4;
};
