# NEXT BUILD LIST (from his play of levels 1-16, 24 Nov). Agreed, NOT built. He keeps adding while he plays
# all 80 levels; the next build comes together with Area 4. Build ONLY when he says "build".
1. Obstacle sounds (DONE in code, commit 2043eaf, not in an APK): bangle = china plate smash, louder
   (tools/plate_sound.py, tools/ob_loud.py); every obstacle sound cleaned and louder; crackers dip under them (sfx.ob).
2. Title screen: no bakery. Crackers scene: night over Grandpa's street, fireworks over the Crackers Factory,
   cracker boxes in front, big "Crackers Match" logo.
3. Daily tasks too high: 20 / 30 / 50 + 100 for all three (200 a day, was 600).
4. Daily + Piggy icons: same top-left spot, a little away from the screen edge, moved ~30 px lower, about 20%
   bigger (Daily 54 -> 64, Piggy 44 -> 64, same size), each on a round glowing badge, pulse when something to collect.
5. Piggy bank clear: "120/250" under it; tap opens a card "Win levels to fill it. When it's full, watch a short
   video and get 250 coins."; AD badge on it when full.
6. Win screen less crowded: drop the "Next build" line and the piggy icon; everything in one card with a gold border;
   keep ribbon, stars, man, reward line, buttons.
7. Level card: after Next it opens over the dimmed home street (like from home), not the dark level screen; the dim
   covers the full screen (no bright strips top and bottom on his phone).
8. Coin Blast win: like the win screen: red "COIN BLAST!" ribbon, gold rays, coin pile counting up, coins raining,
   Next + AD Reward x2 (doubles the coins).

# Agreed plans

BUILT on 23 Nov (level-80 APK, see current-state.md): win screen, tall-screen gaps, Area 3 (in the game, levels
61-80, end leads to Area 4 Delivery Hub), out-of-moves help, ways to earn coins, Coin Blast every 5th, hard levels,
1000 Wala look, board shapes, gold/hint fix, obstacle look (diya + gift), pacing, story fixes.
Sections below are kept for the details. Area 4 = GHILLI Delivery Hub (docs/area4.md), Madurai = Area 5.

## Win screen (agreed 20 Nov) — add only items 1, 2, 3, 4, 6. The man stays exactly as he is.
1. Top text: small red ribbon at the very top "LEVEL 21 COMPLETE" (story serif, art/fonts/CormorantItalic.ttf),
   level name ("Hourglass") smaller in cream under it. Replaces the cartoon "Level 21 · Hourglass" (win.json wLv).
2. Stars: 3 gold stars between the ribbon and BLASTUU! (middle bigger, a bit higher), drop in one by one with pop
   + small sparkle burst. Moves left: 5+ = 3 stars, 2-4 = 2, 0-1 = 1.
3. Ribbon counter: "[diya] +1 · [coin] +70", both count up. The diya picture above the ribbon stays.
4. Soft gold rays slowly turning behind the gold ring (ONE pre-made picture, rotated). Small firework bursts in the
   two empty top corners, timed with the firework sounds already playing (_win_bursts in cm_app).
6. Progress line above Next / Reward: "Next build: Coffee Stall · 2 more diyas" + thin bar;
   "Ready to build: Coffee Stall!" when enough diyas; hidden when the area is done.
Code: cm_app.gd won() and the win part of _build_overlays(); layout ui/win.json.

## Tall-screen gaps (offered 20 Nov, not agreed yet)
Level card dim and level background should fill the full screen height on tall phones (Moto shows bright street
strips above/below the 390x844 stage).

