# Game design notes (decided with Rajarajan)

## Story
- "Grandpa's Dream": the man comes back to Grandpa's old street in Sivakasi. Grandpa's notebook: "One day, Sivakasi
  crackers will light up every home." Intro plays once on first open (phones: video/story.ogv, ~30 s, Skip top-right).
- Area 1 Sivakasi Street (30 levels, 10 builds, ends with the Crackers Factory; dusk, fireworks, notebook tick,
  "NEXT: Bunder Street, Chennai"). Area 2 GHILLI CRACKERS shop on Bunder Street, Chennai (levels 31-60, 12 builds).
  Area 3 Busy Days at GHILLI (order room, levels 61-80, 9 builds), Area 4 GHILLI Delivery Hub (docs/area4.md),
  Area 5 Madurai.
- Builds cost diyas; levels give diyas (1 normal, 2 hard, 3 super hard). Every build can be finished once the
  area's last level is won.

## Difficulty (agreed 16 Nov)
- Difficulty from obstacles, board shape, goal placement, luck and moves — never from many colours (3 or 4, never 5).
- 1-6 easy; then normal; every 5th level from 15 Hard; every 20th Super hard; the level after a Hard is a Breather.
- Lucky refills (new crackers pre-arranged into a special) and calm refills (stop endless free cascades) per type:
  Easy 3 colours 40-50%/80%, Normal 3-4 25%/85%, Hard 4 15%/90%, Super hard 4 10%/90%, Breather 3 50%/80%.

## Obstacles
- One breakable type per level (alone in mass or with crates). Never mix two breakable types. Cabinet levels: no breakables.
- Intro about one every 6 levels: 11 pot, 18 soda, 24 coconut, 33 matchbox, 39 newspaper, 44 bangles, 49 gift wrap, 54 diyas.
- Cabinets: one cabinet type per level; goal icon = that cabinet's item; subtle item picture on closed doors, no numbers.
- When any fixed obstacle breaks, crackers above fall in (20 Nov). Gold floor stays until a cracker on it is cleared.
- Colour Matchbox does NOT crack crates next to the crackers it clears (decided 19 Nov).

## Look
- Character: the code-drawn man in the coat (scripts/app/face.gd top badge, winguy.gd win screen), not photos.
- Popup windows: the street Welcome look (scripts/app/skin.gd, class UISkin): cream gradient card, 4px #6B0F1A border,
  Lilita One titles #FF3D5E with #6B0F1A outline, red/yellow/white buttons. Use UISkin for every new window.
- Story/scene captions: Cormorant Garamond Italic, letterbox bars.
