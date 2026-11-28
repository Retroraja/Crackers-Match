# Prompt for a fresh chat (24 Nov 2026)

Paste this into a new chat attached to the "Crakers Match" project:

---
Continue Crackers Match (Godot 4.3 Android match-3). Repo Retroraja/Crackers-Match, branch
claude/project-thread-nyydf2 (PR #1, holds everything). Read first: docs/START-HERE.md, docs/working-rules.md,
docs/fps-rules.md, docs/current-state.md, then the NEXT BUILD LIST at the top of docs/plans.md.

Rules (strict):
- Talk first, short replies, low tokens. Simple words.
- NEVER build an APK or push a code change that triggers a build until I say "build". Docs-only pushes need
  "[preview]" in the commit message so CI does not build.
- Save every agreed fix to the top list in docs/plans.md (and the project doc claude/next-build-list-24nov.md).
- When I ask for a visual, make it accurate on the first try: same size and base line as the crackers, the board's
  own tile colours, don't touch neighbouring tiles. Change only what I asked.
- Phones only show pictures (fps-rules): no live drawing, no heavy particle effects.

State: my phone has the level-80 APK (commit 8c033f7, 23 Nov). Since then nothing is built. One code change is
already in the repo but not in an APK: louder, cleaner obstacle sounds and bangle = china plate smash (commit 2043eaf).

Next build list (all agreed, not built) — the full detail is in docs/plans.md items 1-18:
1. Obstacle sounds louder (done in code).
2. New title screen: crackers / fireworks scene, no bakery.
3. Daily tasks 20 / 30 / 50 + 100 for all three.
4. Daily + Piggy icons 64 px, a little off the edge, ~30 px lower, glowing round badge.
5. Piggy shows "120/250", tap card explains the ad, AD badge when full.
6. Win screen in one card with a gold border; no "Next build" line, no piggy icon.
7. Level card after Next opens over the dimmed street; dim covers the full screen.
8. Coin Blast win in win-screen style with Next + AD Reward x2.
9. New bar crackers unlock at 12, 22, 32... (off the hard levels). Hard levels unchanged otherwise.
10. Area 1 board shapes at 13, 17, 22, 27.
11. Split boards become U shapes (bottom 2 rows joined): 13, 32, 65, 78.
12. New goal "Blast X crackers", about 1 level in 5 from level 3.
13. New goal "Bring down": potli bag (from 6, every 10) and pambaram (from 41, every 10, 5 apart from the bag).
    Real 3D art, cracker-sized, standing on the tile floor. At the bottom: bag wiggles, pambaram spins, then flies to
    the goal. No coins, no clearing, nothing drawn below the board. Intro card + hand demo.
14. Ad screen: full screen, status strip visible only during the ad, X just below it, black behind.
15. Portals: first at 28 (plain); 46 portal + bag, 71 portal + pambaram.
16. Rangoli: dropped.
17. BUG: level back arrow / Exit level quit at once. Add a "Leave level?" card (Keep playing / Leave).
Next APK = this list + Area 4 (GHILLI Delivery Hub, docs/area4.md), built only on my "build".
I'm playing all 80 levels and will add more fixes.
---
