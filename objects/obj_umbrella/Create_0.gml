/// Someone relaxing on the beach under a sunshade. The umbrella is springy: land on it and it
/// throws a snake up high (to the upper ledges), but it folds shut onto its owner's head
/// ("OUCH!"). A while later it opens again, and from then on its owner has a bump on the head.
/// Frames (4 per person, 3 people): open, folded ("ouch!"), folded (dizzy), open with a bump.
image_speed = 0;
variant = floor(x / TILE) mod 3;     // which person (the same on both PCs)
fold_t = 0;                          // steps until it opens again
bumped = false;
net_id = -1;                         // online: the same number on both PCs
image_index = variant * 4;

/// A snake bounced on it: it folds onto the person's head.
fold = function()
{
    if (fold_t > 0) return;
    fold_t = 170;
    bumped = true;
    var _g = obj_game;
    _g.play_sfx(_g.sfx.bonk);
    _g.add_popup(x, y - 74, "OUCH!");
};
