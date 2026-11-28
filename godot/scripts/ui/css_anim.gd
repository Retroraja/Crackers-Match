# Plays the web game's CSS @keyframes animations (ui/anims.json) on Controls:
# translate, scale, rotate and opacity, with the same durations, delays, easing curves and repeats.
extends Node

var KF := {}
var live: Array = []

func _ready() -> void:
	KF = JSON.parse_string(FileAccess.get_file_as_string("res://ui/anims.json"))
	process_mode = Node.PROCESS_MODE_ALWAYS

# cubic-bezier easing like CSS
static func bez(t: float, x1: float, y1: float, x2: float, y2: float) -> float:
	var lo := 0.0
	var hi := 1.0
	var u := t
	for i in 18:
		u = (lo + hi) / 2.0
		var x := 3.0 * x1 * u * (1 - u) * (1 - u) + 3.0 * x2 * u * u * (1 - u) + u * u * u
		if x < t: lo = u
		else: hi = u
	return 3.0 * y1 * u * (1 - u) * (1 - u) + 3.0 * y2 * u * u * (1 - u) + u * u * u

static func ease_fn(e: String) -> Array:
	e = e.strip_edges()
	match e:
		"linear": return [0.0, 0.0, 1.0, 1.0]
		"ease": return [0.25, 0.1, 0.25, 1.0]
		"ease-in": return [0.42, 0.0, 1.0, 1.0]
		"ease-out": return [0.0, 0.0, 0.58, 1.0]
		"ease-in-out": return [0.42, 0.0, 0.58, 1.0]
	if e.begins_with("cubic-bezier("):
		var p := e.substr(13).trim_suffix(")").split(",")
		return [float(p[0]), float(p[1]), float(p[2]), float(p[3])]
	return [0.25, 0.1, 0.25, 1.0]

# play `name` on control c. iters < 0 = forever. vars: {"sx":..,"sy":..,"sr":..} for scatter-type animations.
func play(c: CanvasItem, name: String, dur: float, delay := 0.0, easing := "ease", iters := 1, fill_both := true, vars := {}, alternate := false) -> void:
	if c == null or not KF.has(name):
		return
	stop(c)
	if c is Control:
		var cc := c as Control
		if not cc.has_meta("base"):
			# an element captured mid-animation at opacity 0 is really fully visible when it rests
			var a0 := cc.modulate.a
			if a0 < 0.01 and _has_op(name):
				a0 = 1.0
			var s0 := cc.scale
			if absf(s0.x) < 0.01 or absf(s0.y) < 0.01:
				s0 = Vector2.ONE
			cc.set_meta("base", [cc.position, s0, cc.rotation, a0])
		if cc.pivot_offset == Vector2.ZERO:
			cc.pivot_offset = cc.size / 2.0
	var a := {"c": c, "k": name, "d": maxf(dur, 0.001), "dl": delay, "e": ease_fn(easing), "n": iters, "t": 0.0, "fill": fill_both, "vars": vars, "alt": alternate}
	live.append(a)
	if fill_both and delay > 0.0:
		_apply(a, 0.0)

func _has_op(name: String) -> bool:
	for fr in KF[name]:
		if fr[1].has("op"):
			return true
	return false

func stop(c: CanvasItem, reset := false) -> void:
	for a in live.duplicate():
		if a.c == c:
			live.erase(a)
	if reset and c is Control and c.has_meta("base"):
		var b: Array = c.get_meta("base")
		c.position = b[0]
		c.scale = b[1]
		c.rotation = b[2]
		c.modulate.a = b[3]

func _process(dt: float) -> void:
	var _t0 := Time.get_ticks_usec()
	_process_a(dt)
	CMGame.perf_add("css_anim", Time.get_ticks_usec() - _t0)

func _process_a(dt: float) -> void:
	if live.is_empty():
		return
	for a in live.duplicate():
		if not is_instance_valid(a.c):
			live.erase(a)
			continue
		a.t += dt
		var t: float = a.t - a.dl
		if t < 0.0:
			continue
		var k: float = t / a.d
		var it := int(floor(k))
		if a.n >= 0 and it >= a.n:
			_apply(a, 1.0 if not (a.alt and a.n % 2 == 0) else 0.0)
			live.erase(a)
			if not a.fill:
				stop(a.c, true)
			continue
		var f := k - it
		if a.alt and it % 2 == 1:
			f = 1.0 - f
		_apply(a, f)

func _val(frames: Array, prop: String, f: float, base: float, e: Array) -> float:
	var pts: Array = []
	for fr in frames:
		if fr[1].has(prop) and not (fr[1][prop] is Array):
			pts.append([fr[0], float(fr[1][prop])])
	if pts.is_empty():
		return base
	if pts[0][0] > 0.0:
		pts.push_front([0.0, base])
	if pts[-1][0] < 1.0:
		pts.append([1.0, base])
	for i in range(1, pts.size()):
		if f <= pts[i][0]:
			var a = pts[i - 1]
			var b = pts[i]
			var u: float = (f - a[0]) / maxf(b[0] - a[0], 1e-5)
			u = bez(u, e[0], e[1], e[2], e[3])
			return lerpf(a[1], b[1], u)
	return pts[-1][1]

func _apply(a: Dictionary, f: float) -> void:
	var c: CanvasItem = a.c
	var fr: Array = KF[a.k]
	var e: Array = a.e
	var v: Dictionary = a.vars
	if c is Control:
		var b: Array = c.get_meta("base")
		var tx := _val(fr, "tx", f, 0.0, e)
		var ty := _val(fr, "ty", f, 0.0, e)
		if v.has("sx"):
			# translate: var(--sx) var(--sy) at the end
			var q := _val(fr, "op", f, 1.0, e)
			var u := 1.0 - q
			tx += v.sx * u
			ty += v.sy * u
		c.position = b[0] + Vector2(tx, ty)
		c.scale = b[1] * Vector2(_val(fr, "sx", f, 1.0, e), _val(fr, "sy", f, 1.0, e))
		var rot := _val(fr, "rot", f, 0.0, e)
		if v.has("sr"):
			rot += v.sr * (1.0 - _val(fr, "op", f, 1.0, e))
		c.rotation = b[2] + deg_to_rad(rot)
		c.modulate.a = b[3] * _val(fr, "op", f, 1.0, e)
	else:
		c.modulate.a = _val(fr, "op", f, 1.0, e)
