# dev (23 Nov): Area 4 "GHILLI Deliveries" MOCK renders (for approval, not the final pictures).
# -- --mode=lane --p=x,y,z --l=x,y,z --fov=50 --w=1080 --h=2338 --shot=/tmp/x.png   (finished GHILLI + old dusty van)
# -- --mode=map --fest=0|1 --van=N --w=1080 --h=5845 --shot=/tmp/map.png              (tall delivery road, ortho)
extends Node

const A := "res://art/a2/%s.glb"

func V3(s: String) -> Vector3:
	var a := s.split(",")
	return Vector3(float(a[0]), float(a[1]), float(a[2]))

var a := {}
var root: Node3D

func _ready() -> void:
	for s in OS.get_cmdline_user_args():
		if s.begins_with("--") and "=" in s:
			a[s.substr(2, s.find("=") - 2)] = s.substr(s.find("=") + 1)
	RenderingServer.directional_shadow_atlas_set_size(8192, true)
	var sv := SubViewport.new()
	sv.size = Vector2i(int(a.get("w", 1080)), int(a.get("h", 2338)))
	sv.msaa_3d = Viewport.MSAA_4X
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sv)
	await get_tree().process_frame
	var cam: Camera3D
	if a.get("mode", "lane") == "lane":
		cam = await lane(sv)
	elif a.get("mode") == "street":
		cam = await street_view(sv)
	elif a.get("mode") == "road":
		cam = road_view(sv)
	else:
		cam = map(sv)
	for i in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	sv.get_texture().get_image().save_png(a.get("shot", "/tmp/a4.png"))
	print("PIC saved ", a.get("shot", "/tmp/a4.png"))
	get_tree().quit()

# ------------------------------------------------------------------ helpers
func put(par: Node3D, path: String, pos: Vector3, s := 1.0, rot_y := 0.0) -> Node3D:
	var ps: PackedScene = load(path if path.begins_with("res://") else A % path)
	var o: Node3D = ps.instantiate()
	o.scale = Vector3.ONE * s
	o.rotation.y = rot_y
	o.position = pos
	par.add_child(o)
	return o

func recolor(o: Node3D, f: Callable) -> void:
	for c in o.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.get_active_material(i)
			if src is BaseMaterial3D:
				var m: BaseMaterial3D = src.duplicate()
				f.call(m, String(src.resource_name).to_lower())
				mi.set_surface_override_material(i, m)

func mat(c: String, emit := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c)
	m.roughness = 0.9
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = Color(c)
		m.emission_energy_multiplier = emit
	return m

