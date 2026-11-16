# One look for every popup window (16 Nov, 21:44): the street Welcome card.
# Cream gradient card with a dark crimson border, pink-red titles with a crimson outline (the MATCH logo colours),
# red main buttons, yellow buttons for coins / buying, white buttons for "Not now".
extends RefCounted
class_name UISkin

const DARK := "#6B0F1A"
const TEXT := "#5a2a1a"
const LINK := "#C8102E"
const TITLE := "#FF3D5E"

static func rgba(h: String, a := -1.0) -> Array:
	var c := Color(h)
	return [c.r, c.g, c.b, c.a if a < 0 else a]

static func lin(st: Array) -> Dictionary:
	var s: Array = []
	for q in st:
		s.append([q[0], rgba(q[1])])
	return {"t": "lin", "ang": 180, "st": s}

static func sh(x: float, y: float, b: float, c: String, inset := false) -> Dictionary:
	return {"x": x, "y": y, "b": b, "s": 0.0, "c": rgba(c), "in": inset}

static func card_box(rad := 26.0) -> Dictionary:
	return {"bg": [lin([[0, "#fffdf2"], [1, "#ffefc4"]])], "rad": [rad, rad, rad, rad], "bw": [4, 4, 4, 4], "bcol": rgba(DARK),
		"sh": [sh(0, 8, 0, DARK), sh(0, 18, 30, "#00000077")]}

static func btn_box(kind: String, rad := 18.0) -> Dictionary:
	if kind == "yellow":
		return {"bg": [lin([[0, "#FFF6C2"], [0.4, "#FFD23F"], [1, "#F59E0B"]])], "rad": [rad, rad, rad, rad], "bw": [3, 3, 3, 3], "bcol": rgba(DARK),
			"sh": [sh(0, -5, 0, "#c76a00", true), sh(0, 5, 0, DARK)]}
	if kind == "white":
		return {"bgc": rgba("#ffffff"), "rad": [rad, rad, rad, rad], "bw": [3, 3, 3, 3], "bcol": rgba(DARK), "sh": [sh(0, 4, 0, DARK)]}
	return {"bg": [lin([[0, "#FF8FA8"], [0.45, "#FF3D5E"], [1, "#C8102E"]])], "rad": [rad, rad, rad, rad], "bw": [3, 3, 3, 3], "bcol": rgba(DARK),
		"sh": [sh(0, -5, 0, "#8a0a20", true), sh(0, 5, 0, DARK)]}

static func _box_of(c: Control) -> ColorRect:
	for ch in c.get_children():
		if ch is ColorRect and ch.material is ShaderMaterial:
			return ch
	return null

static func _lbl(c: Control) -> Label:
	if c.has_node("txt"):
		return c.get_node("txt")
	return null

# put a new painted box behind c's children (the old one is hidden)
static func reskin(c: Control, box: Dictionary) -> void:
	var old := _box_of(c)
	if old:
		old.visible = false
	var prev: Node = c.get_node_or_null("skin")
	if prev:
		prev.free()
	var lay := WebLayout.new()
	var nb := lay.make({"i": 0, "id": "", "tag": "div", "r": [0, 0, c.size.x, c.size.y], "op": 1, "box": box}, Vector2.ZERO)
	nb.name = "skin"
	nb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(nb)
	c.move_child(nb, 0)

static func title_label(l: Label) -> void:
	var ls: LabelSettings = l.label_settings.duplicate()
	ls.font = WebLayout.font("LilitaOne")
	ls.font_color = Color(TITLE)
	ls.outline_size = 5
	ls.outline_color = Color(DARK)
	ls.shadow_color = Color(0, 0, 0, 0)
	l.label_settings = ls
	l.material = null
	for ch in l.get_children():
		if ch is Label:
			ch.visible = false

static func text_label(l: Label, col := TEXT) -> void:
	var ls: LabelSettings = l.label_settings.duplicate()
	ls.font_color = Color(col)
	ls.outline_size = 0
	ls.shadow_color = Color(0, 0, 0, 0)
	l.label_settings = ls
	l.material = null
	for ch in l.get_children():
		if ch is Label:
			ch.visible = false

static func button(b: Control, kind := "red") -> void:
	if b == null:
		return
	reskin(b, btn_box(kind, minf(18.0, b.size.y / 2.0)))
	var l := _lbl(b)
	if l:
		var ls: LabelSettings = l.label_settings.duplicate()
		ls.font = WebLayout.font("Sora-800")
		ls.font_size = mini(ls.font_size, 22)
		if kind == "white":
			ls.font_color = Color(DARK)
			ls.outline_size = 0
		else:
			ls.font_color = Color.WHITE
			ls.outline_size = 4
			ls.outline_color = Color(DARK)
		ls.shadow_color = Color(0, 0, 0, 0)
		l.label_settings = ls
		l.material = null
		for ch in l.get_children():
			if ch is Label:
				ch.visible = false

# the whole card: new box, titles and text recoloured; elements with their own box (pills, ribbons, buttons) are left alone
static func card(c: Control) -> void:
	reskin(c, card_box())
	_text(c)

static func _text(c: Control) -> void:
	for ch in c.get_children():
		if not ch is Control or ch.name == "skin":
			continue
		var w: Dictionary = ch.get_meta("web", {})
		if w.get("tag", "") == "button" or _box_of(ch) != null:
			continue
		var l := _lbl(ch)
		if l and l.label_settings and l.visible:
			if l.label_settings.font_size >= 22:
				title_label(l)
			else:
				text_label(l)
		_text(ch)
