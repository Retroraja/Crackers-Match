# PLAY GAMES SETUP (26 Nov, he did it in Play Console):
#   app com.retroraja.crackersmatch.godot, AAB v2 (API 36) on Internal testing. Cloud project crackers-match.
#   Play Games Project ID (app id) = 37177410253. Saved Games ON. Both clients saved. SETUP DONE 26 Nov 17:40.
#   OAuth Android client "Crackers Match" (Play signing SHA-1 90:6B:5A:A0:94:83:FF:DA:B5:E3:BF:32:39:A7:A2:AC:57:76:86:9E)
#     = 37177410253-35uaicfbi9u0ht61k8hhmstlem8c1leq.apps.googleusercontent.com (docs/play-games/oauth-client-play.json)
#   2nd client "Crackers Match Test" with our key SHA-1 F5:AD:...:56:45 (for sideloaded APKs).
#   SIGN-IN PLAN (his OK 26 Nov): play as GUEST first (progress saved on phone). Profile page (open by tapping the
#   gold profile frame, top bar left) shows avatar, name ("Guest"), green "Sign in with Google Play" button under
#   the name, records. After sign-in: button -> small "Saved to cloud" tick; cloud save starts only after the tap;
#   new phone: sign in -> progress comes back. Needs a Godot Play Games plugin + app id 37177410253.
#   CI now also makes CrackersMatchGodot.aab (godot.yml). Bump version/code for every Play upload.
# NEXT FIXES (26 Nov night, his list; build ONLY when he says "build"; he is testing the menu APK and may add more):
#  1. Proper sounds for every special: rocket full whoosh + blast; ground chakra blast on landing (hiss gave a tick);
#     flowerpot, sky shot (+ small pops on landing), rail, sparkler play their own files (they only gave a swoosh).
#  2. Soft scroll for Daily sheet, Areas, Trophy Room (Godot scroll flings too hard).
#  3. Trophy Room: 12 trophies (add Matchbox Maker, Bomb Maker, Booster Fan, Coin Collector, Lucky Spinner, Daily Player).
#  4. Soft tap sound (ui_tab, low) instead of the strong swoosh on Shop, Daily, Piggy, Profile.
#  5. Back arrow (top left) on every page: Profile, Areas, Trophies, Lucky Wheel.
#  6. Tall phones: bottom menu bar and level booster area reach the real screen bottom (no blank strip).
#  7. Google Play sign-in + cloud save (plugin, app id 37177410253; plan in "SIGN-IN PLAN" above).
#  8. New app icon = previews/icons/icon-2.png (3x3 board cut, specials on gold tiles, lit middle red, gold corner
#     ornaments; tools/pic/app_icon.py). Fitted to rounded-square phone icons. Set as launcher icon (all sizes).
#  9. Win-screen man (approved 27 Nov): keep the old code man, only: slimmer right shoulder/hip sleeve, slimmer
#     sweeping arm, head and body straight (no tilt/lean), no black sleeve lines. Ready file:
#     docs/pending/winguy_next.gd.txt -> copy over godot/scripts/app/winguy.gd. Skin and hair stay as they are.
#  10. Diya stack breakable: picture too big, spills onto the next tile -> 80% of the tile, centred (levels 53, 56...).
#  11. Shop (approved 27 Nov, previews/shop-no-coin-packs.png): HIDE the real-money coin packs (Starter, 1,000-15,000
#      coins). He: NO real-money packs, maybe several months; do not bring it up again unless he asks.
#      Shop = "You have N coins"; Free with ads: Daily free chest (NEW, once a day: coins / booster / life), +50 coins,
#      Coin chest +300 (3 videos in a row), Free Rocket, Free Hammer, +1 life; Lives: Refill all 900, Unlimited 30 min
#      1500; Start boosters x3: Rocket 900, Colour Matchbox 1900, Ground Chakra 1200, Bomb 1500, Hammer 1200.
#  12. New 3D chest art (Canva, red+gold rangoli, open lid with coins): art/web/shop_chest.png. Use it EVERYWHERE a
#      chest shows (Shop, Lucky Wheel 500-coin prize, rewards, popups) instead of art/web/ui-chest.webp.
#  13. My Crackers page: first row = Mayil Matchbox (LEGENDARY tag, peacock art, lock, "Unlocks at Level 101").
#      Every cracker locked until its level (greyed, lock icon, "Unlocks at Level N" instead of the count):
#      Rocket 2, Colour Matchbox 3, Ground Chakra 5, Lakshmi Vedi Hammer 5, Bomb 8, Sparkler 12, Flowerpot 22,
#      Sky Shot 32, Snake 42, Rail 52, 1000 Wala 62, Seven Shot 72, Mayil Matchbox 101 (same as UNL / SBU in cm_app).
#  14. 1000 Wala (27 Nov): NO line/string drawn along the path. Same 15-tile zig-zag path (same gameplay); a small
#      red cracker picture (our b0, pooled) sits on each path tile, they pop one by one along the path (gold flash
#      picture + crackle), each pop breaks its tile. He will judge it in the game (no mock).
#  15. Gold floor tile sound (his file, 27 Nov): sfx/ob_gold.wav = double coin clink (his clip C, ~0.9 s, loud).
#      In cm_game.gd floor hit: gold floor -> sfx.ob("ob_gold") instead of "paper"; add "ob_gold" to Sfx NAMES.
#  16. Diya obstacle new art (his OK 27 Nov, no picture first; he judges in game): real 3D clay diya (Canva, cut
#      and kept at a sharp size), ~80% of the tile, centred; normal + cracked (after a hit) + stack versions.
#      Small still flame painted in the picture (no live fire, no FPS cost). Replaces fix 10's resize.
#  RULE for every fix: must not crash the game and must not lower FPS.
# NEXT PLAN (after build 0.3, 27 Nov; build only when he says "build"):
#  P1. Edit Profile (later): pencil/Edit button by the name -> card: Name box (max 14, simple bad-word block,
#      default = Google Play name), Avatar grid (~12: new premium Canva Diwali characters + some crackers; some locked,
#      unlock with trophies), frame colour (gold/silver/ruby/emerald, unlock with trophies), Save. Shown in the top-bar
#      profile frame too; saved to the cloud.
#  P2. Tall phones: he still sees a blank strip at the bottom of the level screen (check on his phone size).
# BUILT 26 Nov (menu APK, see current-state.md): top bar, lives, bottom menu + Areas/Trophy Room/Lucky Wheel/Profile,
# level screen theme per area (1 royal blue, 2 maroon, 3 teal, 4 navy, 5 ruby), Shop badge, popups navy, Area 2
# "Inside the shop!" card, Area 3 Chennai labels. Still waiting: Diya + 1000 Wala (his OK, picture first), gold
# floor tile sound (his file), Google sign-in + cloud save code.
# NEXT FIXES (25 Nov, after the 100-level APK):
#  - TROPHY ROOM page (26 Nov, previews/trophy-room.png): scrollable list, permanent trophies (Rocket Master,
#    Star Collector, Chakra Spinner, Sparkler Fan, Builder, 3-Star Hero...); each has bronze -> silver -> gold steps;
#    finishing a step shows a green Claim button = coin reward; all done = gold trophy + "Complete". Top shows counts.
#  - LUCKY WHEEL page (26 Nov, previews/lucky-wheel.png, art/wheel/, tools/pic/wheel_build.py): 8 prizes (100/50/200
#    coins, 500-coin chest, Rocket, Bomb, Hammer, +1 life); SPIN FREE once a day; Spin again = watch ad; timer;
#    bulbs blink while spinning. Wheel rim/segments built at full size (sharp); hub/pointer/bulbs Canva.
#  - Crate sounds DONE 26 Nov: wood + steel crates same sounds; first hit = sfx/ob_crate_hit (his "small break"),
#    last hit = sfx/ob_crate (his crate destroy, quieter). Gold floor tile still old paper sound (waiting his file).
#  - PROFILE page (talked 26 Nov): avatar, name, my records; progress saved with Play Games cloud save (he does the
#    Play Console steps later; remind him).
#  - LIVES (his OK 26 Nov): real lives like Royal Match. 5 hearts max; losing a level takes 1 heart; +1 heart every
#    30 min (timer in the heart pill, "Full" at 5); at 0 hearts: wait, watch an ad (+1) or pay coins (refill all).
#  - TOP BAR (26 Nov, talking): too crowded. Remove the diya pill (Build button shows diyas). Premium design:
#    coins, lives, settings only, even gaps, shiny Canva pills, coin/heart icons half outside the pill, small gold
#    profile frame, soft dark fade behind. Picture first.
#    (his OK) diya pill stays: 3 cream pills + gear (previews/top-bar.png). Numbers never overlap: text shrinks to
#    fit inside the pill; from 1,000,000 show short form (1.2M) so it stays readable.
#  - Title: DONE in code 25 Nov: option 1 angle, picture by phone clock (afternoon 6-16 art/web/title_aft.webp,
#    evening 16-19 title_eve.webp, night 19-6 title_base.webp). Fireworks = ready-made bursts (no circles, v2,
#    tools/pic/title_bursts.py, title.gd SpriteFw), softer by day. Approved 15:23.
#  - Shop icon on home: same 64 px glowing badge as Daily/Piggy, same height as Daily, mirrored on the right
#    (Test button moves under it). Waiting for his OK.
#  - Area 3 parcel labels -> Chennai (his choice 25 Nov, option 1): big top label "CHENNAI", small labels
#    T. Nagar, Mylapore, Adyar, Anna Nagar, Velachery (no Madurai/Salem/Kanchipuram/Vellore; Madurai stays the
#    Area 5 surprise). Re-render the Area 3 order-room pictures (same look, only the labels) and check the Area 3
#    start/end lines say Chennai, not "more towns".
#  - Seven Shot: DONE in code 25 Nov: same blast/animation, but the 7 shells stay inside the board (rise to the top
#    rows, hang with a spark, fall onto targets). Not yet seen in a video.
#  - Diya obstacle (talk done, waiting for his OK): real 3D clay diya like the pambaram render, ~80% of the tile,
#    standing on the tile base line, small soft shadow, nothing outside the tile; cracked + stack versions too.
#    Ask: small lit flame or not.
#  - 1000 Wala (waiting for his OK): a real cracker-string picture across the tiles it hits, bursting one by one
#    (flash + smoke puff pictures), string gets shorter; no drawn lines.
#  - Area 2 slide (his pick option 1, 25 Nov): keep the 2 pictures (shop front builds 1-6, inside builds 7-12) but
#    make the move clear: after build 6 a short fade + "Inside the shop!" card, then picture 2 (pic_street _place).
#  - Cracker meter tip (level 2): DONE in code 25 Nov: "Drag the cracker onto the board!" moved down under the
#    meter (toast28 y 150 -> 208) so the meter stays visible.
#  - Special sounds DONE 26 Nov: Ground Chakra = the flowerpot hiss, faster and higher (spinning); Flowerpot unchanged
#    (fireball pops tried and removed: the tiles' own break sounds are enough).
#  - Breakable sounds DONE 26 Nov: all real recordings from his Pixabay files: pot = clay pot break, diya = plate
#    break, soda = glass break, bangles = lightbulb break, coconut = bone crack (soft short hit + full split),
#    matchbox = matches box, newspaper = paper rip (short + full), gift = sealing tape rip + slap. All <1 s.
#  - (old) Clay pot sound: DONE 26 Nov: his pick = the first new one (tools/pot_tab_sounds.py), made louder, now
#    sfx/ob_pot.wav. Kenney recordings were rejected ("don't feel like sounds").
#  - Areas tab (his OK 26 Nov): FIRST tab, in place of Events. One picture card per area (1 Sivakasi Street,
#    2 GHILLI Crackers, 3 Order Room, 4 Delivery Hub, 5 Madurai locked "Coming soon"); finished areas: View button
#    (finished picture + fireworks); current area: "Builds 5/9". Events come later as their own icons on the
#    home screen (each event its own name/icon, like other games), not a bottom tab.
#  - Bottom menu (talked 26 Nov, waiting): bar flat to the screen bottom (no border/strip), raised selected tab with
#    name, page slide; tab sound = sfx/ui_tab.wav = his file "retro arcade menu navigate" (Pixabay, vadim_makes_sound); his 2nd file "ui sound" (Pixabay, arnav_geddada) saved as sfx/ui_tab2.wav; no slide sound, light vibration if on;
#    each tab gets a simple page. Profile icon (top-left Hydrogen Bomb, does nothing now): his call.
#  - Level screen THEMES (26 Nov): clean style like his Royal Match picture: solid colour top bar, cream cards
#    with ribbon labels (Target / Moves), man in an arch frame with a gold edge, thin gold line, Cracker meter in
#    the theme colour (below the line, no overlap), cream board floor, booster boxes in the theme colour. No
#    patterns/sparkles (he found those silly). 10 colours, one per area later: previews/themes/ (themes.json,
#    tools/pic/themes_mock.py). Mockups only; no black. Not built yet.
#  - Win screen: DONE in code 25 Nov (his pick option 1): old look, no card/border, no piggy/next-build line,
#    Next + Reward buttons 40 px higher (not at the screen's bottom edge).
# BUILT 25 Nov (100-level APK, see current-state.md): every item of the NEXT BUILD LIST below except 17 (rangoli,
# dropped) and 20's power (Mayil Matchbox only shows on the level card, art = Colour Matchbox in peacock colours,
# shine + feather eye, approved 25 Nov 12:03). Area 4 (items 21/25/26) is in the game. Not checked on a phone yet.
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
9. Free bar crackers move off the hard levels: unlock at 12, 22, 32, 42, 52, 62, 72 (+3 free each) instead of
   10, 20, 30... (hammer stays 5). Hard levels keep their moves and the 2-hit crates as they are now (agreed 24 Nov).
