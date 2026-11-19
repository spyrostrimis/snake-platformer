// How high the view rises for the fight: the deck and the shore both in sight.
if (!ready)
{
    ready = true;
    cam_lock_y = max(0, shore_y + 60 - 450);    // (the view is 800 x 450 for this fight)
}
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
var _g = obj_game;
if (_g.state != "play") exit;
if (!active) { image_index = 0; exit; }
var _angry = hp <= hp_max / 2;
timer--;

// Every hit: it rocks and smokes for a moment.
if (hp < last_hp)
{
    last_hp = hp;
    state = "hurt";
    timer = 40;
    _g.play_sfx(_g.sfx.growl);
}

var _p = instance_nearest(x, y, obj_player);
switch (state)
{
    case "idle":
        image_index = 0;
        if (timer <= 0 && _p != noone) { state = "fire"; timer = 16; shots = _angry ? 2 : 1; }
        break;

    case "fire":
        // A flash and a boom: a bomb lobbed at the snake (the second one leads it a little).
        image_index = (timer > 8) ? 0 : 1;
        if (timer <= 0)
        {
            if (_p != noone && abs(_p.y - y) < 60 && abs(_p.x - x) < 280)
            {
                // Up on the deck: a point-blank shot along it.
                var _b = shoot(spr_bomb, x + sign(_p.x - x) * 46, y - 12, sign(_p.x - x) * 6, -2.5, 0.22);
                _b.life = 90;
                _g.play_sfx(_g.sfx.smash);
            }
            else if (_p != noone)
            {
                var _lead = (shots == 1 && _angry) ? _p.vx * 40 : 0;
                fire_bomb(_p.x + _lead + irandom_range(-24, 24), _angry ? 62 : 74);
            }
            shots--;
            if (shots > 0) { timer = 24; }
            else { state = "idle"; timer = _angry ? 80 : 115; }
        }
        break;

    case "hurt":
        image_index = 2;
        if (timer <= 0) { state = "idle"; timer = 50; }
        break;
}
