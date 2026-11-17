# face.js: the man in the coat in the level badge, chest-up. Blinks, looks around, smiles, surprise, grin, worry, cheer.
# (Build 29 went back to this drawn man; the suit-man photo looked blurry in the app.)
extends Control
class_name CMFace

const M := {"idle": {"sm": 0.3, "br": 0.0, "ey": 1.0, "mo": 0.0, "wo": 0.0, "wk": 0.0},
	"smile": {"sm": 1.0, "br": 0.2, "ey": 0.95, "mo": 0.0, "wo": 0.0, "wk": 0.0},
	"wow": {"sm": 0.4, "br": 1.0, "ey": 1.35, "mo": 0.7, "wo": 0.0, "wk": 0.0},
	"grin": {"sm": 1.6, "br": 0.5, "ey": 0.8, "mo": 0.45, "wo": 0.0, "wk": 1.0},
	"worried": {"sm": -0.6, "br": 0.2, "ey": 1.05, "mo": 0.0, "wo": 1.0, "wk": 0.0},
	"cheer": {"sm": 1.8, "br": 0.8, "ey": 0.7, "mo": 0.8, "wo": 0.0, "wk": 0.0}}

var t := 0.0
var m := "idle"
var mt := 0.0
var base := "idle"
var bl := 0.0
var nb := 2.0
var look := 0.0
var lt := 0.0
var lk := 0.0
var bounce := 0.0
var v := {"sm": 0.3, "br": 0.0, "ey": 1.0, "mo": 0.0, "wo": 0.0, "wk": 0.0}
var pen: Pen
# story: head turn (-1 left .. 1 right), walk bob, body sway and breathing; all 0 in the game badge
var turn := 0.0
var bob := 0.0
var sway := 0.0
var breathe := 0.0
var shrug := 0.0

