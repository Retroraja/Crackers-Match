# A small HTML-canvas-like path drawer so the web game's code-drawn pictures (face.js, winguy.js)
# can be copied line by line: save/restore/translate/rotate/scale, moveTo/lineTo/quadratic/bezier/arc/ellipse/roundRect,
# fill with a colour or a linear gradient, stroke, clip to a polygon.
extends RefCounted
class_name Pen

var ci: CanvasItem
var xf := Transform2D.IDENTITY
var stack: Array = []
var subs: Array = []        # list of PackedVector2Array (in screen space)
var cur := PackedVector2Array()
var last := Vector2.ZERO
var clip_poly := PackedVector2Array()
const N := 14              # samples per curve

func _init(c: CanvasItem) -> void:
	ci = c

func save() -> void:
	stack.append([xf, clip_poly])

func restore() -> void:
	var s: Array = stack.pop_back()
	xf = s[0]
	clip_poly = s[1]

func translate(x: float, y: float) -> void:
	xf = xf * Transform2D(0, Vector2(x, y))

func rotate(a: float) -> void:
	xf = xf * Transform2D(a, Vector2.ZERO)

func scale(x: float, y: float) -> void:
	xf = xf * Transform2D(0, Vector2(x, y), 0, Vector2.ZERO)

func k() -> float:
	return sqrt(absf(xf.determinant()))

func begin() -> void:
	subs.clear()
	cur = PackedVector2Array()

func _p(x: float, y: float) -> Vector2:
	last = Vector2(x, y)
	return xf * last

func move(x: float, y: float) -> void:
	if cur.size() > 0:
		subs.append(cur)
	cur = PackedVector2Array([_p(x, y)])

func line(x: float, y: float) -> void:
	cur.append(_p(x, y))

func quad(cx: float, cy: float, x: float, y: float) -> void:
	var p0 := last
	for i in range(1, N + 1):
		var t := i / float(N)
		var u := 1.0 - t
		var q := p0 * u * u + Vector2(cx, cy) * 2 * u * t + Vector2(x, y) * t * t
		cur.append(xf * q)
	last = Vector2(x, y)

func bez(c1x: float, c1y: float, c2x: float, c2y: float, x: float, y: float) -> void:
	var p0 := last
	for i in range(1, N + 1):
		var t := i / float(N)
		var u := 1.0 - t
		var q := p0 * u * u * u + Vector2(c1x, c1y) * 3 * u * u * t + Vector2(c2x, c2y) * 3 * u * t * t + Vector2(x, y) * t * t * t
		cur.append(xf * q)
	last = Vector2(x, y)

func arc(x: float, y: float, r: float, a0: float, a1: float, ccw := false) -> void:
	var d := a1 - a0
	if ccw:
		while d > 0: d -= TAU
	else:
		while d < 0: d += TAU
	d = clampf(d, -TAU, TAU)
	var n := maxi(6, int(absf(d) / TAU * 40))
	for i in n + 1:
		var a := a0 + d * i / float(n)
		cur.append(_p(x + cos(a) * r, y + sin(a) * r))

func ellipse(x: float, y: float, rx: float, ry: float) -> void:
	move(x + rx, y)
	for i in range(1, 33):
		var a := i / 32.0 * TAU
		cur.append(_p(x + cos(a) * rx, y + sin(a) * ry))

func rrect(x: float, y: float, w: float, h: float, r: float) -> void:
	r = minf(r, minf(w, h) / 2)
	move(x + r, y)
	arc(x + w - r, y + r, r, -PI / 2, 0)
	arc(x + w - r, y + h - r, r, 0, PI / 2)
	arc(x + r, y + h - r, r, PI / 2, PI)
	arc(x + r, y + r, r, PI, PI * 1.5)

func rect(x: float, y: float, w: float, h: float) -> void:
	move(x, y)
	line(x + w, y)
	line(x + w, y + h)
	line(x, y + h)

func close() -> void:
	if cur.size() > 0:
		cur.append(cur[0])

func _all() -> Array:
	var a := subs.duplicate()
	if cur.size() > 0:
		a.append(cur)
	return a

# linear gradient in local coordinates: [x0, y0, x1, y1, [[offset, colour], ...]]
func lin(x0: float, y0: float, x1: float, y1: float, st: Array) -> Dictionary:
	return {"a": xf * Vector2(x0, y0), "b": xf * Vector2(x1, y1), "st": st}

static func _ramp(st: Array, t: float) -> Color:
	t = clampf(t, 0.0, 1.0)
	for i in range(1, st.size()):
		if t <= st[i][0]:
			var a = st[i - 1]
			var b = st[i]
			return Color(a[1]).lerp(Color(b[1]), (t - a[0]) / maxf(b[0] - a[0], 1e-5))
	return Color(st[-1][1])

func fill(paint) -> void:
	for sp in _all():
		var pts: PackedVector2Array = sp
		if pts.size() > 1 and pts[0].distance_to(pts[pts.size() - 1]) < 0.01:
			pts = pts.slice(0, pts.size() - 1)
		if pts.size() < 3:
			continue
		var polys: Array = [pts]
		if clip_poly.size() > 2:
			polys = Geometry2D.intersect_polygons(pts, clip_poly)
		for poly in polys:
			_fill_one(poly, paint)

func _fill_one(pts: PackedVector2Array, paint) -> void:
	if Geometry2D.triangulate_polygon(pts).is_empty():
		# not a simple polygon: split it into simple pieces
		var parts := Geometry2D.merge_polygons(pts, PackedVector2Array())
		if parts.size() == 1 and parts[0] == pts:
			return
		for q in parts:
			if not Geometry2D.is_polygon_clockwise(q) or parts.size() == 1:
				if not Geometry2D.triangulate_polygon(q).is_empty():
					_fill_one(q, paint)
		return
	if paint is Dictionary:
		var a: Vector2 = paint.a
		var d: Vector2 = paint.b - a
		var cols := PackedColorArray()
		for p in pts:
			cols.append(_ramp(paint.st, (p - a).dot(d) / maxf(d.length_squared(), 1e-5)))
		ci.draw_polygon(pts, cols)
	else:
		ci.draw_colored_polygon(pts, paint if paint is Color else Color(paint))

func stroke(col, w: float) -> void:
	var c: Color = col if col is Color else Color(col)
	for sp in _all():
		var pts: PackedVector2Array = sp
		if pts.size() < 2:
			continue
		ci.draw_polyline(pts, c, w * k(), true)
		# round caps
		ci.draw_circle(pts[0], w * k() / 2, c)
		ci.draw_circle(pts[pts.size() - 1], w * k() / 2, c)

func clip() -> void:
	var a := _all()
	if a.size() > 0:
		clip_poly = a[0]
