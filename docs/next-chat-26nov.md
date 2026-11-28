Continue Crackers Match (Godot 4.3 Android match-3). Repo Retroraja/Crackers-Match, branch claude/project-thread-nyydf2 (PR #1). Read docs/plans.md (NEXT FIXES at the top), docs/working-rules.md and docs/current-state.md first. Last APK: 25 Nov, 100 levels (commit f1d889f). Make the NEXT APK with everything below.

MY RULES (strict):
- Short replies, simple words, low tokens. One thing at a time. Don't give me many options.
- When I use a question mark: talk only, don't act. "Ok" = do it.
- NO change may lower FPS (~69-82 now). Only pooled ready-made pictures. No live drawing, no new particles/lights/shaders.
- Icons/UI must be premium Canva art (generate-image), never flat code-drawn. Similar to Royal Match, never copied.
- Canva gives only a 200px preview here (full-size download is blocked). Use Canva pieces only at a size where they stay sharp; build big shapes (like the wheel rim) at full size (see godot/tools/pic/wheel_build.py).
- Picture first only where I say "picture first". Don't change level goals unless I say.
- Save notes to docs/plans.md and project doc claude/next-build-list-24nov.md.

ALREADY IN CODE, NOT YET IN AN APK (check they still work):
- Title screen picture by phone clock (afternoon/evening/night) + new uneven fireworks (art/fx/fw_*).
- Win screen: old look, Next/Reward buttons moved up 40px.
- Level 2 cracker-meter tip card moved lower.
- Seven Shot shells stay inside the board.
- New sounds: pot, diya, soda, bangle, coconut, matchbox, newspaper, gift, crates (ob_crate / ob_crate_hit), chakra (flowerpot sped), tab sound sfx/ui_tab.wav.

BUILD IN THE NEXT VERSION:
1. TOP BAR (approved, previews/top-bar.png, tools/pic/topbar_mock.py, art/topbar/): cream Canva pills with gold rim (coins, hearts, diyas) + premium blue gear (art/topbar/gear_src.png), small gold profile frame, big icons half outside the pill, soft dark fade behind, bar a little lower. Numbers shrink to fit inside the pill; 1,000,000+ shows short form (1.2M).
2. LIVES (approved): real lives like Royal Match. 5 hearts max; losing a level takes 1; +1 every 30 min (timer shows in the heart pill, "Full" at 5); at 0: wait, watch an ad (+1) or pay coins (refill all).
3. BOTTOM MENU: Areas (first tab, area picture cards, finished = View, current = "Builds 5/9", 5 Madurai "Coming soon"), Trophies, Home (raised), Lucky Wheel, Crackers. Premium icons art/web/nav-map.png, nav-trophy.png, nav-wheel.png; thin gold divider lines; taller bar, icons ~70px; Level/Build buttons moved up so nothing overlaps; tab sound ui_tab.wav + light vibration.
4. TROPHY ROOM page (previews/trophy-room.png): scrollable, permanent trophies, each with bronze/silver/gold steps; finished step = green Claim button (coins); all done = gold trophy + "Complete".
5. LUCKY WHEEL page (previews/lucky-wheel.png, tools/pic/wheel_page_mock.py, art/wheel/): 8 prizes (100/50/200 coins, 500-coin chest, Rocket, Bomb, Hammer, +1 life); SPIN FREE once a day; "Spin again" with AD; next-spin timer; bulbs blink while spinning (same picture, no FPS cost).
6. PROFILE page: avatar, name, my records (cloud save later).
7. WAITING FOR MY OK (ask me first, picture first): Diya obstacle as real 3D clay diya (~80% of tile, cracked + stack versions; ask: small flame or not). 1000 Wala as a real cracker-string picture bursting one by one (no drawn lines).
8. Other waiting items in docs/plans.md: Shop icon same size/height as Daily, Area 3 parcel labels -> Chennai places, Area 2 "Inside the shop!" fade card, level-screen theme per area (previews/themes), replace violet in popups, gold floor tile sound (still old paper sound; I'll send a sound).

REMIND ME: Play Console steps for Play Games cloud save (create app com.retroraja.crackersmatch.godot, Play Games Services, SHA-1 F5:AD:62:1E:E0:41:3A:CA:F6:4B:56:98:E6:9B:8D:44:D1:DC:56:45, Saved Games on, add tester Gmail, send Project ID).

Start by telling me in 3 lines what you'll build first, then build. At the end give me the APK link (release godot-dev).
