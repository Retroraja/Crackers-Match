# Out of Moves and Level Failed, the agreed design (build-28-plan item 31, preview "Level Failed Preview" 13 Nov):
# dimmed board behind, one card with a raised gold frame and dark purple inside, red "Level N" ribbon,
# goals left with red counts, "+5 Moves", green Watch Ad (pulses), blue Buy with the coin price, small Give Up.
# Step 2 after Give Up: "Level Failed", goals left, green Try Again (pulses), small Back to Street.
extends RefCounted
class_name LoseUI

var root: Control
var s1: Control
var s2: Control
var n := {}           # named parts
var lay := WebLayout.new()
const W := 284.0      # inner content width
const X0 := 53.0      # content left on the stage

static func rgba(h: String, a := -1.0) -> Array:
	var c := Color(h)
	return [c.r, c.g, c.b, c.a if a < 0 else a]

static func lin(ang: float, st: Array) -> Dictionary:
	var s: Array = []
	for q in st:
		s.append([q[0], rgba(q[1])])
	return {"t": "lin", "ang": ang, "st": s}

static func txt(s: String, font: String, fs: float, col: String, ts := [], ta := "center") -> Dictionary:
	return {"s": s, "font": font, "fs": fs, "col": rgba(col), "ta": ta, "ls": 0, "ts": ts, "stroke": [0.0, rgba(col)], "grad": null}

static func sh(x: float, y: float, b: float, c: String, inset := false, s := 0.0) -> Dictionary:
	return {"x": x, "y": y, "b": b, "s": s, "c": rgba(c), "in": inset}

func mk(parent: Control, r: Array, box = null, t = null, name := "") -> Control:
	var d := {"i": 0, "id": name, "tag": "div", "r": r, "op": 1}
	if box != null:
		d.box = box
	if t != null:
		d.txt = t
	var po := parent.get_global_rect().position - root.get_global_rect().position if parent != root else Vector2.ZERO
	var c := lay.make(d, po)
	if name != "":
		c.name = name
		n[name] = c
	parent.add_child(c)
	return c

func build(parent: Control) -> void:
	root = Control.new()
	root.size = Vector2(390, 844)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.visible = false
	parent.add_child(root)
	# the board behind is dimmed (radial: lighter purple in the middle, near black at the edges)
	mk(root, [0, 0, 390, 844], {"bg": [{"t": "rad", "cen": [0.5, 0.45], "shape": [0.75, 0.75], "circle": false,
		"st": [[0, rgba("#2a0f50", 0.75)], [1, rgba("#0a0318", 0.93)]]}]})
	s1 = _card(222, 452, "Out of Moves", "You're almost there! Keep going?", true)
	s2 = _card(260, 318, "Level Failed", "So close! You only needed a little more.", false)
	for t in ["title1", "title2", "big"]:
		UISkin.title_label(n[t].get_node("txt"))
	UISkin.button(n["bAd"], "red")
	UISkin.button(n["bCoin"], "yellow")
	UISkin.button(n["bRetry"], "red")

