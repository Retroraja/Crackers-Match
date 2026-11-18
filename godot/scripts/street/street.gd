# The 3D village street (street/index.html): Sunset Village, Area 1, 10 build tasks paid with diyas.
# The layout (which kit piece goes where, the trees, the stones) was exported from the web page into street/layout.json;
# this script rebuilds it from the kit meshes (street/kit) and plays the same build animations and camera moves.
extends Node3D
class_name Street

signal changed          # diyas / step / busy changed: the home screen redraws
signal task_done(last: bool)
signal area_won
signal sfx(name: String)

var L: Dictionary
var N := {}             # layout id -> Node3D
var cam: Camera3D
var env: Environment
var sun: DirectionalLight3D
var fx: StreetFx
var water_mat: StandardMaterial3D
var stones: MultiMesh
var STD: Array
var TASKS: Array = []
var VW: Array = []
var LAMP_GL := {}
var EM: Array = []
var TW: Array = []
var clock := 0.0
var SPEED := 1.0
var diyas := 0
var step := 0
var busy := false
var auto := false
var won := false
var FAST := false
var FN := 0
var FT := 0
var SHOW := false
var fwT := 0.0
var camP := Vector3(0, 34, 74)
var camL := Vector3(0, 0, -2)
var CAMID := 0
var expo := 1.0
var _tint_cache := {}
var lite := false
var area := 1
var shop: ShopArea

static func V(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])

static func M(e: Array) -> Transform3D:
	return Transform3D(Basis(Vector3(e[0], e[1], e[2]), Vector3(e[4], e[5], e[6]), Vector3(e[8], e[9], e[10])), Vector3(e[12], e[13], e[14]))

static func back(t: float) -> float:
	var c := 1.6
	return 1 + (c + 1) * pow(t - 1, 3) + c * pow(t - 1, 2)

static func sm(t: float) -> float:
	return t * t * (3 - 2 * t)

func rnd(a: float, b: float) -> float:
	return a + randf() * (b - a)

# ---------------------------------------------------------------- tweens on the game clock
func tween(d: float, fn: Callable, delay := 0.0) -> void:
	TW.append({"t": -delay, "d": maxf(d, 1e-4), "fn": fn})

func after(s: float, fn: Callable) -> void:
	tween(1e-4, func(k: float):
		if k >= 1:
			fn.call(), s)

func _s0(o: Node3D) -> float:
	if not o.has_meta("s0"):
		o.set_meta("s0", o.scale.x)
	return o.get_meta("s0")

func pop(o: Node3D, delay: float, d := 0.45) -> void:
	var s := _s0(o)
	o.visible = false
	tween(d, func(k: float):
		o.visible = true
		o.scale = Vector3.ONE * maxf(0.001, back(k)) * s, delay)

func grow(o: Node3D, delay: float, d := 0.7) -> void:
	var s := _s0(o)
	o.visible = false
	tween(d, func(k: float):
		o.visible = true
		o.scale = Vector3(maxf(0.001, back(k)) * s, maxf(0.001, back(minf(1, k * 1.2))) * s, maxf(0.001, back(k)) * s), delay)

func drop_in(o: Node3D, delay: float, h := 4.0) -> void:
	if not o.has_meta("y0"):
		o.set_meta("y0", o.position.y)
	var y0: float = o.get_meta("y0")
	var s := _s0(o)
	o.visible = false
	tween(0.5, func(k: float):
		o.visible = true
		o.position.y = y0 + (1 - k) * (1 - k) * h
		o.scale = Vector3.ONE * maxf(0.01, back(k)) * s, delay)

func sink_away(o: Node3D, delay: float) -> void:
	var y0 := o.position.y
	var s := o.scale.x
	tween(0.5, func(k: float):
		o.position.y = y0 - k * 0.5
		o.scale = Vector3.ONE * maxf(0.001, s * (1 - k))
		if k >= 1:
			o.visible = false, delay)

