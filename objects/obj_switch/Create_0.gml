/// A lever that opens the gates (obj_gate). A snake pulls it by touching it or with its
/// tongue; the partner (one player) pulls it too. Online, a pull on either PC opens the gates
/// on both.
image_speed = 0;
image_index = 0;
pulled = false;

/// Pulled: the lever flips, the gates open. _send: tell the other PC (online).
pull = function(_send)
{
    if (pulled) return;
    var _g = obj_game;
    pulled = true;
    image_index = 1;
    _g.play_sfx(_g.sfx.flag);
    _g.burst(x, y - 30, make_colour_rgb(120, 255, 120), 10);
    with (obj_gate) open_gate();
    if (_send && _g.net_mode != "") _g.net_event({ t: "switch" });
};
