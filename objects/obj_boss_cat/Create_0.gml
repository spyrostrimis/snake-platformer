/// Wild Whiskers: a fierce wild calico cat with lynx ear tufts, fangs and claws out.
/// She prowls, crouches and pounces in long arcs, hisses and dashes claws-first,
/// and coughs up spiky hairballs. Crashing into a wall leaves her dizzy.
event_inherited();
boss_name = "WILD WHISKERS";
hw = 30;
hh = 22;
hp_max = 10;
hp = hp_max;
points = 10000;
music = "music_04.ogg";
state = "prowl";
timer = 70;
pounces = 0;    // pounces left in a row (more when angry)
throws = 0;
was_airborne = false;
