/// A mole hole in the floor (kind "mole") or a crack in the cave roof (kind "bat") that keeps
/// sending out creatures: whenever its last one has been knocked out, a new one comes out
/// a few seconds later. Not a creature itself. The level sets kind when it makes it.
/// Online, only the host makes the creatures; the joiner gets them from the host's world.
if (!variable_instance_exists(id, "kind")) kind = "mole";
image_speed = 0;
child = noone;
timer = 20;
regrow = 300;           // frames after a knock-out before the next one comes out