# ---------------------------------------------------------------- effects
func dust(c: Vector3, n: int, sp: float) -> void:
	for i in n:
		fx.part(true, Vector3(c.x + rnd(-sp, sp), 0.4, c.z + rnd(-sp, sp)), {"s0": rnd(1, 2), "s1": rnd(2.5, 3.5), "col": Color("#e8d8c0"), "op": 0.5, "v": Vector3(rnd(-1, 1), rnd(0.5, 1.2), rnd(-1, 1)), "d": rnd(0.8, 1.3)})

func sparkle(c: Vector3, n: int, y := 3.0) -> void:
	for i in n:
		var a := rnd(0, 6.28)
		fx.part(false, Vector3(c.x, y, c.z), {"s0": 0.6, "s1": 0.2, "col": Color("#ffe27a"), "add": true, "v": Vector3(cos(a) * rnd(2, 6), rnd(3, 8), sin(a) * rnd(2, 6)), "g": 10.0, "d": rnd(0.8, 1.3)})

func ring(c: Vector3, col := Color("#fff2c0"), y := 0.12) -> void:
	var m := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.5
	tm.outer_radius = 0.65
	tm.rings = 48
	tm.ring_segments = 3
	m.mesh = tm
	m.scale = Vector3(1, 0.02, 1)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = col
	mat.no_depth_test = false
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.position = Vector3(c.x, y, c.z)
	add_child(m)
	tween(0.7, func(k: float):
		var s := 1 + k * 6
		m.scale = Vector3(s, 0.02, s)
		mat.albedo_color.a = 1 - k
		if k >= 1:
			m.queue_free())

func firework() -> void:
	var x := rnd(-12, 12)
	var y := rnd(15, 24)
	var z := rnd(-78, -62)
	var col: Color = [Color("#ff4d6d"), Color("#ffd24a"), Color("#3ad06a"), Color("#4aa3ff"), Color("#c86bff"), Color.WHITE][randi() % 6]
	var n := 90 if lite else 170
	for i in n:
		var a := rnd(0, 6.28)
		var b := acos(rnd(-1, 1))
		var sp := rnd(6, 9) * 0.95 * 60.0 * 0.016 * 1.6
		fx.part(false, Vector3(x, y, z), {"s0": 1.1, "s1": 0.9, "col": col, "add": true, "v": Vector3(sin(b) * cos(a), cos(b), sin(b) * sin(a)) * sp, "g": 1.0, "d": 2.2})

# ---------------------------------------------------------------- build the world
func _ready() -> void:
	L = JSON.parse_string(FileAccess.get_file_as_string("res://street/layout.json"))
	STD = L.STD
	for v in L.VW:
		VW.append({"p": V(v[0]), "look": V(v[1])})
	TASKS = L.tasks
	fx = StreetFx.new()
	add_child(fx)
	_world()
	_nodes()
	_inst()
	set_stones(-9.0)

func _world() -> void:
	cam = Camera3D.new()
	cam.fov = 52
	cam.near = 0.3
	cam.far = 400
	add_child(cam)
	cam.current = true
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#9aa2e0")
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.0
	env.tonemap_white = 3.0
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_DEPTH
	env.fog_light_color = Color("#f7b486")
	env.fog_depth_begin = 70
	env.fog_depth_end = 190
	env.fog_depth_curve = 1.0
	env.fog_density = 1.0
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.light_color = Color("#ffb070")
	sun.light_energy = 1.3
	sun.shadow_enabled = not lite
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 70
	sun.shadow_bias = 0.05
	add_child(sun)
	sun.look_at_from_position(Vector3(-26, 30, 20), Vector3.ZERO, Vector3.UP)
	# ground with the painted grass and path, a big outer grass plane, and the stream
	var gm := StandardMaterial3D.new()
	gm.albedo_texture = load("res://street/art/ground.webp")
	gm.roughness = 1.0
	var g := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(120, 200)
	g.mesh = pm
	g.material_override = gm
	g.position = Vector3(0, 0, -25)
	add_child(g)
	var om := StandardMaterial3D.new()
	om.albedo_color = Color("#5aa843")
	om.roughness = 1.0
	var o := MeshInstance3D.new()
	var opm := PlaneMesh.new()
	opm.size = Vector2(600, 600)
	o.mesh = opm
	o.material_override = om
	o.position = Vector3(0, -0.03, 0)
	add_child(o)
	water_mat = StandardMaterial3D.new()
	water_mat.albedo_texture = load("res://street/art/water.png")
	water_mat.uv1_scale = Vector3(30, 1, 1)
	water_mat.roughness = 0.12
	water_mat.metallic = 0.25
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.albedo_color = Color(1, 1, 1, 0.93)
	water_mat.emission_enabled = true
	water_mat.emission = Color("#0a2236")
	var w := MeshInstance3D.new()
	var wpm := PlaneMesh.new()
	wpm.size = Vector2(120, 4.2)
	w.mesh = wpm
	w.material_override = water_mat
	w.position = Vector3(0, 0.05, L.SZ)
	w.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(w)

