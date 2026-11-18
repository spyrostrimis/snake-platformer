# SNAGMAN

A side-scrolling platformer made with [GameMaker](https://gamemaker.io), a tribute to the 90s PC platformers (*Jazz Jackrabbit 2* above all), with a hangman twist. Each level hides the letters of a secret word: grab the right ones to open the exit door, and every wrong letter is a miss. A boss guards each exit and holds one letter of the word.

Two snakes to play: **Peto** (green) glides on its spinning tail and rockets upward; **Sockee** (red) double-jumps and dashes ahead. Play alone, two on one PC with a split screen, or **online** with a friend.

It grew out of [snake_hangman](https://github.com/spyrostrimis/snake_hangman) (v5 "Jungle Jam" and v6); its history from v6 on comes with it.

## Running it

Open `snake_hangman5.yyp` in GameMaker, or from the command line with [GM-CLI](https://www.npmjs.com/package/@gamemaker/gm-cli):

```bash
npx @gamemaker/gm-cli run
```

### The music (not in this repository)

The levels play the [*Jazz Jackrabbit 2 – 20th Anniversary Tribute Album*](https://jj20.bandcamp.com/album/jazz-jackrabbit-2-20th-anniversary-tribute-album) by the JJ20 Team, licensed [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/), so the tracks are kept out of git. To hear them, download the album (free), convert each track to Ogg Vorbis unchanged, and save them in this folder as `music_01.ogg` … `music_09.ogg`, numbered by track. Or copy the nine `.ogg` files from a packaged build. Without them the game plays silently, apart from its own sound effects. `.gitignore` keeps them out of commits.

## Playing

| | Move | Jump | Tongue | Roll (hold) | Boost |
|---|---|---|---|---|---|
| One player / online | Arrows or A D | Z, Space, Up or W | X or J | Shift | C |
| Split screen, P1 (top) | A D, S down | W | F | G | H |
| Split screen, P2 (bottom) | Arrows, Down | Up | J | K | L |
| Gamepad | Stick / D-pad | A | X | RB / LB / Y | B |

These are the default keys: every one of them can be changed in **Options > Change keys** (gamepad buttons stay as above).

The title menu: **1 PLAYER** (pick Peto or Sockee), **2 PLAYERS** (Local split screen, or Online), **OPTIONS**, **ABOUT** (the credits) and **QUIT GAME**. Arrows choose, Enter confirms, Esc goes back; M mutes and unmutes the sound anywhere (the music carries on where it was). Online, the host picks a snake in the room and the friend gets the other one. In a game: P pauses, N (in the pause menu) skips the level.

**Options** has the music and sound-effect volumes, the key bindings, full screen, and a few developer options for testing (start at any level, starting lives, no damage, show FPS). They're saved in `settings.ini` in the game's save folder (`%LOCALAPPDATA%\snake_hangman5`).

Every 10 gems a snake collects give it an **extra life**.

The two snakes share one bar of misses: 6 wrong letters per level, and only **5 from level 10 on**.

### SNUG-ATTACK (two players)

A super move for when you play together, split screen or online: **Sockee** catches, **Peto** is the ball.

1. **Sockee** presses **Roll + Tongue** (Shift + X). A quick tap is a call: a "SNUG!" bubble over his head on both screens, so Peto knows. Held, Sockee curls up into a C on the spot, ready to catch, for up to 5 seconds.
2. **Peto** rolls (hold **Roll**) towards Sockee. When the ball rolls into the C, Sockee snugs it for a moment and flings it back the way it came.
3. Peto stays a ball: **whatever it hits is knocked out** (skeletons too) and a **boss takes a huge hit** (a third of its health bar); the ball bounces off it.

The numbers (5 seconds, fling, damage) are at the top of `scripts/scr_snug`.

### THE SLINGSHOT (two players)

The second super move: **Peto** is the bow, **Sockee** the arrow.

1. **Peto** presses **Roll + Tongue** (Shift + X). A quick tap is a call: a "SLING!" bubble over his head on both screens, so Sockee knows. Held, Peto rears up into a bow on the spot, his tongue as the string, opening towards Sockee, for up to 5 seconds. **Up / Down** (Jump / Down) aim it.
2. **Sockee** holds **Roll** and presses **Boost** (Shift + C) towards Peto: the dashing ball shoots into the string and sits there as the arrow. (Just rolling in isn't enough.)
3. The longer Peto keeps holding, the further it's drawn: the **SLINGSHOT** meter at the bottom fills through **three levels**. When Peto lets go, Sockee flies like an arrow: level 1 is one hit, level 2 two hits (as much as SNUG-ATTACK), level 3 three hits.
4. The arrow knocks out every creature it touches, skeletons too, and bounces off a boss. Unlike SNUG-ATTACK's ball it only hurts creatures: it doesn't break cracked walls or crates.

The numbers (5 seconds, the levels, damage) are at the top of `scripts/scr_sling`.

### Box Snake Egg (two players)

When a snake runs out of lives while its friend is still playing, it curls up into a **Box Snake Egg** where it last stood safely, and its screen follows the friend. The friend is told, and a small arrow at the edge of their screen points to the egg. **Three hits** (tongue, stomp, boost or a fast roll) break it, and the snake comes back right there with **one life**. If both snakes are out, it's game over.

### Online

Press **O**. One player hosts (**H**) and gets a 5-character room code (copied to the clipboard); the other joins (**J**) and types it. The two games find each other through public STUN servers and a few seconds of messages on [ntfy.sh](https://ntfy.sh), then talk directly over UDP: no server to run, no port forwarding. Once connected, the host picks the snakes and presses Enter.

Pausing (P / Esc) online pauses both games: the friend sees who paused ("Wait! Sockee has paused his game!"). Only the one who paused can carry on; Q leaves the online game.

**Chat:** press **T** (in the room or during a game) to talk to your friend; Enter sends, Esc closes. While the box is up your snake stands still (the game doesn't pause). Emojis: **Tab** opens a grid of 24, and shortcuts turn into emojis as you type: `:)` `:D` `xD` `;)` `:P` `:O` `:|` `:(` `:'(` `>:(` `<3` `</3` `(y)` `(n)` `(*)`. Emojis from Windows' own panel (Win + .) work too when they match one of ours. English, Turkish and Greek letters all show. Nothing is saved: the last 5 lines fade after 8 seconds and are gone when you disconnect.

If the code can't connect (both players behind CGNAT), install [Tailscale](https://tailscale.com) on both PCs, and join with **I** (join by IP) using the host's Tailscale address and the room code.

How it is built: `scripts/scr_net` and `objects/obj_net` make the connection; the online game itself (the host runs the world, each PC its own snake) is in `objects/obj_game/Create_0.gml` under "Online game".

### Developer notes (F3)

Spotted a bug or had an idea while playing? Press **F3** anywhere (menus, a game, online), type, and press Enter. Each note becomes one line in `notes.txt` with the time, the level, the mode and where your snake is (in pixels and tiles), plus a screenshot taken the moment you pressed F3 (Tab turns it off; Esc cancels and throws it away). Playing alone or two on one PC, the game pauses while you write. Online it carries on: your friend sees "Wait up! Peto is taking a note", and your snake waits frozen and can't be hurt until you're done.

The notes and screenshots (`notes_shots/`) stay on your own PC, in the game's save folder (`%LOCALAPPDATA%\snake_hangman5`), never in the repository. **Options > Developer > Notes key F3**: Left / Right turns the key off, Enter opens the folder.

## Working on it together

- `git pull` before you start; commit small steps; `git push` when it works.
- Split the work by area, so you aren't both editing the same `.gml` file at once.
- Adding a resource (object, sprite, script) changes `snake_hangman5.yyp`: pull just before, push soon after.
- Check `git status` before committing: GameMaker sometimes re-saves files you didn't touch.
- Share playable builds as GitHub Releases, not in git.
- Project notes for Claude Code (and how to edit GameMaker files safely) are in `CLAUDE.md`.

## Credits

- Game, art and code: Spyros Trimis, Can Dereli and Claude. All characters, levels and art are original; the art is drawn in code (`art_src/make_art.js`, SVG rendered with sharp).
- Music: the JJ20 Team (Megahit, Zyrit, BPStudio, Gridscape, Bitrotator, SIDNIFY, Vincenzo and Ziona), CC BY-NC-ND 4.0. The album covers Alexander Brandon's music; *Jazz Jackrabbit 2* belongs to Epic Games. This is an unofficial fan tribute, not endorsed by Epic Games.
- Text uses Comic Sans MS, already on Windows; no fonts are bundled. The chat's letters (with Turkish and Greek) are baked from Windows' Arial Bold into `spr_text_font` by `art_src/make_text_font.js`; the chat's emojis are drawn in `art_src/make_art.js`.
