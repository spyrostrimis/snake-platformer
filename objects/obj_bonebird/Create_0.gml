/// Skeleton bird: flaps back and forth around its home in the air. When a snake passes
/// below, it dives at the spot where the snake was, then flies back up. Only a boost (or the
/// Slingshot) breaks it; the tongue and stomps just clank off its bones.
/// Frames: wings up, wings down, diving.
event_inherited();
hw = 13;
hh = 10;
points = 300;
boost_only = true;
image_speed = 0;
home_x = x;
home_y = y;
state = "patrol";       // patrol | dive | rise
t = random(10);
rest = 60;              // a pause before it can dive again
dive_x = x;
dive_y = y;
timer = 0;
facing = 1;

base_kill = kill;
kill = function(_dmg = 1, _by = noone)
{
    obj_game.burst(x, y, make_colour_rgb(240, 228, 200), 12);
    obj_game.play_sfx(obj_game.sfx.rattle);
    base_kill(_dmg, _by);
};