func _tinted(base: Material, hex: String) -> Material:
	var key := "%s|%s" % [base.resource_path, hex]
	if not _tint_cache.has(key):
		var m: StandardMaterial3D = base.duplicate()
		m.albedo_color = Color(hex)
		_tint_cache[key] = m
	return _tint_cache[key]

func piece(n: String) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = load("res://street/kit/%s.res" % n)
	mi.name = n
	return mi

func _nodes() -> void:
	var boards := {}
	for n in L.nodes:
		var par: Node3D = self if int(n.p) < 0 else N.get(int(n.p))
		if par == null:
			continue
		var o: Node3D
		if n.has("piece") or (n.has("group") and ResourceLoader.exists("res://street/kit/%s.res" % n.group) and n.group != ""):
			var nm: String = n.piece if n.has("piece") else n.group
			var mi := piece(nm)
			if n.has("tint"):
				for si in n.tint:
					var base := mi.mesh.surface_get_material(int(si))
					mi.set_surface_override_material(int(si), _tinted(base, n.tint[si]))
			if nm == "MI_WindowGlass":
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			o = mi
		elif n.has("plane"):
			if int(n.p) < 0:
				continue   # the outer ground plane: made in _world
			var q := QuadMesh.new()
			q.size = Vector2(n.plane[0], n.plane[1])
			var mi2 := MeshInstance3D.new()
			mi2.mesh = q
			var m := StandardMaterial3D.new()
			if n.has("tex"):
				m.albedo_texture = load("res://street/art/board%d.png" % int(n.tex))
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				m.alpha_scissor_threshold = 0.3
				m.roughness = 0.6
			mi2.material_override = m
			o = mi2
		elif n.has("other"):
			continue
		else:
			o = Node3D.new()
		o.transform = M(n.m)
		o.visible = n.v
		par.add_child(o)
		N[int(n.id)] = o
	# lamp glow (a sprite inside each post lantern)
	for id in L.lists.LAMPS:
		var l: Node3D = N[int(id)]
		var gl := MeshInstance3D.new()
		var q := QuadMesh.new()
		gl.mesh = q
		gl.material_override = StreetFx.sprite_material(StreetFx.GLOW, true)
		gl.material_override.render_priority = 1
		gl.position = Vector3(0.1, 2.15, 0)
		gl.scale = Vector3.ONE * 0.01
		gl.visible = false
		gl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		l.add_child(gl)
		LAMP_GL[int(id)] = gl

func _inst() -> void:
	var done := {}
	for it in L.inst:
		var key: String = "%s|%s" % [it.piece, str(it.list[0])]
		if done.has(key):
			continue
		done[key] = true
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = load("res://street/kit/%s.res" % it.piece)
		mm.instance_count = it.list.size()
		for i in it.list.size():
			mm.set_instance_transform(i, M(it.list[i]))
		var mi := MultiMeshInstance3D.new()
		mi.multimesh = mm
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if (it.cast and not lite) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
		if it.stones:
			stones = mm

