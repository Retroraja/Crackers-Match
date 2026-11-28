# Area 1 levels 1-10, same boards as the web build (levels28.js, 15 Nov 2026).
# Area 1 = levels 1-30 (factory at 30), Area 2 = 31-60 (Ghilli Crackers shop), Area 3 = 61-80 (order room). Hard (2 diyas): 10 and every 5th level
#   from 15. New cabinets: 15 bottles (B), 20 cups (U), 25 kaapi (Q).
# Map letters: . cracker   # no cell   c crate   w 2-hit crate   g gold floor
#   breakables (18 Nov): p clay pot  s soda  n coconut  m matchbox stack  e newspaper  b bangles  f gift wrap  d diya stack
#   (one breakable type per level, one cabinet type per level; moves cut 30% / Hard 15% on 18 Nov)
#   x crate on gold   X 2-hit crate on gold   o hidden hole   K/k sweet-shop cabinet 2x2 (B bottles, U cups, Q kaapi)
#   1 Rocket   2 Bomb   3 Colour Matchbox   4 Ground Chakra (placed at the start)
extends RefCounted
class_name Levels

const C3 := [0, 1, 2]
const C4 := [0, 1, 2, 5]

static func base() -> Array:
	return [
		{"name": "Crate Start", "moves": 20, "colors": C3, "luck": 0.5,
		 "rows": ["##....##", "#......#", "........", "........", "........", "........", "........", ".cccccc.", "..cccc.."]},
		{"name": "Rocket Lesson", "moves": 18, "colors": C3, "luck": 0.5, "teach": "rocket", "intro": ["rocket"],
		 "rows": ["........", "........", "........", "........", "........", "cccccccc", "cccccccc", "cccccccc", "########"]},
		{"name": "Hidden Hole", "moves": 20, "colors": C3, "luck": 0.5, "teach": "line5", "intro": ["hole"],
		 "rows": ["........", "........", "........", "cccccccc", "ccoooocc", "ccoooocc", "ccoooocc", "cccccccc", "########"]},
		{"name": "Gold Floor", "moves": 14, "colors": C3, "luck": 0.5, "intro": ["gold"],
		 "rows": ["........", "........", "..1.....", "gggggggg", "gggggggg", "gggggggg", "#gggggg#", "##gggg##", "###gg###"]},
		{"name": "Chakra Lesson", "moves": 13, "colors": C3, "luck": 0.5, "teach": "square", "intro": ["chakra"],
		 "rows": ["........", "........", "........", "........", "cc....cc", "cc....cc", "cccccccc", "cccccccc", "########"]},
		{"name": "Gold Under Crates", "moves": 14, "colors": C3, "luck": 0.5,
		 "rows": ["........", "........", ".....2..", "gggxxggg", "ggxxxxgg", "gxxxxxxg", "xxxxxxxx", "gggggggg", "gggggggg"]},
		{"name": "Dig Down", "moves": 18, "colors": C3, "luck": 0.5, "intro": ["wood"],
		 "rows": ["........", "........", "..1.....", "........", "........", "xxxxxxxx", "xxxxxxxx", "xxxxxxxx", "XxxXXxxX"]},
		{"name": "Plus Board", "moves": 18, "colors": C3, "luck": 0.5, "teach": "lshape", "intro": ["atom"],
		 "rows": ["........", "........", "........", "cccccc2c", "c2cccccc", "cccccccc", "##cccc##", "##c2cc##", "##cccc##"]},
		{"name": "First Cabinets", "moves": 18, "colors": C3, "luck": 0.5, "intro": ["cab"],
		 "rows": ["........", "........", "....1...", "........", "cccccccc", "xxKkKkxx", "xxkkkkxx", "xxxxxxxx", "cccccccc"]},
		{"name": "Opening Blast", "moves": 24, "colors": C4, "luck": 0.34, "ltype": "h", "combo": {"r": 1, "c": 3, "dr": 0, "dc": 1},
		 "rows": ["........", "...31...", "........", "xKkggKkx", "xkkggkkx", "cccccccc", "........", "XxxxxxxX", "xxXxxXxx"]},
		# ---------------- Area 2: Bunder Street, Chennai (levels 11-25)
		{"name": "Shop Floor", "moves": 17, "colors": C4, "luck": 0.45, "intro": ["pot"],
		 "rows": ["........", "........", "........", "........", "pppppppp", "ppppcccc", "cwcwwcwc", "cccccccc", "########"]},
		{"name": "Gold Aisle", "moves": 17, "colors": C4, "luck": 0.45,
		 "rows": ["........", "...gg...", "...gg...", "ppggggpp", "ppggggpp", "pggggggp", "gggggggg", "gggggggg", "gggggggg"]},
		{"name": "Box Stack", "moves": 18, "colors": C4, "luck": 0.42,
		 "rows": ["........", "........", "..1..1..", "........", "wwwwwwww", "cccccccc", "wwwwwwww", "cccccccc", "cccccccc"]},
		{"name": "Diamond", "moves": 15, "colors": C4, "luck": 0.42,
		 "rows": ["###..###", "##....##", "#......#", "...pp...", "..pppp..", "..pppp..", "#ppppp.#", "##pppp##", "###..###"]},
		{"name": "Bottle Shop", "moves": 23, "colors": C4, "luck": 0.34, "ltype": "h", "intro": ["cab_bottles"],
		 "rows": ["........", "........", "........", "BkBkBkBk", "kkkkkkkk", "xXxXxXxX", "XxXXXxXX", "gggggggg", "gggggggg"]},
		{"name": "Twin Towers", "moves": 18, "colors": C4, "luck": 0.4,
		 "rows": ["........", "........", "cc....cc", "cc....cc", "xx....xx", "xx....xx", "XX.11.XX", "XXggggXX", "XXggggXX"]},
		{"name": "Wall Shelves", "moves": 18, "colors": C4, "luck": 0.4,
		 "rows": ["........", "........", "pppppppp", "........", "pppppppp", "........", "pppppppp", "ppppcccc", "cccccccc"]},
		{"name": "Gold Rush", "moves": 18, "colors": C4, "luck": 0.4, "intro": ["soda"],
		 "rows": ["........", "...3....", "gggggggg", "gsgssgsg", "gggggggg", "sgsggsgs", "gggggggg", "sggggggs", "XXggggXX"]},
		{"name": "Cabinet Corners", "moves": 20, "colors": C4, "luck": 0.38,
		 "rows": ["........", "........", "KkxxxxKk", "kkxccxkk", "xxccccxx", "xxccccxx", "KkxccxKk", "kkxxxxkk", "cccccccc"]},
		{"name": "Tea Cups", "moves": 23, "colors": C4, "luck": 0.34, "ltype": "h", "intro": ["cab_cups"],
		 "rows": ["........", "........", "........", "XXXXXXXX", "xUkXxUkX", "xkkXxkkX", "XXXXXXXX", "gggggggg", "gggggggg"]},
		{"name": "Hourglass", "moves": 17, "colors": C4, "luck": 0.38,
		 "rows": ["........", "#......#", "##....##", "###..###", "###..###", "##ssss##", "#ssssss#", "sssssssc", "wwwwwwww"]},
		{"name": "Gold Vault", "moves": 21, "colors": C4, "luck": 0.36,
		 "rows": ["........", "........", "........", "XXXXXXXX", "XXXXXXXX", "xxxxxxxx", "xxxxxxxx", "########", "########"]},
		{"name": "Checkerboard", "moves": 20, "colors": C4, "luck": 0.36, "intro": ["coco"],
		 "rows": ["........", "........", "nnnnnncw", "wcwcwcwc", "cwcwcwcw", "wcwcwcwc", "gggggggg", "gggggggg", "########"]},
		{"name": "Sweet Shop", "moves": 21, "colors": C4, "luck": 0.36,
		 "rows": ["........", "....4...", "KkKkKkKk", "kkkkkkkk", "........", "KkKkKkKk", "kkkkkkkk", "xxxxxxxx", "xxxxxxxx"]},
		{"name": "Kaapi Corner", "moves": 23, "colors": C4, "luck": 0.32, "ltype": "h", "intro": ["cab_kaapi"],
		 "rows": ["........", "........", "XXQkQkXX", "XXkkkkXX", "xXxXxXxX", "XxQkQkXX", "XxkkkkXX", "gggggggg", "gggggggg"]},
		# ---------------- levels 26-60 (17-18 Nov): generated from board patterns; Hard every 5th level
		{"name": "Diwali Lights", "moves": 20, "colors": C4, "luck": 0.42,
		 "rows": ["........", "........", "KkKkKkKk", "kkkkkkkk", "........", "....KkKk", "....kkkk", "xxxxxxxx", "xxxxxxxx"]},
		{"name": "Sparkler Lane", "moves": 19, "colors": C4, "luck": 0.42,
		 "rows": ["..1..2..", "#......#", "##....##", "###..###", "##pppp##", "#pppppp#", "pppppppp", "pppppXXx", "gggggggg"]},
		{"name": "Flowerpot Row", "moves": 21, "colors": C4, "luck": 0.41,
		 "rows": ["........", "........", "........", "cccccccc", "cccccccc", "gggggggg", "xxxxxxxx", "xxxxxxxx", "gggggggg"]},
		{"name": "Rocket Road", "moves": 20, "colors": C4, "luck": 0.41,
		 "rows": ["........", "........", "....KkKk", "....kkkk", "xxxxxxxx", "Kk....Kk", "kk....kk", "gggggggg", "gggggggg"]},
		{"name": "Grand Finale", "moves": 23, "colors": C4, "luck": 0.36, "ltype": "h",
		 "rows": ["###..###", "##....##", "#......#", "...nn...", "..nnnn..", ".nnnXxn.", "..nXxn..", "#..nn..#", "##gggg##"]},
		{"name": "Bijili Box", "moves": 20, "colors": C4, "luck": 0.4,
		 "rows": ["........", "........", "ww....ww", "cc....cc", "xx....xx", "XX.gg.XX", "XXggggXX", "XXggggXX", "XXggggXX"]},
		{"name": "Atom Alley", "moves": 21, "colors": C4, "luck": 0.4,
		 "rows": ["...##...", "...##...", "...##...", "ppp##ppp", "ppp##ppp", "ggg##ggg", "pgp##pgp", "ggg##ggg", "ggg##ggg"]},
		{"name": "Garland Gate", "moves": 20, "colors": C4, "luck": 0.39,
		 "rows": ["..1..2..", "........", "KkKkKkKk", "kkkkkkkk", "........", "Kk..Kk..", "kk..kk..", "xxxxxxxx", "xxxxxxxx"]},
		{"name": "Lantern Lane", "moves": 19, "colors": C4, "luck": 0.39, "intro": ["match"],
		 "rows": ["........", "#......#", "##....##", "###..###", "##mmmm##", "#cwwwwc#", "cxxxxxxc", "xXXXXXXx", "gggggggg"]},
		{"name": "Grand Finale", "moves": 23, "colors": C4, "luck": 0.34, "ltype": "h",
		 "rows": ["........", "........", "........", "mmmmmmmm", "mmcwcwcw", "gggggggg", "xXxXxXxX", "xXxXxXxX", "gggggggg"]},
		{"name": "Bunder Street", "moves": 20, "colors": C4, "luck": 0.38,
		 "rows": ["..1..2..", "........", "Kk....Kk", "kk....kk", "xxxxxxxx", "....KkKk", "....kkkk", "gggggggg", "gggggggg"]},
		{"name": "Parrys Corner", "moves": 18, "colors": C4, "luck": 0.38,
		 "rows": ["###..###", "##....##", "#......#", "...cc...", "..cxxc..", ".cxXXxc.", "..cxxc..", "#..cc..#", "##gggg##"]},
		{"name": "Cracker Crates", "moves": 20, "colors": C4, "luck": 0.37,
		 "rows": ["........", "........", ".#....#.", "pp.pp.pp", "pp#pp#pp", "pp.gg.pp", "pp#gg#pp", "pXggggXX", "XXggggXX"]},
		{"name": "Shutter Up", "moves": 21, "colors": C4, "luck": 0.37, "intro": ["news"],
		 "rows": ["..1..2..", "........", "eeeeeecw", "wcwcwcwc", "gggggggg", "xgxgxgxg", "gxgxgxgx", "gggggggg", "########"]},
		{"name": "Fresh Paint", "moves": 23, "colors": C4, "luck": 0.32, "ltype": "h",
		 "rows": ["........", "........", "KkKkKkKk", "kkkkkkkk", "........", "KkKkKkKk", "kkkkkkkk", "xXxXxXxX", "xXxXxXxX"]},
		{"name": "Tube Light", "moves": 19, "colors": C4, "luck": 0.36,
		 "rows": ["........", "#......#", "##....##", "###..###", "##eeee##", "#eeeeee#", "exxxxxxc", "xXXXXXXx", "gggggggg"]},
		{"name": "Counter Top", "moves": 21, "colors": C4, "luck": 0.36,
		 "rows": ["....####", ".....###", "......##", ".......#", "pppppppp", "pppppppp", "#ggggggg", "##ppXXXX", "###ggggg"]},
		{"name": "Shelf Stack", "moves": 20, "colors": C4, "luck": 0.35,
		 "rows": ["........", "........", "Kk..Kk..", "kk..kk..", "xxxxxxxx", "..KkKk..", "..kkkk..", "gggggggg", "gggggggg"]},
		{"name": "Display Rack", "moves": 18, "colors": C4, "luck": 0.35, "intro": ["bangle"],
		 "rows": ["###..###", "##....##", "#......#", "...bb...", "..bxxb..", ".bxXXxb.", "..bxxb..", "#..bb..#", "##gggg##"]},
		{"name": "Striped Awning", "moves": 23, "colors": C4, "luck": 0.3, "ltype": "h",
		 "rows": ["........", "........", "bb....bb", "bb....bb", "bb....bb", "bb.gg.bb", "bbggggbb", "bbggggbb", "XXggggXX"]},
		{"name": "Marigold", "moves": 21, "colors": C4, "luck": 0.34,
		 "rows": ["........", "........", "cwcwcwcw", "wcw##cwc", "gg####gg", "xg####gx", "gxg##gxg", "gggggggg", "########"]},
		{"name": "Lantern Glow", "moves": 20, "colors": C4, "luck": 0.34,
		 "rows": ["........", "........", "KkKkKkKk", "kkkkkkkk", "........", "..KkKk..", "..kkkk..", "xxxxxxxx", "xxxxxxxx"]},
		{"name": "Thatha’s Photo", "moves": 19, "colors": C4, "luck": 0.33,
		 "rows": ["#..#.##.", "#..#..#.", "#.....#.", "........", "pppppppp", "pppppppp", "pppppppp", "pppppppx", "gggggggg"]},
		{"name": "Big City", "moves": 21, "colors": C4, "luck": 0.33, "intro": ["gift"],
		 "rows": ["........", "........", "........", "ffffffcc", "wwwwwwww", "gggggggg", "xxxxxxxx", "XXXXXXXX", "gggggggg"]},
		{"name": "Busy Bazaar", "moves": 23, "colors": C4, "luck": 0.28, "ltype": "h",
		 "rows": ["........", "........", "KkKk..Kk", "kkkk..kk", "xXxXxXxX", "....KkKk", "....kkkk", "gggggggg", "gggggggg"]},
		{"name": "Night Market", "moves": 18, "colors": C4, "luck": 0.32,
		 "rows": ["##1..2##", "##....##", "#......#", "...ff...", "..fxxf..", ".fxXXxf.", "..fxxf..", "#..fc..#", "##gggg##"]},
		{"name": "Festival Rush", "moves": 20, "colors": C4, "luck": 0.32,
		 "rows": ["........", "........", "wwwwwwww", "cccccccc", "###..###", "###..###", "#XXggXX#", "XXggggXX", "XXggggXX"]},
		{"name": "Gift Boxes", "moves": 21, "colors": C4, "luck": 0.31, "intro": ["dstack"],
		 "rows": ["........", "........", "dddddddd", "ddwcwcwc", "gggggggg", "xgxgxgxg", "gxgxgxgx", "gggggggg", "########"]},
		{"name": "Sweet Treats", "moves": 20, "colors": C4, "luck": 0.31,
		 "rows": ["..1..2..", "........", "KkKkKkKk", "kkkkkkkk", "........", "....KkKk", "....kkkk", "xxxxxxxx", "xxxxxxxx"]},
		{"name": "Ghilli Opening", "moves": 23, "colors": C4, "luck": 0.26, "ltype": "h",
		 "rows": ["........", "#......#", "##....##", "###pp###", "##pppp##", "#pppppp#", "pppppppp", "pppppppp", "gggggggg"]},
		{"name": "Lucky Star", "moves": 21, "colors": C4, "luck": 0.3,
		 "rows": ["###..###", "##....##", "#......#", "dddddddd", "dddddddd", "gggggggg", "dxxxxxxx", "XXXXXXXX", "gggggggg"]},
		{"name": "Silver Rain", "moves": 20, "colors": C4, "luck": 0.3,
		 "rows": ["..1..2..", "........", "..KkKk..", "..kkkk..", "xxxxxxxx", "....KkKk", "....kkkk", "gggggggg", "gggggggg"]},
		{"name": "Golden Sky", "moves": 18, "colors": C4, "luck": 0.29,
		 "rows": ["........", "........", "ccc##ccc", "cxc##cxc", "xXx##xXx", "cxc##cxc", "ccc##ccc", "gg....gg", "gggggggg"]},
		{"name": "Mega Blast", "moves": 20, "colors": C4, "luck": 0.29,
		 "rows": ["........", "........", "pp....pp", "pp....pp", "pp....pp", "pp.gg.pp", "ppggggpp", "ppggggXX", "XXggggXX"]},
		{"name": "Ghilli Night", "moves": 23, "colors": C4, "luck": 0.24, "ltype": "h",
		 "rows": ["........", "........", "ssssssss", "ssssssss", "gggggggg", "sgsgsgsg", "gsgsgsgs", "gggggggg", "########"]},
		# ---------------- Area 3: Busy Days at GHILLI, the order room (levels 61-80, 23 Nov). Hard 65/70/75, Super Hard 80,
		#   a breather (3 colours) after each Hard. About one board in three has a new shape (islands, pillars, ring...).
		{"name": "Back Room Door", "moves": 19, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "........", "pppppppp", "pppppppp", "cccccccc", "wwwwwwww", "gggggggg", "gggggggg"]},
		{"name": "Phone Rings", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "QkQkQkQk", "kkkkkkkk", "........", "xxxxxxxx", "XxXxXxXx", "gggggggg", "########"]},
		{"name": "Order Book", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "ssssssss", "sss##sss", "ss####ss", "gg####gg", "ggg##ggg", "gggggggg", "XXXXXXXX"]},
		{"name": "Carton Stack", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "..1.....", "wwwwwwww", "cccccccc", "wwwwwwww", "xxxxxxxx", "XXXXXXXX", "gggggggg"]},
		{"name": "Rush Hour", "moves": 23, "colors": C4, "luck": 0.0, "ltype": "h",
		 "rows": ["...##...", "...##...", "eee##eee", "eee##eee", "eXe##eXe", "ggg##ggg", "XXX##XXX", "ggg##ggg", "ggg##ggg"]},
		{"name": "Tea Break", "moves": 20, "colors": C3, "luck": 0.0,
		 "rows": ["........", "........", "........", "UkUkUkUk", "kkkkkkkk", "cccccccc", "gggggggg", "########", "########"]},
		{"name": "Brown Paper", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "..#..#..", "nn#nn#nn", "nn....nn", "..#..#..", "gg#gg#gg", "xxxxxxxx", "gggggggg"]},
		{"name": "String & Tape", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "mmmmmmmm", "mcmcmcmc", "gggggggg", "xgxgxgxg", "gxgxgxgx", "gggggggg", "########"]},
		{"name": "Gift Wrap", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["#.##.#.#", "#..#...#", "#......#", "........", "ffffffff", "ffffffff", "gggggggg", "xxxxxxxx", "XXXXXXXX"]},
		{"name": "Big Order", "moves": 23, "colors": C4, "luck": 0.0, "ltype": "h",
		 "rows": ["........", "........", "BkBkBkBk", "kkkkkkkk", "xxxxxxxx", "XxXxXxXx", "gggggggg", "gggggggg", "########"]},
		{"name": "Bill Desk", "moves": 19, "colors": C3, "luck": 0.0,
		 "rows": ["........", "........", "........", "bbbbbbbb", "bbbbbbbb", "gggggggg", "gggggggg", "########", "########"]},
		{"name": "Weighing Scale", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["....####", ".....###", "......##", "dddddddd", "dddddddd", "gggggggg", "#xxxxxxx", "##XXXXXX", "###ggggg"]},
		{"name": "Sand Buckets", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "pppppppp", "pppppppp", "###..###", "###..###", "##gggg##", "#xxxxxx#", "XXggggXX"]},
		{"name": "Fire Drill", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "....4...", "KkKkKkKk", "kkkkkkkk", "........", "KkKkKkKk", "kkkkkkkk", "XXXXXXXX", "gggggggg"]},
		{"name": "Delivery Cycle", "moves": 23, "colors": C4, "luck": 0.0, "ltype": "h",
		 "rows": ["........", "........", "ssssssss", "sss##sss", "sx####xs", "gg####gg", "xxg##gxx", "gggggggg", "XXxxxxXX"]},
		{"name": "Carrier Loaded", "moves": 19, "colors": C3, "luck": 0.0,
		 "rows": ["........", "........", "........", "cccccccc", "cccccccc", "xxxxxxxx", "gggggggg", "gggggggg", "########"]},
		{"name": "Parcel Tags", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", ".#....#.", "ff.ff.ff", "ff#ff#ff", "ff.gg.ff", "ff#gg#ff", "XXggggXX", "XXggggXX"]},
		{"name": "Orders Pile Up", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["...##...", "...##...", "...##...", "Uk.##.Uk", "kk.##.kk", "xxx##xxx", "XXX##XXX", "gggggggg", "gggggggg"]},
		{"name": "Night Shift", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["#..#.##.", "#..#..#.", "#.....#.", "eeeeeeee", "eeeeeeee", "gggggggg", "xxxxxxxx", "XXXXXXXX", "gggggggg"]},
		{"name": "Busy Days", "moves": 24, "colors": C4, "luck": 0.0, "ltype": "s",
		 "rows": ["........", "........", "dddddddd", "ddd##ddd", "dX####Xd", "XX####XX", "gXX##XXg", "gggggggg", "XXXXXXXX"]},
	]


