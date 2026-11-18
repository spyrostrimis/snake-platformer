/// Online chat: short messages with emojis between the two players, so nobody needs a phone
/// to talk. Nothing is kept: lines fade from the screen and are gone when the game
/// disconnects. Messages travel as events on the game's own link (net_event), so they
/// arrive in order and are sent again if lost.
///
/// T opens the chat box, Enter sends, Esc closes, Tab opens the emoji grid.
/// Shortcuts such as :) and <3 turn into emojis as they're typed, and so do real emojis
/// (from Windows' own emoji panel, Win + .) that match one of ours.
///
/// The functions that use obj_game's variables are called from obj_game's events.

#macro CHAT_MAX_LEN 80          // characters in one message (an emoji counts as one)
#macro CHAT_LINES 5             // lines on screen at once
#macro CHAT_LIFE 480            // frames a line stays (8 seconds), fading over the last second
#macro CHAT_BOX_Y 280           // the chat box's top, in the 640 x 360 HUD space
#macro EMOJI_BASE 0xE000        // emoji i is the character EMOJI_BASE + i (Unicode's private-use area)
#macro EMOJI_PICK_COLS 8        // the emoji grid's columns

/// The emojis, in spr_emoji's frame order (drawn in art_src/make_art.js): the shortcuts
/// typed in chat, and the real emojis that become this one.
function chat_emoji_list()
{
    static _list = [
        { name: "smile",        keys: [":-)", ":)"],          uni: [0x1F642, 0x263A, 0x1F60A] },
        { name: "grin",         keys: [":-D", ":D"],          uni: [0x1F600, 0x1F603, 0x1F604, 0x1F601] },
        { name: "laugh",        keys: ["xD", "XD"],           uni: [0x1F602, 0x1F606, 0x1F923] },
        { name: "wink",         keys: [";-)", ";)"],          uni: [0x1F609] },
        { name: "tongue",       keys: [":-P", ":P", ":p"],    uni: [0x1F61B, 0x1F61C, 0x1F61D] },
        { name: "love",         keys: [],                     uni: [0x1F60D, 0x1F970] },
        { name: "cool",         keys: [],                     uni: [0x1F60E] },
        { name: "wow",          keys: [":-O", ":O", ":o"],    uni: [0x1F62E, 0x1F632, 0x1F62F] },
        { name: "meh",          keys: [":-|", ":|"],          uni: [0x1F610, 0x1F611] },
        { name: "sad",          keys: [":-(", ":("],          uni: [0x1F641, 0x2639, 0x1F61E, 0x1F614] },
        { name: "cry",          keys: [":'("],                uni: [0x1F622, 0x1F62D] },
        { name: "angry",        keys: [">:-(", ">:("],        uni: [0x1F620, 0x1F621, 0x1F92C] },
        { name: "skull",        keys: [],                     uni: [0x1F480, 0x2620] },
        { name: "heart",        keys: ["<3"],                 uni: [0x2764, 0x1F496, 0x1F497, 0x1F493, 0x1F495, 0x2665] },
        { name: "broken heart", keys: ["</3"],                uni: [0x1F494] },
        { name: "thumbs up",    keys: ["(y)", "(Y)"],         uni: [0x1F44D] },
        { name: "thumbs down",  keys: ["(n)", "(N)"],         uni: [0x1F44E] },
        { name: "fire",         keys: [],                     uni: [0x1F525] },
        { name: "star",         keys: ["(*)"],                uni: [0x2B50, 0x1F31F, 0x2605] },
        { name: "party",        keys: [],                     uni: [0x1F389, 0x1F973] },
        { name: "eyes",         keys: [],                     uni: [0x1F440] },
        { name: "snake",        keys: [],                     uni: [0x1F40D] },
        { name: "gem",          keys: [],                     uni: [0x1F48E] },
        { name: "100",          keys: [],                     uni: [0x1F4AF] },
    ];
    return _list;
}