func set_stones(t: float) -> void:
	if stones == null:
		return
	for i in STD.size():
		var q: Dictionary = STD[i]
		var e: float = clampf((t - q.d) / 0.5, 0.0, 1.0)
		var s := maxf(0.0001, back(e))
		stones.set_instance_transform(i, Transform3D(Basis(Vector3.UP, q.a).scaled(Vector3(s, s, s)), Vector3(q.x, 0.02 + (1 - e) * (1 - e) * 1.2, q.z)))

func ids(a: Array) -> Array:
	var r: Array = []
	for i in a:
		if N.has(int(i)):
			r.append(N[int(i)])
	return r

# ---------------------------------------------------------------- the 10 tasks (same order as the web)
func build_house(H: Dictionary) -> float:
	var g: Node3D = N[int(H.g)]
	var c := g.global_position
	sink_away(N[int(H.pile)], 0)
	after(0.1, func(): dust(c, 22, 3))
	var d := 0.15
	for st in H.steps:
		var j := 0
		for o in ids(st):
			drop_in(o, d + j * 0.04, 4)
			j += 1
		d += 0.15 + st.size() * 0.04
	after(d + 0.1, func():
		sparkle(c, 40, 4)
		ring(c))
	var X := ids(H.X)
	for i in X.size():
		pop(X[i], d + 0.4 + i * 0.12, 0.45)
	return d + 0.4 + X.size() * 0.12 + 0.5

func smoke_from(id: int) -> void:
	var p: Vector3 = N[id].global_position + Vector3(0, 1.6, 0)
	EM.append({"k": "smoke", "p": p, "r": 3.0, "a": 0.0})

# Area 2: the shop. The street stays loaded but hidden; tasks, camera views and builds come from ShopArea.
func set_area(a: int) -> void:
	if a == area or a != 2:
		return
	area = 2
	if shop == null:
		shop = ShopArea.new()
		shop.st = self
		add_child(shop)
		shop.build()
	for c in get_children():
		if c == cam or c == fx or c == sun or c == shop or c is WorldEnvironment:
			continue
		if c is Node3D:
			(c as Node3D).visible = false
	fx.clear()
	EM.clear()
	SHOW = false
	won = false
	busy = false
	step = 0
	# indoors: crisper edges (2x MSAA), warm ambient light, no distance fog
	# (MSAA left off: with it, code-made boxes vanished in tests)
	env.fog_enabled = false
	env.ambient_light_color = Color("#ffe2c4")
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 1.0
	sun.light_color = Color("#ffc690")
	sun.light_energy = 1.45
	sun.rotation = Vector3(deg_to_rad(-38), deg_to_rad(-40), 0)
	TASKS = ShopArea.TASKS.duplicate(true)
	VW = shop.VW
	cam_home(true)