## Area 3 "Busy Days at GHILLI" (talked 18 Nov) — inside the same Chennai shop, indoor builds (Royal Match style)
- 20 levels, 9 builds. The back store room behind the shop becomes GHILLI's ORDER ROOM (orders come in, get packed,
  go out). Builds (agreed 21 Nov, replaces the 18 Nov list; no kids/customers in a back room), in work order:
  1 Clear the Back Room (junk out, broom + bucket)
  2 Phone Order Desk (phone, order book, order board on the wall)
  3 Stock Racks (steel racks of Sivakasi cracker cartons)
  4 Packing Table (brown paper, string, tape)
  5 Gift Box & Wrap Table (Diwali gift boxes + wrapping paper)
  6 Bill Desk & Weighing Scale (bills for big orders)
  7 Fire Safety Corner (sand buckets, fire extinguisher)
  8 Delivery Cycle (at the back door, carrier loaded)
  9 Ready Orders Corner (packed parcels tagged for other towns -> "light up more towns")
  Order board fills with one slip per build. Look (done 21 Nov): bright and colourful room -
  white tube light, light cream walls + sky-blue band, light cream/red tiles, brighter doors.
  Camera + look (done 21 Nov, his indoor reference video + Kenney kit he gave): ONE full-screen picture from INSIDE a
  long narrow room (4.4 x 7 m), camera near the front at 3.8 m looking down the room; floor and walls fill the
  whole screen (no beige). Kenney Furniture Kit (art/a3/kit, CC0) + KIT_LOOK in backroom.gd = flat matching colours,
  no photo textures, soft light. Left wall 3 racks, right wall gift shelf + fire corner, back wall bill desk/window/
  phone desk/board/door, centre packing table, front parcels + cycle.
- Story links (agreed 21 Nov): notebook step 3 stays "Light up more towns"; Area 3 = the first steps to it.
  Start = 3 slides (area_start.gd, start_area = 3, art/story3): 1 notebook, steps 1-2 ticked, step 3 gets gold line;
  2 the man opens the door from the shop into the dusty back store room; 3 in the mess, the man: "First, get GHILLI
  ready!"; card "AREA 3 · Busy Days at GHILLI · the first steps to more towns". (Slides made 21 Nov, dev: --t=a3start.)
  End: sales book up, Madurai letter, "Madurai" written under step 3 in the notebook, NEXT card.
- 3D room: scripts/street/backroom.gd (Backroom, TASKS + skip_to), rendered by tools/pic/a3_pic.gd; textures
  tools/a3tex.py -> art/a3. 9 builds made 21 Nov (builds only, no levels yet): ONE picture a3p0 holds all 9
  (render: a3_pic.gd --w=1620 --h=3507 --ceil=1 --p=0.3,3.8,5.5 --l=0.05,0.3,-3.0 --fov=58 --steps=0..9 --out=/tmp/pics/a3p0, then
  make_pics.py /tmp/pics godot 3) -> street/pics/a3_p0*.webp + a3.json (~0.6 MB). NOT wired into the game yet
  (pic_street set_area only knows 2; levels 61-80, order send-outs and the area end still to do).
- Area 3 end: sales book going up + letter "Open a shop in Madurai?" -> Area 4 = second shop in Madurai.
  Grandpa's notebook never changes. New Year / festival shows much later.
- Build it the picture way from the first build (docs/fps-rules.md): make the 3D room on the computer
  (like scripts/street/bazaar.gd + tools/a2gen.py for Area 2), render 2-3 pictures with godot/tools/pic, stickers per
  build. Order send-outs = 2D animations over the picture (parcel sticker flying out, slip pinned on the board).
- Expected size: ~5-10 MB per new area.

## Area 4 = GHILLI Delivery Hub (docs/area4.md, agreed 23 Nov). Madurai moved to Area 5. Not built yet.

## Saved to-do
- Approved video "area2-start-and-12-builds.mp4" should be copied into previews/ when convenient.

## Help when players run out (agreed 20 Nov) — not built yet
Out of Moves "buy moves" (cm_app MOVEP / tries.coin): ONE price (900 coins), more moves the more THIS level is failed.
- Fail count is per level only; it resets when that level is cleared.
- Tries 1-3: +5 moves · try 4: +10 · try 5 and after: +20.
- Ad on Out of Moves: +5 moves only, once per try (no rocket). NO free booster on retry (decided: keeps coins worth it).
  Players wait for the bigger offer and buy once (his Gardenscapes way).