func _card(top: float, h: float, title: String, line: String, step1: bool) -> Control:
	var card := Control.new()
	card.size = Vector2(390, 844)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(card)
	var k := "1" if step1 else "2"
	# gold frame and purple inside
	# cream card like the Welcome window
	mk(card, [28, top, 334, h], UISkin.card_box(), null, "frame" + k)
	# ribbon
	mk(card, [125, top - 22, 140, 44], {"bg": [lin(180, [[0, "#ff7a7a"], [0.55, "#e2384a"], [1, "#a81f33"]])], "rad": [14, 14, 14, 14],
		"sh": [sh(0, 4, 0, "#6e1020"), sh(0, 6, 10, "#00000088")]}, txt("Level 1", "TitanOne", 22, "#ffffff", [{"x": 0, "y": 2, "b": 0, "c": rgba("#6e1020")}]), "rib" + k)
	var y := top + 3 + 26 + 6
	mk(card, [X0, y, W, 40], null, txt(title, "LilitaOne", 34, UISkin.TITLE), "title" + k)
	y += 42
	mk(card, [X0, y, W, 20], null, txt(line, "Sora-700", 15, UISkin.TEXT), "line" + k)
	y += 34
	mk(card, [X0, y, W, 64], null, null, "goals" + k)
	y += 64 + 18
	if step1:
		mk(card, [X0, y - 4, W, 50], null, txt("+5 Moves", "LilitaOne", 44, UISkin.TITLE), "big")
		y += 56
		var g := mk(card, [X0, y, W, 58], {"bg": [lin(180, [[0, "#86e86f"], [0.55, "#36b52f"], [1, "#22861d"]])], "rad": [18, 18, 18, 18],
			"sh": [sh(0, 5, 0, "#165f12"), sh(0, 8, 12, "#00000077")]}, txt("Watch Ad", "TitanOne", 22, "#ffffff", [{"x": 0, "y": 2, "b": 0, "c": rgba("#165f12")}]), "bAd")
		# the yellow AD badge used on every ad button
		var ad := mk(g, [X0, y + 18, 29, 22], {"bgc": rgba("#FFD24A"), "rad": [11, 11, 11, 11], "sh": [sh(0, 2, 0, "#B07A12")]}, txt("AD", "Sora-800", 11, "#7A3A00"))
		ad.set_meta("web", {"tag": "span", "cls": "adb"})
		y += 70
		var bl := mk(card, [X0, y, W, 58], {"bg": [lin(180, [[0, "#7cc4ff"], [0.55, "#2f86e0"], [1, "#1d5fae"]])], "rad": [18, 18, 18, 18],
			"sh": [sh(0, 5, 0, "#133f78"), sh(0, 8, 12, "#00000077")]}, txt("Buy", "TitanOne", 22, "#ffffff", [{"x": 0, "y": 2, "b": 0, "c": rgba("#133f78")}]), "bCoin")
		var tag := mk(bl, [X0, y + 16, 70, 26], {"bgc": rgba("#000000", 0.28), "rad": [10, 10, 10, 10]}, txt("950", "Sora-700", 15, "#ffffff"), "tag")
		var coin := TextureRect.new()
		coin.texture = WebLayout.tex("art/ui-coin.webp")
		coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coin.size = Vector2(18, 18)
		coin.position = Vector2(8, 4)
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tag.add_child(coin)
		y += 66
		mk(card, [X0, y, W, 16], null, txt("", "Sora-500", 12.5, UISkin.DARK), "lMsg")
		y += 26
		mk(card, [X0 + 80, y, W - 160, 26], null, txt("Give Up", "Sora-700", 15, UISkin.DARK), "bGive")
	else:
		var g2 := mk(card, [X0, y, W, 58], {"bg": [lin(180, [[0, "#86e86f"], [0.55, "#36b52f"], [1, "#22861d"]])], "rad": [18, 18, 18, 18],
			"sh": [sh(0, 5, 0, "#165f12"), sh(0, 8, 12, "#00000077")]}, txt("Try Again", "TitanOne", 22, "#ffffff", [{"x": 0, "y": 2, "b": 0, "c": rgba("#165f12")}]), "bRetry")
		y += 74
		mk(card, [X0 + 60, y, W - 120, 26], null, txt("Back to Street", "Sora-700", 15, UISkin.DARK), "bHome")
	return card

# goals left: dark rounded tiles with a red count badge
func goals(k: String, items: Array) -> void:
	var row: Control = n["goals" + k]
	for c in row.get_children():
		c.queue_free()
	var tot := items.size() * 64.0 + (items.size() - 1) * 10.0
	for j in items.size():
		var x := (W - tot) / 2.0 + j * 74.0
		var t := lay.make({"i": 0, "id": "", "tag": "div", "r": [x, 0, 64, 64], "op": 1, "box": {"bgc": rgba("#FFF3D6"), "rad": [16, 16, 16, 16], "bw": [2, 2, 2, 2], "bcol": rgba("#E8C98A")}}, Vector2.ZERO)
		row.add_child(t)
		var im := TextureRect.new()
		im.texture = WebLayout.tex(items[j][0])
		im.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		im.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		im.size = Vector2(50, 50)
		im.position = Vector2(7, 7)
		im.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.add_child(im)
		var w := maxf(24.0, 12.0 + 9.0 * str(items[j][1]).length())
		var b := lay.make({"i": 0, "id": "", "tag": "b", "r": [64 - w + 6, 46, w, 24], "op": 1, "box": {"bgc": rgba("#e2384a"), "rad": [12, 12, 12, 12],
			"sh": [sh(0, 2, 0, "#6e1020")]}, "txt": txt(str(items[j][1]), "TitanOne", 14, "#ffffff")}, Vector2.ZERO)
		t.add_child(b)