func _ready() -> void:
	pen = Pen.new(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func mood(n: String, hold: float = 1.4) -> void:
	if not M.has(n):
		return
	if n == "worried":
		base = "worried"
	m = n
	mt = hold
	if n == "grin" or n == "cheer":
		bounce = 1.0

func calm() -> void:
	base = "idle"

func _process(dt: float) -> void:
	dt = minf(dt, 0.05)
	t += dt
	if mt > 0:
		mt -= dt
		if mt <= 0:
			m = base
	var g: Dictionary = M[m]
	var kk := minf(1.0, dt * 10)
	for i in g:
		v[i] += (g[i] - v[i]) * kk
	nb -= dt
	if nb <= 0:
		bl = 0.14
		nb = 2.2 + randf() * 3
	if bl > 0:
		bl -= dt
	lt -= dt
	if lt <= 0:
		lt = 1.5 + randf() * 2.5
		lk = [-1.0, 0.0, 1.0, 0.0][randi() % 4] if m == "idle" else 0.0
	look += (lk - look) * minf(1.0, dt * 6)
	if bounce > 0:
		bounce = maxf(0.0, bounce - dt * 2.2)
	queue_redraw()

func _draw() -> void:
	if pen == null:
		return
	var c := pen
	var W := size.x
	var H := size.y
	c.xf = Transform2D.IDENTITY
	c.clip_poly = PackedVector2Array()
	c.save()
	var sc := minf(W / 150.0, H / 235.0)
	c.translate(W / 2, H + 2 - sin(bounce * PI) * 4 - bob)
	c.scale(sc, sc)
	c.rotate(sway)
	var br2 := sin(t * 1.6) * breathe
	c.save()
	c.scale(1.0 + br2 * 0.01, 1.0 + br2 * 0.025 - shrug * 0.04)
	# coat shoulders
	c.begin(); c.move(-80, 0); c.bez(-80, -40, -60, -62, -30, -70); c.line(30, -70); c.bez(60, -62, 80, -40, 80, 0); c.close(); c.fill(Color("#2C2B34"))
	c.begin(); c.move(-22, -72); c.line(22, -72); c.line(4, 0); c.line(-4, 0); c.close(); c.fill(Color("#F2F3F7"))
	c.begin(); c.move(-28, -72); c.line(-46, -30); c.line(-30, -24); c.line(-3, 0); c.line(-10, 0); c.close(); c.move(28, -72); c.line(46, -30); c.line(30, -24); c.line(3, 0); c.line(10, 0); c.close(); c.fill(Color("#3A3944"))
	c.begin(); c.move(60, -34); c.line(38, -38); c.line(40, -30); c.line(58, -26); c.close(); c.fill(Color("#FF2FA8"))
	c.restore()
	# neck and head
	c.translate(0, -140 - br2 * 1.5 + shrug * 4)
	c.rotate(turn * 0.05)
	CMFace.head_base(c)
	c.translate(-4 + turn * 13, 0)
	var br: float = v.br * 6
	var wo: float = v.wo
	var sm: float = v.sm
	c.begin(); c.move(-36, -14 - br + wo * 3); c.quad(-23, -21 - br - sm, -10, -14 - br - wo * 6); c.move(10, -14 - br - wo * 6); c.quad(23, -21 - br - sm, 36, -14 - br + wo * 3); c.stroke("#2A282D", 4.2)
	# eyes
	var blink := bl > 0
	var lx := look * 3.5 + turn * 3.0
	for i in 2:
		var ex := -23.0 if i == 0 else 23.0
		var shut: bool = blink or (i == 1 and v.wk > 0.5)
		var o: float = v.ey
		if shut:
			c.begin(); c.move(ex - 9, 1); c.quad(ex, -4.0 if (i == 1 and v.wk > 0.5 and not blink) else 4.0, ex + 9, 1); c.stroke("#2A282D", 2.6)
			continue
		c.save()
		c.begin(); c.move(ex - 11, 1); c.quad(ex, -7 * o, ex + 11, 1); c.quad(ex, 5 * o, ex - 11, 1); c.clip()
		c.begin(); c.rect(ex - 12, -10, 24, 18); c.fill(Color("#F4EEE8"))
		c.begin(); c.arc(ex + 1 + lx, -0.5, 4.2 if o > 1.2 else 5.0, 0, TAU); c.fill(Color("#2A1A12"))
		c.begin(); c.arc(ex + 2.5 + lx, -2.2, 1.3, 0, TAU); c.fill(Color.WHITE)
		c.restore()
		c.begin(); c.move(ex - 12, 1); c.quad(ex, -8 * o, ex + 12, 1); c.stroke("#2A282D", 2.2)
	c.begin(); c.move(3, -4); c.quad(10, 18, 6, 24); c.quad(0, 28, -6, 24); c.stroke(Color(130 / 255.0, 76 / 255.0, 46 / 255.0, 0.75), 2.4)
	# mouth
	var mo: float = v.mo
	if mo > 0.08:
		c.begin(); c.move(-16 - sm * 2, 36 - sm * 2); c.quad(2, 40 + sm * 3 + mo * 14, 18 + sm * 2, 35 - sm * 3); c.quad(2, 38 + sm, -16 - sm * 2, 36 - sm * 2); c.fill(Color("#5A1F1A"))
		if sm > 0.8:
			c.begin(); c.move(-12, 37 - sm); c.quad(2, 39 + sm, 14, 36 - sm * 2); c.line(13, 39); c.quad(2, 42, -11, 40); c.fill(Color.WHITE)
	else:
		c.begin(); c.move(-18, 38 - sm * 2); c.quad(2, 40 + sm * 5, 20, 35 - sm * 3); c.stroke("#6E2E26", 3.2)
	c.restore()

# neck, ears, face, stubble shade and hair (same in face.js and winguy.js)
static func head_base(c: Pen) -> void:
	c.begin(); c.rrect(-22, 30, 44, 50, 12); c.fill(c.lin(0, 30, 0, 80, [[0.0, "#A9704A"], [1.0, "#C48A60"]]))
	c.begin(); c.ellipse(-49, 6, 7, 14); c.ellipse(49, 6, 7, 14); c.fill(Color("#BC8359"))
	c.begin(); c.move(-47, -26); c.bez(-49, 14, -44, 38, -27, 53); c.quad(-10, 66, 0, 66); c.quad(10, 66, 27, 53); c.bez(44, 38, 49, 14, 47, -26); c.bez(38, -60, -38, -60, -47, -26)
	c.fill(c.lin(-50, 0, 50, 0, [[0.0, "#D9A27A"], [0.6, "#D19668"], [1.0, "#B57B52"]]))
	c.begin(); c.move(-44, 16); c.bez(-42, 36, -27, 53, -27, 53); c.quad(-10, 66, 0, 66); c.quad(10, 66, 27, 53); c.bez(40, 38, 44, 16, 44, 16); c.quad(0, 44, -44, 16)
	c.fill(c.lin(0, 20, 0, 66, [[0.0, Color(70 / 255.0, 60 / 255.0, 60 / 255.0, 0)], [1.0, Color(70 / 255.0, 62 / 255.0, 66 / 255.0, 0.42)]]))
	c.begin(); c.move(-50, 10); c.quad(-66, -14, -54, -34); c.quad(-74, -56, -46, -66); c.quad(-52, -92, -20, -84); c.quad(-12, -110, 14, -92); c.quad(38, -106, 44, -80); c.quad(70, -78, 60, -52); c.quad(76, -34, 56, -20); c.quad(60, -6, 52, 8); c.quad(50, -12, 40, -26); c.quad(30, -16, 22, -36); c.quad(10, -18, 2, -38); c.quad(-8, -16, -16, -40); c.quad(-28, -22, -34, -40); c.quad(-44, -20, -50, 10)
	c.fill(c.lin(-46, -8, 34, -96, [[0.0, "#17161B"], [0.5, "#34333B"], [0.82, "#83858F"], [1.0, "#BDBFC8"]]))
