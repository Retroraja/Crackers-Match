# Area 3 "Busy Days at GHILLI" (21 Nov): the back store room behind the GHILLI CRACKERS shop.
# Built only for the computer: rendered to pictures (tools/pic) like Area 2, phones never draw it.
# Same look as Area 2: the Poly Haven CC0 textures already in art/a2/gen, Kenney CC0 furniture (art/shop),
# warm light. Units: meters. x across the room, y up, z towards the camera; back wall at z = -D, open front at z = 0.
extends Node3D
class_name Backroom

const W := 5.0      # room width (x -W/2..W/2): narrow enough for a phone-tall picture
const D := 7.0      # room depth
const H := 4.0      # ceiling
const F := 2.6      # floor runs to z = F (the shop door wall, shown only for the doorway slide)
var front := false
var ceiling := false   # true for eye-level shots (the slides); the top view leaves it out
const WH := 6.0     # walls are drawn taller than the ceiling so the top view never shows past them
const G := "res://art/a2/gen/%s"
const K := "res://art/shop/%s.glb"
var O := {}
var env: Environment
var sun: DirectionalLight3D

func tex(n: String) -> Texture2D:
	return load((G % n) if not n.begins_with("res://") else n)

# triplanar in world space: boxes of any size keep the same texture scale (like the tiled .glb pieces of Area 2)
func mat(diff: String, nor := "", tint := Color.WHITE, tile := 2.0, rough := 0.9) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex(diff)
	m.albedo_color = tint
	if nor != "":
		m.normal_enabled = true
		m.normal_texture = tex(nor)
		m.normal_scale = 0.8
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE / tile
	m.roughness = rough
	return m