## Ways to earn coins (agreed 20 Nov) — not built yet
- Piggy bank (Indian clay money pot / undiyal) on the home screen under Daily: +50 coins per win, full at 250
  (5 wins); when full it shakes and glows; one ad breaks it. Win screen shows coins dropping into it.
- Daily tasks using our specials ("Make 5 Rockets", "Fire 3 Ground Chakras", "Break 20 clay pots", "Win 3 levels"):
  3 a day = 50, 100, 150 coins + 300 for finishing all three (~600 a day).
- Ad for coins in the Shop: 50 coins per ad, up to 3 a day.
- 3-star bonus: +30 coins on a 3-star win (stars from the win screen plan).
- Left as is for now (decide later): build chest (builds give NO coins today; only the area end gives 500), free gift every 4 h.

## DONE in code, goes into the next APK (commit after ffc4df3)
- Coin Blast after EVERY 5th level (was only after 5 and 10), with a Skip link on its card (skip = gone for that
  one, next level card opens). Android back on that card = Skip.

## Hard levels (agreed 21 Nov) — not built yet
Hard levels had 26-31 moves vs normal 17-21 (he finished level 35 with 12-15 moves left). Change ONLY hard levels'
moves to about 22-24. Boards unchanged. Normal levels untouched. He plays and tells, then adjust.
Added 21 Nov (talked, saved for later): ALL hard levels end with many moves left. Why: hard levels get ~50% more
moves than normal (26-31 vs 18-21), most start with a free special (Colour Matchbox), and use the same 1-hit
obstacles as normal levels. Rule idea: hard = 22-24 moves, no free start special, more 2-hit obstacles.

## 1000 Wala look (talked 21 Nov, not agreed yet)
Now: a line of 15 small pops hopping tile to tile ("pencil line"). Idea: a red cracker string laid along the path,
then a fast chain of 25-30 bangs with flash, sparks, smoke puff, small tile shake, crackle sound, ~1.5-2 s.

## Board shape variety (agreed 21 Nov) — not built yet
Now: 34 of 60 boards are full 9x8 squares; most of the other 26 only lose a corner/row. He wants variety in later
levels, but NOT object shapes (no heart, star, diya...). Play-changing layouts instead:
two islands (gap between), pillars (blocked cells in the middle), staircase edges, ring (hole in the centre),
skyline (uneven column heights), narrow channel (thin opening top or bottom).
Mixed in after level 30, about one in three levels. Difficulty/moves unchanged by this.

## Gold tiles "match on their own" + wrong hints (found 21 Nov, saved for later) — not built yet
Why (cm/cm_game.gd): a 2x2 square counts as a match. hint_move() prefers special-making swaps (incl. squares) and
lights only the 2 swapped tiles, so the hint looks like no match. A square makes a Ground Chakra that flies to a goal
tile, and gold under a cracker is a goal, so gold breaks "by itself". luck() also sets up ~30% of refills to match,
and calm() only stops ~60% of landing matches after level 30.
Rule idea: hint lights every tile of the match and shows a plain 3-in-a-row first; from level 31 new crackers are
not set up to match.

## Obstacle look (talked 21 Nov, saved for later) — not built yet
All breakables use the same simple break. Rule idea: one bold object per tile with a sharp dark outline like the
clay pot; first hit cracks it, last hit bursts it its own way.
- Diya stack (art/brk/diya_1.png = 3 small diyas, from level 53): replace with 1 big sharp, edgy clay diya; flame
  flares, then the clay cracks into pieces.
- Gift box (from level 49): ribbon unties on hit 1; on hit 2 the lid pops, sides fall open, confetti bursts.

## Pacing after all specials (talked 21 Nov, NOT agreed yet)
Now all 8 specials are unlocked by level 40, then nothing new comes. He noted that "something new every 5 levels"
would also use things up fast. Idea: unlock specials about every 10 levels so the 8th comes near level 80; a new
obstacle or board trick halfway between (levels 5, 15, 25...); a reward chest every 10 levels.
