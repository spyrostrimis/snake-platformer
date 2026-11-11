if (obj_game.state != "play") exit;
if (fold_t > 0)
{
    fold_t--;
    if (fold_t == 0) obj_game.play_sfx(obj_game.sfx.spring);   // pops open again
}
var _f = 0;
if (fold_t > 130) _f = 1;
else if (fold_t > 0) _f = 2;
else if (bumped) _f = 3;
image_index = variant * 4 + _f;
