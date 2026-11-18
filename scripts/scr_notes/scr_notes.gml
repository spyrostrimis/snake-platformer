/// Developer notes: F3 jots down a bug or an idea while playing, in any mode.
/// Each note is one line in notes.txt, with the time, the level, the mode and where the
/// snake is, plus (unless turned off with Tab) a screenshot in notes_shots/. Both live in the
/// game's save folder on this PC (%LOCALAPPDATA%\snake_hangman5), never in the repository.
/// One player, or two on one PC: the game pauses while the note is written.
/// Online: the game carries on; the friend is told to wait, and this PC's snake is frozen
/// and can't be hurt until the note is done.
///
/// The functions here use obj_game's variables and are called from obj_game's events.

#macro NOTE_MAX_LEN 200         // characters in one note
#macro NOTE_FILE "notes.txt"
#macro NOTE_SHOTS "notes_shots"

/// Sets up the notes (obj_game's Create).
function notes_init()
{
    note_open = false;      // the note box is up
    note_text = "";
    note_info = "";         // when, where and how: worked out when F3 was pressed
    note_shot = "";         // the screenshot's file ("" if none)
    note_shot_now = false;  // take the screenshot at the end of this frame's drawing
    note_keep_shot = true;  // Tab turns the screenshot off (and back on)
    note_paused = false;    // the note paused the game, so closing it carries on
    note_toast_t = 0;       // "Note saved" shows while this counts down
    note_toast = "";
    net_note_peer = false;  // online: the friend is writing a note
}

/// True when F3 may open a note (not while something else is being typed).
function note_can()
{
    if (!settings.notes_key || chat_open) return false;
    if (state == "title" && keys_wait) return false;
    if (state == "online" && (online_mode == "type" || online_mode == "type_ip")) return false;
    return true;
}

/// A number with a leading zero: 7 -> "07".
function note_two(_n) { return (_n < 10 ? "0" : "") + string(_n); }

/// The note's heading: when, which level, which mode and where each snake is.
function note_where()
{
    var _t = date_current_datetime();
    var _when = string(date_get_year(_t)) + "-" + note_two(date_get_month(_t)) + "-" + note_two(date_get_day(_t))
        + " " + note_two(date_get_hour(_t)) + ":" + note_two(date_get_minute(_t)) + ":" + note_two(date_get_second(_t));
    var _in_game = state == "play" || state == "paused" || state == "clear" || state == "gameover" || state == "victory";
    var _where = _in_game ? "L" + string(level_index + 1) + " " + level_names[level_index] : state + " screen";
    var _mode = (net_mode != "") ? "online " + net_mode : ((_in_game && array_length(pl) == 2) ? "2 players" : (_in_game ? "1 player" : "menus"));
    var _snakes = "";
    for (var _k = 0; _k < array_length(pl); _k++)
    {
        if (net_mode != "" && _k != my_pid) continue;
        var _p = pl[_k];
        if (!_in_game || !instance_exists(_p.inst)) continue;
        _snakes += " | " + _p.skin.nice + " x " + string(round(_p.inst.x)) + " y " + string(round(_p.inst.y))
            + " (tile " + string(floor(_p.inst.x / TILE)) + ", " + string(floor(_p.inst.y / TILE)) + ")";
    }
    return _when + " | " + _where + " | " + _mode + _snakes;
}

/// F3: opens the note box. The screenshot is taken at the end of this frame's drawing,
/// before the box shows.
function note_open_box()
{
    note_open = true;
    note_text = "";
    keyboard_string = "";
    note_keep_shot = true;
    note_info = note_where();
    // notes_shots/2026-11-18_21-04-33.png (with _2, _3 ... if one is taken the same second)
    var _stamp = string_replace_all(string_replace_all(string_copy(note_info, 1, 19), " ", "_"), ":", "-");
    if (!directory_exists(NOTE_SHOTS)) directory_create(NOTE_SHOTS);
    note_shot = NOTE_SHOTS + "/" + _stamp + ".png";
    for (var _n = 2; file_exists(note_shot); _n++) note_shot = NOTE_SHOTS + "/" + _stamp + "_" + string(_n) + ".png";
    note_shot_now = true;
    // Alone or two on one PC, the game waits; online it carries on, and the friend is told.
    note_paused = false;
    if (net_mode == "")
    {
        if (state == "play")
        {
            state = "paused";
            audio_pause_all();
            note_paused = true;
        }
    }
    else net_event({ t: "note", on: true });
}

/// Closes the note box (saved or not) and carries on.
function note_close()
{
    note_open = false;
    note_text = "";
    keyboard_string = "";
    // A screenshot that isn't wanted goes.
    if (note_shot != "" && !note_keep_shot && file_exists(note_shot)) file_delete(note_shot);
    note_shot = "";
    if (note_paused && state == "paused")
    {
        state = "play";
        audio_resume_all();
    }
    note_paused = false;
    if (net_mode != "") net_event({ t: "note", on: false });
}

