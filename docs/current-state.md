# Current state — menu APK (26 Nov 2026), branch claude/project-thread-nyydf2 (PR #1)

APK: https://github.com/Retroraja/Crackers-Match/releases/download/godot-dev/CrackersMatchGodot.apk
AAB (Play, version code 3, API 36): same release, CrackersMatchGodot.aab

## New in this APK (26 Nov)
1. Top bar (scripts/app/top_bar.gd, art/topbar): gold profile frame (opens Profile), cream gold-rim pills (coins,
   lives, diyas; pill built at full size by tools/pic/pill_build.py), big icons half outside, blue Canva gear, soft
   dark fade; numbers shrink to fit, 1,000,000+ = 1.2M.
2. Lives (cm_app lives_now/use_life/add_life, scripts/app/lives_box.gd): 5 max, +1 every 30 min (timer in the heart
   pill, "Full" at 5). Give up or Leave mid-level takes 1. At 0, Play opens "Out of lives": ad +1 or 900 coins refill.
3. Bottom menu (scripts/app/menu_ui.gd, art/menu from tools/pic/menu_art.py): Areas, Trophies, Home (raised),
   Lucky Wheel, Crackers; gold top line + divider lines; tab sound sfx/ui_tab.wav + light vibration; Level/Build
   buttons 32 px higher. Android back closes a page.
4. Areas page: area picture cards; finished = View (picture + firework bursts), current = "Builds n/N", later =
   Locked, Area 5 Madurai "Coming soon".
5. Trophy Room: 6 permanent trophies (Rocket Master, 3-Star Hero, Chakra Spinner, Obstacle Breaker, Level Winner,
   Builder), bronze/silver/gold steps, green Claim = coins, gold + Complete. Stats in S.stat (from the daily events).
6. Lucky Wheel: 8 prizes (100/50/200 coins, 500 chest, Rocket, Hammer, Bomb, +1 life), free spin once a day,
   "Spin again" with an ad (3 a day), timer to midnight, lit-bulb picture blinks while spinning. Wheel = one picture.
7. Profile: avatar, name (Guest), "Sign in with Google Play" button (says "comes soon" in this APK), records.
8. Level screen theme per area (scripts/app/level_theme.gd): solid colour bar + gold line, cream Target/Moves cards
   with ribbons, man in a gold arch, meter + locked boosters in the area colour, cream board floor.
   Area 1 royal blue, 2 deep maroon, 3 peacock teal, 4 midnight navy, 5 ruby red. Star bar hidden.
9. Shop = round glowing badge like Daily (right side); Test button under it.
10. Popups: violet -> navy blue (card, hard card, banners, settings, rewards, dims).
11. Area 2: after build 6 a fade card "Inside the shop!" before picture 2.
12. Area 3: parcel labels are Chennai places (T. Nagar, Mylapore, Adyar, Anna Nagar, Velachery) + big CHENNAI tag;
    room pictures re-rendered; start lines say Chennai.
13. From before (in code since 25-26 Nov): title picture by phone clock + new fireworks, win screen buttons 40 px up,
    level 2 meter tip lower, Seven Shot shells inside the board, new obstacle sounds + crate sounds + faster chakra.
NOT in it: Diya / 1000 Wala pictures (wait for his OK), gold floor tile sound (wait for his file), real Google
sign-in / cloud save (button only). Dev: tools/shot (screenshots: godot -- --do=EXPR --step=SEC:EXPR --at=SEC:PNG).

# Before: 100-level APK (25 Nov 2026), branch claude/project-thread-nyydf2 (PR #1)

APK: https://github.com/Retroraja/Crackers-Match/releases/download/godot-dev/CrackersMatchGodot.apk

## New in this APK (25 Nov, the whole NEXT BUILD LIST in plans.md)
1. Obstacle sounds louder, bangle = china plate smash (2043eaf).
2. Title: night picture of the Crackers Factory (warm windows), our crackers on show in front, logo + fireworks
   (art/web/title_base.webp from tools/pic/title_night.py). Bakery effects/clouds off.
3. Daily tasks 20/30/50 + 100 for all three.
4-5. Daily + Piggy: 64 px on a round glowing badge (art/web/ic_badge.png), 16 px from the edge, ~30 px lower; glow
   pulses when there is something to collect. Piggy shows "120/250", tap = help card, AD badge when full.
6. Win screen in one card with a gold border; no Next build line, no piggy icon.
7. Next opens the level card over the dimmed home street; card dim covers the full screen.
8. Coin Blast win: scripts/app/bonus_win.gd (ribbon, rays, coin pile, count up, coin rain, Next + AD Reward x2).
9. Bar crackers unlock at 12, 22, 32, 42, 52, 62, 72 (hammer 5).
10-11. Board shapes 13 (U), 17 pillars, 22 ring, 27 skyline; U boards 13, 32, 65 (78 already joined).
12. Blast X: extra goal on 4, 9, 14 ... 99 (levels.gd all(): "blast"), toast at start, intro card at 4.
13. Bring down: potli bag (6, 16 ... 96) and pambaram (41, 51 ... 91): 3D renders art/toy/bag.png, top.png
    (tools/pic/toy3d.gd --toy=potli|pambaram, toy_tiles.py). Map letters v / t; 2 on the board, 3 to bring down,
    +5 moves on those levels. Engine: cm_game.gd "bring down" section (toy_exit, _draw_toy). Intro card + hand demo.
14. Ad: black behind the ad (cm_app _ad_black), status bar shown only while the ad is open (CMAds.java bars()).
15. Portals: levels.gd "portal" [[r_out,c_out,r_in,c_in]]: 28 plain, 46 + bag, 71 + pambaram (cm_game gravity).
17. "Leave level?" card (scripts/app/ask_box.gd) on back arrow, Exit level and the phone's back button.
18. Coin pills grow to fit (cm_app coin_t); home pill shrinks the font.
19. Sky Shot: shell stays over the board, gold flash + ring, 12 target rings (gold on goals), stars with trails
    (art/fx, tools/pic/sky_fx.py).
20. Mayil Matchbox on the level card (art/toy/mayil.png, tools/pic/mayil_recolor.py + mayil_shine.py), Level 101.
21. Test tools: "Test" on home (scripts/app/test_ui.gd), "Win now" in the level top bar.
22. Area 4 GHILLI Delivery Hub, levels 81-100 (Hard 85/90/95, Super Hard 100), 9 builds (pic_street A4_TASKS,
    costs 2,2,2,3,3,3,3,3,4). Builds 1-4 pop with gold glow; 5-9 deliveries (pic_street _deliver). Pictures:
    tools/pic/a4_render.sh -> tools/pic/a4_pics.py. Area 4 start slides (art/story4), end -> NEXT Madurai (soon).
    Players who finished Area 3 enter Area 4 on their next Play.

# Before: level-80 APK (23 Nov 2026)

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