# ================================================================== 25 Nov build (docs/plans.md NEXT BUILD LIST)
# Only what the list says changes; every existing goal stays as it is.
#   v potli bag, t pambaram (bring down, goal 3 each). "portal": [[r_out, c_out, r_in, c_in], ...]
#   "blast": {colour: n} = extra goal "Blast n crackers of that colour" (about 1 level in 5).
const COLNAME := ["red", "blue", "green", "yellow", "purple", "orange"]
static func all() -> Array:
	var L: Array = base()
	# Area 1 board shapes (item 10): 13 two islands = U shape (item 11), 17 pillars (2 short columns of no-cells), 22 ring, 27 skyline.
	L[12].rows = ["...##...", "...##...", "..1##1..", "...##...", "www##www", "ccc##ccc", "www##www", "cccccccc", "cccccccc"]
	L[16].rows = ["........", "........", "pp#pp#pp", "..#..#..", "pp#pp#pp", "........", "pppppppp", "ppppcccc", "cccccccc"]
	L[21].rows = ["........", "........", "........", "XXXXXXXX", "XXX##XXX", "xxx##xxx", "xxxxxxxx", "########", "########"]
	L[26].rows = ["#..#.##.", "#..#..#.", "#.1...2.", "........", "..pppp..", "..pppp..", "pppppppp", "pppppXXx", "gggggggg"]
	# split boards -> U shape: the last 2 rows are one joined row (item 11): 32, 65 (78 already joins at the bottom)
	L[31].rows[7] = "gggggggg"
	L[31].rows[8] = "gggggggg"
	L[64].rows[7] = "gggggggg"
	L[64].rows[8] = "gggggggg"
	# portals (item 15): 28 first (plain); left board top-left, right board bottom-right, 4 portals between them
	var P4 := [[5, 0, 3, 4], [5, 1, 3, 5], [5, 2, 3, 6], [5, 3, 3, 7]]
	L[27].rows = ["....####", "....####", "....####", "cccc....", "gggg....", "....cccc", "####gggg", "####xxxx", "####gggg"]
	L[27].portal = P4
	L[27].intro = ["portal"]
	# 46 portal + potli bag, 71 portal + pambaram (the piece goes down the left board, through, down the right)
	L[45].rows = ["v...####", "...v####", "....####", "cwcw....", "gg##....", "....cwcw", "####gxxg", "####xggx", "####gggg"]
	L[45].portal = P4
	L[70].rows = ["t...####", "...t####", "....####", "bbbb....", "gggg....", "....bbbb", "####gggg", "####gbbg", "####gggg"]
	L[70].portal = P4
	# bring down (item 13): bag 6, 16, 26 ... 96; pambaram 41, 51, 61 ... 91. Two start on the board, 3 to bring down.
	for lv in [6, 16, 26, 36, 56, 66, 76]:
		_toy(L[lv - 1], "v")
	for lv in [41, 51, 61]:
		_toy(L[lv - 1], "t")
	for lv in [46, 71]:
		L[lv - 1].moves = int(L[lv - 1].moves) + 5
	L[5].intro = L[5].get("intro", []) + ["bag"]
	L[40].intro = L[40].get("intro", []) + ["top"]
	# Area 4 GHILLI Delivery Hub, levels 81-100
	L.append_array(area4())
	# Blast X (item 12): an extra goal on about 1 level in 5 (4, 9, 14 ... 99), never instead of a goal
	for lv in range(4, 101, 5):
		var o: Dictionary = L[lv - 1]
		if o.has("blast"):
			continue
		var cols: Array = o.colors
		var k: int = cols[(lv / 5) % cols.size()]
		var f := 1.1 if cols.size() <= 3 else 0.85
		var n := clampi(roundi(int(o.moves) * f / 5.0) * 5, 10, 30)
		o.blast = {k: n}
	L[3].intro = L[3].get("intro", []) + ["blast"]
	return L