func flat(c: Color, rough := 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	return m

func box(m: Material, c: Vector3, s: Vector3, parent: Node3D = null, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = s
	mi.mesh = b
	mi.material_override = m
	mi.position = c
	mi.rotation = rot
	(parent if parent else self).add_child(mi)
	return mi

func quad(m: Material, c: Vector3, s: Vector2, rot := Vector3.ZERO, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = s
	mi.mesh = q
	mi.material_override = m
	mi.position = c
	mi.rotation = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	(parent if parent else self).add_child(mi)
	return mi

func alpha(path: String, tint := Color.WHITE, add := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(path)
	m.albedo_color = tint
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if add else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	if add:
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return m

func put(path: String, pos: Vector3, s := 1.0, rot := Vector3.ZERO, parent: Node3D = null) -> Node3D:
	var o: Node3D = (load(path) as PackedScene).instantiate()
	o.scale = Vector3.ONE * s
	o.rotation = rot
	o.position = pos
	(parent if parent else self).add_child(o)
	return o

# ---------------------------------------------------------------- light: dim and dusty, sun through the back door and window
func light(world_env: Environment, dl: DirectionalLight3D) -> void:
	env = world_env
	sun = dl
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#f4ead8")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#fff6e8")
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.95
	sun.light_color = Color("#fff0d4")
	sun.light_energy = 2.6
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30
	sun.shadow_bias = 0.04
	# from behind the back wall, high and from the left: patches of sun on the floor in front of the door and window
	sun.rotation = Vector3(deg_to_rad(-30), deg_to_rad(165), 0)
	var bulb := OmniLight3D.new()
	bulb.light_color = Color("#fff4e0")
	bulb.light_energy = 1.6
	bulb.omni_range = 9.0
	bulb.omni_attenuation = 1.4
	bulb.shadow_enabled = true
	bulb.position = Vector3(-0.6, H - 0.9, -4.5)
	add_child(bulb)
	O.bulb_light = bulb
	# bright order room (21 Nov): white tube lights on both side walls fill the room, no dark corners
	for p in [Vector3(-W / 2 + 0.4, 3.0, -4.6), Vector3(W / 2 - 0.4, 3.0, -4.6), Vector3(-W / 2 + 0.4, 3.0, -1.2), Vector3(W / 2 - 0.4, 3.0, -1.2)]:
		var l := OmniLight3D.new()
		l.light_color = Color("#ffffff")
		l.light_energy = 0.45
		l.omni_range = 6.0
		l.omni_attenuation = 1.0
		l.position = p
		add_child(l)

# ---------------------------------------------------------------- the room
func build() -> void:
	var plaster := mat("ghilli_new_0.jpg", "ghilli_new_1.jpg", Color(1.08, 1.02, 0.9), 3.0)
	var dado := mat("row_24.jpg", "row_25.jpg", Color(0.62, 0.92, 1.25), 3.0)
	var floor_m := mat("res://art/a3/floor_bright.jpg", "", Color(0.95, 0.93, 0.9), 0.9, 0.6)
	var ceil_m := mat("ghilli_new_0.jpg", "", Color(0.85, 0.8, 0.72), 3.0)
	var wood := mat("counter_0.jpg", "", Color(0.85, 0.7, 0.55), 1.5, 0.8)
	var door_m := mat("counter_0.jpg", "", Color(0.55, 0.8, 1.25), 1.0, 0.6)
	var t := 0.2
	# floor and ceiling
	box(floor_m, Vector3(0, -0.05, (F - D) / 2), Vector3(W + 0.4, 0.1, D + F))
	# ceiling and beams only cast shadows (the camera looks in from above, dollhouse style)
	var cl := box(ceil_m, Vector3(0, H + 0.05, (F - D) / 2), Vector3(W + 0.4, 0.1, D + F))
	if not ceiling:
		cl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	else:
		for z in [-1.0, -3.4, -5.8]:
			box(wood, Vector3(0, H - 0.1, z), Vector3(W, 0.2, 0.18))
	# side walls: plaster above, teal dado below (an old Chennai godown)
	for sx in [-1, 1]:
		var x: float = sx * (W / 2 + t / 2)
		box(plaster, Vector3(x, (WH + 1.1) / 2, (F - D) / 2), Vector3(t, WH - 1.1, D + F))
		box(dado, Vector3(x, 0.55, (F - D) / 2), Vector3(t, 1.1, D + F))
		box(wood, Vector3(x - sx * 0.11, 1.12, (F - D) / 2), Vector3(0.03, 0.05, D + F))
	# back wall with the back door (right) and a barred window (left)
	var bz := -D - t / 2
	var dx := 1.3; var dw := 1.0; var dh := 2.3
	var wx := -1.3; var ww := 1.1; var wy0 := 1.5; var wy1 := 2.5
	_wall_with_holes(plaster, dado, bz, t, [[dx - dw / 2, dx + dw / 2, 0.0, dh], [wx - ww / 2, wx + ww / 2, wy0, wy1]])
	# door frame and the old blue wooden door, half open (swung into the room)
	var fr := flat(Color("#f2efe6"), 0.5)
	box(fr, Vector3(dx - dw / 2 - 0.06, dh / 2, -D + 0.02), Vector3(0.12, dh, 0.26))
	box(fr, Vector3(dx + dw / 2 + 0.06, dh / 2, -D + 0.02), Vector3(0.12, dh, 0.26))
	box(fr, Vector3(dx, dh + 0.06, -D + 0.02), Vector3(dw + 0.24, 0.12, 0.26))
	var hinge := Node3D.new()
	hinge.position = Vector3(dx + dw / 2, 0, -D + 0.08)
	add_child(hinge)
	box(door_m, Vector3(-dw / 2, dh / 2, 0), Vector3(dw, dh - 0.04, 0.06), hinge)
	for y in [0.5, 1.15, 1.8]:
		box(flat(Color("#2f4f80")), Vector3(-dw / 2, y, 0.04), Vector3(dw - 0.16, 0.05, 0.02), hinge)
	box(flat(Color("#c9a24a"), 0.3), Vector3(-dw + 0.12, 1.05, 0.06), Vector3(0.05, 0.16, 0.04), hinge)
	hinge.rotation.y = deg_to_rad(-62)
	O.door = hinge
	# outside the door: bright lane wall (just a lit plane, so the door glows with daylight)
	var outside := StandardMaterial3D.new()
	outside.albedo_texture = tex("ghilli_new_0.jpg")
	outside.albedo_color = Color(1.0, 0.93, 0.8)
	outside.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad(outside, Vector3(dx, 1.5, -D - 1.6), Vector2(3.2, 3.0))
	box(flat(Color(0.95, 0.9, 0.8)), Vector3(dx, -0.02, -D - 0.8), Vector3(2.4, 0.04, 1.6))
	quad(outside, Vector3(wx, 2.0, -D - 1.2), Vector2(2.4, 2.0))
	# window bars and frame
	box(fr, Vector3(wx, wy0 - 0.04, -D + 0.02), Vector3(ww + 0.16, 0.08, 0.3))
	box(fr, Vector3(wx, wy1 + 0.04, -D + 0.02), Vector3(ww + 0.16, 0.08, 0.26))
	for i in 6:
		var x := wx - ww / 2 + (i + 0.5) * ww / 6
		box(flat(Color("#2a2a2c"), 0.5), Vector3(x, (wy0 + wy1) / 2, -D - 0.02), Vector3(0.025, wy1 - wy0, 0.025))
	# sun shafts from the window and the door (soft additive strips)
	# the hanging bulb
	var cord := flat(Color("#1d1d1f"), 0.6)
	box(cord, Vector3(-0.6, H - 0.45, -4.5), Vector3(0.015, 0.9, 0.015))
	var bm := flat(Color("#ffd9a0"), 0.3)
	bm.emission_enabled = true
	bm.emission = Color("#ffc070")
	bm.emission_energy_multiplier = 3.0
	var bs := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.07; sm.height = 0.16
	bs.mesh = sm
	bs.material_override = bm
	bs.position = Vector3(-0.6, H - 0.95, -4.5)
	add_child(bs)
	messy()
	if front:
		# the wall between the shop and this room, with its doorway (the man opens this door in the start slide)
		_front_wall(plaster, dado, fr)

# a wall at z with rectangular holes [x0, x1, y0, y1]: built from boxes around the holes
func _wall_with_holes(plaster: Material, dado: Material, z: float, t: float, holes: Array) -> void:
	var xs := [-W / 2 - t]
	for h in holes:
		xs.append(h[0]); xs.append(h[1])
	xs.append(W / 2 + t)
	xs.sort()
	for i in xs.size() - 1:
		var x0: float = xs[i]; var x1: float = xs[i + 1]
		var cx := (x0 + x1) / 2
		var hole: Array = []
		for h in holes:
			if cx > h[0] and cx < h[1]:
				hole = h
		var spans: Array = []
		if hole.is_empty():
			spans = [[0.0, WH]]
		else:
			if hole[2] > 0.0:
				spans.append([0.0, hole[2]])
			spans.append([hole[3], WH])
		for s in spans:
			var y0: float = s[0]; var y1: float = s[1]
			if y0 < 1.1:
				var top := minf(y1, 1.1)
				box(dado, Vector3(cx, (y0 + top) / 2, z), Vector3(x1 - x0, top - y0, t))
				y0 = top
			if y1 > y0:
				box(plaster, Vector3(cx, (y0 + y1) / 2, z), Vector3(x1 - x0, y1 - y0, t))

# ---------------------------------------------------------------- the dusty mess (build 1 clears it)
func messy() -> void:
	O.junk = []
	var j := Node3D.new()
	add_child(j)
	O.junk_root = j
	var bc := "cardboardBoxClosed"; var bo := "cardboardBoxOpen"
	# box piles against both walls and in the middle; some tipped over
	var piles := [
		[bc, -2.6, 0.0, -5.9, 2.45, 0.2], [bc, -2.5, 0.3, -5.85, 2.3, 0.5], [bo, -2.7, 0.6, -5.9, 2.16, 1.2],
		[bc, -1.9, 0.0, -6.2, 2.45, 0.1], [bc, -2.7, 0.0, -4.9, 2.59, 0.9], [bc, -2.6, 0.32, -4.95, 2.3, 0.3],
		[bo, -2.1, 0.0, -4.2, 2.3, 2.0], [bc, 2.6, 0.0, -4.4, 2.45, 0.4], [bc, 2.6, 0.31, -4.3, 2.3, 1.0],
		[bc, 2.7, 0.0, -3.4, 2.59, 0.2], [bc, 2.55, 0.33, -3.45, 2.16, 0.7], [bc, 2.65, 0.6, -3.4, 2.02, 0.1],
		[bo, 2.4, 0.0, -2.4, 2.3, 2.6], [bc, -0.6, 0.0, -3.6, 2.45, 0.6], [bc, -0.4, 0.31, -3.7, 2.16, 1.3],
		[bo, 0.5, 0.0, -2.6, 2.16, 0.4], [bc, -1.4, 0.0, -2.1, 2.3, 2.2], [bc, 0.6, 0.0, -5.0, 2.16, 0.8],
		[bc, -2.65, 0.0, -1.3, 2.3, 0.5], [bo, 1.5, 0.0, -1.2, 2.02, 1.9],
	]
	for p in piles:
		O.junk.append(put(K % p[0], Vector3(p[1], p[2], p[3]), p[4], Vector3(0, p[5], 0), j))
	O.junk.append(put(K % bc, Vector3(-0.9, 0.13, -1.2), 2.2, Vector3(0, 0.7, PI / 2), j))
	O.junk.append(put(K % bc, Vector3(1.9, 0.13, -5.6), 2.2, Vector3(PI / 2, 0.3, 0), j))
	for o in O.junk:
		_cardboard(o)
	# burlap sacks (squashed spheres)
	var burlap := mat("res://art/a3/burlap.jpg", "", Color(1, 1, 1), 0.6)
	for s in [[-1.2, -5.7, 0.0], [-0.7, -5.9, 0.6], [-0.95, -5.4, 1.2], [1.0, -3.4, 0.3], [-2.4, -3.2, 2.0]]:
		var mi := MeshInstance3D.new()
		var sp := SphereMesh.new()
		sp.radius = 0.38; sp.height = 0.6
		mi.mesh = sp
		mi.material_override = burlap
		mi.scale = Vector3(1.0, 1.0, 0.8)
		mi.position = Vector3(s[0], 0.27, s[1])
		mi.rotation.y = s[2]
		j.add_child(mi)
		O.junk.append(mi)
	# newspaper bundles tied with string
	var paper := mat("res://art/a3/paper.jpg", "", Color(1, 1, 1), 0.5)
	var str_m := flat(Color("#b0895a"))
	for b in [[0.2, 0.0, -1.8, 0.3], [0.25, 0.22, -1.82, 0.5], [-1.7, 0.0, -3.0, 1.4], [2.0, 0.0, -1.9, 0.2]]:
		var n := Node3D.new()
		n.position = Vector3(b[0], b[1], b[2])
		n.rotation.y = b[3]
		j.add_child(n)
		box(paper, Vector3(0, 0.11, 0), Vector3(0.6, 0.22, 0.42), n)
		box(str_m, Vector3(0, 0.11, 0), Vector3(0.62, 0.23, 0.02), n)
		box(str_m, Vector3(0, 0.11, 0), Vector3(0.02, 0.23, 0.44), n)
		O.junk.append(n)
	# an old empty bookcase leaning on the left wall and a stool knocked over
	O.junk.append(put(K % "bookcaseOpen", Vector3(-2.95, 0.0, -2.9), 3.0, Vector3(0, PI / 2, deg_to_rad(-6)), j))
	# dust on the floor, cobwebs in the corners
	var dirt := alpha("res://art/a3/dirt.png", Color(1, 1, 1, 0.9))
	for d in [[-1.0, -2.5, 3.2], [1.2, -4.6, 3.0], [0.2, -1.0, 2.6], [-1.9, -5.0, 2.4]]:
		var q := quad(dirt, Vector3(d[0], 0.012, d[1]), Vector2(d[2], d[2]), Vector3(-PI / 2, 0, 0), j)
		O.junk.append(q)
	var web := alpha("res://art/a3/cobweb.png", Color(1, 1, 1, 0.8))
	O.junk.append(quad(web, Vector3(-W / 2 + 0.55, H - 0.55, -D + 0.02), Vector2(1.1, 1.1), Vector3(0, 0, PI), j))
	O.junk.append(quad(web, Vector3(W / 2 - 0.02, H - 0.5, -D + 0.6), Vector2(1.2, 1.0), Vector3(0, -PI / 2, PI), j))
	O.junk.append(quad(web, Vector3(-W / 2 + 0.02, H - 0.5, -1.0), Vector2(1.2, 1.0), Vector3(0, PI / 2, PI / 2), j))
	# the mess was laid out for a 6.4 m room: pull it in to this width (cobwebs stay on the walls)
	for c in j.get_children():
		var n3 := c as Node3D
		if absf(absf(n3.position.x) - W / 2) > 0.1:
			n3.position.x *= W / 6.4

func _front_wall(plaster: Material, dado: Material, fr: Material) -> void:
	var z := F + 0.1
	var dw := 1.2; var dh := 2.3
	for sx in [-1, 1]:
		var x0 := dw / 2; var x1 := W / 2 + 0.2
		box(plaster, Vector3(sx * (x0 + x1) / 2, (H + 1.1) / 2, z), Vector3(x1 - x0, H - 1.1, 0.2))
		box(dado, Vector3(sx * (x0 + x1) / 2, 0.55, z), Vector3(x1 - x0, 1.1, 0.2))
		box(fr, Vector3(sx * (dw / 2 + 0.06), dh / 2, z), Vector3(0.12, dh, 0.3))
	box(plaster, Vector3(0, (H + dh) / 2, z), Vector3(dw, H - dh, 0.2))
	# the shop floor on our side of the door (same tiles as the GHILLI shop)
	box(mat("tile_0.jpg", "tile_1.jpg", Color(1.0, 0.96, 0.9), 1.8, 0.7), Vector3(0, -0.05, z + 2.5), Vector3(W, 0.1, 5.0))
	box(fr, Vector3(0, dh + 0.06, z), Vector3(dw + 0.24, 0.12, 0.3))
	# the door leaf swung open into the room (hinge on the left)
	var hinge := Node3D.new()
	hinge.position = Vector3(-dw / 2, 0, z - 0.12)
	add_child(hinge)
	box(mat("counter_0.jpg", "", Color(0.45, 0.65, 0.95), 1.0, 0.75), Vector3(dw / 2, dh / 2, 0), Vector3(dw - 0.04, dh - 0.04, 0.06), hinge)
	hinge.rotation.y = deg_to_rad(70)
	# shop light falling in through the doorway
	var l := OmniLight3D.new()
	l.light_color = Color("#fff2dc")
	l.light_energy = 1.2
	l.omni_range = 6.0
	l.position = Vector3(0.0, 2.2, z + 1.2)
	add_child(l)

# Kenney boxes are a light peach: old brown cardboard, a little dusty
var _cb := {}
func _cardboard(o: Node3D) -> void:
	for c in o.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.get_active_material(i)
			if src is StandardMaterial3D:
				if not _cb.has(src):
					var m: StandardMaterial3D = src.duplicate()
					m.albedo_color = m.albedo_color.lerp(Color(0.62, 0.48, 0.34), 0.55)
					m.roughness = 0.95
					_cb[src] = m
				mi.set_surface_override_material(i, _cb[src])

# ================================================================ the 9 builds (21 Nov, docs/plans.md Area 3)
# Each build is a Node3D group, hidden until built. skip_to(n) shows the room after n builds (for the pictures).
# Every build after the first also pins one order slip on the order board (the board fills up through the area).
const TASKS := [
	{"n": "Clear the Back Room", "c": 2, "ic": "🧹", "site": [0, 0.3, -4.0]},
	{"n": "Phone Order Desk", "c": 2, "ic": "☎️", "site": [0, 1.0, -6.6]},
	{"n": "Stock Racks", "c": 3, "ic": "🗄️", "site": [-2.1, 1.6, -1.3]},
	{"n": "Packing Table", "c": 3, "ic": "📦", "site": [0.3, 0.6, -3.0]},
	{"n": "Gift Box & Wrap Table", "c": 3, "ic": "🎁", "site": [2.2, 1.0, -3.6]},
	{"n": "Bill Desk & Weighing Scale", "c": 4, "ic": "🧾", "site": [-1.6, 0.6, -6.0]},
	{"n": "Fire Safety Corner", "c": 4, "ic": "🧯", "site": [2.0, 0.8, -1.7]},
	{"n": "Delivery Cycle", "c": 4, "ic": "🚲", "site": [1.5, 0.6, -5.4]},
	{"n": "Ready Orders Corner", "c": 5, "ic": "🚚", "site": [-0.3, 0.5, -0.6]},
]
var B: Array = []      # Node3D per build
var slips: Array = []  # slip i is pinned by build i + 1

func pic_mat(path: String, rough := 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(path)
	m.roughness = rough
	return m

func cyl(m: Material, c: Vector3, r: float, h: float, parent: Node3D, rot := Vector3.ZERO, r2 := -1.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r if r2 < 0 else r2
	cm.height = h
	cm.radial_segments = 20
	mi.mesh = cm
	mi.material_override = m
	mi.position = c
	mi.rotation = rot
	parent.add_child(mi)
	return mi

func group(i: int) -> Node3D:
	if B.is_empty():
		for k in TASKS.size():
			var n := Node3D.new()
			add_child(n)
			B.append(n)
	return B[i]

# a gift box with a gold ribbon cross
func gift(c: Vector3, s: Vector3, col: Color, parent: Node3D, ry := 0.0) -> void:
	var n := Node3D.new()
	n.position = c
	n.rotation.y = ry
	parent.add_child(n)
	box(flat(col, 0.5), Vector3(0, s.y / 2, 0), s, n)
	var gold := flat(Color("#f5c542"), 0.3)
	gold.metallic = 0.5
	box(gold, Vector3(0, s.y / 2, 0), Vector3(s.x + 0.01, s.y + 0.01, 0.04), n)
	box(gold, Vector3(0, s.y / 2, 0), Vector3(0.04, s.y + 0.01, s.z + 0.01), n)
	box(gold, Vector3(-0.04, s.y + 0.03, 0), Vector3(0.07, 0.05, 0.1), n, Vector3(0, 0, 0.6))
	box(gold, Vector3(0.04, s.y + 0.03, 0), Vector3(0.07, 0.05, 0.1), n, Vector3(0, 0, -0.6))

# a cracker carton with its label on the front (+z of the carton)
func carton(c: Vector3, s: Vector3, i: int, parent: Node3D, ry := 0.0) -> void:
	var n := Node3D.new()
	n.position = c
	n.rotation.y = ry
	parent.add_child(n)
	box(flat(Color("#b9946a"), 0.95), Vector3(0, s.y / 2, 0), s, n)
	var q := quad(pic_mat("res://art/a3/carton%d.jpg" % (i % 6)), Vector3(0, s.y / 2, s.z / 2 + 0.003), Vector2(s.x * 0.98, s.y * 0.98), Vector3.ZERO, n)
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func builds() -> void:
	var wood := mat("counter_0.jpg", "", Color(0.95, 0.78, 0.6), 1.2, 0.75)
	var dark_wood := mat("counter_0.jpg", "", Color(0.6, 0.42, 0.3), 1.2, 0.75)
	var steel := flat(Color("#7b8794"), 0.45)
	steel.metallic = 0.6
	var black := flat(Color("#202024"), 0.5)
	# tube light fittings on the side walls (the room is bright from the start)
	for tz in [-4.6, -1.2]:
		for sx in [-1, 1]:
			put(G % "tube.glb", Vector3(sx * (W / 2 - 0.1), 3.0, tz), 1.0, Vector3(0, PI / 2, 0))
	# 1 clear the back room: the junk goes (handled in skip_to); a broom and a bucket stay by the back wall
	var g := group(0)
	cyl(flat(Color("#c79a52")), Vector3(-2.3, 0.75, -6.75), 0.02, 1.5, g, Vector3(0, 0, 0.12))
	cyl(flat(Color("#d9c58a")), Vector3(-2.22, 0.12, -6.75), 0.14, 0.24, g, Vector3.ZERO, 0.08)
	cyl(flat(Color("#3a7ec9"), 0.4), Vector3(2.15, 0.16, -6.6), 0.16, 0.32, g, Vector3.ZERO, 0.13)
	# 2 phone order desk: a desk under the order board, a big red phone, the open order book, pen stand and a chair
	g = group(1)
	var bx := 0.05
	box(pic_mat("res://art/a3/cork.jpg"), Vector3(bx, 1.95, -D + 0.03), Vector3(1.5, 1.0, 0.05), g)
	var dk := Node3D.new()
	dk.position = Vector3(bx, 0, -D + 0.42)
	g.add_child(dk)
	box(wood, Vector3(0, 0.76, 0), Vector3(1.3, 0.06, 0.62), dk)
	box(dark_wood, Vector3(-0.45, 0.37, 0), Vector3(0.36, 0.74, 0.58), dk)
	for lx in [0.6]:
		for lz in [-0.26, 0.26]:
			box(dark_wood, Vector3(lx, 0.37, lz), Vector3(0.06, 0.74, 0.06), dk)
	box(flat(Color("#f8f3e4")), Vector3(0.12, 0.8, 0.08), Vector3(0.42, 0.02, 0.3), dk, Vector3(0, 0.1, 0))
	box(flat(Color("#2e86de")), Vector3(0.12, 0.795, 0.08), Vector3(0.44, 0.012, 0.32), dk, Vector3(0, 0.1, 0))
	cyl(flat(Color("#f5c542"), 0.4), Vector3(0.48, 0.85, -0.12), 0.05, 0.12, dk)
	# chair
	var ch := Node3D.new()
	ch.position = Vector3(bx + 0.1, 0, -D + 1.05)
	g.add_child(ch)
	box(flat(Color("#2ead5b"), 0.5), Vector3(0, 0.45, 0), Vector3(0.45, 0.05, 0.42), ch)
	box(flat(Color("#2ead5b"), 0.5), Vector3(0, 0.75, 0.2), Vector3(0.45, 0.55, 0.05), ch)
	for lx in [-0.19, 0.19]:
		for lz in [-0.18, 0.18]:
			box(steel, Vector3(lx, 0.22, lz), Vector3(0.04, 0.44, 0.04), ch)
	var ph := Node3D.new()
	ph.position = Vector3(bx - 0.3, 0.79, -D + 0.42)
	ph.scale = Vector3.ONE * 1.4
	g.add_child(ph)
	var red := flat(Color("#b3202c"), 0.35)
	box(red, Vector3(0, 0.07, 0), Vector3(0.3, 0.14, 0.24), ph, Vector3(-0.15, 0, 0))
	cyl(flat(Color("#f0e6d0"), 0.4), Vector3(0, 0.15, 0.03), 0.07, 0.02, ph, Vector3(-0.5, 0, 0))
	box(red, Vector3(0, 0.19, -0.02), Vector3(0.34, 0.05, 0.07), ph)
	box(black, Vector3(0.24, 0.02, 0.0), Vector3(0.04, 0.04, 0.04), ph)
	# the first slip comes with the board
	# 6 bill desk (under the window) with the green cash box, the bill book and a platform weighing scale
	g = group(5)
	put(K % "kitchenBar", Vector3(-1.75, 0, -6.15), 3.0, Vector3(0, PI, 0), g)
	put(K % "kitchenBarEnd", Vector3(-0.46, 0, -6.15), 3.0, Vector3(0, PI, 0), g)
	put(G % "cashbox.glb", Vector3(-1.95, 1.12, -6.2), 1.0, Vector3(0, 0.2, 0), g)
	box(flat(Color("#f4efe0")), Vector3(-1.25, 1.14, -6.15), Vector3(0.3, 0.04, 0.22), g, Vector3(0, -0.2, 0))
	box(flat(Color("#c8283a")), Vector3(-1.25, 1.165, -6.15), Vector3(0.3, 0.01, 0.06), g, Vector3(0, -0.2, 0))
	var sc := Node3D.new()
	sc.position = Vector3(-2.0, 0, -5.2)
	g.add_child(sc)
	box(steel, Vector3(0, 0.07, 0), Vector3(0.6, 0.14, 0.5), sc)
	box(flat(Color("#2e86de"), 0.4), Vector3(0, 0.15, 0), Vector3(0.56, 0.02, 0.46), sc)
	box(steel, Vector3(0, 0.6, -0.22), Vector3(0.05, 0.95, 0.05), sc)
	cyl(flat(Color("#f8f3e4"), 0.3), Vector3(0, 1.12, -0.2), 0.16, 0.05, sc, Vector3(PI / 2, 0, 0))
	cyl(flat(Color("#c8283a"), 0.4), Vector3(0, 1.12, -0.23), 0.18, 0.04, sc, Vector3(PI / 2, 0, 0))
	box(black, Vector3(0.04, 1.14, -0.17), Vector3(0.1, 0.012, 0.01), sc, Vector3(0, 0, 0.6))
	carton(Vector3(0, 0.16, 0), Vector3(0.34, 0.26, 0.3), 1, sc)
	# 4 packing table: brown paper roll, string, parcels half done
	g = group(3)
	var t := Node3D.new()
	t.position = Vector3(0.3, 0, -3.0)
	g.add_child(t)
	box(wood, Vector3(0, 0.86, 0), Vector3(1.8, 0.07, 0.9), t)
	for lx in [-0.82, 0.82]:
		for lz in [-0.38, 0.38]:
			box(dark_wood, Vector3(lx, 0.42, lz), Vector3(0.07, 0.84, 0.07), t)
	box(dark_wood, Vector3(0, 0.25, 0), Vector3(1.6, 0.04, 0.8), t)
	var kraft := flat(Color("#b98a55"), 0.9)
	cyl(kraft, Vector3(-0.55, 0.98, -0.18), 0.09, 0.7, t, Vector3(0, 0, PI / 2))
	box(kraft, Vector3(-0.1, 0.9, 0.05), Vector3(0.7, 0.005, 0.5), t, Vector3(0, 0.15, 0))
	cyl(flat(Color("#e8dcc0")), Vector3(0.62, 0.95, -0.25), 0.06, 0.1, t)
	var str_m := flat(Color("#e9e0c8"))
	for p in [[0.3, 0.1, 0.36, 0.2], [0.65, 0.12, 0.3, -0.3], [0.45, 0.02, 0.28, 0.6]]:
		var pn := Node3D.new()
		pn.position = Vector3(p[0], 0.895, p[1])
		pn.rotation.y = p[3]
		t.add_child(pn)
		box(kraft, Vector3(0, p[2] / 2, 0), Vector3(0.32, p[2], 0.26), pn)
		box(str_m, Vector3(0, p[2] / 2, 0), Vector3(0.33, p[2] + 0.005, 0.015), pn)
		box(str_m, Vector3(0, p[2] / 2, 0), Vector3(0.015, p[2] + 0.005, 0.27), pn)
	put(K % "cardboardBoxOpen", Vector3(1.0, 0, -2.3), 2.0, Vector3(0, 0.3, 0), g)
	# 5 gift box & wrap table: the gift-box shelf on the right wall and the wrap table in front of it
	g = group(4)
	var sh := Node3D.new()
	sh.position = Vector3(W / 2 - 0.3, 0, -3.9)
	sh.rotation.y = -PI / 2
	g.add_child(sh)
	for sx in [-0.8, 0.8]:
		box(dark_wood, Vector3(sx, 1.2, 0), Vector3(0.06, 2.4, 0.5), sh)
	box(dark_wood, Vector3(0, 1.2, -0.24), Vector3(1.66, 2.4, 0.02), sh)
	var gcols := [Color("#d62846"), Color("#2e86de"), Color("#7b3fbf"), Color("#2ead5b"), Color("#ff7a1a"), Color("#e84a5f"), Color("#f5c542")]
	var k := 0
	for r in 4:
		var y := 0.08 + r * 0.6
		box(wood, Vector3(0, y, 0), Vector3(1.6, 0.04, 0.48), sh)
		var x := -0.68
		while x < 0.62:
			var w := 0.22 + (k % 3) * 0.05
			var hh := 0.2 + ((k * 7) % 4) * 0.05
			gift(Vector3(x + w / 2, y + 0.02, 0.0), Vector3(w, hh, 0.3), gcols[k % gcols.size()], sh, (k % 2) * 0.08)
			x += w + 0.06
			k += 1
	var gw := Node3D.new()
	gw.position = Vector3(1.55, 0, -3.3)
	gw.rotation.y = -PI / 2 + 0.1
	g.add_child(gw)
	box(wood, Vector3(0, 0.76, 0), Vector3(1.1, 0.06, 0.7), gw)
	for lx in [-0.48, 0.48]:
		for lz in [-0.3, 0.3]:
			box(dark_wood, Vector3(lx, 0.37, lz), Vector3(0.06, 0.74, 0.06), gw)
	cyl(flat(Color("#c79a52")), Vector3(0.62, 0.3, 0.45), 0.2, 0.6, gw)
	for i in 6:
		var a := i * TAU / 6
		cyl(pic_mat("res://art/a3/wrap%d.jpg" % (i % 4)), Vector3(0.62 + cos(a) * 0.09, 0.75, 0.45 + sin(a) * 0.09), 0.045, 0.9, gw, Vector3(sin(a) * 0.15, 0, cos(a) * 0.15))
	for i in 3:
		cyl(flat(gcols[i], 0.4), Vector3(-0.35 + i * 0.16, 0.83, -0.18), 0.06, 0.08, gw)
	box(pic_mat("res://art/a3/wrap0.jpg"), Vector3(0.1, 0.8, 0.08), Vector3(0.5, 0.005, 0.4), gw, Vector3(0, 0.3, 0))
	var bas := cyl(flat(Color("#b88648"), 0.95), Vector3(-0.2, 0.92, 0.12), 0.17, 0.25, gw, Vector3.ZERO, 0.13)
	bas.name = "hamper"
	gift(Vector3(-0.25, 0.95, 0.1), Vector3(0.14, 0.18, 0.14), gcols[0], gw)
	gift(Vector3(-0.12, 0.95, 0.16), Vector3(0.12, 0.14, 0.12), gcols[3], gw)
	# 3 stock racks (left wall, front): steel racks to the ceiling full of Sivakasi cracker cartons
	g = group(2)
	for rz in [-1.85, -0.55]:
		var rk := Node3D.new()
		rk.position = Vector3(-W / 2 + 0.35, 0, rz)
		rk.rotation.y = PI / 2
		g.add_child(rk)
		for px in [-0.6, 0.6]:
			for pz in [-0.25, 0.25]:
				box(steel, Vector3(px, H / 2 - 0.1, pz), Vector3(0.05, H - 0.2, 0.05), rk)
		for r in 5:
			var y := 0.12 + r * 0.74
			box(steel, Vector3(0, y, 0), Vector3(1.26, 0.03, 0.54), rk)
			for c in 3:
				carton(Vector3(-0.4 + c * 0.4, y + 0.015, 0.0), Vector3(0.36, 0.3 + (r + c) % 2 * 0.08, 0.44), r * 3 + c, rk)
	# 8 the delivery cycle by the back door, carrier box full of parcels
	g = group(7)
	var cy := Node3D.new()
	cy.position = Vector3(1.45, 0, -5.45)
	cy.rotation.y = 0.35
	g.add_child(cy)
	var frame_m := flat(Color("#1f5fbf"), 0.35)
	frame_m.metallic = 0.4
	for wx in [-0.55, 0.55]:
		var tor := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.3
		tm.outer_radius = 0.35
		tor.mesh = tm
		tor.material_override = black
		tor.position = Vector3(wx, 0.35, 0)
		tor.rotation.x = PI / 2
		cy.add_child(tor)
		cyl(steel, Vector3(wx, 0.35, 0), 0.03, 0.12, cy, Vector3(PI / 2, 0, 0))
	for seg in [[Vector3(-0.55, 0.35, 0), Vector3(0.0, 0.35, 0)], [Vector3(0.0, 0.35, 0), Vector3(0.45, 0.85, 0)], [Vector3(-0.55, 0.35, 0), Vector3(-0.15, 0.85, 0)], [Vector3(-0.15, 0.85, 0), Vector3(0.45, 0.85, 0)], [Vector3(0.0, 0.35, 0), Vector3(-0.15, 0.85, 0)], [Vector3(0.55, 0.35, 0), Vector3(0.45, 0.95, 0)]]:
		var a: Vector3 = seg[0]; var b2: Vector3 = seg[1]
		var mid := (a + b2) / 2
		var mi := cyl(frame_m, mid, 0.025, a.distance_to(b2), cy)
		mi.basis = Basis(Quaternion(Vector3.UP, (b2 - a).normalized()))
	box(black, Vector3(-0.15, 0.92, 0), Vector3(0.22, 0.05, 0.12), cy)
	box(steel, Vector3(0.45, 1.0, 0), Vector3(0.04, 0.04, 0.5), cy)
	box(steel, Vector3(-0.55, 0.78, 0), Vector3(0.45, 0.03, 0.3), cy)
	box(flat(Color("#c8283a"), 0.6), Vector3(-0.55, 0.96, 0), Vector3(0.42, 0.32, 0.34), cy)
	box(flat(Color("#f5c542"), 0.4), Vector3(-0.55, 0.97, 0.172), Vector3(0.3, 0.1, 0.005), cy)
	box(kraft, Vector3(-0.55, 1.18, 0), Vector3(0.3, 0.14, 0.24), cy, Vector3(0, 0.3, 0))
	# 7 fire safety corner (front right): red stand of sand buckets, an extinguisher, the FIRE SAFETY sign
	g = group(6)
	var fs := Node3D.new()
	fs.position = Vector3(W / 2 - 0.25, 0, -1.7)
	fs.rotation.y = -PI / 2
	g.add_child(fs)
	var redp := flat(Color("#d0202e"), 0.4)
	box(redp, Vector3(0, 1.3, -0.05), Vector3(1.2, 0.06, 0.06), fs)
	for lx in [-0.58, 0.58]:
		box(redp, Vector3(lx, 0.65, -0.05), Vector3(0.06, 1.3, 0.06), fs)
	for i in 3:
		var bxp := -0.38 + i * 0.38
		cyl(redp, Vector3(bxp, 1.02, 0.03), 0.13, 0.26, fs, Vector3.ZERO, 0.1)
		cyl(flat(Color("#e8cf8e"), 0.95), Vector3(bxp, 1.15, 0.03), 0.12, 0.01, fs)
		box(steel, Vector3(bxp, 1.27, -0.04), Vector3(0.04, 0.08, 0.04), fs)
	var ex := Node3D.new()
	ex.position = Vector3(0.85, 0, 0.1)
	fs.add_child(ex)
	cyl(redp, Vector3(0, 0.35, 0), 0.11, 0.7, ex)
	box(black, Vector3(0, 0.75, 0), Vector3(0.12, 0.1, 0.12), ex)
	box(black, Vector3(0.1, 0.72, 0), Vector3(0.18, 0.03, 0.03), ex, Vector3(0, 0, -0.4))
	cyl(flat(Color("#e8cf8e"), 0.95), Vector3(-0.85, 0.2, 0.15), 0.25, 0.4, fs)
	var sign := quad(pic_mat("res://art/a3/firesign.jpg"), Vector3(0, 1.85, -0.07), Vector2(0.9, 0.45), Vector3.ZERO, fs)
	sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# 9 ready orders corner (front): packed parcels on a wooden pallet, tagged for other towns
	g = group(8)
	var ro := Node3D.new()
	ro.position = Vector3(-0.35, 0, -0.6)
	ro.rotation.y = 0.12
	g.add_child(ro)
	box(dark_wood, Vector3(0, 0.07, 0), Vector3(1.6, 0.14, 1.0), ro)
	var ti := 0
	for layer in 3:
		var nx := 4 - layer
		for ix in nx:
			for iz in 2:
				var c := Vector3(-0.6 + layer * 0.2 + ix * 0.4, 0.14 + layer * 0.3, -0.22 + iz * 0.44)
				var pn := Node3D.new()
				pn.position = c
				pn.rotation.y = randf_range(-0.08, 0.08)
				ro.add_child(pn)
				box(kraft, Vector3(0, 0.14, 0), Vector3(0.38, 0.28, 0.42), pn)
				box(str_m, Vector3(0, 0.14, 0), Vector3(0.385, 0.285, 0.02), pn)
				box(str_m, Vector3(0, 0.14, 0), Vector3(0.02, 0.285, 0.425), pn)
				if iz == 1:
					var tg := quad(pic_mat("res://art/a3/tag%d.jpg" % (ti % 4)), Vector3(0.07, 0.16, 0.213), Vector2(0.2, 0.075), Vector3(0, 0, randf_range(-0.1, 0.1)), pn)
					tg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
					ti += 1
	# a big tag on top: the first parcel going to Madurai
	var big := quad(pic_mat("res://art/a3/tag2.jpg"), Vector3(0.0, 1.06, 0.1), Vector2(0.42, 0.16), Vector3(-1.0, 0, 0), ro)
	big.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# order slips on the board: one per build from build 2 on
	for i in 8:
		var sm := pic_mat("res://art/a3/slip%d.jpg" % (i % 4))
		var col := i % 4
		var row := i / 4
		var sl := quad(sm, Vector3(bx - 0.5 + col * 0.33 + (row % 2) * 0.08, 2.17 - row * 0.42, -D + 0.065), Vector2(0.24, 0.3), Vector3(0, 0, randf_range(-0.12, 0.12)))
		var pin := box(flat(Color("#e8243c"), 0.3), Vector3(0, 0.12, 0.01), Vector3(0.035, 0.035, 0.03), sl)
		pin.position = Vector3(0, 0.12, 0.01)
		slips.append(sl)

func _person(kind: String, pos: Vector3, rot_y: float, s: float, parent: Node3D) -> void:
	var o := put("res://art/a2/people/character-%s.glb" % kind, pos, s, Vector3(0, rot_y, 0), parent)
	var ap: AnimationPlayer = o.find_child("AnimationPlayer", true, false)
	if ap and ap.has_animation("idle"):
		ap.play("idle")
		ap.seek(0.3, true)
		ap.pause()

# the room after n builds (0 = the mess)
func skip_to(n: int) -> void:
	if B.is_empty():
		builds()
	O.junk_root.visible = n < 1
	for i in B.size():
		(B[i] as Node3D).visible = i < n
	for i in slips.size():
		(slips[i] as Node3D).visible = i + 1 < n
