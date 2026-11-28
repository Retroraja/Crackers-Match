# A CSS box (rounded corners, colour + up to 2 gradients, border, outer/inset shadows) drawn as plain
# triangles with colours at their corners. 19 Nov speed fix: the old per-pixel shader (box.gdshader) made
# every panel cost full-screen work each frame; on his OPPO A78 one Welcome card took the title from 12 to 8 fps.
# Phones draw these triangles almost for free; the shape is rebuilt only when the box changes.
extends ColorRect
class_name CssBox

var pm := ShaderMaterial.new()   # the box's settings (same names as the old shader), not used for drawing
var _key := ""
const SEG := 6        # points per rounded corner
const RINGS := 4      # rings from the centre to the edge (for gradients)

func _init() -> void:
	color = Color(0, 0, 0, 0)

func p(k: String):
	return pm.get_shader_parameter(k)

func _process(_dt: float) -> void:
	# the few settings other code changes later (size, colour) -> redraw when they change
	var k := str(p("size")) + str(p("bgc")) + str(p("g0_type")) + str(p("g1_type")) + str(size)
	if k != _key:
		_key = k
		queue_redraw()

# rounded rectangle outline (clockwise from the top-left corner), relative to the box's top-left
func _outline(o: Vector2, s: Vector2, r: Vector4) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var rr := [r.x, r.y, r.z, r.w]
	for i in 4:
		rr[i] = clampf(rr[i], 0.0, minf(s.x, s.y) * 0.5)
	var cs := [o + Vector2(rr[0], rr[0]), o + Vector2(s.x - rr[1], rr[1]), o + Vector2(s.x - rr[2], s.y - rr[2]), o + Vector2(rr[3], s.y - rr[3])]
	var a0 := [PI, -PI / 2, 0.0, PI / 2]
	for i in 4:
		for j in SEG + 1:
			var a: float = a0[i] + PI / 2 * j / SEG
			pts.append(cs[i] + Vector2(cos(a), sin(a)) * rr[i])
	return pts

func _ramp(n: int, c: Array, ps: PackedFloat32Array, t: float) -> Color:
	if n <= 0:
		return Color(0, 0, 0, 0)
	if t <= ps[0]:
		return c[0]
	for i in range(1, n):
		if t <= ps[i]:
			var k := (t - ps[i - 1]) / maxf(ps[i] - ps[i - 1], 1e-5)
			return (c[i - 1] as Color).lerp(c[i], k)
	return c[n - 1]

func _gt(pre: String, lp: Vector2, sz: Vector2) -> float:
	var ty: int = p(pre + "type")
	if ty == 1:
		var a := deg_to_rad(float(p(pre + "ang")))
		var dir := Vector2(sin(a), -cos(a))
		var L := absf(sz.x * sin(a)) + absf(sz.y * cos(a))
		return (lp - sz * 0.5).dot(dir) / maxf(L, 1e-3) + 0.5
	var cen: Vector2 = p(pre + "cen")
	var rad: Vector2 = p(pre + "rad")
	if ty == 3:
		var d2 := lp - cen * sz
		var ang := rad_to_deg(atan2(d2.x, -d2.y))
		if ang < 0.0:
			ang += 360.0
		return fposmod(ang / maxf(rad.x, 0.01), 1.0)
	return ((lp - cen * sz) / Vector2(maxf(rad.x * sz.x, 1e-3), maxf(rad.y * sz.y, 1e-3))).length()

static func _over(top: Color, bot: Color) -> Color:
	var a := top.a + bot.a * (1.0 - top.a)
	if a < 1e-5:
		return Color(0, 0, 0, 0)
	return Color((top.r * top.a + bot.r * bot.a * (1.0 - top.a)) / a, (top.g * top.a + bot.g * bot.a * (1.0 - top.a)) / a, (top.b * top.a + bot.b * bot.a * (1.0 - top.a)) / a, a)

func _fill(lp: Vector2, sz: Vector2) -> Color:
	var f: Color = p("bgc")
	for pre in ["g1_", "g0_"]:
		if int(p(pre + "type")) > 0:
			var n: int = p(pre + "n")
			f = _over(_ramp(n, p(pre + "c"), p(pre + "p"), _gt(pre, lp, sz)), f)
	return f

# every triangle goes into ONE list, sent to the GPU in one call
var _P := PackedVector2Array()
var _C := PackedColorArray()
var _I := PackedInt32Array()
func _v(pt: Vector2, c: Color) -> int:
	_P.append(pt)
	_C.append(c)
	return _P.size() - 1

# a ring between two outlines (same point count), colours per point
func _ring(a: PackedVector2Array, b: PackedVector2Array, ca: PackedColorArray, cb: PackedColorArray) -> void:
	var n := a.size()
	var ia := PackedInt32Array()
	var ib := PackedInt32Array()
	for i in n:
		ia.append(_v(a[i], ca[i]))
		ib.append(_v(b[i], cb[i]))
	for i in n:
		var j := (i + 1) % n
		_I.append_array([ia[i], ia[j], ib[j], ia[i], ib[j], ib[i]])

