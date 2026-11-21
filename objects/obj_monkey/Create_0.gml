/// Mango, the volcano's orange monkey. All the way up the mountain he stays a few ledges above
/// the snakes, crouched behind a rock on one of the level's perches (lvl.perches): now and
/// then he peeks out and throws a chunk of honey at a snake below (stuck for a while; see the
/// snake's honey_stick). The higher the snakes climb, the higher he leaps to escape them.
/// At the summit he hides behind his rock (lvl.monkey_hide), scared of the rock monster, and
/// helps: he throws big honey at it, so it gets stuck and is easy to hit. When it's beaten he
/// comes out, hops over to a snake, blows it a kiss (a heart pops up) and gives it the last
/// letter of the word; then off he goes.
/// He can't be touched or hurt. He's a creature only so online play keeps him in step: the
/// host runs him, the joiner copies his place and pose.
/// Frames: crouched behind the rock, peeking, throwing, leaping, scared, happy (the kiss).
event_inherited();
hw = 14;
hh = 22;
no_gem = true;
image_speed = 0;
is_harmless = function() { return true; };
state = "start";        // start | perch | leap | boss | thank | gone
cur = -1;               // the perch he's on (index into perches)
perches = obj_game.lvl.perches;
hide = obj_game.lvl.monkey_hide;
throw_t = 120;
peek_t = 0;             // >0: peeking out (then the throw)
throw_show = 0;         // frames the throwing pose still shows
lx0 = x; ly0 = y; lx1 = x; ly1 = y; lt = 0; ldur = 40; leap_to = "perch";
gift = "";              // the letter he gives (the boss's)
thank_t = 0;
heart_t = 0;            // a heart rising from his kiss (on both PCs)
helped = false;

/// Leaps (in an arc) to (_x, _y); then he's in state _then.
leap = function(_x, _y, _then)
{
    lx0 = x; ly0 = y; lx1 = _x; ly1 = _y;
    lt = 0;
    ldur = clamp(point_distance(x, y, _x, _y) / 7, 28, 56);
    leap_to = _then;
    state = "leap";
    if (_x != x) facing = sign(_x - x);
};

/// Throws honey from behind his rock at the point (_tx, _ty): sprite _spr (spr_honey at a
/// snake, spr_honeybig at the boss), landing after about _t steps.
throw_honey = function(_tx, _ty, _spr, _t)
{
    var _g = obj_game;
    var _sx = x + facing * 8;
    var _sy = y - 50;
    var _grav = 0.3;
    var _h = instance_create_layer(_sx, _sy, "Instances", obj_hazard);
    _h.sprite_index = _spr;
    _h.vx = (_tx - _sx) / _t;
    _h.vy = (_ty - _sy - 0.5 * _grav * _t * _t) / _t;
    _h.grav = _grav;
    _h.life = 240;
    _h.spin = true;
    _h.net_id = _g.net_next_id++;
    _g.play_sfx(_g.sfx.throw_);
};

/// The boss is beaten: he'll thank the snakes with letter _ch.
start_thanks = function(_ch)
{
    gift = _ch;
    state = "thank";
    thank_t = 0;
};