/// The emoji (frame of spr_emoji) that character _c stands for, or -1.
function emoji_index(_c)
{
    var _o = ord(_c);
    return (_o >= EMOJI_BASE && _o < EMOJI_BASE + array_length(chat_emoji_list())) ? _o - EMOJI_BASE : -1;
}

/// The emoji a real emoji's code point _o becomes, or -1.
function emoji_from_unicode(_o)
{
    static _map = undefined;
    if (is_undefined(_map))
    {
        _map = {};
        var _l = chat_emoji_list();
        for (var _i = 0; _i < array_length(_l); _i++) for (var _j = 0; _j < array_length(_l[_i].uni); _j++) _map[$ string(_l[_i].uni[_j])] = _i;
    }
    var _v = _map[$ string(_o)];
    return is_undefined(_v) ? -1 : _v;
}

/// Every shortcut as [text, emoji], longest first (so >:( wins over :( ).
function chat_shortcut_list()
{
    static _list = undefined;
    if (is_undefined(_list))
    {
        _list = [];
        var _l = chat_emoji_list();
        for (var _i = 0; _i < array_length(_l); _i++) for (var _j = 0; _j < array_length(_l[_i].keys); _j++) array_push(_list, [_l[_i].keys[_j], _i]);
        array_sort(_list, function(_a, _b) { return string_length(_b[0]) - string_length(_a[0]); });
    }
    return _list;
}

/// _text with its shortcuts turned into emojis.
function chat_shortcuts(_text)
{
    var _l = chat_shortcut_list();
    for (var _i = 0; _i < array_length(_l); _i++) if (string_pos(_l[_i][0], _text) > 0) _text = string_replace_all(_text, _l[_i][0], chr(EMOJI_BASE + _l[_i][1]));
    return _text;
}

/// True for the characters the chat font (spr_text_font) can draw: English, Turkish, Greek
/// and the rest of Western Europe's letters, plus everyday punctuation.
function text_char_ok(_o)
{
    return variable_struct_exists(text_font_glyphs(), string(_o));
}

/// Typed text made safe to show: only characters the font can draw, at most _max of them.
/// With _emoji, real emojis become ours and ours are kept; without, both are dropped.
function text_clean(_text, _max, _emoji)
{
    var _out = "";
    var _n = string_length(_text);
    for (var _i = 1; _i <= _n && string_length(_out) < _max; _i++)
    {
        var _c = string_char_at(_text, _i);
        var _o = ord(_c);
        if (_emoji)
        {
            var _e = emoji_from_unicode(_o);
            if (_e >= 0) { _out += chr(EMOJI_BASE + _e); continue; }
            if (emoji_index(_c) >= 0) { _out += _c; continue; }
        }
        if (text_char_ok(_o)) _out += _c;
    }
    return _out;
}

/// Draws _text (with emojis) left-aligned at (_x, _y) in the 640 x 360 HUD space, in the
/// outlined chat font (spr_text_font, which has Turkish and Greek letters), at full window
/// resolution so it stays sharp. Returns its width in HUD units. With _draw false, only measures.
function rich_text(_x, _y, _text, _col = c_white, _alpha = 1, _draw = true)
{
    var _m = matrix_get(matrix_world);
    if (_draw) matrix_set(matrix_world, matrix_build_identity());
    var _glyphs = text_font_glyphs();
    var _x0 = _x * 2;
    var _px = _x0;
    var _py = round(_y * 2);
    var _n = string_length(_text);
    for (var _i = 1; _i <= _n; _i++)
    {
        var _c = string_char_at(_text, _i);
        var _e = emoji_index(_c);
        if (_e >= 0)
        {
            if (_draw) draw_sprite_ext(spr_emoji, _e, round(_px) + 1, _py + (TEXT_FONT_H - 24) / 2, 1, 1, 0, c_white, _alpha);
            _px += 26;
            continue;
        }
        var _g = _glyphs[$ string(ord(_c))];
        if (is_undefined(_g)) continue;
        // [x, y, width, x offset, advance]: white letters with a dark outline, tinted _col.
        if (_draw && _g[2] > 0) draw_sprite_part_ext(spr_text_font, 0, _g[0], _g[1], _g[2], TEXT_FONT_H, round(_px + _g[3]), _py, 1, 1, _col, _alpha);
        _px += _g[4];
    }
    if (_draw) matrix_set(matrix_world, _m);
    return (_px - _x0) / 2;
}

