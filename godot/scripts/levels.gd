# Area 1 levels 1-10, same boards as the web build (levels28.js, 15 Nov 2026).
# Area 2 levels 11-25 (17 Nov): four colours, less luck, fewer spare moves. Hard (2 diyas): 15, 20, 25.
# Map letters: . cracker   # no cell   c crate   w 2-hit crate   g gold floor
#   x crate on gold   X 2-hit crate on gold   o hidden hole   K/k sweet-shop cabinet 2x2
#   1 Rocket   2 Bomb   3 Colour Matchbox   4 Ground Chakra (placed at the start)
extends RefCounted
class_name Levels

const C3 := [0, 1, 2]
const C4 := [0, 1, 2, 5]

static func all() -> Array:
	return [
		{"name": "Crate Start", "moves": 20, "colors": C3, "luck": 0.5,
		 "rows": ["##....##", "#......#", "........", "........", "........", "........", "........", ".cccccc.", "..cccc.."]},
		{"name": "Rocket Lesson", "moves": 18, "colors": C3, "luck": 0.5, "teach": "rocket", "intro": ["rocket"],
		 "rows": ["........", "........", "........", "........", "........", "cccccccc", "cccccccc", "cccccccc", "########"]},
		{"name": "Hidden Hole", "moves": 20, "colors": C3, "luck": 0.5, "teach": "line5", "intro": ["hole"],
		 "rows": ["........", "........", "........", "cccccccc", "ccoooocc", "ccoooocc", "ccoooocc", "cccccccc", "########"]},
		{"name": "Gold Floor", "moves": 20, "colors": C3, "luck": 0.5, "intro": ["gold"],
		 "rows": ["........", "........", "..1.....", "gggggggg", "gggggggg", "gggggggg", "#gggggg#", "##gggg##", "###gg###"]},
		{"name": "Chakra Lesson", "moves": 18, "colors": C3, "luck": 0.5, "teach": "square", "intro": ["chakra"],
		 "rows": ["........", "........", "........", "........", "cc....cc", "cc....cc", "cccccccc", "cccccccc", "########"]},
		{"name": "Gold Under Crates", "moves": 20, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", ".....2..", "gggxxggg", "ggxxxxgg", "gxxxxxxg", "xxxxxxxx", "gggggggg", "gggggggg"]},
		{"name": "Dig Down", "moves": 26, "colors": C3, "luck": 0.5, "intro": ["wood"],
		 "rows": ["........", "........", "..1.....", "........", "........", "xxxxxxxx", "xxxxxxxx", "xxxxxxxx", "XxxXXxxX"]},
		{"name": "Plus Board", "moves": 25, "colors": C3, "luck": 0.5, "teach": "lshape", "intro": ["atom"],
		 "rows": ["........", "........", "........", "cccccc2c", "c2cccccc", "cccccccc", "##cccc##", "##c2cc##", "##cccc##"]},
		{"name": "First Cabinets", "moves": 26, "colors": C3, "luck": 0.5, "intro": ["cab"],
		 "rows": ["........", "........", "....1...", "........", "cccccccc", "xxKkKkxx", "xxkkkkxx", "xxxxxxxx", "cccccccc"]},
		{"name": "Opening Blast", "moves": 30, "colors": C4, "luck": 0.34, "ltype": "h", "combo": {"r": 1, "c": 3, "dr": 0, "dc": 1},
		 "rows": ["........", "...31...", "........", "xKkggKkx", "xkkggkkx", "cccccccc", "........", "XxxxxxxX", "xxXxxXxx"]},
		# ---------------- Area 2: Bunder Street, Chennai (levels 11-25)
		{"name": "Shop Floor", "moves": 24, "colors": C4, "luck": 0.45,
		 "rows": ["........", "........", "........", "........", "cccccccc", "cccccccc", "cwcwwcwc", "cccccccc", "########"]},
		{"name": "Gold Aisle", "moves": 24, "colors": C4, "luck": 0.45,
		 "rows": ["........", "...gg...", "...gg...", "..gggg..", "..gggg..", ".gggggg.", "gggggggg", "gggggggg", "gggggggg"]},
		{"name": "Box Stack", "moves": 26, "colors": C4, "luck": 0.42,
		 "rows": ["........", "........", "..1..1..", "........", "wwwwwwww", "cccccccc", "wwwwwwww", "cccccccc", "cccccccc"]},
		{"name": "Diamond", "moves": 22, "colors": C4, "luck": 0.42,
		 "rows": ["###..###", "##....##", "#......#", "...cc...", "..cxxc..", "..cxxc..", "#..cc..#", "##....##", "###..###"]},
		{"name": "Cabinet Row", "moves": 30, "colors": C4, "luck": 0.34, "ltype": "h",
		 "rows": ["........", "...2....", "........", "KkKkKkKk", "kkkkkkkk", "xxxxxxxx", "XxXxXxXx", "gggggggg", "gggggggg"]},
		{"name": "Twin Towers", "moves": 26, "colors": C4, "luck": 0.4,
		 "rows": ["........", "........", "cc....cc", "cc....cc", "xx....xx", "xx....xx", "XX.11.XX", "XXggggXX", "XXggggXX"]},
		{"name": "Wall Shelves", "moves": 26, "colors": C4, "luck": 0.4,
		 "rows": ["........", "........", "wwwwwwww", "........", "wwwwwwww", "........", "wwwwwwww", "cccccccc", "cccccccc"]},
		{"name": "Gold Rush", "moves": 25, "colors": C4, "luck": 0.4,
		 "rows": ["........", "...3....", "gggggggg", "gxgxxgxg", "gggggggg", "xgxggxgx", "gggggggg", "XggggggX", "XXggggXX"]},
		{"name": "Cabinet Corners", "moves": 28, "colors": C4, "luck": 0.38,
		 "rows": ["........", "........", "KkxxxxKk", "kkxccxkk", "xxccccxx", "xxccccxx", "KkxccxKk", "kkxxxxkk", "cccccccc"]},
		{"name": "Big Blast", "moves": 32, "colors": C4, "luck": 0.34, "ltype": "h",
		 "rows": ["........", "..1..1..", "........", "XXXXXXXX", "xKkxxKkx", "xkkxxkkx", "XXXXXXXX", "gggggggg", "gggggggg"]},
		{"name": "Hourglass", "moves": 24, "colors": C4, "luck": 0.38,
		 "rows": ["........", "#......#", "##....##", "###..###", "###..###", "##cccc##", "#cccccc#", "cccccccc", "wwwwwwww"]},
		{"name": "Gold Vault", "moves": 30, "colors": C4, "luck": 0.36,
		 "rows": ["........", "........", "........", "XXXXXXXX", "XXXXXXXX", "xxxxxxxx", "xxxxxxxx", "########", "########"]},
		{"name": "Checkerboard", "moves": 28, "colors": C4, "luck": 0.36,
		 "rows": ["........", "........", "cwcwcwcw", "wcwcwcwc", "cwcwcwcw", "wcwcwcwc", "gggggggg", "gggggggg", "########"]},
		{"name": "Sweet Shop", "moves": 30, "colors": C4, "luck": 0.36,
		 "rows": ["........", "....4...", "KkKkKkKk", "kkkkkkkk", "........", "KkKkKkKk", "kkkkkkkk", "xxxxxxxx", "xxxxxxxx"]},
		{"name": "Grand Opening", "moves": 34, "colors": C4, "luck": 0.32, "ltype": "h",
		 "rows": ["...33...", "........", "XXKkKkXX", "XXkkkkXX", "xxxxxxxx", "XxKkKkxX", "XxkkkkxX", "gggggggg", "gggggggg"]},
	]