10. Board shapes in Area 1 too (hook before level 30): 13 two islands, 17 pillars, 22 ring, 27 skyline. Not on
    Hard (15/20/25/30) or intro levels (11/18/23). Same obstacle types and moves, targets a little smaller, kept easy.
11. Islands = U shape (agreed 24 Nov): the 2-column empty strip runs down the middle, but the LAST 2 ROWS are one
    full joined row, so matches cross at the bottom. Level 32 changes to this, and Area 1 level 13 uses it.
12. New goal "Blast X crackers" (agreed 24 Nov, changed 25 Nov): e.g. "Blast 25 red crackers"; goal panel shows that
    cracker with a count; every cracker of that colour cleared counts, specials included. ONLY ADDED as an extra goal
    to about 1 level in 5 (levels 3-100). EXISTING GOALS STAY EXACTLY AS THEY ARE; no level becomes Blast-X-only.
13. New goal "Bring down" — potli bag + pambaram (agreed 24 Nov):
    - Piece: not matchable or breakable, specials pass it; falls when the cells below clear; can be swapped.
    - EXIT (his words, no coin animation, it would cost FPS): bag at the bottom row wiggles a little with a sound, then
      the whole bag flies up to its goal icon. Pambaram at the bottom row spins fast for a short flash, then the whole
      pambaram flies to its goal. Neither clears anything. Nothing is drawn below the board (no holes, trays, arrows).
    - More pieces drop in from the top until the goal count is done.
    - GOAL PANEL: bag / pambaram icon with a count; the arriving piece lands on it, it pulses, 3 -> 2 -> 1 -> tick.
    - ART: real 3D renders (godot/tools/pic/toy3d.gd). Pambaram: round top painted red / yellow / red (his flag
      colours), wooden cap, bare wooden cone, short iron nail, chunky (scale 1.35 wide) (previews/pambaram-3d.png).
      Bag: red velvet potli, gold string, to be redone as a real 3D render the same way (sketch previews/potli3d.png).
    - SIZE (agreed 16:15, previews/bag-pambaram-on-board.png): same size as the crackers, standing on the tile floor like
      the green bomb (pambaram nail tip touches the bottom of the tile); bag keeps its soft shadow, only narrower.
    - TEACHING (level 6): intro card "New: Potli Bag" + picture + "Clear the crackers under the bags. Bring them to the
      bottom!"; hand demo once (one swap right under a bag, the bag drops a cell; any touch stops it); first bag out:
      toast "Bag collected! 2 more." Same pattern for the pambaram at 41.
