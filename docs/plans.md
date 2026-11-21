# Agreed plans — NOT built yet (wait for his "go")

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

## Area 4 Madurai — second shop. Not designed yet.

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

## 1000 Wala look (talked 21 Nov, not agreed yet)
Now: a line of 15 small pops hopping tile to tile ("pencil line"). Idea: a red cracker string laid along the path,
then a fast chain of 25-30 bangs with flash, sparks, smoke puff, small tile shake, crackle sound, ~1.5-2 s.

## Board shape variety (agreed 21 Nov) — not built yet
Now: 34 of 60 boards are full 9x8 squares; most of the other 26 only lose a corner/row. He wants variety in later
levels, but NOT object shapes (no heart, star, diya...). Play-changing layouts instead:
two islands (gap between), pillars (blocked cells in the middle), staircase edges, ring (hole in the centre),
skyline (uneven column heights), narrow channel (thin opening top or bottom).
Mixed in after level 30, about one in three levels. Difficulty/moves unchanged by this.