// ---------- The chat on obj_game ----------

/// Sets up the chat (obj_game's Create).
function chat_init()
{
    chat_open = false;      // the chat box is up
    chat_text = "";         // what's typed in it
    chat_lines = [];        // { name, col, text, life }, oldest first
    chat_pick = false;      // the emoji grid is up
    chat_pick_i = 0;        // the emoji chosen in it
}

/// True when chat can be used: online, linked, in the room or a game.
function chat_can()
{
    if (net_mode == "" || net.state != "connected") return false;
    if (state == "online") return online_mode == "room";
    return state == "play" || state == "paused" || state == "clear" || state == "gameover" || state == "victory";
}

/// This PC's snake (_mine) or the friend's, in the room or a game.
function chat_skin(_mine)
{
    if (array_length(pl) == 2) return pl[_mine ? my_pid : 1 - my_pid].skin;
    var _host_c = (net_mode == "host") ? character : net_lobby_c;
    return snakes[(_mine == (net_mode == "host")) ? _host_c : 1 - _host_c];
}

function chat_open_box()
{
    chat_open = true;
    chat_pick = false;
    chat_text = "";
    keyboard_string = "";
}

function chat_close()
{
    chat_open = false;
    chat_pick = false;
    chat_text = "";
    keyboard_string = "";
}

/// Adds a line to the screen; the oldest goes when there are too many.
function chat_add(_skin, _text)
{
    array_push(chat_lines, { name: _skin.nice, col: _skin.colour, text: _text, life: CHAT_LIFE });
    while (array_length(chat_lines) > CHAT_LINES) array_delete(chat_lines, 0, 1);
}

/// A message from the friend's game (net_apply_event).
function chat_receive(_m)
{
    if (!is_string(_m)) return;
    _m = text_clean(_m, CHAT_MAX_LEN, true);
    if (_m == "") return;
    chat_add(chat_skin(false), _m);
    play_sfx(sfx.chat);
}

/// Forgets every line (the link closed).
function chat_reset()
{
    chat_lines = [];
    if (chat_open) chat_close();
}

/// Every step: lines fade (not while the box is up, so they can be read before replying).
function chat_tick()
{
    if (chat_open) return;
    for (var _i = array_length(chat_lines) - 1; _i >= 0; _i--) if (--chat_lines[_i].life <= 0) array_delete(chat_lines, _i, 1);
}

/// Typing in the chat box (called each step while it's up).
function chat_step()
{
    if (!chat_can()) { chat_close(); return; }
    if (chat_pick)
    {
        // The emoji grid: arrows choose, Enter puts it in. Keys typed meanwhile are ignored.
        keyboard_string = chat_text;
        var _n = array_length(chat_emoji_list());
        if (keyboard_check_pressed(vk_left))  chat_pick_i = (chat_pick_i + _n - 1) mod _n;
        if (keyboard_check_pressed(vk_right)) chat_pick_i = (chat_pick_i + 1) mod _n;
        if (keyboard_check_pressed(vk_up))    chat_pick_i = (chat_pick_i + _n - EMOJI_PICK_COLS) mod _n;
        if (keyboard_check_pressed(vk_down))  chat_pick_i = (chat_pick_i + EMOJI_PICK_COLS) mod _n;
        if (keyboard_check_pressed(vk_enter))
        {
            if (string_length(chat_text) < CHAT_MAX_LEN) chat_text += chr(EMOJI_BASE + chat_pick_i);
            keyboard_string = chat_text;
            chat_pick = false;
        }
        else if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_tab)) chat_pick = false;
        return;
    }
    if (keyboard_check_pressed(vk_escape)) { chat_close(); return; }
    if (keyboard_check_pressed(vk_tab)) { chat_pick = true; keyboard_string = chat_text; return; }
    if (keyboard_string != chat_text)
    {
        chat_text = text_clean(chat_shortcuts(keyboard_string), CHAT_MAX_LEN, true);
        keyboard_string = chat_text;
    }
    if (keyboard_check_pressed(vk_enter))
    {
        var _m = string_trim(chat_text);
        if (_m != "")
        {
            net_event({ t: "chat", m: _m });
            chat_add(chat_skin(true), _m);
        }
        chat_close();
    }
}

