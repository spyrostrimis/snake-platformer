/// A loose rock in the cavern ceiling. When a snake passes underneath, it shakes, then drops
/// as a falling rock (a projectile, so online the joiner sees the host's rock), and grows
/// back a few seconds later. Not a creature: it can't be knocked out.
image_speed = 0;
state = "ready";        // ready | shake | gone
timer = 0;
regrow = 200;           // frames before a fallen rock is back
