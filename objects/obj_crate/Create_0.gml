/// The partner's crate, floating down under a parachute in the partner's colour (red for
/// Sockee, green for Peto). Set by obj_combo_spot: spot (the combo spot), skin_id (the snake
/// inside). Once it lands, touching it opens it and the partner pops out (obj_buddy).
image_speed = 0;
landed = false;
chute = 1;              // the parachute: 1 open, shrinking to 0 once it lands
t = 0;
hint_frame = 0;
skin = obj_game.snakes[skin_id];
