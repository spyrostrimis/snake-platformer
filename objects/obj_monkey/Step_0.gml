var _g = obj_game;
// The heart from his kiss rises on both PCs (it shows while he's happy).
if (floor(image_index) == 5) heart_t++; else heart_t = 0;
// Online, the joiner copies the host's monkey.
if (net_mirror()) { mirror_step(); exit; }
event_inherited();
image_speed = 0;
if (_g.state != "play") exit;

// The snakes: the highest one (he stays ahead of it), and the nearest.
var _top = noone;
with (obj_player) if (!hidden && (_top == noone || y < _top.y)) _top = id;
var _p = instance_nearest(x, y, obj_player);
var _np = array_length(perches);
var _boss = instance_find(obj_boss_golem, 0);

switch (state)
{
    case "start":
        // To the first perch well above the snakes.
        cur = 0;
        if (_top != noone) while (cur < _np - 1 && perches[cur][1] > _top.y + 12 - 7 * TILE) cur++;
        x = perches[cur][0];
        y = perches[cur][1];
        state = "perch";
        image_index = 0;
        break;

    case "perch":
        // The snakes climbed close: off to a perch higher up (he only ever goes up).
        if (_top != noone)
        {
            var _j = cur;
            while (_j < _np - 1 && perches[_j][1] > _top.y + 12 - 7 * TILE) _j++;
            if (_j > cur) { cur = _j; leap(perches[_j][0], perches[_j][1], "perch"); image_index = 3; break; }
        }
        // The summit: the rock monster is awake, or the snakes are up there: hide by the fight.
        if ((instance_exists(_boss) && _boss.active) || (_top != noone && _top.y < hide[1] + 3 * TILE))
        {
            leap(hide[0], hide[1], "boss");
            image_index = 3;
            break;
        }
        if (_p != noone && _p.x != x) facing = sign(_p.x - x);
        // Now and then: peek out and throw honey at a snake below.
        if (throw_show > 0) { throw_show--; image_index = 2; break; }
        if (peek_t > 0)
        {
            peek_t--;
            image_index = 1;
            if (peek_t == 0)
            {
                if (_p != noone && !_p.hidden)
                {
                    var _d = point_distance(x, y, _p.x, _p.y);
                    throw_honey(_p.x + _p.vx * 12, _p.y, spr_honey, clamp(_d / 7, 30, 90));
                    throw_show = 16;
                }
                throw_t = 170 + irandom(110);
            }
            break;
        }
        image_index = 0;
        throw_t--;
        // (Not at a snake that is stuck already, or just got free.)
        if (throw_t <= 0 && _p != noone && !_p.hidden && _p.honey_t == 0 && _p.honey_cd == 0 && _p.y > y - 30 && _p.y - y < 420) peek_t = 22;
        else if (throw_t <= 0) throw_t = 30;
        break;

    case "leap":
        // An arc from one rock to the next.
        lt = min(1, lt + 1 / ldur);
        var _arc = 50 + max(0, ly0 - ly1) * 0.35;
        x = lerp(lx0, lx1, lt);
        y = lerp(ly0, ly1, lt) - _arc * 4 * lt * (1 - lt);
        image_index = 3;
        if (lt >= 1)
        {
            state = leap_to;
            image_index = (state == "boss") ? 4 : 0;
            if (state == "gone")
            {
                if (_g.net_mode == "host") _g.net_event({ t: "kill", i: net_id });
                instance_destroy();
                exit;
            }
        }
        break;

    case "boss":
        // Behind his rock by the fight, scared stiff, but he helps: big honey at the monster.
        facing = (instance_exists(_boss) && _boss.x < x) ? -1 : 1;
        if (throw_show > 0) { throw_show--; image_index = 2; break; }
        if (peek_t > 0)
        {
            peek_t--;
            image_index = 1;
            if (peek_t == 0 && instance_exists(_boss))
            {
                var _t = 40;
                throw_honey(_boss.x + _boss.vx * _t * 0.8, _boss.y - 10, spr_honeybig, _t);
                throw_show = 16;
                throw_t = 300 + irandom(90);
            }
            break;
        }
        image_index = 4;
        if (instance_exists(_boss) && _boss.active && _boss.state != "stuck")
        {
            throw_t--;
            if (throw_t <= 0) peek_t = 24;
        }
        break;

    case "thank":
        // Out he comes: over to a snake, a kiss, the letter.
        thank_t++;
        if (thank_t == 1)
        {
            image_index = 0;
            if (_p != noone) leap(_p.x - sign(_p.x - x + 0.01) * 40, _p.y + _p.hh, "thank");
            else thank_t = 2;
            image_index = 3;
            break;
        }
        image_index = 5;
        if (_p != noone && _p.x != x) facing = sign(_p.x - x);
        if (thank_t == 3) { _g.play_sfx(_g.sfx.pop); _g.play_sfx(_g.sfx.oneup); _g.say("MANGO BLOWS YOU A KISS!", 120); }
        if (thank_t == 70)
        {
            // The last letter: the boss had it, Mango gives it.
            if (gift != "" && _p != noone)
            {
                var _l = instance_create_layer(_p.x, _p.y - 34, "Instances", obj_letter);
                _l.ch = gift;
                _g.net_spawned(_l, "letter");
                _g.say("MANGO GIVES YOU THE LAST LETTER!", 150);
                _g.burst(_p.x, _p.y - 34, make_colour_rgb(255, 230, 90), 14);
            }
            gift = "";
        }
        if (thank_t == 150) leap(x - facing * 120, y - 400, "gone");
        break;
}