# put 2 toys in the free top rows (columns 2 and 5, lowest free row first), +5 moves for the longer goal
static func _toy(o: Dictionary, ch: String) -> void:
	var rows: Array = o.rows.duplicate()
	var put := 0
	for want in [2, 5]:
		var done := false
		for r in [2, 1, 0]:
			for dc in [0, 1, -1, 2, -2]:
				var c: int = want + dc
				if done or c < 0 or c > 7:
					continue
				var row: String = rows[r]
				if row[c] == "." and _open_below(rows, r, c):
					rows[r] = row.substr(0, c) + ch + row.substr(c + 1)
					done = true
					put += 1
		if done:
			continue
	o.rows = rows
	o.moves = int(o.moves) + 5

static func _open_below(rows: Array, r: int, c: int) -> bool:
	# the column must go on to the bottom without a no-cell gap
	var seen_hole := false
	for q in range(r + 1, rows.size()):
		if String(rows[q])[c] == "#":
			seen_hole = true
		elif seen_hole:
			return false
	return true

# ---------------------------------------------------------------- Area 4: GHILLI Delivery Hub (levels 81-100, 25 Nov)
# 20 levels for its 9 builds, like Area 3. Hard 85, 90, 95, Super Hard 100, a 3-colour breather after each Hard.
# Hard: 22-24 moves, no free start special, every second crate a 2-hit crate.
static func area4() -> Array:
	var C4 := [0, 1, 2, 5]
	var C3 := [0, 1, 2]
	return [
		{"name": "Van Repair", "moves": 24, "colors": C4, "luck": 0.0,
		 "rows": ["t.......", "......t.", "........", "pppppppp", "cwcwcwcw", "gggggggg", "xxxxxxxx", "gggggggg", "gggggggg"]},
		{"name": "Order Board", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "KkKkKkKk", "kkkkkkkk", "........", "xXxXxXxX", "gggggggg", "gggggggg", "########"]},
		{"name": "Packing Table", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["...##...", "...##...", "nnn##nnn", "nnn##nnn", "ggg##ggg", "xxx##xxx", "ggg##ggg", "gggggggg", "gggggggg"]},
		{"name": "Brown Boxes", "moves": 20, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "..#..#..", "ff#ff#ff", "ff....ff", "..#..#..", "gg#gg#gg", "xxxxxxxx", "gggggggg"]},
		{"name": "Delivery Rush", "moves": 23, "colors": C4, "luck": 0.0, "ltype": "h",
		 "rows": ["........", "........", "ssssssss", "sXsXsXsX", "gggggggg", "XxXxXxXx", "xXxXxXxX", "gggggggg", "########"]},
		{"name": "Bike Bells", "moves": 24, "colors": C3, "luck": 0.0,
		 "rows": [".v......", "......v.", "........", "eeeeeeee", "eeeeeeee", "cccccccc", "gggggggg", "gggggggg", "########"]},
		{"name": "Temple Order", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["###..###", "##....##", "#......#", "...dd...", "..dxxd..", ".dxXXxd.", "..dxxd..", "#..dd..#", "##gggg##"]},
		{"name": "Flower Garlands", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "mmmmmmmm", "mcmcmcmc", "gggggggg", "xgxgxgxg", "gxgxgxgx", "gggggggg", "########"]},
		{"name": "Wedding Hall", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "#......#", "##....##", "###..###", "##ffff##", "#ffffff#", "fxxxxxxf", "xXXXXXXx", "gggggggg"]},
		{"name": "Kalyana Mahal", "moves": 23, "colors": C4, "luck": 0.0, "ltype": "h",
		 "rows": ["........", "........", "BkBkBkBk", "kkkkkkkk", "xXxXxXxX", "XxXxXxXx", "gggggggg", "gggggggg", "########"]},
		{"name": "School Bell", "moves": 24, "colors": C3, "luck": 0.0,
		 "rows": ["t.......", "......t.", "........", "bbbbbbbb", "bbbbbbbb", "gggggggg", "cccccccc", "gggggggg", "########"]},
		{"name": "Classroom", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "cc#..#cc", "cc#..#cc", "pp#..#pp", "pp....pp", "XX....XX", "XXggggXX", "XXggggXX"]},
		{"name": "Sports Day", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "........", "eeeeeeee", "eee##eee", "ggg##ggg", "xxxxxxxx", "XXXXXXXX", "gggggggg"]},
		{"name": "Flats Gate", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["#..#.##.", "#..#..#.", "#.....#.", "........", "ssssssss", "ssssssss", "gggggggg", "xxxxxxxx", "XXXXXXXX"]},
		{"name": "Lift Lobby", "moves": 23, "colors": C4, "luck": 0.0, "ltype": "h",
		 "rows": ["...##...", "...##...", "nnn##nnn", "nXn##nXn", "ggg##ggg", "XxX##XxX", "xXx##xXx", "gggggggg", "gggggggg"]},
		{"name": "Balcony Lights", "moves": 24, "colors": C3, "luck": 0.0,
		 "rows": [".v......", "......v.", "........", "dddddddd", "dddddddd", "cccccccc", "gggggggg", "gggggggg", "########"]},
		{"name": "Marina Road", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", "QkQkQkQk", "kkkkkkkk", "........", "xxxxxxxx", "XxXxXxXx", "gggggggg", "########"]},
		{"name": "Beach Party", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["........", "........", ".#....#.", "ff.ff.ff", "ff#ff#ff", "ff.gg.ff", "ff#gg#ff", "XXggggXX", "XXggggXX"]},
		{"name": "Lighthouse", "moves": 21, "colors": C4, "luck": 0.0,
		 "rows": ["###..###", "##....##", "#......#", "pppppppp", "pppppppp", "gggggggg", "pxxxxxxx", "XXXXXXXX", "gggggggg"]},
		{"name": "Madurai Calling", "moves": 24, "colors": C4, "luck": 0.0, "ltype": "s",
		 "rows": ["........", "........", "dddddddd", "ddd##ddd", "dX####Xd", "XX####XX", "gXX##XXg", "gggggggg", "XXXXXXXX"]},
	]
