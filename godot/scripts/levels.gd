# Area 1 levels 1-10, same boards as the web build (levels28.js, 15 Nov 2026).
# Map letters: . cracker   # no cell   c crate   w 2-hit crate   g gold floor
#   x crate on gold   X 2-hit crate on gold   o hidden hole   K/k sweet-shop cabinet 2x2
#   1 Rocket   2 Bomb   3 Colour Matchbox   4 Ground Chakra (placed at the start)
extends RefCounted
class_name Levels

const C3 := [0, 1, 2]
const C4 := [0, 1, 2, 5]

static func all() -> Array:
	return [
		{"name": "Crate Start", "moves": 18, "colors": C3, "luck": 0.5,
		 "rows": ["##....##", "#......#", "........", "........", "........", "........", "........", ".cccccc.", "..cccc.."]},
		{"name": "Rocket Lesson", "moves": 18, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", "........", "........", "........", "cccccccc", "cccccccc", "cccccccc", "########"]},
		{"name": "Hidden Hole", "moves": 20, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", "........", "cccccccc", "ccoooocc", "ccoooocc", "ccoooocc", "cccccccc", "########"]},
		{"name": "Gold Floor", "moves": 20, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", "..1.....", "gggggggg", "gggggggg", "gggggggg", "#gggggg#", "##gggg##", "###gg###"]},
		{"name": "Chakra Lesson", "moves": 18, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", "........", "........", "cc....cc", "cc....cc", "cccccccc", "cccccccc", "########"]},
		{"name": "Gold Under Crates", "moves": 20, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", ".....2..", "gggxxggg", "ggxxxxgg", "gxxxxxxg", "xxxxxxxx", "gggggggg", "gggggggg"]},
		{"name": "Dig Down", "moves": 26, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", "..1.....", "........", "........", "xxxxxxxx", "xxxxxxxx", "xxxxxxxx", "XxxXXxxX"]},
		{"name": "Plus Board", "moves": 25, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", "........", "cccccc2c", "c2cccccc", "cccccccc", "##cccc##", "##c2cc##", "##cccc##"]},
		{"name": "First Cabinets", "moves": 26, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", "....1...", "........", "cccccccc", "xxKkKkxx", "xxkkkkxx", "xxxxxxxx", "cccccccc"]},
		{"name": "Opening Blast", "moves": 30, "colors": C4, "luck": 0.34, "hard": true,
		 "rows": ["........", "...31...", "........", "xKkggKkx", "xkkggkkx", "cccccccc", "........", "XxxxxxxX", "xxXxxXxx"]},
	]