func run_task(name: String) -> void:
	if area == 2:
		shop.run(name)
		return
	var LS: Dictionary = L.lists
	match name:
		"Light the Street Lamps":
			var lamps := ids(LS.LAMPS)
			for i in lamps.size():
				var l: Node3D = lamps[i]
				var d := 0.2 + i * 0.22
				l.scale = Vector3(1, 0.001, 1)
				tween(0.5, func(k: float):
					l.visible = true
					l.scale.y = maxf(0.001, back(k)), d)
				after(d, func(): dust(l.position, 4, 0.5))
				var gl: Node3D = LAMP_GL[int(LS.LAMPS[i])]
				tween(0.5, func(k: float):
					gl.visible = true
					gl.scale = Vector3.ONE * (0.01 + k * 2.4), d + 0.45)
			tween(1.5, func(k: float): expo = 1 + k * 0.04, 1)
		"Lay the Stone Path":
			var T1 := 0.0
			for q in STD:
				T1 = maxf(T1, q.d)
			T1 += 0.6
			tween(T1, func(k: float): set_stones(k * T1))
			after(0.4, func(): dust(Vector3(0, 0, 46), 8, 2))
		"Build the Bakery":
			var t := build_house(LS.BAK)
			after(t, func(): smoke_from(int(LS.BAK.chim)))
		"Plant Trees Along the Road":
			for e in LS.GARD:
				var o: Node3D = N[int(e[0])]
				var d: float = 0.3 + float(e[1]) * 3.4
				grow(o, d, 0.7)
				if randf() < 0.35:
					after(d, func(): sparkle(o.position, 6, 2))
		"Build the Coffee Stall":
			var site := V(L.SITE.cof)
			after(0.1, func(): dust(site, 16, 3))
			var X := ids(LS.COF.X)
			for i in X.size():
				drop_in(X[i], 0.2 + i * 0.12, 3)
			after(0.4 + X.size() * 0.12, func():
				sparkle(site, 40, 3.5)
				ring(site)
				EM.append({"k": "steam", "p": X[3].global_position + Vector3(0, 0.3, 0), "r": 2.5, "a": 0.0}))
		"Plant the Vegetable Farm":
			var site := V(L.SITE.farm)
			after(0.1, func(): dust(site, 14, 3.5))
			var i := 0
			for e in LS.FARM:
				var o: Node3D = N[int(e[0])]
				var nm: String = e[1]
				if nm.contains("Fence") or nm.contains("Wagon"):
					drop_in(o, 0.2 + i * 0.06, 2)
				else:
					grow(o, 0.6 + i * 0.06, 0.5)
				i += 1
			after(2.8, func(): sparkle(site, 30, 2))
		"Build the Bridge":
			var c := Vector3(L.BX, 0, L.SZ)
			var bank := ids(LS.BANK)
			for i in bank.size():
				grow(bank[i], 0.2 + i * 0.08, 0.5)
			var br := ids(LS.BR)
			for i in br.size():
				drop_in(br[i], 1.0 + i * 0.1, 2.5)
			after(1.1, func(): dust(c, 10, 2))
			after(3.4, func():
				sparkle(c, 30, 2)
				ring(c, Color("#bfeaff"), 0.4))
		"Open the Crackers Shop":
			build_house(LS.SMITH)
		"Open the Market":
			var X := ids(LS.MKT)
			for i in X.size():
				drop_in(X[i], 0.2 + i * 0.14, 2.5)
			after(0.3, func():
				dust(V(L.SITE.mkt), 12, 3)
				dust(V(L.SITE.cart), 6, 1.5))
			after(2.4, func(): sparkle(V(L.SITE.mkt), 30, 3))
		"Build the Crackers Factory":
			var t := build_house(LS.CRK)
			after(t, func(): smoke_from(int(LS.CRK.chim)))
			var E := ids(LS.ENDX)
			for i in E.size():
				if E[i].name.contains("Border"):
					drop_in(E[i], 0.2 + i * 0.08, 1.5)
				else:
					grow(E[i], t * 0.6 + i * 0.1, 0.5)
			after(t + 0.6, func(): SHOW = true)

func task_len(T: Dictionary) -> float:
	var sh: Dictionary = L.shots[T.shot]
	return (float(T.dur) if float(T.dur) > 0 else float(sh.d) - 0.6) + 0.8

# ---------------------------------------------------------------- doing tasks
func can_do() -> int:
	var n := 0
	var d := diyas
	for i in range(step, TASKS.size()):
		if d < int(TASKS[i].c):
			break
		d -= int(TASKS[i].c)
		n += 1
	return n

func do_task(all: bool) -> void:
	if busy or won or can_do() == 0:
		return
	busy = true
	auto = all
	changed.emit()
	run_next()

func build_all() -> void:
	var n := can_do()
	if n < 1:
		return
	FAST = true
	FN = 0
	FT = n
	do_task(true)

# story: a golden "dream" outline of the Crackers Factory (rim-lit, additive), before it is built
var _ghost: Array = []
var _ghost_mat: ShaderMaterial
var _ghost_tw: Tween
func ghost(on: bool, scan := false) -> void:
	if not on:
		if _ghost_tw:
			_ghost_tw.kill()
		for d in _ghost:
			if is_instance_valid(d):
				d.queue_free()
		_ghost.clear()
		return
	if not _ghost.is_empty():
		return
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back, fog_disabled;
uniform float a = 0.0;
uniform float h = 100.0;
uniform vec4 col : source_color = vec4(1.0, 0.76, 0.32, 1.0);
varying float wy;
void vertex() {
	wy = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}
