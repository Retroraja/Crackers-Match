# 25 Nov: test tools for his test version (not hidden): a "Test" button on home opens this card.
#   Area tabs 1-4, one button per build (jumps to just before it and plays its animation; tap again to replay),
#   Play all builds, Area start, Area end, +100 diyas, and "Go to level" (number box). The level top bar gets a small
#   "Win now" button (cm_app). Uses only what is already in the game: no FPS cost.
extends Control
class_name TestUI

var app
var lay := WebLayout.new()
var tab := 1
var body: Control
var tabs: Array = []
var lvbox: LineEdit

func _lbl(t: String, fs := 15, col := "#ffffff") -> Dictionary:
	return LoseUI.txt(t, "Sora-800", fs, col)

func mk(parent: Control, r: Array, t = null, kind := "") -> Control:
	var d := {"i": 0, "id": "", "tag": "div", "r": r, "op": 1}
	if t != null:
		d.txt = t
	var c := lay.make(d, Vector2.ZERO)
	parent.add_child(c)
	if kind != "":
		UISkin.button(c, kind)
	return c

func build(a) -> void:
	app = a
	size = Vector2(390, 844)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0.04, 0.01, 0.09, 0.7)
	dim.position = Vector2(0, -400)
	dim.size = Vector2(390, 1644)
	add_child(dim)
	app.tap(dim, close)
	var card := Panel.new()
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color("#fff6e0")
	cs.border_color = Color("#6B0F1A")
	cs.set_border_width_all(4)
	cs.set_corner_radius_all(24)
	card.add_theme_stylebox_override("panel", cs)
	card.position = Vector2(14, 70)
	card.size = Vector2(362, 700)
	add_child(card)
	app.tap(card, func(): pass)
	var t := mk(card, [0, 12, 362, 34], LoseUI.txt("Test tools · Builds", "LilitaOne", 26, UISkin.TITLE))
	var x := mk(card, [314, 10, 38, 38], _lbl("×", 22), "red")
	app.tap(x, close)
	for i in 4:
		var b := mk(card, [14 + i * 85, 56, 79, 40], _lbl("Area %d" % (i + 1), 15), "white")
		var ai := i + 1
		app.tap(b, func(): show_tab(ai))
		tabs.append(b)
	body = Control.new()
	body.position = Vector2(0, 104)
	body.size = Vector2(362, 440)
	card.add_child(body)
	# go to level
	var gl := mk(card, [14, 560, 120, 40], LoseUI.txt("Go to level", "Sora-800", 15, UISkin.TEXT))
	gl.get_node("txt").horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lvbox = LineEdit.new()
	lvbox.position = Vector2(132, 560)
	lvbox.size = Vector2(100, 42)
	lvbox.placeholder_text = "1-%d" % app.levels.size()
	lvbox.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	lvbox.add_theme_font_size_override("font_size", 20)
	card.add_child(lvbox)
	var go := mk(card, [244, 558, 104, 46], _lbl("Go", 18), "green")
	app.tap(go, func():
		var n := int(lvbox.text)
		if n >= 1 and n <= app.levels.size():
			close()
			app.dev_goto(n))
	var dy := mk(card, [14, 620, 160, 50], _lbl("+100 diyas", 16), "yellow")
	app.tap(dy, func():
		app.dev_diyas(100)
		app.toast28("+100 diyas"))
	var note := mk(card, [184, 620, 170, 50], LoseUI.txt("Test version only", "Sora-700", 12, UISkin.TEXT))

func open() -> void:
	visible = true
	show_tab(clampi(int(app.street.area), 1, 4))

func close() -> void:
	visible = false

func show_tab(a: int) -> void:
	tab = a
	for i in tabs.size():
		UISkin.button(tabs[i], "red" if i + 1 == a else "white")
	for c in body.get_children():
		c.queue_free()
	var names: Array = app.dev_build_names(a)
	for i in names.size():
		var col := i % 2
		var row := i / 2
		var b := mk(body, [14 + col * 170, row * 50, 164, 44], _lbl("%d · %s" % [i + 1, names[i]], 11), "white")
		var bi := i
		app.tap(b, func():
			close()
			app.dev_build(a, bi))
	var y := ((names.size() + 1) / 2) * 50 + 6
	var all := mk(body, [14, y, 334, 44], _lbl("Play all builds", 16), "green")
	app.tap(all, func():
		close()
		app.dev_build(a, -1))
	var st := mk(body, [14, y + 52, 164, 44], _lbl("Area start", 15), "yellow")
	app.tap(st, func():
		close()
		app.dev_area_start(a))
	var en := mk(body, [184, y + 52, 164, 44], _lbl("Area end", 15), "yellow")
	app.tap(en, func():
		close()
		app.dev_area_end(a))
