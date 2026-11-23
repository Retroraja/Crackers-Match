# Current state — level-80 APK (23 Nov 2026), branch claude/project-thread-nyydf2 (PR #1)

APK: https://github.com/Retroraja/Crackers-Match/releases/download/godot-dev/CrackersMatchGodot.apk

## New in this APK (23 Nov, everything he asked for up to the end of Area 3)
1. Story ("Grandpa's Dream"): on phones it plays live over the same street pictures he builds on (no video;
   video/ is no longer exported). The promise shot shows the Crackers Factory as a big gold blueprint
   (art/story/factory_dream.png from tools/pic/factory_blueprint.py) drawn from the ground up; the man stands to the
   left. New line: "Thatha, I'll rebuild your street… and your Crackers Factory." Then a card:
   Win levels → Earn diyas → Build the street ("Every level you win gives a diya. Diyas rebuild Grandpa's street.").
2. Area 3 "Busy Days at GHILLI" in the game: levels 61-80 (Hard 65/70/75, Super Hard 80, 3-colour breather after
   each Hard), order room picture with 9 builds (costs 2,2,2,3,3,3,3,3,4 = 25 diyas = what 61-80 give),
   Area 3 start slides after the Area 2 reward, Area 3 end (room ready, orders going out, NEXT: GHILLI Delivery Hub ·
   coming soon), reward 1500 coins. After that, Play says Area 4 is coming soon.
   Build window: area titles (Sivakasi Street / GHILLI Crackers / Order Room), build icons for Areas 2-3
   (art/web/task-aA-N.webp, cut from the stickers).
3. Win screen (plan items 1, 2, 3, 4, 6): red "LEVEL N COMPLETE" ribbon + level name, 3 stars by moves left
   (5+ = 3, 2-4 = 2, 0-1 = 1), "[diya] +1 · [coin] +70" counting up, gold rays turning behind the ring
   (art/win/rays.png), small fireworks in the top corners with the firework sounds, "Next build: X · N more diyas"
   + bar / "Ready to build: X!". The man is unchanged. A coin drops into the piggy bank.
4. Coins: piggy bank on home under Daily (+50 per win, full at 250, shakes and glows, one ad breaks it);
   daily tasks in the Daily sheet (3 of: Make 5 Rockets, Fire 3 Ground Chakras, Break 30 obstacles, Win 3 levels;
   50/100/150 + 300 for all three); Shop: watch a video for +50 coins, 3 a day; 3-star win +30 coins;
   reward chest every 10 levels (not 30/60/80, which have area rewards): +200 coins, 1 Bomb, 2 Rockets.
5. Out of Moves: one price 900 coins; moves by tries on this level: tries 1-3 +5, try 4 +10, try 5+ +20
   (S.fails, a try ends at Give Up, cleared when the level is won). Ad: +5 once per try.
6. Hard levels: 22-24 moves (level 10 keeps its combo lesson, 24 moves), no free start special, every second crate
   is a 2-hit crate.
7. Board shapes after 30 (levels 32, 38, 42, 46, 48, 52, 56, 58 + about one in three of 61-80): islands, pillars,
   staircase, ring, skyline, narrow channel.
8. Gold/hint fix: the hint lights every tile of the match and shows a plain 3-in-a-row first; from level 31 new
   crackers are never set up to match (no lucky refills) and landing matches are stopped 95% of the time.
9. Tall phones: the game background and every window dim cover the whole screen (cm_app._tall_fix).
10. Diya obstacle: one big sharp clay diya (art/brk/diyab*.png); on its hit the flame flares, then the clay cracks
    into pieces. Gift box: hit 1 unties the ribbon (bow flies off), hit 2 pops the lid, the sides fall open, confetti.
    (tools/pic/brk_new.py)
11. 1000-Wala: a red cracker string is laid along a path through its 15 tiles, then 28 fast bangs run down it
    (flash, sparks, smoke, small shake, crackle), ~1.7 s.
12. Pacing: bar crackers unlock at 5, 10, 20, 30, 40, 50, 60 and 75 (Seven Shot), each with 3 free.
13. Coin Blast after every 5th level with a Skip (from 20 Nov).

Not checked on a phone yet. Bot play (weak, no lucky refills) loses most levels after 30 by a few goals, the
same as before on old levels; 70 and 75 were eased. He plays and tells.

## Earlier history (short)
- 14-16 Nov: web game ported to Godot (cm_game board, cm_app screens, UI captured from the web into ui/*.json).
- 17 Nov: story intro "Grandpa's Dream", Area 1 = 30 levels, 10 builds; Area 2 Chennai GHILLI shop, 12 builds, 60 levels.
- 18 Nov: breakables (pot, soda, coconut, matchbox, newspaper, bangles, gift, diyas), cabinets per type.
- 18-19 Nov: speed work (videos test, board baking, man drawn once) -> led to fps-rules.md and picture areas.
- 20 Nov: level card pause, back button, picture-based areas (see git history for that APK's list).
