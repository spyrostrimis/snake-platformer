/// A giant mosquito. It buzzes about its spot; when a snake comes near it stops, points its
/// needle (the warning) and dives at the snake in a straight line, then flies back. The tongue,
/// a stomp or a boost beats it.
/// Frames: wings A, wings B, needle aimed (aiming and diving).
event_inherited();
hw = 16;
hh = 12;
points = 350;
image_speed = 0;
home_x = x;
home_y = y;
t = random(2 * pi);
state = "hover";
timer = 60 + irandom(60);
dive_dir = 0;
