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
Also picked (from the talk, confirm details before building):
1. Ad on Out of Moves = +5 moves AND a free rocket placed on the board.
2. After a lost level, the next try starts with one free booster ("Try again with a free Rocket!").
4. Each build pops a small chest: coins + a booster (the street pays like Gardenscapes' map).
5. Piggy bank: every win adds coins; when full, one ad breaks it (~500 coins).
Later maybe: 3 win streak (start boosters), 6 free gift every 4 h, 7 daily tasks, 8 ad for coins in Shop,
9 easier hard levels 23-25 (start special or +2-3 moves).
