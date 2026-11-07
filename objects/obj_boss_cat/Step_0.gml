// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play" || !active) exit;

var _g = obj_game;
var _angry = hp <= hp_max / 2;   // faster, and pounces twice in a row, in the second half
var _at_edge = x <= arena_x1 || x >= arena_x2;
timer--;

switch (state)
{
    case "prowl":
        // Stalks towards the snake, low and steady.
        var _dist = face_player();
        vx = facing * (_angry ? 2.2 : 1.6);
        image_index = (_g.frame div 8) mod 2;
        if (timer <= 0)
        {
            var _roll = irandom(2);
            if (_dist > 170 && _roll == 0) { state = "cough"; timer = 30; throws = _angry ? 5 : 3; }
            else if (_roll == 1) { state = "hiss"; timer = _angry ? 26 : 36; _g.play_sfx(_g.sfx.hiss); }
            else { state = "crouch"; timer = _angry ? 28 : 40; pounces = _angry ? 2 : 1; }
        }
        break;

    case "crouch":
        // Bum in the air, wiggling: the pounce is coming.
        vx = 0;
        face_player();
        image_index = 2;
        x += sin(_g.frame * 0.9) * 1.2;
        if (timer <= 0 && on_ground)
        {
            // Leap at where the snake is now.
            var _target = instance_nearest(x, y, obj_player);
            var _dx = (_target != noone) ? _target.x - x : facing * 160;
            vy = _angry ? -10.5 : -9.5;
            vx = clamp(_dx / 42, -7, 7);
            if (abs(vx) < 2) vx = facing * 2;
            state = "pounce";
            was_airborne = false;
            _g.play_sfx(_g.sfx.growl);
        }
        break;

    case "pounce":
        image_index = 3;
        if (!on_ground) was_airborne = true;
        if (hit_wall != 0 || (_at_edge && !on_ground))
        {
            // Splat into the wall: dizzy, the best time to strike back.
            state = "dizzy";
            timer = 80;
            vx = 0;
            _g.play_sfx(_g.sfx.smash);
            part_particles_create(_g.ps, x + facing * hw, y, _g.pt_rock, 8);
        }
        else if (on_ground && was_airborne)
        {
            vx = 0;
            part_particles_create(_g.ps, x, y + hh, _g.pt_dust, 8);
            pounces--;
            if (pounces > 0) { state = "crouch"; timer = 16; }
            else { state = "prowl"; timer = 60; }
        }
        break;

    case "hiss":
        // Fur on end, hissing, then a claws-first dash along the ground.
        vx = 0;
        face_player();
        image_index = 4;
        x += irandom_range(-1, 1);
        if (timer <= 0) { state = "dash"; timer = 60; _g.play_sfx(_g.sfx.charge); }
        break;

    case "dash":
        vx = facing * (_angry ? 8.5 : 7.5);
        image_index = 3;
        if (_g.frame mod 3 == 0) part_particles_create(_g.ps, x - facing * hw, y + hh, _g.pt_dust, 1);
        if (hit_wall != 0 || _at_edge)
        {
            state = "dizzy";
            timer = 70;
            vx = 0;
            _g.play_sfx(_g.sfx.smash);
            part_particles_create(_g.ps, x + facing * hw, y, _g.pt_rock, 8);
        }
        else if (timer <= 0) { state = "prowl"; timer = 60; }
        break;

    case "cough":
        // Hacks up spiky hairballs that arc at the snake.
        vx = 0;
        face_player();
        image_index = (timer > 12) ? 0 : 4;
        if (timer <= 0)
        {
            var _aim = instance_nearest(x, y, obj_player);
            var _d = (_aim != noone) ? _aim.x - x : facing * 200;
            shoot(spr_hairball, x + facing * 36, y - 18, clamp(_d / 45, -5.5, 5.5), -6.5, 0.3);
            _g.play_sfx(_g.sfx.throw_);
            throws--;
            timer = 22;
            if (throws <= 0) { state = "prowl"; timer = 80; }
        }
        break;

    case "dizzy":
        vx = 0;
        image_index = 5;
        if (_g.frame mod 20 == 0) _g.burst(x, y - hh - 6, make_colour_rgb(255, 240, 120), 3);
        if (timer <= 0) { state = "prowl"; timer = 60; }
        break;
}

vy = min(vy + gravity_pull, 9);
entity_move();