func box(par: Node3D, size: Vector3, pos: Vector3, c: String, rot_y := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat(c)
	mi.position = pos
	mi.rotation.y = rot_y
	par.add_child(mi)
	return mi

# old dusty van: Kenney van, paint faded to dusty beige-grey, sunk on flat tyres, slight lean
func dusty_van(par: Node3D, pos: Vector3, rot_y: float, s: float) -> Node3D:
	var v := put(par, "cars/van", pos, s, rot_y)
	recolor(v, func(m: BaseMaterial3D, _n: String):
		if m.albedo_texture:
			var img: Image = m.albedo_texture.get_image()
			if img.is_compressed():
				img.decompress()
			img.convert(Image.FORMAT_RGBA8)
			var dust := Color("#8a7658")
			for y in img.get_height():
				for x in img.get_width():
					var c := img.get_pixel(x, y)
					var g := c.get_luminance()
					var d := Color(g, g, g).lerp(dust, 0.7).darkened(0.2)
					img.set_pixel(x, y, c.lerp(d, 0.85))
			m.albedo_texture = ImageTexture.create_from_image(img)
		m.roughness = 1.0
		m.metallic = 0.0)
	v.position.y -= 0.12 * s
	v.rotation.z = 0.035
	return v

# GHILLI van after build 1: body repainted red (hue of the coloured texels), rest kept
func ghilli_van(par: Node3D, pos: Vector3, rot_y: float, s: float) -> Node3D:
	var v := put(par, "cars/van", pos, s, rot_y)
	recolor(v, func(m: BaseMaterial3D, _n: String):
		if m.albedo_texture:
			var img: Image = m.albedo_texture.get_image()
			if img.is_compressed():
				img.decompress()
			img.convert(Image.FORMAT_RGBA8)
			for y in img.get_height():
				for x in img.get_width():
					var c := img.get_pixel(x, y)
					if c.s > 0.3 and c.b > c.r and c.b > c.g:
						img.set_pixel(x, y, Color.from_hsv(0.995, 0.85, clampf(c.v * 0.95, 0.3, 0.92)))
			m.albedo_texture = ImageTexture.create_from_image(img)
		m.roughness = 0.3)
	return v

# ------------------------------------------------------------------ mock 1: GHILLI side lane, old van
func lane(sv: SubViewport) -> Camera3D:
	sv.transparent_bg = false
	var st := Street.new()
	st.sv = sv
	sv.add_child(st)
	await get_tree().process_frame
	st.set_area(2)
	st.sun.shadow_enabled = true
	st.sun.directional_shadow_max_distance = 90
	st.process_mode = Node.PROCESS_MODE_INHERIT
	st.skip_to(12)
	st.SHOW = false
	st.EM.clear()
	st.fx.clear()
	st.process_mode = Node.PROCESS_MODE_DISABLED
	var bz: Node3D = st.bazaar
	dusty_van(bz, V3(a.get("van", "-0.6,0.3,6.2")), float(a.get("vr", "1.62")), 1.55)
	# junk by the van: old tyre stand-ins (cardboard boxes) and a cone
	put(bz, "res://art/shop/cardboardBoxOpen.glb", Vector3(3.4, 0.02, 6.0), 2.6, 0.5)
	put(bz, "roads/construction-cone", Vector3(-3.9, 0.02, 7.2), 2.0, 0.0)
	var cam := st.cam
	cam.fov = float(a.get("fov", 50))
	cam.position = V3(a.get("p", "0.3,3.0,15"))
	cam.look_at(V3(a.get("l", "0,3.0,0")), Vector3.UP)
	return cam

# ------------------------------------------------------------------ mock 2/3: tall delivery road
# road runs from GHILLI (z=+20) up to the beach (z=-300); x wiggles
func rx(z: float) -> float:
	return 5.0 * sin(z / 30.0) + 1.5 * sin(z / 11.0 + 1.0)

var MAPW := 46.0
var PL := [  # name, z, side(-1 left / 1 right)
	["temple", -18.0, -1], ["wedding", -50.0, 1], ["school", -82.0, -1], ["apts", -114.0, 1],
	["fair", -146.0, -1], ["office", -178.0, 1], ["beach", -215.0, 0]]

func map(sv: SubViewport) -> Camera3D:
	sv.transparent_bg = false
	var fest := int(a.get("fest", 0))   # how many places are done
	root = Node3D.new()
	sv.add_child(root)
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#8fd0f0")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#dfe8f5")
	env.ambient_light_energy = 0.32
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 1.0
	we.environment = env
	root.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("#fff2dc")
	sun.light_energy = 0.72
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 500
	sun.rotation = Vector3(deg_to_rad(-55), deg_to_rad(-30), 0)
	root.add_child(sun)
	# ground: grass, then sand + sea at the top
	box(root, Vector3(200, 0.2, 300), Vector3(0, -0.1, -70), "#6fae45")
	box(root, Vector3(200, 0.2, 60), Vector3(0, -0.05, -222), "#e6cf94")
	var sea := box(root, Vector3(200, 0.2, 120), Vector3(0, 0.02, -302), "#1f8fd0")
	sea.material_override.roughness = 0.3
	# lighter grass patches
	seed(7)
	for i in 40:
		var z := randf_range(-205, 25)
		var x := randf_range(-30, 30)
		if absf(x - rx(z)) < 8:
			continue
		var d := box(root, Vector3(randf_range(5, 12), 0.05, randf_range(4, 9)), Vector3(x, 0.01, z), "#7dba52", randf() * TAU)
		d.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	road()
	# GHILLI shop at the bottom
	ghilli_spot()
	for i in PL.size():
		var p: Array = PL[i]
		var on := i < fest
		var side: int = p[2]
		var z: float = p[1]
		var x: float = rx(z) + side * 12.5
		var g := Node3D.new()
		g.position = Vector3(x, 0, z)
		g.scale = Vector3.ONE * 1.3
		root.add_child(g)
		call("place_" + p[0], g, on, side)
	trees()
	# the van on the road
	if a.has("van"):
		var vz := float(a.van)
		var dz := 0.5
		var ang := atan2(rx(vz - dz) - rx(vz + dz), -2 * dz)
		ghilli_van(root, Vector3(rx(vz) + 1.6, 0.3, vz), ang + PI, 2.1)
	var cam := Camera3D.new()
	root.add_child(cam)
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.size = MAPW
	var pitch := deg_to_rad(float(a.get("pitch", 45)))
	var midz := float(a.get("midz", -112))
	cam.rotation = Vector3(-pitch, 0, 0)
	cam.position = Vector3(0, 0, midz) + Vector3(0, sin(pitch), cos(pitch)) * 200.0
	cam.near = 1
	cam.far = 600
	cam.current = true
	# dots + places, projected, for the 2D overlay
	await_print(cam, sv)
	return cam

func await_print(cam: Camera3D, sv: SubViewport) -> void:
	await get_tree().process_frame
	var n := 20
	var z0 := 8.0
	var z1 := -205.0
	for i in n:
		var z := lerpf(z0, z1, float(i) / (n - 1))
		var q := cam.unproject_position(Vector3(rx(z), 0.2, z))
		print("PIC dot %d %.1f %.1f %.2f" % [i, q.x, q.y, z])
	for p in PL:
		var z: float = p[1]
		var x: float = rx(z) + int(p[2]) * 12.5
		var q := cam.unproject_position(Vector3(x, 0, z))
		print("PIC place %s %.1f %.1f" % [p[0], q.x, q.y])

func road() -> void:
	var stool := SurfaceTool.new()
	var ln := SurfaceTool.new()
	stool.begin(Mesh.PRIMITIVE_TRIANGLES)
	ln.begin(Mesh.PRIMITIVE_TRIANGLES)
	var w := 3.6
	var z := 30.0
	var k := 0
	while z > -212.0:
		var z2 := z - 1.0
		var a0 := Vector3(rx(z), 0.12, z)
		var a1 := Vector3(rx(z2), 0.12, z2)
		var d := (a1 - a0).normalized()
		var nrm := Vector3(-d.z, 0, d.x)
		quad(stool, a0 - nrm * w, a0 + nrm * w, a1 + nrm * w, a1 - nrm * w)
		# edge lines and centre dashes
		for e in [-w + 0.35, w - 0.35]:
			quad(ln, a0 + nrm * (e - 0.12) + Vector3.UP * 0.02, a0 + nrm * (e + 0.12) + Vector3.UP * 0.02, a1 + nrm * (e + 0.12) + Vector3.UP * 0.02, a1 + nrm * (e - 0.12) + Vector3.UP * 0.02)
		if k % 4 < 2:
			quad(ln, a0 - nrm * 0.15 + Vector3.UP * 0.02, a0 + nrm * 0.15 + Vector3.UP * 0.02, a1 + nrm * 0.15 + Vector3.UP * 0.02, a1 - nrm * 0.15 + Vector3.UP * 0.02)
		z = z2
		k += 1
	stool.generate_normals()
	ln.generate_normals()
	var r := MeshInstance3D.new()
	r.mesh = stool.commit()
	r.material_override = mat("#5d636b")
	root.add_child(r)
	var l := MeshInstance3D.new()
	l.mesh = ln.commit()
	l.material_override = mat("#f4f1e6")
	l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(l)
	# kerbs
	var kb := SurfaceTool.new()
	kb.begin(Mesh.PRIMITIVE_TRIANGLES)
	z = 30.0
	while z > -212.0:
		var z2 := z - 1.0
		var a0 := Vector3(rx(z), 0.10, z)
		var a1 := Vector3(rx(z2), 0.10, z2)
		var d := (a1 - a0).normalized()
		var nrm := Vector3(-d.z, 0, d.x)
		for e in [-1.0, 1.0]:
			quad(kb, a0 + nrm * e * w, a0 + nrm * e * (w + 0.8), a1 + nrm * e * (w + 0.8), a1 + nrm * e * w)
		z = z2
	kb.generate_normals()
	var km := MeshInstance3D.new()
	km.mesh = kb.commit()
	km.material_override = mat("#d9d2c0")
	root.add_child(km)

func quad(s: SurfaceTool, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3) -> void:
	for p in [p0, p2, p1, p0, p3, p2]:
		s.add_vertex(p)

func trees() -> void:
	seed(11)
	var kinds := ["tree_default", "tree_oak", "tree_palmTall", "tree_palm", "plant_bushLarge"]
	for i in 120:
		var z := randf_range(-205, 25)
		var x := randf_range(-32, 32)
		if absf(x - rx(z)) < 7.5:
			continue
		var near := false
		for p in PL:
			var px: float = rx(p[1]) + int(p[2]) * 12.5
			if Vector2(x - px, z - float(p[1])).length() < 14.0:
				near = true
		if near or z > 4:
			continue
		var t := put(root, "nature/" + kinds[randi() % kinds.size()], Vector3(x, 0, z), randf_range(3.5, 5.0), randf() * TAU)
		recolor(t, _leaf)

func _leaf(m: BaseMaterial3D, n: String) -> void:
	if n.contains("leaf") or n.contains("grass") or n.contains("green"):
		m.albedo_color = Color("#5fa83a")
	elif n.contains("wood") or n.contains("bark") or n.contains("trunk"):
		m.albedo_color = Color("#8a6a4a")

func people(g: Node3D, c: Vector3, n: int, r: float) -> void:
	var kinds := ["female-a", "female-b", "female-c", "female-d", "female-e", "male-a", "male-b", "male-c", "male-d", "male-e"]
	for i in n:
		var ang := randf() * TAU
		var p := c + Vector3(cos(ang), 0, sin(ang)) * randf_range(0.0, r)
		put(g, "people/character-" + kinds[randi() % kinds.size()], p, 3.2, randf() * TAU)

func bunting(g: Node3D, p0: Vector3, p1: Vector3, h: float) -> void:
	var cols := ["#ff3b3b", "#ffcc00", "#2fb34a", "#2f7fff", "#ff7a00", "#d63bd6"]
	var n := int(p0.distance_to(p1) / 0.9)
	for i in n + 1:
		var t := float(i) / n
		var p := p0.lerp(p1, t)
		p.y = h - 1.2 * (1.0 - pow(2.0 * t - 1.0, 2))
		var f := box(g, Vector3(0.55, 0.6, 0.05), p, cols[i % cols.size()], atan2(p1.x - p0.x, p1.z - p0.z) + PI / 2)
		f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		f.material_override = mat(cols[i % cols.size()], 0.4)

func lamps(g: Node3D, p0: Vector3, p1: Vector3, h: float) -> void:
	var n := int(p0.distance_to(p1) / 1.2)
	for i in n + 1:
		var t := float(i) / n
		var p := p0.lerp(p1, t)
		p.y = h - 0.8 * (1.0 - pow(2.0 * t - 1.0, 2))
		var b := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.22
		sm.height = 0.44
		b.mesh = sm
		b.material_override = mat(["#ffd23a", "#ff6a3a", "#fff3a0"][i % 3], 2.0)
		b.position = p
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		g.add_child(b)

func city(g: Node3D, name: String, pos: Vector3, s: float, rot := 0.0) -> Node3D:
	return put(g, "res://art/a2/city/%s.glb" % name if FileAccess.file_exists("res://art/a2/city/%s.glb" % name) else "res://art/city/%s.glb" % name, pos, s, rot)

func face(side: int) -> float:
	# buildings face the road
	return PI / 2 if side < 0 else -PI / 2

func ghilli_spot() -> void:
	var g := Node3D.new()
	g.position = Vector3(rx(14) + 11.0, 0, 16)
	root.add_child(g)
	box(g, Vector3(16, 6, 7), Vector3(0, 3, 0), "#f3e3c4")
	box(g, Vector3(16.6, 0.5, 7.6), Vector3(0, 6.2, 0), "#c9a77a")
	box(g, Vector3(12, 1.8, 0.3), Vector3(0, 4.7, 3.6), "#d8262e")
	box(g, Vector3(10, 3.2, 0.3), Vector3(0, 1.6, 3.55), "#ffcf4a")
	for i in 8:
		box(g, Vector3(1.5, 0.3, 2.4), Vector3(-5.25 + i * 1.5, 3.55, 4.6), "#ff4a4a" if i % 2 == 0 else "#ffffff")

# ---- the 7 places; on = festive after its Build
func place_temple(g: Node3D, on: bool, side: int) -> void:
	box(g, Vector3(12, 0.5, 12), Vector3(0, 0.25, 0), "#e8d7b0")
	box(g, Vector3(12.4, 2.2, 0.6), Vector3(0, 1.1, 6.0), "#c84a3a")
	box(g, Vector3(12.4, 2.2, 0.6), Vector3(0, 1.1, -6.0), "#c84a3a")
	box(g, Vector3(0.6, 2.2, 12.4), Vector3(6.0, 1.1, 0), "#c84a3a")
	box(g, Vector3(0.6, 2.2, 12.4), Vector3(-6.0, 1.1, 0), "#c84a3a")
	# gopuram at the road side
	var gx := -side * 6.0
	var cols := ["#f0c070", "#e89a50", "#f0c070", "#e89a50", "#f0c070", "#e89a50"]
	for i in 6:
		var s := 1.0 - i * 0.13
		box(g, Vector3(3.2 * s, 1.6, 6.0 * s), Vector3(gx, 2.3 + i * 1.6, 0), cols[i])
	box(g, Vector3(0.9, 0.6, 3.2), Vector3(gx, 12.2, 0), "#ffd23a")
	# shrine
	box(g, Vector3(4, 3.4, 4), Vector3(side * 1.5, 2.2, 0), "#f5e6c8")
	box(g, Vector3(2.6, 2.2, 2.6), Vector3(side * 1.5, 5.0, 0), "#e89a50")
	if on:
		bunting(g, Vector3(gx, 9, -5), Vector3(side * 5.5, 3.5, -5), 6.5)
		bunting(g, Vector3(gx, 9, 5), Vector3(side * 5.5, 3.5, 5), 6.5)
		lamps(g, Vector3(-5.5, 2.5, 6.2), Vector3(5.5, 2.5, 6.2), 2.6)
		lamps(g, Vector3(-5.5, 2.5, -6.2), Vector3(5.5, 2.5, -6.2), 2.6)
		people(g, Vector3(side * 1.5, 0.5, 0), 14, 5.0)
		for p in [Vector3(gx, 0, 3.6), Vector3(gx, 0, -3.6)]:
			put(g, "nature/tree_palm", p, 3.5)

func place_wedding(g: Node3D, on: bool, side: int) -> void:
	city(g, "building-c", Vector3(side * 2, 0, 0), 9.0, face(side))
	box(g, Vector3(10, 0.2, 12), Vector3(-side * 5, 0.1, 0), "#b5ad98")
	if on:
		put(g, "res://art/city/detail-awning-wide.glb", Vector3(-side * 3.0, 0, 0), 9.0, face(side))
		for p in [Vector3(-side * 7.5, 0, 3), Vector3(-side * 7.5, 0, -3)]:
			put(g, "nature/tree_palm", p, 3.0)
		bunting(g, Vector3(-side * 7.5, 0, -4), Vector3(-side * 7.5, 0, 4), 5.0)
		lamps(g, Vector3(-side * 2, 0, -5), Vector3(-side * 2, 0, 5), 7.5)
		people(g, Vector3(-side * 5, 0.2, 0), 12, 4.0)

func place_school(g: Node3D, on: bool, side: int) -> void:
	city(g, "building-a", Vector3(side * 4, 0, -3), 8.0, face(side))
	city(g, "building-a", Vector3(side * 4, 0, 5), 8.0, face(side))
	box(g, Vector3(12, 0.2, 18), Vector3(-side * 3, 0.1, 1), "#d8b98a")
	box(g, Vector3(0.25, 8, 0.25), Vector3(-side * 6, 4, 1), "#dddddd")
	if on:
		box(g, Vector3(0.05, 1.2, 1.8), Vector3(-side * 6, 7.3, 2), "#ff8a1e")
		for p in [Vector3(-side * 2, 0, -5), Vector3(-side * 2, 0, 7)]:
			put(g, "res://art/city/detail-parasol-a.glb", p, 7.0)
		bunting(g, Vector3(-side * 2, 0, -6), Vector3(-side * 2, 0, 8), 5.5)
		people(g, Vector3(-side * 3, 0.2, 1), 16, 5.5)

func place_apts(g: Node3D, on: bool, side: int) -> void:
	city(g, "building-l", Vector3(side * 3, 0, -4), 8.5, face(side))
	city(g, "building-n", Vector3(side * 3, 0, 6), 8.5, face(side))
	box(g, Vector3(9, 0.2, 18), Vector3(-side * 4, 0.1, 1), "#a9b0b5")
	if on:
		lamps(g, Vector3(-side * 1, 0, -9), Vector3(-side * 1, 0, 11), 10.0)
		lamps(g, Vector3(-side * 1, 0, -9), Vector3(-side * 1, 0, 11), 6.5)
		people(g, Vector3(-side * 4, 0.2, 1), 10, 4.5)
		for z in [-3.0, 5.0]:
			put(g, "nature/pot_large", Vector3(-side * 6, 0.2, z), 2.0)

func place_fair(g: Node3D, on: bool, side: int) -> void:
	box(g, Vector3(18, 0.15, 18), Vector3(0, 0.08, 0), "#d9b47c")
	put(g, "gen/stall", Vector3(-4, 0.15, -5), 1.6, 0.2)
	put(g, "gen/stall", Vector3(4, 0.15, 5), 1.6, 2.8)
	if on:
		for p in [Vector3(-5, 0, 3), Vector3(5, 0, -4), Vector3(0, 0, 6), Vector3(1, 0, -7)]:
			put(g, "res://art/city/detail-parasol-a.glb", p, 8.0, randf() * TAU)
		bunting(g, Vector3(-8, 0, -8), Vector3(8, 0, 8), 6.0)
		bunting(g, Vector3(-8, 0, 8), Vector3(8, 0, -8), 6.0)
		people(g, Vector3.ZERO, 22, 7.0)
		box(g, Vector3(0.3, 9, 0.3), Vector3(0, 4.5, 0), "#c84a3a")

func place_office(g: Node3D, on: bool, side: int) -> void:
	city(g, "building-m", Vector3(side * 3, 0, 0), 9.0, face(side))
	box(g, Vector3(9, 0.2, 14), Vector3(-side * 5, 0.1, 0), "#a9b0b5")
	if on:
		put(g, "res://art/city/detail-parasol-a.glb", Vector3(-side * 6, 0, 3), 7.0)
		lamps(g, Vector3(-side * 1, 0, -6), Vector3(-side * 1, 0, 6), 6.0)
		bunting(g, Vector3(-side * 8, 0, -5), Vector3(-side * 8, 0, 5), 4.5)
		people(g, Vector3(-side * 5, 0.2, 0), 12, 4.0)

func place_beach(g: Node3D, on: bool, _side: int) -> void:
	g.position = Vector3(rx(-215), 0, -224)
	for x in [-18.0, -8.0, 9.0, 19.0]:
		put(g, "nature/tree_palmBend", Vector3(x, 0, 6), 4.5, randf() * TAU)
	if on:
		for p in [Vector3(-12, 0, -2), Vector3(-4, 0, 2), Vector3(5, 0, -3), Vector3(13, 0, 1)]:
			put(g, "res://art/city/detail-parasol-a.glb", p, 8.0, randf() * TAU)
		lamps(g, Vector3(-16, 0, 4), Vector3(16, 0, 4), 5.0)
		people(g, Vector3(0, 0.1, 0), 24, 12.0)


# ------------------------------------------------------------------ test 23 Nov: LOW view behind the van (like his reference)
# black outline shell (inverted hull) on every mesh = sharp, edgy cartoon edges
var OUTL: StandardMaterial3D

func outline(o: Node3D, w := 0.03) -> void:
	if OUTL == null:
		OUTL = StandardMaterial3D.new()
		OUTL.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		OUTL.albedo_color = Color("#20140c")
		OUTL.cull_mode = BaseMaterial3D.CULL_FRONT
		OUTL.grow = true
	var m: StandardMaterial3D = OUTL.duplicate()
	m.grow_amount = w
	var list: Array = o.find_children("*", "MeshInstance3D", true, false)
	if o is MeshInstance3D:
		list.append(o)
	for c in list:
		(c as MeshInstance3D).material_overlay = m

func shiny(o: Node3D, rough := 0.35) -> void:
	recolor(o, func(m: BaseMaterial3D, _n: String):
		m.roughness = rough
		m.metallic_specular = 0.5)

func gbox(par: Node3D, size: Vector3, pos: Vector3, c: String, ow := 0.05) -> MeshInstance3D:
	var b := box(par, size, pos, c)
	b.material_override.roughness = 0.55
	outline(b, ow)
	return b

func gopuram(g: Node3D) -> void:
	# temple wall + gate tower (gopuram) + shrine; tiers with niches, kalasams on top
	var wallc := "#f1dfb8"
	gbox(g, Vector3(13, 3.2, 0.8), Vector3(0, 1.6, 0), wallc)
	for x in range(-6, 7, 2):
		gbox(g, Vector3(0.9, 0.5, 1.0), Vector3(x, 3.45, 0), "#c8402e", 0.03)
	for i in 7:
		var k := 1.0 - i * 0.11
		var w := 9.0 * k
		var d := 5.0 * k
		var y := 3.2 + i * 1.75
		gbox(g, Vector3(w, 1.5, d), Vector3(0, y + 0.75, 0), ["#f4c45a", "#e8873a", "#4fb0c6", "#e8873a", "#f4c45a", "#d9534f", "#f4c45a"][i], 0.045)
		gbox(g, Vector3(w + 0.5, 0.25, d + 0.5), Vector3(0, y + 1.5, 0), "#fff1cf", 0.03)
		for j in int(w / 1.4):
			var x := -w / 2 + 0.9 + j * 1.4
			gbox(g, Vector3(0.6, 0.9, 0.2), Vector3(x, y + 0.75, d / 2 + 0.05), ["#c8402e", "#2f7f9e", "#3e9b4f"][(i + j) % 3], 0.02)
	gbox(g, Vector3(3.2, 1.4, 2.0), Vector3(0, 16.2, 0), "#d9534f")
	for x in [-1.0, 0.0, 1.0]:
		gbox(g, Vector3(0.35, 0.9, 0.35), Vector3(x, 17.3, 0), "#ffd23a", 0.02)
	# gate opening
	gbox(g, Vector3(3.0, 4.2, 0.3), Vector3(0, 2.1, 2.6), "#4a2a16", 0.03)

func road_view(sv: SubViewport) -> Camera3D:
	sv.transparent_bg = false
	root = Node3D.new()
	sv.add_child(root)
	var we := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var pm := ProceduralSkyMaterial.new()
	pm.sky_top_color = Color("#3d9be6")
	pm.sky_horizon_color = Color("#bfe6ff")
	pm.ground_horizon_color = Color("#bfe6ff")
	pm.ground_bottom_color = Color("#7fbf4a")
	pm.sky_curve = 0.12
	sky.sky_material = pm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#cfdcf0")
	env.ambient_light_energy = 0.42
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.adjustment_enabled = true
	env.adjustment_contrast = 1.12
	env.adjustment_saturation = 1.18
	we.environment = env
	root.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("#fff0d6")
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.shadow_blur = 0.3
	sun.directional_shadow_max_distance = 120
	sun.rotation = Vector3(deg_to_rad(-38), deg_to_rad(-140), 0)
	root.add_child(sun)
	# ground: red-earth verges, grass, asphalt road going into the screen
	box(root, Vector3(300, 0.2, 400), Vector3(0, -0.1, -150), "#7fbf4a")
	box(root, Vector3(13, 0.06, 400), Vector3(0, 0.03, -150), "#c98b5a")
	var rd := box(root, Vector3(8, 0.08, 400), Vector3(0, 0.06, -150), "#4d535c")
	rd.material_override.roughness = 0.8
	for e in [-3.7, 3.7]:
		box(root, Vector3(0.22, 0.1, 400), Vector3(e, 0.07, -150), "#f2efe4")
	for i in 40:
		box(root, Vector3(0.25, 0.1, 2.4), Vector3(0, 0.07, 4 - i * 6.0), "#f6d23a")
	# kerb stones, black and white like Indian roads
	for i in 60:
		for e in [-4.3, 4.3]:
			gbox(root, Vector3(0.5, 0.3, 1.6), Vector3(e, 0.15, 6 - i * 3.2), "#f4f4f0" if i % 2 == 0 else "#2a2a2a", 0.02)
	# temple on the left, ahead
	var t := Node3D.new()
	t.position = Vector3(float(a.get("tx", -11.0)), 0, float(a.get("tz", -42.0)))
	t.rotation.y = deg_to_rad(float(a.get("tr", 38.0)))
	root.add_child(t)
	gopuram(t)
	# trees and palms both sides, buildings far right
	seed(5)
	for i in 26:
		var side := -1 if i % 2 == 0 else 1
		var z := 2.0 - i * 6.5 + randf_range(-2, 2)
		var x := side * randf_range(8.0, 16.0)
		if side < 0 and z < -25 and z > -60:
			continue
		var tr := put(root, "nature/" + ["tree_palmTall", "tree_palmBend", "tree_oak", "tree_palm"][randi() % 4], Vector3(x, 0, z), randf_range(4.5, 6.5), randf() * TAU)
		recolor(tr, _leaf)
		outline(tr, 0.02)
	for b in [["building-c", 18, -40], ["building-d", 20, -60], ["building-a", 17, -80], ["building-g", 22, -100]]:
		var o := city(root, b[0], Vector3(b[1], 0, b[2]), 7.0, -PI / 2)
		outline(o, 0.02)
	# GHILLI van: from behind, big, bottom right
	var v := ghilli_van(root, V3(a.get("van", "2.0,0.3,3.0")), float(a.get("vr", "0.0")), float(a.get("vs", "1.5")))
	shiny(v, 0.5)
	outline(v, 0.025)
	var cam := Camera3D.new()
	root.add_child(cam)
	cam.fov = float(a.get("fov", 52))
	cam.position = V3(a.get("p", "0.2,4.6,12.5"))
	cam.look_at(V3(a.get("l", "-1.2,1.2,-30")), Vector3.UP)
	cam.current = true
	return cam


# ------------------------------------------------------------------ test 2 (23 Nov): the SAME Area 2 Chennai street,
# low camera behind the GHILLI van, a plaster-textured gopuram temple on the left pavement
var TEXW: Texture2D
var TEXN: Texture2D
var TEXS: Texture2D

func pmat(c: String, stone := false) -> StandardMaterial3D:
	if TEXW == null:
		TEXW = load("res://art/a2/gen/row_0.jpg")
		TEXN = load("res://art/a2/gen/row_1.jpg")
		TEXS = load("res://art/a2/gen/row_4.jpg")
	var m := StandardMaterial3D.new()
	m.albedo_texture = TEXS if stone else TEXW
	m.albedo_color = Color(c).lightened(0.15)
	m.normal_enabled = not stone
	m.normal_texture = TEXN
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE * (0.5 if stone else 0.35)
	m.roughness = 0.85
	return m

func tbox(par: Node3D, size: Vector3, pos: Vector3, c: String, stone := false) -> MeshInstance3D:
	var b := box(par, size, pos, c)
	b.material_override = pmat(c, stone)
	return b

func temple(g: Node3D) -> void:
	# compound wall (stone) with red-white stripes, gopuram over the gate, shrine vimana behind
	for side in [-1, 1]:
		tbox(g, Vector3(6.5, 3.0, 0.7), Vector3(side * 5.25, 1.5, 0), "#d9cbb0", true)
		for i in 7:
			tbox(g, Vector3(0.46, 2.0, 0.08), Vector3(side * 5.25 - 3.0 + i * 1.0, 1.6, 0.38), "#c0392b" if i % 2 == 0 else "#f6efe2")
		tbox(g, Vector3(6.6, 0.35, 0.9), Vector3(side * 5.25, 3.15, 0), "#e8d7b0")
	var cols := ["#e9c46a", "#e07b39", "#4aa3b5", "#e07b39", "#e9c46a", "#c84a3a", "#e9c46a"]
	tbox(g, Vector3(4.6, 4.4, 4.0), Vector3(0, 2.2, 0), "#efe0bf", true)
	tbox(g, Vector3(1.9, 3.4, 0.2), Vector3(0, 1.7, 2.02), "#3b2414")
	for i in 7:
		var k := 1.0 - i * 0.1
		var w := 5.0 * k
		var d := 4.2 * k
		var y := 4.4 + i * 1.45
		tbox(g, Vector3(w, 1.2, d), Vector3(0, y + 0.6, 0), cols[i])
		tbox(g, Vector3(w + 0.3, 0.22, d + 0.3), Vector3(0, y + 1.3, 0), "#fff3d6")
		# little figure niches
		var n := maxi(2, int(w / 0.9))
		for j in n:
			var x := -w / 2 + (j + 0.5) * w / n
			tbox(g, Vector3(0.42, 0.75, 0.12), Vector3(x, y + 0.6, d / 2 + 0.06), ["#2e86ab", "#c0392b", "#27ae60", "#f39c12"][(i + j) % 4])
	tbox(g, Vector3(2.6, 1.0, 1.5), Vector3(0, 15.1, 0), "#d35400")
	for x in [-0.8, 0.0, 0.8]:
		var k := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.22
		sm.height = 0.7
		k.mesh = sm
		var km := StandardMaterial3D.new()
		km.albedo_color = Color("#f1c40f")
		km.metallic = 0.8
		km.roughness = 0.25
		k.material_override = km
		k.position = Vector3(x, 15.9, 0)
		g.add_child(k)
	# shrine behind
	tbox(g, Vector3(4, 3.5, 4), Vector3(0, 1.75, -6), "#efe0bf", true)
	for i in 3:
		tbox(g, Vector3(3.2 - i * 0.8, 1.0, 3.2 - i * 0.8), Vector3(0, 4.0 + i, -6), cols[i + 1])

func street_view(sv: SubViewport) -> Camera3D:
	sv.transparent_bg = false
	var st := Street.new()
	st.sv = sv
	sv.add_child(st)
	await get_tree().process_frame
	st.set_area(2)
	st.sun.shadow_enabled = true
	st.sun.directional_shadow_max_distance = 120
	st.process_mode = Node.PROCESS_MODE_INHERIT
	st.skip_to(12)
	st.SHOW = false
	st.EM.clear()
	st.fx.clear()
	st.process_mode = Node.PROCESS_MODE_DISABLED
	var bz: Node3D = st.bazaar
	for c in bz.get_children():
		if c is Node3D and (c as Node3D).position.distance_to(Vector3(-11, 0.18, 18.5)) < 0.5:
			c.visible = false
	var t := Node3D.new()
	t.position = V3(a.get("tp", "-34,0.18,22"))
	t.rotation.y = deg_to_rad(float(a.get("tr", "150")))
	t.scale = Vector3.ONE * float(a.get("ts", "1.0"))
	bz.add_child(t)
	temple(t)
	# the far side of the street was never built in Area 2 (behind its camera): a row of city buildings
	var far := [["building-c", -60, 31], ["building-a", -46, 31], ["building-d", -74, 31], ["building-g", -88, 31],
		["building-l", -60, -3], ["building-n", -74, -3], ["building-i", -88, -3], ["building-m", -104, 12]]
	for b in far:
		var o := city(bz, b[0], Vector3(b[1], 0.18, b[2]), 9.0, PI if b[2] > 20 else 0.0)
		if b[1] < -100:
			o.rotation.y = PI / 2
	for x in [-52, -66, -80, -94]:
		recolor(put(bz, "nature/tree_palmTall", Vector3(x, 0.18, 26), 9.0, randf() * TAU), _leaf)
	var v := ghilli_van(bz, V3(a.get("van", "6,0.3,10.5")), float(a.get("vr", "-1.45")), float(a.get("vs", "1.7")))
	var cam := st.cam
	cam.fov = float(a.get("fov", 50))
	cam.position = V3(a.get("p", "16,4.2,11.5"))
	cam.look_at(V3(a.get("l", "-30,2.0,12")), Vector3.UP)
	return cam