/// Adds the note to notes.txt.
function note_save()
{
    var _text = string_trim(note_text);
    if (_text == "") _text = "(screenshot only)";
    var _line = note_info + (note_keep_shot ? " | shot " + note_shot : "") + " | " + _text;
    var _f = file_text_open_append(NOTE_FILE);
    if (_f < 0) { note_toast = "Couldn't write " + NOTE_FILE; note_toast_t = 180; return; }
    file_text_write_string(_f, _line);
    file_text_writeln(_f);
    file_text_close(_f);
    note_toast = "Note saved" + (note_keep_shot ? " with a screenshot" : "") + " (Options > Developer opens the folder)";
    note_toast_t = 180;
}

/// Typing in the note box (called each step while it's up).
function note_step()
{
    if (keyboard_check_pressed(vk_escape)) { note_keep_shot = false; note_close(); return; }
    if (keyboard_check_pressed(vk_tab)) note_keep_shot = !note_keep_shot;
    if (keyboard_string != note_text)
    {
        note_text = text_clean(keyboard_string, NOTE_MAX_LEN, false);
        keyboard_string = note_text;
    }
    if (keyboard_check_pressed(vk_enter))
    {
        // Enter on an empty note with no screenshot is just a cancel.
        if (string_trim(note_text) != "" || note_keep_shot) note_save();
        note_close();
    }
}

/// Every step: the online snake waits safely while its player writes (obj_player's Step).
/// True: this snake does nothing else this step.
function note_hold_snake(_inst)
{
    if (!obj_game.note_open || obj_game.net_mode == "") return false;
    // Frozen in place and can't be hurt (5 keeps it from blinking: see obj_player's Draw).
    _inst.invuln = max(_inst.invuln, 5);
    return true;
}

/// _text split into lines no wider than _w HUD units (at spaces when it can).
function text_wrap(_text, _w)
{
    var _lines = [];
    var _line = "";
    var _n = string_length(_text);
    for (var _i = 1; _i <= _n; _i++)
    {
        var _try = _line + string_char_at(_text, _i);
        if (rich_text(0, 0, _try, c_white, 1, false) > _w && _line != "")
        {
            var _sp = string_last_pos(" ", _line);
            if (_sp > 0)
            {
                array_push(_lines, string_copy(_line, 1, _sp - 1));
                _line = string_delete(_line, 1, _sp) + string_char_at(_text, _i);
            }
            else
            {
                array_push(_lines, _line);
                _line = string_char_at(_text, _i);
            }
        }
        else _line = _try;
    }
    array_push(_lines, _line);
    return _lines;
}

/// Draws the note box, the "Note saved" message, and the friend's "wait up" (Draw GUI, in
/// the 640 x 360 HUD space). The box stays hidden on the frame its screenshot is taken.
function notes_draw()
{
    var _hint = make_colour_rgb(170, 190, 230);
    if (net_note_peer && net_mode != "")
    {
        var _friend = chat_skin(false);
        hud_text(320, 92, "WAIT UP! " + _friend.name + " IS TAKING A NOTE", 0.42, fa_center, _friend.colour, ((frame div 30) mod 2 == 0) ? 1 : 0.7);
    }
    if (note_toast_t > 0 && !note_open) body_text(634, 344, note_toast, make_colour_rgb(140, 255, 140), fa_right);
    if (!note_open || note_shot_now) return;

    menu_panel(40, 96, 600, 254);
    hud_text(320, 104, "NOTE", 0.5, fa_center, make_colour_rgb(255, 230, 140));
    var _y = 124;
    var _info = text_wrap(note_info, 536);
    for (var _i = 0; _i < array_length(_info); _i++) { rich_text(52, _y, _info[_i], _hint); _y += 15; }
    _y += 5;
    var _lines = text_wrap(note_text, 536);
    for (var _i = 0; _i < array_length(_lines); _i++)
    {
        var _w = rich_text(52, _y, _lines[_i]);
        if (_i == array_length(_lines) - 1 && (frame div 20) mod 2 == 0) rich_text(52 + _w, _y, "|", make_colour_rgb(255, 230, 140));
        _y += 16;
    }
    body_text(52, 216, note_keep_shot ? "Screenshot: kept" : "Screenshot: off", note_keep_shot ? make_colour_rgb(140, 255, 140) : make_colour_rgb(255, 150, 150));
    var _held = (net_mode != "") ? "Your snake waits safely; your friend's game carries on." : "The game is paused.";
    body_text(588, 216, _held, _hint, fa_right);
    body_text(320, 234, "Enter: save    Tab: screenshot on / off    Esc: cancel", c_white, fa_center);
}

/// At the very end of Draw GUI: the screenshot for a note just opened (so it shows the game,
/// HUD and all, without the note box).
function notes_shoot()
{
    if (!note_shot_now) return;
    note_shot_now = false;
    screen_save(note_shot);
}
