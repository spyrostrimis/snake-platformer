/// The run's state machine; the snake and creatures update themselves only during play.

frame++;
for (var _i = array_length(messages) - 1; _i >= 0; _i--)
{
    // Only the oldest message counts down, so they show one after another.
    if (_i == 0) messages[0].life--;
    if (messages[_i].life <= 0) array_delete(messages, _i, 1);
}
for (var _i = array_length(popups) - 1; _i >= 0; _i--)
{
    var _p = popups[_i];
    _p.y -= 0.6;
    _p.life -= 1;
    if (_p.life <= 0) array_delete(popups, _i, 1);
}

var _enter = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
if (keyboard_check_pressed(ord("M")))
{
    sound_on = !sound_on;
    if (!sound_on) stop_music();
    else if (state == "play") play_music(lvl.music);
    else if (state == "title" || state == "credits") play_music("music_02.ogg");
}

// Secret code: typing JJNXT during a level skips straight to the next one.
if (string_length(keyboard_string) > 20) keyboard_string = string_copy(keyboard_string, string_length(keyboard_string) - 9, 10);
if (string_pos("jjnxt", string_lower(keyboard_string)) > 0)
{
    keyboard_string = "";
    if (state == "play" || state == "paused" || state == "clear") skip_level();
}

switch (state)
{
    case "title":
        title_pan += 0.6;
        if (_enter) { play_sfx(sfx.select); new_game(); }
        else if (keyboard_check_pressed(ord("C"))) { play_sfx(sfx.select); state = "credits"; }
        else if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(ord("D")))
        {
            // Choose the snake.
            var _step = (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) ? -1 : 1;
            character = (character + _step + array_length(snakes)) mod array_length(snakes);
            play_sfx(sfx.select);
        }
        break;

    case "credits":
        title_pan += 0.6;
        if (_enter || keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("C"))) { play_sfx(sfx.select); state = "title"; }
        break;

    case "play":
        level_time++;
        if (keyboard_check_pressed(ord("P")) || keyboard_check_pressed(vk_escape))
        {
            state = "paused";
            audio_pause_all();
        }
        // F1: back to the last checkpoint. F2: start the level over.
        else if (keyboard_check_pressed(vk_f1))
        {
            respawn_at_checkpoint();
            messages = [];
            say("BACK TO THE CHECKPOINT", 90);
        }
        else if (keyboard_check_pressed(vk_f2)) start_level();
        break;

    case "paused":
        if (keyboard_check_pressed(ord("P")) || keyboard_check_pressed(vk_escape) || _enter)
        {
            state = "play";
            audio_resume_all();
        }
        break;

    case "clear":
        // Count the bonus up like the old tally screens.
        if (tally.shown < tally.bonus)
        {
            var _step = min(tally.bonus - tally.shown, 150);
            tally.shown += _step;
            score_now += _step;
            if (frame mod 4 == 0) play_sfx(sfx.gem);
        }
        else if (_enter)
        {
            level_index++;
            if (level_index >= array_length(levels))
            {
                state = "victory";
                play_music("music_02.ogg");
            }
            else start_level();
        }
        break;

    case "gameover":
    case "victory":
        if (_enter)
        {
            load_level(0, false);
            state = "title";
        }
        break;
}