14. Ad screen (his screenshot 24 Nov 16:23): our game's top bar peeks through above the ad, then a black band; the ad
    starts lower. Fix: (a) the ad fills the whole screen, (b) the phone's status bar stays visible so the ad's X is
    never hidden, (c) plain black behind the ad so the game never shows through. Check the X on his phone before
    saying it works.
    Detail (agreed 16:29): the time/battery strip shows at the top ONLY while the ad is open (the game hides it
    during play); the ad's X sits just below that strip; everything else behind the ad is black.
15. Portals (agreed 24 Nov 16:32): split board, a glowing hole at the bottom of a left-board column sends whatever
    falls in to the top of a right-board column. Level 28 = first portal level, plain (learn it). Then only 2 levels
    mix portals with the bring-down goal: ~46 portal + potli bag, ~71 portal + pambaram (the piece must go down the
    left board, through the portal, then down the right board to count).
16. How often bag / pambaram: bag 6, 16, 26, then 36, 46, 56, 66, 76; pambaram 41, 51, 61, 71 (5 apart from the bag).
17. Rangoli goal: DROPPED (24 Nov 16:44). Every version tried (tile patterns, paint spreading on the floor, hidden 3x3
    revealed) made the board look worse. Do not bring it back unless he asks.
19. BUG (his video 24 Nov 16:48): the back arrow at the top left of a level (bQuit) and "Exit level" in the gear menu
    (_gs "exit") call quit_level() at once: no question, the level's progress is lost. Fix: both, and the phone's
    back button during a level, open a small card "Leave level?" / "Your moves and progress in this level will be
    lost." with a big green Keep playing and a red Leave; the level pauses behind it.
