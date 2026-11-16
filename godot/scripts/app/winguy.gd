# winguy.js: the drawn man in the coat on the win screen. Hand on the hip, the other arm sweeps out, confetti.
# Plays once (app.js sets hold). Drawn in its own 390 x 600 canvas (the win layout scales it to 0.82).
extends Control
class_name CMWinGuy

var t := 0.0
var conf: Array = []
var fired := false
var ox := 0.0   # kept for the app; not used
var oy := 0.0
var pen: Pen
var _dt := 0.0

func _ready() -> void:
	pen = Pen.new(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(dt: float) -> void:
	_dt = minf(dt, 0.04)
	t += _dt
	queue_redraw()

static func back(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	var c := 1.5
	x -= 1
	return x * x * ((c + 1) * x + c) + 1

func limb(a: Vector2, b: Vector2, w1: float, w2: float, col: String) -> void:
	var c := pen
	var an := atan2(b.y - a.y, b.x - a.x)
	var nx := -sin(an)
	var ny := cos(an)
	c.begin(); c.move(a.x + nx * w1, a.y + ny * w1); c.line(b.x + nx * w2, b.y + ny * w2); c.arc(b.x, b.y, w2, an + 1.57, an - 1.57, true); c.line(a.x - nx * w1, a.y - ny * w1); c.arc(a.x, a.y, w1, an - 1.57, an + 1.57, true); c.close(); c.fill(Color(col))

func hand(H: Vector2, an: float, open: float) -> void:
	var c := pen
	c.save(); c.translate(H.x, H.y); c.rotate(an)
	var skin := "#C98A5E"
	c.begin(); c.rrect(-16, -15, 13, 30, 5); c.fill(Color.WHITE)
	c.begin(); c.rrect(-2, -15, 32, 30, 12); c.fill(Color(skin))
	var ys := [-11.0, -3.5, 4.0, 11.0]
	var Ls := [30.0, 34.0, 32.0, 26.0]
	for i in 4:
		var y: float = ys[i]
		var L: float = Ls[i]
		c.begin(); c.move(25, y * 0.9); c.line(25 + L * 0.82, y * (1 + open * 0.25)); c.stroke(skin, 8.2)
		c.begin(); c.move(27, y * 0.9 + 4); c.line(23 + L * 0.82, y * (1 + open * 0.25) + 4); c.stroke(Color(120 / 255.0, 70 / 255.0, 40 / 255.0, 0.28), 1)
	c.begin(); c.move(6, 12); c.line(24, 26); c.stroke(skin, 9)
	c.restore()

func head(x: float, y: float, tilt: float, blink: bool, smile: float) -> void:
	var c := pen
	c.save(); c.translate(x, y); c.rotate(tilt)
	CMFace.head_base(c)
	var L := [[-40, -34, -30, -76], [-24, -40, -6, -90], [-6, -42, 14, -86], [10, -40, 34, -84], [26, -36, 52, -62], [-48, -8, -52, -44], [42, -24, 60, -34]]
	for i in L.size():
		var l: Array = L[i]
		c.begin(); c.move(l[0], l[1]); c.quad((l[0] + l[2]) / 2.0 + (10 if i % 2 else -10), (l[1] + l[3]) / 2.0, l[2], l[3])
		c.stroke(Color(216 / 255.0, 218 / 255.0, 226 / 255.0, 0.5 + (i % 3) * 0.15), 2.1)
	c.save(); c.translate(-7, 0)
	c.begin(); c.move(-36, -14); c.quad(-23, -21 - smile * 2, -10, -14); c.move(10, -14); c.quad(23, -21 - smile * 2, 36, -14); c.stroke("#2A282D", 4.2)
	if blink:
		c.begin(); c.move(-32, 1); c.quad(-23, 4, -14, 1); c.move(14, 1); c.quad(23, 4, 32, 1); c.stroke("#2A282D", 2.6)
	else:
		for ex in [-23.0, 23.0]:
			c.save()
			c.begin(); c.move(ex - 11, 1); c.quad(ex, -7, ex + 11, 1); c.quad(ex, 5, ex - 11, 1); c.clip()
			c.begin(); c.rect(ex - 12, -8, 24, 14); c.fill(Color("#F4EEE8"))
			c.begin(); c.arc(ex + 1, -0.5, 5, 0, TAU); c.fill(Color("#2A1A12"))
			c.restore()
			c.begin(); c.move(ex - 12, 1); c.quad(ex, -8, ex + 12, 1); c.stroke("#2A282D", 2.2)
	c.begin(); c.move(3, -4); c.quad(10, 18, 6, 24); c.quad(0, 28, -6, 24); c.stroke(Color(130 / 255.0, 76 / 255.0, 46 / 255.0, 0.75), 2.4)
	c.begin(); c.move(-18, 38 - smile * 2); c.quad(2, 46 + smile * 3, 20, 35 - smile * 3); c.stroke("#6E2E26", 3.2)
	c.restore(); c.restore()

func _draw() -> void:
	if pen == null:
		return
	var c := pen
	c.xf = Transform2D.IDENTITY
	c.clip_poly = PackedVector2Array()
	c.stack.clear()
	var dt := _dt
	var H := 600.0 - 44.0
	var cx := 226.0
	var oy0 := 0.0
	var bob := 0.0
	var lean := -0.1
	var base := Vector2(cx, H + 40 + oy0)
	var sh := Vector2(cx - 76, H - 200 + oy0 + bob)
	if t > 0.94 and not fired:
		fired = true
		var cols := ["#FF2FA8", "#FFC62B", "#1E5BFF", "#0DB865", "#FF6A00"]
		for i in 90:
			var a := -1.57 + (randf() - 0.5) * 2.8
			var vv := 260 + randf() * 420
			conf.append({"x": cx - 140 + randf() * 30, "y": H - 90, "vx": cos(a) * vv - 60, "vy": sin(a) * vv, "r": randf() * 6, "vr": randf() * 12 - 6, "col": Color(cols[i % 5]), "w": 6 + randf() * 7, "h": 4 + randf() * 5})
	var keep: Array = []
	for f in conf:
		f.vy += 520 * dt
		f.vx *= 0.99
		f.x += f.vx * dt
		f.y += f.vy * dt
		f.r += f.vr * dt
		if f.y > H + 20:
			continue
		keep.append(f)
		draw_set_transform(Vector2(f.x, f.y), f.r, Vector2(1, absf(cos(f.r * 2)) + 0.2))
		draw_rect(Rect2(-f.w / 2, -f.h / 2, f.w, f.h), f.col)
	conf = keep
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	c.save()
	c.translate(cx, H + 70); c.scale(1.2, 1.2); c.translate(-cx, -(H + 70)); c.translate(base.x, base.y); c.rotate(lean); c.translate(-base.x, -base.y)
	var Y := func(v: float) -> float: return H + v + oy0 + bob
	var cg := "#2C2B34"
	c.begin(); c.move(cx - 72, H + 60 + oy0); c.line(cx - 62, Y.call(-80)); c.bez(cx - 64, Y.call(-120), cx - 78, Y.call(-160), cx - 84, Y.call(-182)); c.bez(cx - 100, Y.call(-212), cx - 60, Y.call(-226), cx - 34, Y.call(-236)); c.line(cx + 34, Y.call(-236)); c.bez(cx + 60, Y.call(-226), cx + 86, Y.call(-218), cx + 92, Y.call(-186)); c.bez(cx + 84, Y.call(-140), cx + 66, Y.call(-110), cx + 62, Y.call(-80)); c.line(cx + 72, H + 60 + oy0); c.close(); c.fill(Color(cg))
	c.save(); c.translate(-7, 0)
	c.begin(); c.move(cx - 30, Y.call(-236)); c.line(cx + 30, Y.call(-236)); c.line(cx + 4, Y.call(-96)); c.line(cx - 4, Y.call(-96)); c.close(); c.fill(Color("#F2F3F7"))
	c.begin(); c.move(cx - 27, Y.call(-238)); c.line(cx - 1, Y.call(-200)); c.line(cx - 34, Y.call(-186)); c.close(); c.move(cx + 27, Y.call(-238)); c.line(cx + 1, Y.call(-200)); c.line(cx + 34, Y.call(-186)); c.close(); c.fill(Color("#D5D6DF"))
	c.begin(); c.move(cx - 36, Y.call(-238)); c.line(cx - 62, Y.call(-160)); c.line(cx - 38, Y.call(-146)); c.line(cx - 50, Y.call(-130)); c.line(cx - 3, Y.call(-92)); c.close(); c.move(cx + 36, Y.call(-238)); c.line(cx + 62, Y.call(-160)); c.line(cx + 38, Y.call(-146)); c.line(cx + 50, Y.call(-130)); c.line(cx + 3, Y.call(-92)); c.close(); c.fill(Color("#3A3944"))
	c.begin(); c.move(cx, Y.call(-92)); c.line(cx - 6, H + 60 + oy0); c.stroke("#17161B", 2)
	c.begin(); c.arc(cx - 2, Y.call(-70), 4, 0, TAU); c.fill(Color("#F4C542"))
	c.begin(); c.move(cx + 72, Y.call(-146)); c.line(cx + 40, Y.call(-152)); c.line(cx + 42, Y.call(-140)); c.line(cx + 70, Y.call(-134)); c.close(); c.fill(Color("#FF2FA8"))
	c.restore()
	c.begin(); c.move(cx + 44, Y.call(-232)); c.bez(cx + 92, Y.call(-228), cx + 118, Y.call(-206), cx + 120, Y.call(-168)); c.bez(cx + 122, Y.call(-120), cx + 112, Y.call(-78), cx + 104, Y.call(-34)); c.line(cx + 72, Y.call(-32)); c.bez(cx + 74, Y.call(-80), cx + 72, Y.call(-120), cx + 64, Y.call(-156)); c.close(); c.fill(Color(cg))
	c.begin(); c.move(cx + 64, Y.call(-156)); c.bez(cx + 72, Y.call(-120), cx + 74, Y.call(-80), cx + 72, Y.call(-32)); c.stroke("#17161B", 2)
	c.save(); c.translate(cx + 88, Y.call(-28)); c.rotate(1.57); c.begin(); c.rrect(-10, -19, 10, 38, 4); c.fill(Color.WHITE); c.restore()
	hand(Vector2(cx + 88, Y.call(-24)), 1.57, 0)
	var bl := fmod(t, 3.1) > 3
	head(cx - 10, H - 310 + oy0 + bob, 0.1, bl, 1)
	var u := clampf((t - 0.7) / 0.42, 0.0, 1.0)
	u = 2 * u * u if u < 0.5 else 1 - 2 * (1 - u) * (1 - u)
	var q := func(p0: float, p1: float, p2: float) -> float:
		var kq := 2 * p1 - 0.5 * (p0 + p2)
		return (1 - u) * (1 - u) * p0 + 2 * u * (1 - u) * kq + u * u * p2
	var a1: float = q.call(0.9, 2.6, 2.02)
	var a2: float = q.call(-1.0, 0.25, 1.88)
	var L := 88.0
	var E := Vector2(sh.x + cos(a1) * L, sh.y + sin(a1) * L)
	var Hh := Vector2(E.x + cos(a2) * L, E.y + sin(a2) * L)
	limb(sh, E, 27, 25, cg)
	limb(E, Hh, 25, 19, cg)
	c.begin(); c.move(sh.x + cos(a1 - 1.57) * 27, sh.y + sin(a1 - 1.57) * 27); c.line(E.x + cos(a2 - 1.57) * 24, E.y + sin(a2 - 1.57) * 24); c.stroke("#17161B", 2)
	hand(Hh, a2, 0.5 + u * 0.5)
	c.restore()
