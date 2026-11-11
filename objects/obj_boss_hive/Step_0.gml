// The top of its vine (the palm's crown), worked out the same way on both PCs.
if (!ready)
{
    ready = true;
    ground_y = y + hh;
    anchor_x = x;
    anchor_y = ground_y - 360;
    y = anchor_y + rope;
}
// Online, the joiner's creatures copy the host's instead of thinking.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
if (obj_game.state != "play") exit;

var _g = obj_game;
if (!active)
{
    // Sways gently, humming, until a snake comes to the beach under it.
    image_index = (_g.frame div 30) mod 2;
    x = anchor_x + sin(_g.frame * 0.01) * 20;
    y = anchor_y + rope;
    exit;
}
var _angry = hp <= hp_max / 2;
timer--;

// Swings on its vine across the beach (the vine pays out when it sags).
swing_t += _angry ? 0.016 : 0.011;
rope = approach(rope, rope_to, 3);
x = anchor_x + sin(swing_t) * 130;
y = anchor_y + rope - abs(sin(swing_t)) * 12;

// Every hit: it shakes, zips back up, and (angry) lets out a couple of wasps.
if (hp < last_hp)
{
    last_hp = hp;
    state = "hurt";
    timer = 34;
    rope_to = 210;
    _g.play_sfx(_g.sfx.growl);
    if (_angry && instance_number(obj_wasp) < 5)
    {
        for (var _s = -1; _s <= 1; _s += 2)
        {
            var _w = instance_create_layer(x + _s * 30, y + 50, "Instances", obj_wasp);
            _w.net_id = _g.net_next_id++;
        }
    }
}

var _p = instance_nearest(x, y, obj_player);
switch (state)
{
    case "hang":
        image_index = (_g.frame div 12) mod 2;
        if (timer <= 0)
        {
            turns++;
            if (turns mod 3 == 0)
            {
                // Tired: it sags low on the vine for a while, buzzing.
                state = "sag";
                timer = 130;
                rope_to = 265;
                _g.play_sfx(_g.sfx.buzz);
            }
            else
            {
                var _r = irandom(99);
                if (_r < 40) attack = "arrows";
                else if (_r < 70) attack = "whirl";
                else attack = "swarm";
                if (attack == "swarm" && instance_number(obj_wasp) >= 4) attack = "arrows";
                if (attack == "whirl" && instance_number(obj_hazard) > 6) attack = "arrows";
                state = "windup";
                timer = _angry ? 24 : 34;
                _g.play_sfx(_g.sfx.charge);
            }
        }
        break;

    case "windup":
        // Red eyes and wasps pouring out: the warning.
        image_index = 2;
        x += irandom_range(-2, 2);
        if (timer <= 0)
        {
            state = "rest";
            timer = _angry ? 40 : 60;
            switch (attack)
            {
                case "arrows":
                    fire_arrows(_p, _angry ? 5 : 3, _angry ? 6.2 : 5.4);
                    if (_angry) { state = "arrows2"; timer = 22; }
                    break;
                case "whirl":
                    var _side = (_p != noone && _p.x < x) ? -1 : 1;
                    spin_whirl(_side);
                    if (_angry) spin_whirl(-_side);
                    _g.play_sfx(_g.sfx.hiss);
                    _g.shake(4);
                    break;
                case "swarm":
                    repeat (_angry ? 4 : 3)
                    {
                        var _w = instance_create_layer(x + irandom_range(-34, 34), y + 50 + irandom(16), "Instances", obj_wasp);
                        _w.net_id = _g.net_next_id++;
                    }
                    _g.play_sfx(_g.sfx.buzz);
                    break;
            }
        }
        break;

    case "arrows2":
        image_index = 2;
        if (timer <= 0)
        {
            fire_arrows(_p, 4, 6.2);
            state = "rest";
            timer = 40;
        }
        break;

    case "rest":
        image_index = (_g.frame div 12) mod 2;
        if (timer <= 0) { state = "hang"; timer = _angry ? 35 : 55; }
        break;

    case "sag":
        image_index = (_g.frame div 6) mod 2;
        if (_g.frame mod 40 == 0) _g.play_sfx(_g.sfx.buzz);
        if (timer <= 0) { rope_to = 210; state = "hang"; timer = 50; }
        break;

    case "hurt":
        image_index = 3;
        if (timer <= 0) { state = "hang"; timer = 30; }
        break;
}
