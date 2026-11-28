# 26 Nov: level screen theme per area (previews/themes, clean like his Royal Match picture):
# solid colour top bar with a thin gold line, cream Target / Moves cards with ribbon labels, the man in an arch
# with a gold edge, Cracker meter and locked booster boxes in the area colour, cream board floor.
# Area 1 royal blue, 2 deep maroon, 3 peacock teal, 4 midnight navy, 5 ruby red.
# Only the existing painted boxes get new colours (UISkin.reskin / set_bg): nothing new is drawn per frame.
extends RefCounted
class_name LevelTheme

const COLS := [Color8(32, 78, 160), Color8(112, 18, 36), Color8(16, 96, 120), Color8(18, 30, 72), Color8(160, 16, 40)]
const GOLD := "#FFAA28"
const BAR_H := 140.0

static func area_of(i: int) -> int:
	if i < 30: return 1
	if i < 60: return 2
	if i < 80: return 3
	if i < 100: return 4
	return 5

static func hx(c: Color, k := 1.0) -> String:
	return Color(clampf(c.r * k, 0, 1), clampf(c.g * k, 0, 1), clampf(c.b * k, 0, 1)).to_html(false)

static func grad(c: Color, k0: float, k1: float, k2 := -1.0) -> Dictionary:
	if k2 < 0:
		return UISkin.lin([[0, "#" + hx(c, k0)], [1, "#" + hx(c, k1)]])
	return UISkin.lin([[0, "#" + hx(c, k0)], [0.5, "#" + hx(c, k1)], [1, "#" + hx(c, k2)]])

static func _style(l: Label, sz: Vector2, fs: int, col: Color, outline: int, ocol: Color) -> void:
	if l == null:
		return
	var ls := LabelSettings.new()
	ls.font = WebLayout.font("LilitaOne")
	ls.font_size = fs
	ls.font_color = col
	ls.outline_size = outline
	ls.outline_color = ocol
	l.label_settings = ls
	l.material = null
	l.position = Vector2.ZERO
	l.size = sz
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for ch in l.get_children():
		if ch is Label:
			ch.visible = false

static func _ribbon(app, c: Control, pill: Control, base: Color) -> void:
	c.position = Vector2((pill.size.x - 96) / 2.0, 3)   # inside the card top: the back / gear buttons sit above it
	c.size = Vector2(96, 26)
	UISkin.reskin(c, {"bg": [grad(base, 1.3, 1.0, 0.75)], "rad": [8, 8, 8, 8], "bw": [2.5, 2.5, 2.5, 2.5], "bcol": UISkin.rgba(GOLD)})
	_style(app.lbl(c), c.size, 17, Color("#FFF6DC"), 6, base.darkened(0.55))

static func apply(app, i: int) -> void:
	var base: Color = COLS[area_of(i) - 1]
	var G: WebLayout = app.G
	var cream := {"bg": [UISkin.lin([[0, "#FFFAE4"], [1, "#F4E8C4"]])], "rad": [14, 14, 14, 14], "bw": [4, 4, 4, 4],
		"bcol": UISkin.rgba("#" + hx(base, 0.85)), "sh": [UISkin.sh(0, 3, 6, "#00000066")]}
	# top bar: one solid colour, thin gold line under it
	var strip: Control = G.nodes[2]
	if not strip.has_meta("themed"):
		strip.set_meta("themed", true)
		for k in range(3, 18):
			G.nodes[k].visible = false
		app.resize_box(strip, Vector2(390, BAR_H))
		var line := ColorRect.new()
		line.name = "gold"
		line.color = Color(GOLD)
		line.position = Vector2(0, BAR_H)
		line.size = Vector2(390, 4)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.add_child(line)
		# tall phones: the bar colour goes on up to the top of the screen
		var up := ColorRect.new()
		up.name = "up"
		up.position = Vector2(0, -400)
		up.size = Vector2(390, 400)
		up.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.add_child(up)
		G.nodes[30].visible = false     # the old pink circle behind the man
		G.nodes[34].visible = false     # "LEVEL N" (the ribbons say Target / Moves)
		G.node("sbar").modulate.a = 0.0 # stars come from moves left; the bar is not shown in the new look
	(strip.get_node("up") as ColorRect).color = base
	UISkin.reskin(strip, {"bgc": [base.r, base.g, base.b, 1.0]})
	# Target / Moves cards (cream, border in the area colour) with ribbons
	for k in [20, 33]:
		UISkin.reskin(G.nodes[k], cream)
	_ribbon(app, G.nodes[21], G.nodes[20], base)
	var mv: Control = G.nodes[36]
	app.set_t(mv, "Moves")
	_ribbon(app, mv, G.nodes[33], base)
	var gm: Control = G.node("gMoves")
	gm.position = Vector2(0, 26)
	gm.size = Vector2(127, 58)
	var gg: Control = G.node("gGoals")
	if not gg.has_meta("y0"):
		gg.set_meta("y0", gg.position.y)
		gg.position.y += 8
	_style(app.lbl(gm), gm.size, 44, Color("#FFFAE6"), 12, base.darkened(0.6))
	gm.remove_meta("col0")
	# the man in an arch with a gold edge
	UISkin.reskin(G.nodes[29], {"bg": [grad(base, 1.25, 0.8)], "rad": [52, 52, 16, 16], "bw": [5, 5, 5, 5], "bcol": UISkin.rgba(GOLD),
		"sh": [UISkin.sh(0, 3, 6, "#00000077")]})
	# Cracker meter and its reward circle in the area colour
	var met: Control = G.node("meter")
	UISkin.reskin(met, {"bg": [grad(base, 1.2, 0.85)], "rad": [17, 17, 17, 17], "bw": [3, 3, 3, 3], "bcol": UISkin.rgba(GOLD)})
	app.set_bg(G.nodes[44], base.darkened(0.55))
	var rw: Control = G.node("mRew")
	UISkin.reskin(rw, {"bg": [grad(base, 1.25, 0.8)], "rad": [20, 20, 20, 20], "bw": [3, 3, 3, 3], "bcol": UISkin.rgba(GOLD)})
	app.theme_base = base
	paint_slots(app)
	# cream board floor with an edge in the area colour (the floor picture is baked when the level starts)
	app.game.floor_a = Color("#EFE3C6")
	app.game.floor_b = Color("#F8F0DC")
	app.game.floor_edge = base.darkened(0.35)

static func paint_slots(app) -> void:
	var base: Color = app.theme_base
	# booster boxes: locked ones in the dark area colour, price pills and lock circles too
	for c in app.G.node("slots").get_children():
		if not (c is Control):
			continue
		var lk: Control = app.kid(c, "i")
		if lk:
			app.set_bg(c, base.darkened(0.45))
			app.set_bg(lk, base.darkened(0.25))
		var pr: Control = app.kid(c, "b")
		if pr and pr.visible and not lk:
			app.set_bg(pr, base.darkened(0.35))