/// Draws the lines, the chat box and the emoji grid (Draw GUI, in the 640 x 360 HUD space).
function chat_draw()
{
    var _blink = (frame div 20) mod 2 == 0;
    var _dark = make_colour_rgb(10, 16, 40);
    // The lines, newest at the bottom, each on a dark strip so it reads over anything.
    var _n = array_length(chat_lines);
    if (!chat_pick)
    {
        for (var _i = 0; _i < _n; _i++)
        {
            var _l = chat_lines[_i];
            var _a = chat_open ? 1 : min(1, _l.life / 60);
            var _y = CHAT_BOX_Y - 2 - (_n - _i) * 16;
            var _who = _l.name + ": ";
            var _w = rich_text(0, 0, _who, c_white, 1, false) + rich_text(0, 0, _l.text, c_white, 1, false);
            draw_set_alpha(0.55 * _a);
            draw_set_colour(_dark);
            draw_roundrect(6, _y, 16 + _w, _y + 15, false);
            draw_set_alpha(1);
            var _wx = 11 + rich_text(11, _y, _who, _l.col, _a);
            rich_text(_wx, _y, _l.text, c_white, _a);
        }
    }
    if (!chat_open) return;

    // The box.
    draw_set_alpha(0.8);
    draw_set_colour(_dark);
    draw_roundrect(6, CHAT_BOX_Y, 634, CHAT_BOX_Y + 18, false);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(120, 150, 230));
    draw_roundrect(6, CHAT_BOX_Y, 634, CHAT_BOX_Y + 18, true);
    var _me = chat_skin(true);
    var _tx = 12 + rich_text(12, CHAT_BOX_Y + 2, _me.nice + ": ", _me.colour);
    _tx += rich_text(_tx, CHAT_BOX_Y + 2, chat_text);
    if (_blink && !chat_pick) rich_text(_tx, CHAT_BOX_Y + 2, "|", make_colour_rgb(255, 230, 140));
    var _hint = chat_pick ? "Arrows: choose    Enter: put it in    Tab / Esc: back" : "Enter: send    Tab: emojis    Esc: close";
    body_text(634, CHAT_BOX_Y + 20, _hint, make_colour_rgb(170, 190, 230), fa_right);

    // The emoji grid, above the box.
    if (chat_pick)
    {
        var _list = chat_emoji_list();
        var _rows = ceil(array_length(_list) / EMOJI_PICK_COLS);
        var _gx = 8;
        var _gy = CHAT_BOX_Y - 6 - _rows * 28 - 16;
        draw_set_alpha(0.85);
        draw_set_colour(_dark);
        draw_roundrect(_gx - 2, _gy - 2, _gx + EMOJI_PICK_COLS * 28 + 2, _gy + _rows * 28 + 16, false);
        draw_set_alpha(1);
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _cx = _gx + (_i mod EMOJI_PICK_COLS) * 28;
            var _cy = _gy + (_i div EMOJI_PICK_COLS) * 28;
            if (_i == chat_pick_i)
            {
                draw_set_colour(make_colour_rgb(255, 230, 140));
                draw_roundrect(_cx + 1, _cy + 1, _cx + 27, _cy + 27, true);
            }
            draw_sprite_ext(spr_emoji, _i, _cx + 2, _cy + 2, 1, 1, 0, c_white, 1);
        }
        var _e = _list[chat_pick_i];
        var _label = _e.name + ((array_length(_e.keys) > 0) ? "    type " + _e.keys[array_length(_e.keys) - 1] : "");
        body_text(_gx + 2, _gy + _rows * 28, _label, make_colour_rgb(255, 230, 140));
    }
    draw_set_colour(c_white);
}