func _fan(ctr: Vector2, cc: Color, ring: PackedVector2Array, cr: PackedColorArray) -> void:
	var c0 := _v(ctr, cc)
	var ir := PackedInt32Array()
	for i in ring.size():
		ir.append(_v(ring[i], cr[i]))
	for i in ring.size():
		_I.append_array([c0, ir[i], ir[(i + 1) % ring.size()]])

func _solid(poly: PackedVector2Array, c: Color) -> void:
	var cr := PackedColorArray()
	cr.resize(poly.size())
	cr.fill(c)
	var ctr := Vector2.ZERO
	for q in poly:
		ctr += q
	_fan(ctr / poly.size(), c, poly, cr)

func _draw() -> void:
	_P = PackedVector2Array()
	_C = PackedColorArray()
	_I = PackedInt32Array()
	var sz: Vector2 = p("size")
	var m: float = p("margin")
	var R: Vector4 = p("radius")
	var o := Vector2(m, m)
	var shn: int = p("sh_n")
	var sg: Array = p("sh_g")
	var sc: Array = p("sh_c")
	var si: PackedFloat32Array = p("sh_in")
	# outer shadows: a solid core plus a soft ring that fades out (blur)
	for i in range(mini(shn, 4) - 1, -1, -1):
		if si[i] > 0.5:
			continue
		var g: Vector4 = sg[i]
		var c: Color = sc[i]
		if c.a <= 0.0:
			continue
		var so := o + Vector2(g.x, g.y) - Vector2(g.w, g.w)
		var ss := sz + Vector2(g.w, g.w) * 2.0
		var sr := R + Vector4(g.w, g.w, g.w, g.w)
		var hb := g.z * 0.5
		var inner := _outline(so + Vector2(hb, hb), ss - Vector2(hb, hb) * 2.0, sr - Vector4(hb, hb, hb, hb))
		var outer := _outline(so - Vector2(hb, hb), ss + Vector2(hb, hb) * 2.0, sr + Vector4(hb, hb, hb, hb))
		var cin := c
		if g.z > 0.0:
			var c0 := Color(c.r, c.g, c.b, 0.0)
			var ci := PackedColorArray()
			var co := PackedColorArray()
			ci.resize(inner.size())
			co.resize(outer.size())
			ci.fill(cin)
			co.fill(c0)
			_ring(outer, inner, co, ci)
			_solid(inner, cin)
		else:
			_solid(_outline(so, ss, sr), cin)
	# the box: rings from the centre to the edge so gradients follow
	var edge := _outline(o, sz, R)
	var ctr := o + sz * 0.5
	var rings: Array = [PackedVector2Array([ctr])]
	for k in range(1, RINGS + 1):
		var t := float(k) / RINGS
		var ring := PackedVector2Array()
		for q in edge:
			ring.append(ctr + (q - ctr) * t)
		rings.append(ring)
	var cols: Array = []
	for ring in rings:
		var cc := PackedColorArray()
		for q in ring:
			cc.append(_fill(q - o, sz))
		cols.append(cc)
	# inset shadows: darken from the edge inwards (approximate, colour per point)
	for i in mini(shn, 4):
		if si[i] < 0.5:
			continue
		var g: Vector4 = sg[i]
		var c: Color = sc[i]
		for k in range(1, rings.size()):
			for q in (rings[k] as PackedVector2Array).size():
				var pt: Vector2 = rings[k][q] - Vector2(g.x, g.y)
				var dx := minf(pt.x - o.x, o.x + sz.x - pt.x) - g.w
				var dy := minf(pt.y - o.y, o.y + sz.y - pt.y) - g.w
				var d := minf(dx, dy)
				var s := 1.0 - clampf(d / maxf(g.z, 1.0), 0.0, 1.0) if g.z > 0.0 else (1.0 if d <= 0.5 else 0.0)
				var cc: PackedColorArray = cols[k]
				cc[q] = _over(Color(c.r, c.g, c.b, c.a * s), cc[q])
				cols[k] = cc
	_fan(ctr, (cols[0] as PackedColorArray)[0], rings[1], cols[1])
	for k in range(1, rings.size() - 1):
		_ring(rings[k], rings[k + 1], cols[k], cols[k + 1])
	# border
	var bwv: Vector4 = p("bw")
	var b := maxf(maxf(bwv.x, bwv.y), maxf(bwv.z, bwv.w))
	var bc: Color = p("bcol")
	if b > 0.0 and bc.a > 0.0:
		var inn := _outline(o + Vector2(b, b), sz - Vector2(b, b) * 2.0, Vector4(maxf(R.x - b, 0), maxf(R.y - b, 0), maxf(R.z - b, 0), maxf(R.w - b, 0)))
		var ca := PackedColorArray()
		ca.resize(edge.size())
		ca.fill(bc)
		_ring(edge, inn, ca, ca)
	if not _I.is_empty():
		RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), _I, _P, _C)
	# soft (anti-aliased) outer edge, one line
	var el := PackedColorArray()
	if b > 0.0 and bc.a > 0.0:
		el.resize(edge.size())
		el.fill(bc)
	else:
		el = PackedColorArray(cols[cols.size() - 1])
	edge.append(edge[0])
	el.append(el[0])
	draw_polyline_colors(edge, el, 1.0, true)