20. Mayil Matchbox (agreed 24 Nov 18:37), replaces the "Golden Matchbox" card on the level card:
    - LOOK: peacock-blue and purple box, silver and gold edges, small peacock-feather mark (one ready-made picture,
      not the colour bundle, not all yellow). Name "Mayil Matchbox". Card text "Legendary cracker · Level 101".
    - UNLOCK: Level 101 (was 100).
    - WHERE: a booster on the level card (picked before play, placed on the board at the start). Never made from a match.
    - POWER (a goal cracker, not a tile cleaner): swap it with a cracker -> peacock lightning (1) hits EVERY goal
      obstacle on the board once (2-hit crate loses a layer, newspaper / gift box breaks), (2) clears every cracker
      of the swapped colour. Normal Colour Matchbox stays as it is (1 colour, obstacles only next to cleared crackers).
    - HOW TO GET IT: still to pick from: 1 free at level 101 with an intro card; small chance in the every-10-levels
      chest; 7-day daily-task streak reward; shop 2,500 coins (no real money).
    - Next step: a picture of the new box for him to approve.
21. Area 4 builds preview (24 Nov, previews/area4-mock/area4-all-9-builds.mp4, not agreed yet): builds 1-4 pop in
    on the still home view (no zoom, gold glow + sparkle), 5-9 deliveries in the temple-video style (temple, Kalyana
    Mahal wedding hall, school, flats, Marina party + lighthouse). Order board now stands on the footpath in front of
    the shop (was hidden). Open: the packing table (build 3) is partly behind the board; move it left by the van?
    Tools: godot/tools/pic/a4_mock.gd (--built=N, --place=wedding|school|apts|marina, seed fixed so palms don't jump),
    godot/tools/pic/a4_builds_video.py.
22. BUG (25 Nov, level 44 screenshot): in-level coin pill (bottom-left, node gCoins in cm_app.gd) - "61140" runs
    out of the pill. Fix: the pill grows to fit the number (up to 7 digits), number stays inside with padding;
    check the same on the level card (lCoins) and home (tCoin) with big numbers.
23. Sky Shot clearer (25 Nov): now it flies up behind the top bar and you can't see what happens. New: tube recoils,
    shell climbs with a short spark trail but STAYS over the board, bursts over the board (~2 rows from the top) with a
    gold flash + ring; for a split second a small glowing ring marks each of the 12 target tiles (4 goal tiles = gold
    ring); then 12 stars with short gold trails fall from the burst onto the rings one after another (~0.6 s total),
    each pops its tile with a small spark. Like the Flowerpot, which is clear.
    FPS RULE (he insists, for this and EVERY change in this list): must not lower FPS or performance. Only moving
    ready-made pictures (pooled sprites), no new particle systems, no live drawing, no extra lights/shaders; check
    the FPS counter on the phone stays where it is now (~69-71).
24. Test tools (25 Nov, his test version only, not hidden): a "Test" button on home opens a Builds card -
    area tabs 1-4, a button per build (jumps to just before it and plays its animation, tap again to replay),
    "Play all builds", "Area start" / "Area end", "+100 diyas". Plus "Go to level" (number box, opens that level,
    earlier levels/builds marked done) and a small "Win now" button in the level top bar (next to back/settings)
    that ends the level as a win. Uses what is already in the game, no FPS cost.
25. Area 4 = levels 81-100 (confirmed 25 Nov), 20 levels for its 9 builds, like Area 3.
26. Area 4 home layout (25 Nov): EVERY build must be clearly visible when he taps Build. Order board stands on the
    footpath in front of the shop (a4_mock: --bstand=1 --bscale=1.4 --board=-0.6,1.75,3.2 --brot=0.9); packing table
    moved to the right side of the shop (--table=1.6,0.19,2.9), the left spot by the van was hidden by the board.
    Builds 1-4 pop in on the still home view (gold glow + sparkle), no camera zoom.
18. Still waiting from him: more fixes while he plays all 80 levels; Area 4 (GHILLI Delivery Hub, docs/area4.md) to be
    built for the same next APK.

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
