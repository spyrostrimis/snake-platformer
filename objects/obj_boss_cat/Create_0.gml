/// Wild Whiskers: a fierce wild calico cat with lynx ear tufts, fangs and claws out.
/// She prowls, crouches and pounces in long arcs, hisses and dashes claws-first,
/// and coughs up spiky hairballs. Crashing into a wall leaves her dizzy.
/// Special attack, Fur Storm: every time she is hit her fur bristles, she sprays a fan of
/// hairballs into the air and pounces back. While her fur is up (hurt_t > 0), landing on her
/// back hurts the snake, so she can't just be bounced on.
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
last_hp = hp;   // to notice each new hit and answer it with the Fur Storm

// hurt_t is shared with the joiner online, so this works on both PCs.
spiky_back = function() { return hurt_t > 0 || state == "fury"; };
