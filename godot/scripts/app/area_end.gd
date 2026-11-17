# End of Area 1 (17 Nov). Plays once after the last build (the factory), over the live 3D street.
# 1 dusk, the factory windows light up   2 fireworks over the street   3 the loaded truck leaves for Chennai
# 4 Grandpa's notebook: step 1 gets a red tick, step 2 is underlined   5 card "NEXT · Bunder Street, Chennai"
# Same look as the intro story (StoryScene): letterbox, serif captions, Tap = next shot, Skip = done.
extends StoryScene
class_name AreaEndScene

var area := 1           # 1: Sivakasi Street done   2: the Chennai shop is open
var truck: Node3D
var wheels: Array = []
var glows: Array = []
var lights: Array = []
var path: PackedVector3Array
var plen: PackedFloat32Array
var drive := -1.0      # distance along the road while driving, -1 = parked
var chase := false
const SPD := 7.5
const TRUCK_SCALE := 1.6

func play(height: float) -> void:
	super.play(height)
	var a: Label = card.get_node("a")
	a.text = "N E X T"
	var t: Label = card.get_node("t")
	t.label_settings = t.label_settings.duplicate()
	t.label_settings.font_size = 38
	t.text = "Bunder Street, Chennai"
	var u: Label = card.get_node("u")
	u.text = "our first shop in the big city"
	book.end_mode = true
	book.tick_i = area - 1
	if area == 2:
		t.text = "More towns to light up"
		u.text = "Area 3 is coming soon"

func _shot(n: int) -> void:
	shot = n
	sid += 1
	var id := sid
	if area == 2:
		match n:
			1: _open_shop(id)
			2: _tick(id)
			3: _next(id)
			_: _finish()
		return
	# (the truck shot is left out for now: the truck did not draw on phones)
	match n:
		1: _dusk(id)
		2: _fireworks(id)
		3: _tick(id)
		4: _next(id)
		_: _finish()