void fragment() {
	float f = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.2);
	float shown = 1.0 - smoothstep(h - 0.05, h, wy);
	float band = exp(-abs(wy - h) * 3.0) * step(wy, h + 0.4);
	ALBEDO = mix(col.rgb, vec3(1.0, 0.95, 0.8), band);
	ALPHA = a * ((0.07 + f * 0.85) * shown + band * 0.9);
}
"""
	_ghost_mat = ShaderMaterial.new()
	_ghost_mat.shader = sh
	var LS: Dictionary = L.lists
	var src: Array = []
	for st in LS.CRK.steps:
		src += ids(st)
	src += ids(LS.CRK.X)
	for o in src:
		var d: Node3D = o.duplicate()
		o.get_parent().add_child(d)
		d.transform = o.transform
		if o.has_meta("y0"):
			d.position.y = o.get_meta("y0")
		if o.has_meta("s0"):
			d.scale = Vector3.ONE * float(o.get_meta("s0"))
		d.visible = true
		var ms: Array = d.find_children("*", "MeshInstance3D", true, false)
		if d is MeshInstance3D:
			ms.append(d)
		for m in ms:
			m.material_override = _ghost_mat
			m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_ghost.append(d)
	sparkle(V(L.SITE.crk) + Vector3(0, 3, 0), 40, 5)
	_ghost_tw = create_tween()
	if scan:
		# v2: traced from the ground up like a blueprint coming alive
		_ghost_mat.set_shader_parameter("a", 1.0)
		_ghost_tw.tween_method(func(v: float): _ghost_mat.set_shader_parameter("h", v), -0.5, 14.0, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_ghost_tw.tween_callback(func(): sparkle(V(L.SITE.crk) + Vector3(0, 6, 0), 50, 6))
		return
	# v1 (chosen): fades in, then gently breathes
	_ghost_tw.tween_method(func(v: float): _ghost_mat.set_shader_parameter("a", v), 0.0, 1.0, 1.4)
	_ghost_tw.tween_method(func(v: float): _ghost_mat.set_shader_parameter("a", v), 1.0, 0.65, 1.0).set_trans(Tween.TRANS_SINE)
	_ghost_tw.tween_method(func(v: float): _ghost_mat.set_shader_parameter("a", v), 0.65, 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	_ghost_tw.tween_method(func(v: float): _ghost_mat.set_shader_parameter("a", v), 1.0, 0.65, 1.0).set_trans(Tween.TRANS_SINE)
	_ghost_tw.tween_method(func(v: float): _ghost_mat.set_shader_parameter("a", v), 0.65, 1.0, 1.0).set_trans(Tween.TRANS_SINE)

# story: night (k 0..1) and a row of diyas lighting up along the path
var _night0 := {}
var sky_node: CanvasItem
func night(k: float) -> void:
	if _night0.is_empty():
		_night0 = {"se": sun.light_energy, "sc": sun.light_color, "ac": env.ambient_light_color, "ae": env.ambient_light_energy, "fc": env.fog_light_color, "ex": env.tonemap_exposure}
	sun.light_energy = lerpf(_night0.se, 0.32, k)
	sun.light_color = (_night0.sc as Color).lerp(Color("#8fa0ff"), k)
	env.ambient_light_color = (_night0.ac as Color).lerp(Color("#5464b0"), k)
	env.ambient_light_energy = lerpf(_night0.ae, 0.62, k)
	env.fog_light_color = (_night0.fc as Color).lerp(Color("#232a52"), k)
	env.tonemap_exposure = lerpf(_night0.ex, 1.1, k)
	if water_mat:
		water_mat.emission = Color("#0a2236").lerp(Color("#03070f"), k)
	if sky_node:
		sky_node.modulate = Color.WHITE.lerp(Color(0.22, 0.24, 0.48), k)
	env.glow_enabled = k > 0.01
	env.glow_intensity = 1.1
	env.glow_bloom = 0.15
	env.glow_hdr_threshold = 0.9

var _diyas: Array = []
func story_diyas(dur: float, on_each: Callable) -> void:
	var pts: Array = STD.duplicate()
	pts.sort_custom(func(a, b): return a.d < b.d)
	var n := 0
	var last := Vector3(1e9, 0, 0)
	var picks: Array = []
	for i in pts.size():
		var q: Dictionary = pts[i]
		var p := Vector3(q.x, 0.15, q.z)
		if p.distance_to(last) < 5.5 or q.z < -50 or q.z > 58:
			continue
		last = p
		var side := 1.0 if n % 2 == 0 else -1.0
		var nx: Dictionary = pts[mini(i + 3, pts.size() - 1)]
		var dir := Vector3(nx.x - q.x, 0, nx.z - q.z).normalized()
		var perp := Vector3(-dir.z, 0, dir.x) * side * 2.1
		picks.append(p + perp)
		n += 1
	picks.sort_custom(func(a, b): return a.z > b.z)
	for i in picks.size():
		var at: Vector3 = picks[i]
		after(i * dur / maxf(1, picks.size()), func():
			fx.part(false, at + Vector3(0, 0.35, 0), {"s0": 0.2, "s1": 2.6, "col": Color(1, 0.66, 0.26), "op": 0.9, "d": 999.0, "add": true, "in": 0.5, "fl": 9.0})
			fx.part(false, at + Vector3(0, 0.35, 0), {"s0": 0.05, "s1": 0.7, "col": Color(1, 0.95, 0.75), "op": 1.0, "d": 999.0, "add": true, "in": 0.35, "fl": 13.0})
			sparkle(at, 6, 0.6)
			on_each.call())

func story_clear() -> void:
	fx.clear()
	night(0.0)

func glide_to(v: Dictionary) -> float:
	CAMID += 1
	var id := CAMID
	var p0 := camP
	var l0 := camL
	var dist := p0.distance_to(v.p)
	var d := clampf(dist / 18.0, 0.7, 1.6)
	var lift := 0.0 if p0.y > 20 else minf(6.0, dist * 0.25)
	tween(d, func(k: float):
		if id != CAMID:
			return
		var e := sm(k)
		camP = p0.lerp(v.p, e)
		camP.y += sin(e * PI) * lift
		camL = l0.lerp(v.look, e))
	return d

func hold_shot(v: Dictionary, d: float) -> void:
	CAMID += 1
	var id := CAMID
	var p0 := camP
	var p1 := p0.lerp(v.look, 0.05)
	tween(d, func(k: float):
		if id != CAMID:
			return
		camP = p0.lerp(p1, sm(k))
		camL = v.look)

func cam_to(p: Vector3, l: Vector3, d: float) -> void:
	CAMID += 1
	var id := CAMID
	var p0 := camP
	var l0 := camL
	tween(d, func(k: float):
		if id != CAMID:
			return
		var e := sm(k)
		camP = p0.lerp(p, e)
		camL = l0.lerp(l, e))

func wide() -> Dictionary:
	if area == 2:
		return shop.WIDE
	return {"p": Vector3(0, 45, 75), "look": Vector3(0, 0, -5)}

func cam_home(instant := false) -> void:
	if step >= TASKS.size() and area == 2:
		cam_to(shop.HOME.p, shop.HOME.look, 0.01 if instant else 1.6)
		return
	if step >= TASKS.size():
		cam_to(Vector3(0, 9.5, -24), Vector3(0, 6.5, -58), 0.01 if instant else 1.6)
		return
	var v: Dictionary = VW[step]
	if instant:
		CAMID += 1
		camP = v.p
		camL = v.look
	else:
		glide_to(v)

func kind_of(T: Dictionary) -> String:
	var n: String = T.n
	if n.contains("Path"): return "stone"
	if n.contains("Lamp"): return "lamp"
	if n.contains("Tree"): return "tree"
	if n.contains("Farm"): return "farm"
	if n.contains("Bridge"): return "bridge"
	if n.contains("Coffee") or n.contains("Market"): return "stall"
	return "house"

var spend_cb: Callable    # the home screen flies the diya from the Build button to the site, then calls back

func run_next() -> void:
	var T: Dictionary = TASKS[step]
	diyas -= int(T.c)
	changed.emit()
	var tot := task_len(T)
	SPEED = maxf(1.0, (tot + 1.2) / (1.5 if FAST else (3.0 if step == 0 else 4.0)))
	if FAST:
		FN += 1
	var wait := maxf(0.0, glide_to(VW[step]) - 0.5)
	var v: Dictionary = VW[step]
	var go := func():
		var cont := func():
			var sh: Dictionary = L.shots[T.shot]
			hold_shot(v, float(T.dur) if float(T.dur) > 0 else float(sh.d))
			run_task(T.n)
			var total := task_len(T)
			sfx.emit("bk:%s:%.2f" % [kind_of(T), total / SPEED])
			after(total, _task_finished)
		if spend_cb.is_valid():
			spend_cb.call(V(T.site), cont)
		else:
			cont.call()
	after(wait, go)

func _task_finished() -> void:
	step += 1
	changed.emit()
	sfx.emit("area" if step >= TASKS.size() else "done")
	if auto and step < TASKS.size() and diyas >= int(TASKS[step].c):
		run_next()
		return
	var was_fast := FAST
	FAST = false
	busy = false
	SPEED = 1.0
	changed.emit()
	if step >= TASKS.size():
		win()
		task_done.emit(true)
	elif was_fast:
		busy = true
		var w := wide()
		cam_to(w.p, w.look, 1.4)
		after(2.6 / maxf(SPEED, 1.0), func():
			busy = false
			cam_home()
			changed.emit()
			task_done.emit(false))
	else:
		task_done.emit(false)

func win() -> void:
	won = true
	var w := wide()
	cam_to(w.p, w.look, 2.4)
	sfx.emit("area")
	area_won.emit()

func speed_up() -> void:
	if busy:
		SPEED = minf(12.0 if FAST else 6.0, maxf(SPEED * 1.8, 2.0))

# fast-forward: used when the street opens with tasks already done
func skip_to(n: int) -> void:
	for i in range(step, mini(n, TASKS.size())):
		run_task(TASKS[i].n)
	step = mini(n, TASKS.size())
	for i in 200:
		_tick(0.1)
	fx.clear()

# ---------------------------------------------------------------- frame
func _tick(dt: float) -> void:
	clock += dt
	var cur := TW
	TW = []
	var keep: Array = []
	for o in cur:
		o.t += dt
		if o.t < 0:
			keep.append(o)
			continue
		var k := minf(1.0, o.t / o.d)
		o.fn.call(k)
		if k < 1:
			keep.append(o)
	TW = keep + TW

func _process(delta: float) -> void:
	if not visible:
		return
	var dt := minf(0.1, delta) * SPEED
	_tick(dt)
	cam.position = camP
	if camP.distance_to(camL) > 0.01:
		cam.look_at(camL, Vector3.UP)
	env.tonemap_exposure = expo
	for e in EM:
		e.a += dt * e.r
		while e.a > 1:
			e.a -= 1
			if e.k == "smoke":
				fx.part(true, e.p + Vector3(rnd(-0.15, 0.15), 0, rnd(-0.15, 0.15)), {"s0": 0.7, "s1": 2.6, "col": Color("#d8d0d0"), "op": 0.5, "v": Vector3(rnd(0.1, 0.4), rnd(0.6, 1), rnd(-0.15, 0.15)), "d": 3.2})
			else:
				fx.part(true, e.p, {"s0": 0.15, "s1": 0.6, "col": Color.WHITE, "op": 0.5, "v": Vector3(rnd(-0.05, 0.05), rnd(0.3, 0.5), rnd(-0.05, 0.05)), "d": 1.6})
	fx.step(dt)
	water_mat.uv1_offset.x -= dt * 0.05
	if SHOW:
		fwT -= dt
		if fwT <= 0:
			firework()
			fwT = rnd(0.3, 0.6)
