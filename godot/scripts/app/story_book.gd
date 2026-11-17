# Grandpa's leather notebook for the story: the cover swings open, an old sepia photo of Thatha is taped on the left,
# and his line writes itself on the right page in ink. Everything is drawn in code (Pen), 340 x 240.
extends Control
class_name StoryBook

const LINES := ["One day,", "Sivakasi crackers", "will light up", "every home."]
const INK := Color("#26264A")
var base_x := 25.0
var open := 0.0:
	set(v):
		open = v
		position.x = base_x - 85.0 * (1.0 - v)   # a closed book sits centred
		queue_redraw()
var wk := 0.0     # 0..1 of the text written
var sig := 0.0    # signature alpha
var pen: Pen
var hand: Font
var serif: Font
var grain: PackedVector2Array
var app
var _last_n := 0

func _ready() -> void:
	pen = Pen.new(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hand = StoryScene.font_var("res://art/fonts/Caveat.ttf", 600)
	serif = StoryScene.font_var("res://art/fonts/CormorantItalic.ttf", 700)
	var r := RandomNumberGenerator.new()
	r.seed = 7
	for i in 90:
		grain.append(Vector2(r.randf_range(-50, 50), r.randf_range(-64, 40)))

func reset() -> void:
	open = 0.0
	wk = 0.0
	sig = 0.0
	_last_n = 0

func write(dur: float, a) -> void:
	app = a
	var t := create_tween()
	t.tween_method(func(v: float):
		wk = v
		var n := int(v * 52)
		if n > _last_n and app and app.sfx and n % 3 == 0:
			app.sfx.play("story_pen", 0.55, randf_range(0.9, 1.15))
		_last_n = n
		queue_redraw(), 0.0, 1.0, dur)

func sign_off() -> void:
	create_tween().tween_method(func(v: float):
		sig = v
		queue_redraw(), 0.0, 1.0, 0.8)

func _process(_dt: float) -> void:
	pass

func _draw() -> void:
	if pen == null:
		return
	var c := pen
	c.xf = Transform2D.IDENTITY
	c.clip_poly = PackedVector2Array()
	var k := open
	var S := 170.0
	# soft shadow and the back cover (right half; the left half is the open front cover)
	var lx := S - 6 + minf(0.0, cos(k * PI)) * 170.0
	c.begin(); c.rrect(lx + 4, 8, 346 - lx - 2, 246, 12); c.fill(Color(0, 0, 0, 0.32))
	c.begin(); c.rrect(S - 6, -6, 182, 252, 10); c.fill(c.lin(0, -6, 0, 246, [[0.0, "#6A3F25"], [1.0, "#3A2014"]]))
	if k > 0.02:
		# right page with a few page edges under it
		for i in 3:
			c.begin(); c.rrect(S, 6 + i, 164 - i * 1.5, 230, 3); c.fill(Color("#D8C39B").darkened(i * 0.05))
		c.begin(); c.rrect(S, 4, 162, 230, 3); c.fill(c.lin(S, 0, S + 162, 0, [[0.0, "#E9DABB"], [0.18, "#F7EEDB"], [1.0, "#F3E7CE"]]))
		for i in 7:
			c.begin(); c.move(S + 14, 58 + i * 24); c.line(S + 150, 58 + i * 24); c.stroke(Color(0.45, 0.42, 0.6, 0.16), 1)
		_text(S)
	# left page appears as the cover settles
	var lp := clampf((k - 0.6) / 0.4, 0.0, 1.0)
	var w := cos(k * PI)
	if w < 0:
		# inside of the cover on the left
		var x1 := S + 168 * w
		var dy := (1.0 - absf(w)) * 12
		c.begin(); c.move(S, -6); c.line(x1, -6 - dy); c.line(x1, 246 + dy); c.line(S, 246); c.close(); c.fill(c.lin(x1, 0, S, 0, [[0.0, "#4A2618"], [1.0, "#6B3A24"]]))
		c.begin(); c.move(S - 2, 0); c.line(x1 + 6 * signf(-w), 0 - dy * 0.8); c.line(x1 + 6 * signf(-w), 240 + dy * 0.8); c.line(S - 2, 240); c.close(); c.fill(Color("#7A2632"))
	if lp > 0:
		c.begin(); c.rrect(8, 4, 162, 230, 3); c.fill(c.lin(8, 0, S, 0, [[0.0, Color(0.95, 0.91, 0.82, lp)], [0.82, Color(0.97, 0.93, 0.85, lp)], [1.0, Color(0.88, 0.82, 0.70, lp)]]))
		_photo(lp)
	if k > 0.02:
		# spine shadow
		c.begin(); c.rect(S - 18, 4, 36, 230); c.fill(c.lin(S - 18, 0, S + 18, 0, [[0.0, Color(0, 0, 0, 0)], [0.5, Color(0.2, 0.1, 0.05, 0.28)], [1.0, Color(0, 0, 0, 0)]]))
	if w >= 0:
		# front cover swinging open over the right side
		var x2 := S + 176 * w - 6 * (1 - w)
		var dy2 := (1.0 - w) * 12
		c.begin(); c.move(S - 6 * w, -6); c.line(x2, -6 - dy2); c.line(x2, 246 + dy2); c.line(S - 6 * w, 246); c.close()
		c.fill(c.lin(S, -6, x2, 246, [[0.0, "#7A4A2C"], [0.5, "#5C3520"], [1.0, "#43261A"]]))
		if w > 0.3:
			_cover(w)

func _cover(w: float) -> void:
	var c := pen
	var a := clampf((w - 0.3) / 0.4, 0.0, 1.0)
	var S := 170.0
	c.save(); c.translate(S, 0); c.scale(w, 1)
	# stitched border and an embossed gold frame
	for i in 40:
		var x := 10.0 + i * 4.0
		if x > 160: break
		c.begin(); c.move(x, 6); c.line(x + 2.2, 6); c.move(x, 234); c.line(x + 2.2, 234); c.stroke(Color(0.85, 0.68, 0.42, 0.55 * a), 1.3)
	for i in 56:
		var y := 8.0 + i * 4.0
		if y > 232: break
		c.begin(); c.move(160, y); c.line(160, y + 2.2); c.stroke(Color(0.85, 0.68, 0.42, 0.55 * a), 1.3)
	c.begin(); c.rrect(26, 54, 116, 132, 8); c.stroke(Color(0.86, 0.68, 0.36, 0.75 * a), 2)
	c.begin(); c.rrect(32, 60, 104, 120, 6); c.stroke(Color(0.86, 0.68, 0.36, 0.4 * a), 1)
	c.restore()
	if w > 0.8:
		var ta := clampf((w - 0.8) / 0.2, 0.0, 1.0)
		draw_set_transform(Vector2(S + 84 * w, 112), 0, Vector2(w, 1))
		var tw := serif.get_string_size("Thatha's", HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_string(serif, Vector2(-tw / 2, 0), "Thatha's", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.95, 0.80, 0.5, ta))
		var tw2 := serif.get_string_size("Notebook", HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_string(serif, Vector2(-tw2 / 2, 26), "Notebook", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.95, 0.80, 0.5, ta))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _text(S: float) -> void:
	var total := 0
	for l in LINES:
		total += l.length()
	var n := int(wk * total)
	var y := 60.0
	for l in LINES:
		var m := mini(n, l.length())
		if m > 0:
			draw_string(hand, Vector2(S + 14, y), l.substr(0, m), HORIZONTAL_ALIGNMENT_LEFT, -1, 23, INK)
		n -= l.length()
		y += 24
	if sig > 0:
		var col := Color(INK.r, INK.g, INK.b, sig)
		draw_string(hand, Vector2(S + 66, y + 26), "— Thatha", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, col)
		# a small ink diya doodle
		var c := pen
		c.save(); c.translate(S + 36, y + 18)
		c.begin(); c.move(-14, 0); c.quad(0, 14, 14, 0); c.line(-14, 0); c.stroke(col, 1.8)
		c.begin(); c.move(0, -3); c.quad(-5, -9, 0, -18); c.quad(5, -9, 0, -3); c.stroke(Color(0.85, 0.45, 0.1, sig), 1.6)
		c.restore()

func _photo(a: float) -> void:
	var c := pen
	c.save(); c.translate(88, 104); c.rotate(-0.07)
	c.begin(); c.rrect(-54, -66, 112, 140, 2); c.fill(Color(0, 0, 0, 0.18 * a))
	c.begin(); c.rrect(-57, -70, 112, 140, 2); c.fill(Color(0.98, 0.97, 0.93, a))
	c.save()
	c.begin(); c.rect(-49, -62, 96, 104); c.clip()
	c.begin(); c.rect(-49, -62, 96, 104); c.fill(c.lin(0, -62, 0, 42, [[0.0, Color(0.80, 0.69, 0.52, a)], [1.0, Color(0.55, 0.42, 0.29, a)]]))
	# an old cracker stall behind him, out of focus
	c.begin(); c.rect(-49, -30, 96, 4); c.fill(Color(0.45, 0.33, 0.22, 0.5 * a))
	for i in 5:
		c.begin(); c.rect(-46 + i * 20, -24, 14, 10); c.fill(Color(0.62, 0.48, 0.33, 0.45 * a))
	_grandpa(a)
	# age: darker corners and grain
	c.begin(); c.rect(-49, -62, 96, 20); c.fill(c.lin(0, -62, 0, -42, [[0.0, Color(0.25, 0.15, 0.08, 0.35 * a)], [1.0, Color(0.25, 0.15, 0.08, 0)]]))
	c.begin(); c.rect(-49, 22, 96, 20); c.fill(c.lin(0, 22, 0, 42, [[0.0, Color(0.25, 0.15, 0.08, 0)], [1.0, Color(0.25, 0.15, 0.08, 0.4 * a)]]))
	c.restore()
	for g in grain:
		var p := c._p(g.x, g.y)
		draw_rect(Rect2(p, Vector2(1, 1)), Color(0.2, 0.12, 0.05, 0.18 * a))
	# tape
	for s in [-1.0, 1.0]:
		c.save(); c.translate(s * 40, -70); c.rotate(s * 0.6)
		c.begin(); c.rect(-14, -6, 28, 12); c.fill(Color(1, 0.98, 0.9, 0.55 * a))
		c.restore()
	c.restore()
	draw_set_transform(Vector2(40, 200), -0.04, Vector2.ONE)
	draw_string(hand, Vector2.ZERO, "Thatha, 1978", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(INK.r, INK.g, INK.b, 0.85 * a))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

# Grandpa in sepia: white side hair, round glasses, big white moustache, shawl over a kurta, a warm smile
func _grandpa(a: float) -> void:
	var c := pen
	var A := func(h: String, al := 1.0) -> Color:
		var col := Color(h)
		col.a = al * a
		return col
	c.save(); c.translate(0, 44); c.scale(0.43, 0.43)
	# kurta and shawl
	c.begin(); c.move(-92, 0); c.bez(-92, -44, -66, -66, -32, -72); c.line(32, -72); c.bez(66, -66, 92, -44, 92, 0); c.close(); c.fill(A.call("#EEE4D2"))
	c.begin(); c.move(-92, 0); c.bez(-90, -40, -70, -62, -40, -70); c.line(10, 0); c.close(); c.fill(A.call("#8E6C4C"))
	c.begin(); c.move(-40, -70); c.line(10, 0); c.stroke(A.call("#6C4F36"), 3)
	c.begin(); c.move(-8, -72); c.line(8, -72); c.line(4, -40); c.line(-4, -40); c.close(); c.fill(A.call("#D9CCB6"))
	c.translate(0, -140)
	# neck, ears, face
	c.begin(); c.rrect(-21, 30, 42, 46, 12); c.fill(A.call("#B18A63"))
	c.begin(); c.ellipse(-49, 6, 8, 15); c.ellipse(49, 6, 8, 15); c.fill(A.call("#BE9670"))
	c.begin(); c.move(-46, -30); c.bez(-49, 14, -44, 40, -27, 55); c.quad(-10, 68, 0, 68); c.quad(10, 68, 27, 55); c.bez(44, 40, 49, 14, 46, -30); c.bez(38, -66, -38, -66, -46, -30)
	c.fill(c.lin(-50, 0, 50, 0, [[0.0, A.call("#D9B790")], [0.6, A.call("#CFAA80")], [1.0, A.call("#B38D66")]]))
	# shine on the bald top
	c.begin(); c.ellipse(-12, -44, 16, 6); c.fill(A.call("#F2DDBE", 0.6))
	# white hair at the sides
	for s in [-1.0, 1.0]:
		c.begin(); c.move(s * 44, -26); c.quad(s * 62, -20, s * 58, 2); c.quad(s * 64, 10, s * 54, 22); c.quad(s * 50, 4, s * 44, -6); c.close(); c.fill(A.call("#F4EFE6"))
		c.begin(); c.move(s * 46, -22); c.quad(s * 58, -12, s * 54, 10); c.stroke(A.call("#BFB4A3"), 1.6)
	# forehead lines
	for i in 3:
		c.begin(); c.move(-20 + i * 2, -36 + i * 6); c.quad(0, -40 + i * 6, 20 - i * 2, -36 + i * 6); c.stroke(A.call("#8E6A48", 0.55), 1.8)
	# brows
	c.begin(); c.move(-38, -16); c.quad(-24, -24, -10, -16); c.move(10, -16); c.quad(24, -24, 38, -16); c.stroke(A.call("#F1ECE2"), 6)
	# smiling eyes
	c.begin(); c.move(-31, -1); c.quad(-23, -6, -15, -1); c.move(15, -1); c.quad(23, -6, 31, -1); c.stroke(A.call("#3A2A1E"), 2.8)
	c.begin(); c.move(-35, 4); c.line(-38, 8); c.move(35, 4); c.line(38, 8); c.stroke(A.call("#8E6A48", 0.6), 1.5)
	# round glasses
	c.begin(); c.arc(-23, -2, 15, 0, TAU); c.stroke(A.call("#3A2A1E"), 2.6)
	c.begin(); c.arc(23, -2, 15, 0, TAU); c.stroke(A.call("#3A2A1E"), 2.6)
	c.begin(); c.move(-8, -4); c.quad(0, -8, 8, -4); c.move(-38, -4); c.line(-48, -8); c.move(38, -4); c.line(48, -8); c.stroke(A.call("#3A2A1E"), 2.2)
	# nose
	c.begin(); c.move(2, 0); c.quad(10, 20, 6, 26); c.quad(0, 30, -7, 26); c.stroke(A.call("#7E5A3C", 0.8), 2.4)
	# big white moustache and the smile under it
	c.begin(); c.move(0, 31); c.bez(-10, 26, -30, 28, -40, 40); c.bez(-28, 36, -12, 44, 0, 38); c.bez(12, 44, 28, 36, 40, 40); c.bez(30, 28, 10, 26, 0, 31); c.fill(A.call("#F6F1E8"))
	c.begin(); c.move(-36, 38); c.bez(-28, 32, -10, 30, 0, 33); c.bez(10, 30, 28, 32, 36, 38); c.stroke(A.call("#BFB4A3"), 1.4)
	c.begin(); c.move(-14, 46); c.quad(0, 54, 14, 46); c.stroke(A.call("#6E3E2A"), 2.6)
	c.restore()