# Area 2: the camera pulls back over the open shop, customers inside, the man cheers
func _open_shop(id: int) -> void:
	if street:
		var w: Dictionary = street.wide()
		street.cam_to(w.p, w.look, 3.2)
		for i in 5:
			_later(0.6 + i * 0.5, id, func():
				street.sparkle(Vector3(randf_range(-4, 4), 0, randf_range(-12, -3)), 30, 3.0)
				_sfx("story_ting", 0.4, randf_range(0.9, 1.2)))
	man.base = "idle"
	man.mood("smile", 99)
	man.position.x = 2
	_tw().tween_property(man, "position:y", H - BOT - 236, 1.0).set_delay(0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_later(1.2, id, func(): man.mood("cheer", 1.2))
	_later(0.5, id, func(): say("“Thatha, our first shop\nin Chennai is open!”", id, 3.4))
	_later(4.4, id, func():
		_tw().tween_property(man, "position:y", H + 40, 0.6)
		_shot(2))

# ------------------------------------------------------------------ 1. dusk: the factory windows light up
func _dusk(id: int) -> void:
	if street:
		street.cam_to(Vector3(-3, 6.5, -27), Vector3(0, 4.2, -57), 4.0)
		var st = street
		create_tween().set_trans(Tween.TRANS_SINE).tween_method(func(k: float): st.night(k), 0.0, 0.8, 3.2)
		_factory_lights(id)
	motes.rate = 8.0
	_later(0.8, id, func(): say("“Thatha… your factory is ready.”", id, 3.0))
	_later(4.6, id, func(): _shot(2))

func _factory_lights(id: int) -> void:
	var g: Node3D = street.N.get(int(street.L.lists.CRK.g))
	if g == null:
		return
	var box := _aabb(g)
	if box.size == Vector3.ZERO:
		return
	var front := box.end.z + 0.15
	var pts: Array = []
	for row in 2:
		for col in 4:
			pts.append(Vector3(lerpf(box.position.x + 1.2, box.end.x - 1.2, col / 3.0), box.position.y + 1.6 + row * 2.4, front))
	for i in pts.size():
		var p: Vector3 = pts[i]
		_later(1.4 + i * 0.16, id, func():
			street.fx.part(false, p, {"s0": 0.3, "s1": 2.4, "col": Color(1, 0.7, 0.3), "op": 0.85, "d": 999.0, "add": true, "in": 0.4, "fl": 5.0})
			street.fx.part(false, p, {"s0": 0.1, "s1": 0.8, "col": Color(1, 0.95, 0.75), "op": 1.0, "d": 999.0, "add": true, "in": 0.3, "fl": 8.0})
			_sfx("story_ting", 0.35, 0.9 + i * 0.05))
	_later(1.6, id, func():
		var l := OmniLight3D.new()
		l.light_color = Color(1, 0.72, 0.38)
		l.light_energy = 0.0
		l.omni_range = 18.0
		street.add_child(l)
		l.global_position = Vector3(box.get_center().x, box.position.y + 3.0, front + 3.0)
		lights.append(l)
		create_tween().tween_property(l, "light_energy", 2.2, 1.6))

func _aabb(n: Node) -> AABB:
	var out := AABB()
	var first := true
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if not mi.is_visible_in_tree():
			continue
		var b: AABB = mi.global_transform * mi.get_aabb()
		if first:
			out = b
			first = false
		else:
			out = out.merge(b)
	return out

# ------------------------------------------------------------------ 2. fireworks over the street
func _fireworks(id: int) -> void:
	if street:
		street.cam_to(Vector3(2, 15, 6), Vector3(0, 12, -62), 3.6)
		for i in 9:
			_later(0.3 + i * 0.4, id, func():
				street.firework()
				_sfx("blast", 0.5, randf_range(0.85, 1.1)))
	man.base = "idle"
	man.mood("smile", 99)
	man.position.x = 2
	var m := _tw()
	m.tween_property(man, "position:y", H - BOT - 236, 1.0).set_delay(0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_later(1.2, id, func(): man.mood("cheer", 1.2))
	_later(0.5, id, func(): say("Sivakasi Street shines again!", id, 3.0))
	_later(3.0, id, func(): say("Tomorrow, the first load of crackers\nleaves for Chennai.", id, 1.6))
	_later(4.8, id, func():
		_tw().tween_property(man, "position:y", H + 40, 0.6)
		_shot(3))

# ------------------------------------------------------------------ 3. the loaded truck leaves for Chennai
func _truck(id: int) -> void:
	_tw().tween_property(man, "position:y", H + 40, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if truck == null:
		_make_truck()
	chase = true
	_later(0.3, id, func():
		_sfx("bk_thud", 0.6)
		_drop_box())
	_later(1.0, id, func():
		drive = 0.0
		_sfx("swoosh", 0.4, 0.6))
	_later(0.6, id, func(): say("The first load of crackers\nleaves for Chennai.", id, 4.2))
	_later(6.6, id, func(): _shot(4))

# a small Indian lorry built from simple shapes (the Kenney truck model did not show on screen, only its shadow):
# red cab with a yellow stripe, open wooden back loaded with cracker boxes, black wheels. Faces +z, 1 unit ~ 1 m.
func _make_truck() -> void:
	if truck or street == null:
		return
	truck = Node3D.new()
	var body := Node3D.new()
	body.scale = Vector3.ONE * TRUCK_SCALE
	truck.add_child(body)
	var B := func(sz: Vector3, pos: Vector3, col: Color, par: Node3D, nm := "") -> MeshInstance3D:
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = sz
		m.mesh = bm
		var mat := StandardMaterial3D.new()
		mat.albedo_color = col
		mat.roughness = 0.55
		m.material_override = mat
		m.position = pos
		if nm != "":
			m.name = nm
		par.add_child(m)
		return m
	B.call(Vector3(1.5, 0.25, 3.0), Vector3(0, 0.45, 0), Color("#3a3a3a"), body)               # chassis
	B.call(Vector3(1.5, 1.0, 1.0), Vector3(0, 1.05, 0.95), Color("#D7263D"), body)             # cab
	B.call(Vector3(1.52, 0.12, 1.02), Vector3(0, 0.85, 0.95), Color("#FFC93C"), body)          # stripe
	B.call(Vector3(1.3, 0.42, 0.04), Vector3(0, 1.25, 1.46), Color("#9fd3ff"), body)           # windscreen
	B.call(Vector3(1.5, 0.08, 1.9), Vector3(0, 0.62, -0.55), Color("#8A5A3C"), body)           # bed floor
	for sx in [-0.73, 0.73]:
		B.call(Vector3(0.06, 0.45, 1.9), Vector3(sx, 0.86, -0.55), Color("#A8703F"), body)     # bed sides
	B.call(Vector3(1.5, 0.45, 0.06), Vector3(0, 0.86, -1.48), Color("#A8703F"), body)          # tailgate
	for w in [Vector3(-0.72, 0.32, 0.9), Vector3(0.72, 0.32, 0.9), Vector3(-0.72, 0.32, -0.9), Vector3(0.72, 0.32, -0.9)]:
		var wm := MeshInstance3D.new()
		var cy := CylinderMesh.new()
		cy.top_radius = 0.32
		cy.bottom_radius = 0.32
		cy.height = 0.22
		wm.mesh = cy
		var mt := StandardMaterial3D.new()
		mt.albedo_color = Color("#1c1c1c")
		wm.material_override = mt
		wm.rotation.z = PI / 2
		wm.position = w
		body.add_child(wm)
		wheels.append(wm)
	var cols := [Color("#D7263D"), Color("#FFC93C"), Color("#FF7A1A"), Color("#2E86DE"), Color("#7B3FBF"), Color("#2EAD5B")]
	var spots := [Vector3(-0.38, 0.9, -1.1), Vector3(0.38, 0.9, -1.1), Vector3(-0.38, 0.9, -0.45), Vector3(0.38, 0.9, -0.45), Vector3(0, 1.32, -0.78), Vector3(-0.38, 0.9, 0.12)]
	for i in spots.size():
		var b: MeshInstance3D = B.call(Vector3(0.6, 0.42, 0.55), spots[i], cols[i], body, "box%d" % i)
		B.call(Vector3(0.62, 0.08, 0.57), Vector3.ZERO, Color("#F5C542"), b)
	street.add_child(truck)
	_road()
	_place(0.0)

func _paint(mi: MeshInstance3D) -> void:
	var src = mi.get_active_material(0)
	var tex: Texture2D = src.albedo_texture if src is BaseMaterial3D else null
	if tex == null:
		return
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode cull_disabled;
uniform sampler2D tex : source_color, filter_nearest;
void fragment() {
	vec3 c = texture(tex, UV).rgb;
	if (c.g > c.r * 1.15 && c.g > c.b * 1.02) {
		float l = dot(c, vec3(0.3, 0.59, 0.11)) / 0.42;
		c = vec3(0.84, 0.13, 0.16) * clamp(l, 0.45, 1.5);
	}
	ALBEDO = c;
	ROUGHNESS = 0.55;
}
"""
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("tex", tex)
	mi.material_override = m

func _drop_box() -> void:
	if truck == null:
		return
	var b: Node3D = truck.get_child(0).get_node_or_null("box4")
	if b == null:
		return
	b.visible = true
	var y := b.position.y
	b.position.y = y + 3.0
	create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).tween_property(b, "position:y", y, 0.55)

# the road: the street's stepping-stone path from the factory gate to the far end
func _road() -> void:
	var pts: Array = street.STD.duplicate()
	pts = pts.filter(func(q): return q.z > -46.0)
	pts.sort_custom(func(a, b): return a.z < b.z)
	path = PackedVector3Array()
	plen = PackedFloat32Array()
	var acc := 0.0
	for q in pts:
		var p := Vector3(q.x, 0.0, q.z)
		if path.size() > 0:
			if p.distance_to(path[path.size() - 1]) < 1.5:
				continue
			acc += p.distance_to(path[path.size() - 1])
		path.append(p)
		plen.append(acc)
	# carry on past the end of the street
	if path.size() > 1:
		var last := path[path.size() - 1]
		var dir := (last - path[path.size() - 2]).normalized()
		for i in 4:
			last += dir * 8.0
			acc += 8.0
			path.append(last)
			plen.append(acc)

func _at(d: float) -> Vector3:
	if path.size() < 2:
		return Vector3(0, 0, -44)
	d = clampf(d, 0.0, plen[plen.size() - 1])
	for i in range(1, path.size()):
		if plen[i] >= d:
			var k := (d - plen[i - 1]) / maxf(0.001, plen[i] - plen[i - 1])
			return path[i - 1].lerp(path[i], k)
	return path[path.size() - 1]

func _place(d: float) -> void:
	var p := _at(d)
	var ahead := _at(d + 3.0)
	truck.global_position = p
	if ahead.distance_to(p) > 0.01:
		var dir := (ahead - p).normalized()
		var want := atan2(dir.x, dir.z)
		truck.rotation.y = lerp_angle(truck.rotation.y, want, 0.2) if d > 0.0 else want

func _process(dt: float) -> void:
	if truck == null or street == null:
		return
	if drive >= 0.0:
		var sp := SPD * minf(1.0, 0.25 + drive / 6.0)
		drive += sp * dt
		_place(drive)
		for w in wheels:
			(w as Node3D).rotate_object_local(Vector3.RIGHT, sp * dt / (0.3 * TRUCK_SCALE))
	if chase:
		street.CAMID += 1
		var p := truck.global_position
		var fwd := Vector3(sin(truck.rotation.y), 0, cos(truck.rotation.y))
		var side := Vector3(fwd.z, 0, -fwd.x)
		var want := p + fwd * 9.0 + side * 4.5 + Vector3(0, 3.2, 0)
		street.camP = street.camP.lerp(want, minf(1.0, dt * 2.2))
		street.camL = street.camL.lerp(p + Vector3(0, 1.2, 0), minf(1.0, dt * 4.0))

# ------------------------------------------------------------------ 4. the notebook: step 1 ticked
func _tick(id: int) -> void:
	chase = false
	drive = -1.0
	var t := _tw()
	t.tween_property(dim, "color:a", 0.62, 0.8)
	_tw().tween_property(cap, "modulate:a", 0.0, 0.3)
	book.reset()
	book.visible = true
	book.scale = Vector2.ONE * 0.35
	book.rotation = -0.5
	book.modulate.a = 0.0
	var b := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	b.tween_property(book, "scale", Vector2.ONE, 0.75).set_delay(0.2)
	b.parallel().tween_property(book, "rotation", 0.0, 0.75).set_delay(0.2)
	b.parallel().tween_property(book, "modulate:a", 1.0, 0.4).set_delay(0.2)
	_sfx("swoosh", 0.35, 0.7, 0.2)
	_later(1.1, id, func():
		_sfx("story_page", 1.0)
		_tw().tween_property(book, "open", 1.0, 0.75).set_trans(Tween.TRANS_CUBIC))
	_later(2.4, id, func():
		book.anim("tick", 1.0, 0.55)
		for i in 3:
			_sfx("story_pen", 0.7, randf_range(0.9, 1.1), i * 0.15))
	_later(3.0, id, func():
		_sfx("story_chime", 0.9)
		motes.burst(Vector2(book.position.x + 315, book.position.y + 120 + 42 * (area - 1)), 30))
	_later(3.9, id, func():
		book.anim("next_hi", 1.0, 0.8)
		_sfx("story_ting", 0.6))
	_later(3.4, id, func(): say("One step done.\nThe next one is waiting…", id, 3.4))
	_later(7.2, id, func(): _shot(shot + 1))

# ------------------------------------------------------------------ 5. NEXT: Bunder Street, Chennai
func _next(id: int) -> void:
	var t := _tw()
	t.tween_property(book, "open", 0.0, 0.45)
	t.tween_property(book, "scale", Vector2.ONE * 0.2, 0.35)
	t.parallel().tween_property(book, "modulate:a", 0.0, 0.35)
	t.tween_callback(func(): book.visible = false)
	_sfx("story_page", 0.6, 1.15)
	_title(id)

func _finish() -> void:
	if done:
		return
	chase = false
	drive = -1.0
	super._finish()
	# clean up behind the flash
	get_tree().create_timer(0.5).timeout.connect(_cleanup)

func _cleanup() -> void:
	if is_instance_valid(truck):
		truck.queue_free()
	for l in lights:
		if is_instance_valid(l):
			l.queue_free()
	if street:
		street.story_clear()
		street.cam_home(true)
