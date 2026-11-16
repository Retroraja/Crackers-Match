# man28.js: the level badge head (side-facing photo head with moods) and the win-screen suit man (24-frame sheet).
extends Control
class_name CMFace

var HEAD: Texture2D = preload("res://art/web/head-side.webp")
var m := "idle"
var base := "idle"
var mt := 0.0
var mT := 0.0
var t := 0.0

func mood(n: String, hold: float = 1.4) -> void:
	if not n in ["idle", "smile", "wow", "grin", "cheer", "worried", "calm"]:
		return
	if n == "worried":
		base = "worried"
	m = n
	mt = hold
	mT = 0.0

func calm() -> void:
	base = "idle"
	if m == "worried":
		m = "idle"

func _process(dt: float) -> void:
	t += dt
	if mt > 0.0:
		mt -= dt
		mT += dt
		if mt <= 0.0:
			m = base
	queue_redraw()

func _star(x: float, y: float, r: float, a: float) -> void:
	var p := PackedVector2Array()
	for i in 10:
		var rr := r * 0.45 if i % 2 else r
		var an := i * PI / 5 - PI / 2 + a
		p.append(Vector2(x + cos(an) * rr, y + sin(an) * rr))
	draw_colored_polygon(p, Color("#FFD24A"))
	p.append(p[0])
	draw_polyline(p, Color("#8A4E08"), 1.5, true)

func _draw() -> void:
	var W := size.x
	var H := size.y
	var k := mT
	var dx := 0.0
	var dy := 0.0
	var rot := 0.0
	var sc := 1.0
	if m == "smile": rot = sin(k * 9) * 0.06 * maxf(0, 1 - k)
	elif m == "wow":
		dy = -absf(sin(k * 7)) * 8 * maxf(0, 1 - k / 1.2)
		sc = 1 + 0.06 * maxf(0, 1 - k)
	elif m == "grin": rot = sin(k * 16) * 0.08 * maxf(0, 1 - k / 1.2)
	elif m == "cheer": dy = -absf(sin(k * 6.3)) * 10 * (1.0 if k < 2 else 0.0)
	elif m == "worried": dx = sin(t * 22) * 1.6
	else: dy = sin(t * 2) * 0.8
	var w := minf(W / 540.0 * 1.05, H / 702.0 * 1.05) * 540.0
	var h := w * 702.0 / 540.0
	draw_set_transform(Vector2(W / 2 + dx, H * 0.56 + dy), rot, Vector2(sc, sc))
	draw_texture_rect(HEAD, Rect2(-w / 2, -h / 2, w, h), false)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	if m == "wow" and k < 1.2:
		var f: Font = WebLayout.font("TitanOne")
		draw_string_outline(f, Vector2(W * 0.82, H * 0.3), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 4, Color("#3A0700"))
		draw_string(f, Vector2(W * 0.82, H * 0.3), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#FFD24A"))
	if m == "grin" and k < 1.2: _star(W * 0.82, H * 0.25, 8, k * 3)
	if m == "cheer" and k < 2:
		_star(W * 0.18, H * 0.2 - k * 4, 6, k * 2)
		_star(W * 0.5, H * 0.1 - k * 4, 7, -k * 2)
		_star(W * 0.82, H * 0.2 - k * 4, 6, k * 3)
	if m == "worried":
		var sx := W * 0.8
		var sy := H * 0.3 + fmod(t * 20, 10)
		draw_colored_polygon(PackedVector2Array([Vector2(sx, sy - 7), Vector2(sx + 4, sy), Vector2(sx, sy + 5), Vector2(sx - 4, sy)]), Color("#7FD1FF"))
