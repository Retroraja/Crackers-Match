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
- 20 levels, 9 builds. Orders come all through the area: after each build a small real order is packed and sent out
  (celebration moment); an order board on the wall fills with slips.
  1 clear the back store room -> neighbour aunty's sparkler pack
  2 order board + old phone -> first phone order: school function
  3 billing counter + cash register -> a family's Diwali bill
  4 packing table (paper, string) -> 5 parcels for nearby houses
  5 gift-box shelf -> office order of 20 Diwali gift boxes
  6 gift-wrap corner -> wedding family's wrapped hampers
  7 stock racks to the ceiling -> temple committee bulk order
  8 delivery cycle at back door -> delivery boy rides out with orders
  9 kids' corner + customer queue -> shop full, big rush of orders
- Story links (agreed 21 Nov): notebook step 3 stays "Light up more towns"; Area 3 = the first steps to it.
  Start = 3 slides (area_start.gd, start_area = 3, art/story3): 1 notebook, steps 1-2 ticked, step 3 gets gold line;
  2 the man opens the door from the shop into the dusty back store room; 3 in the mess, the man: "First, get GHILLI
  ready!"; card "AREA 3 · Busy Days at GHILLI · the first steps to more towns". (Slides made 21 Nov, dev: --t=a3start.)
  End: sales book up, Madurai letter, "Madurai" written under step 3 in the notebook, NEXT card.
- 3D room: scripts/street/backroom.gd (Backroom, TASKS + skip_to), rendered by tools/pic/a3_pic.gd; textures
  tools/a3tex.py -> art/a3. 9 builds made 21 Nov (builds only, no levels yet): ONE picture a3p0 holds all 9
  (render: a3_pic.gd --w=1620 --h=3507 --p=0,7.6,5.6 --l=0,0,-2.8 --fov=55 --steps=0..9 --out=/tmp/pics/a3p0, then
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
