# Area 3 "Busy Days at GHILLI" (21 Nov): the back store room behind the GHILLI CRACKERS shop.
# Built only for the computer: rendered to pictures (tools/pic) like Area 2, phones never draw it.
# Same look as Area 2: the Poly Haven CC0 textures already in art/a2/gen, Kenney CC0 furniture (art/shop),
# warm light. Units: meters. x across the room, y up, z towards the camera; back wall at z = -D, open front at z = 0.
extends Node3D
class_name Backroom

const W := 6.4      # room width (x -W/2..W/2)
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
	env.background_color = Color("#1a1410")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#b8a58c")
	env.ambient_light_energy = 0.32
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.1
	sun.light_color = Color("#fff0d4")
	sun.light_energy = 2.6
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30
	sun.shadow_bias = 0.04
	# from behind the back wall, high and from the left: patches of sun on the floor in front of the door and window
	sun.rotation = Vector3(deg_to_rad(-30), deg_to_rad(165), 0)
	var bulb := OmniLight3D.new()
	bulb.light_color = Color("#ffc07a")
	bulb.light_energy = 1.4
	bulb.omni_range = 7.0
	bulb.omni_attenuation = 1.4
	bulb.shadow_enabled = true
	bulb.position = Vector3(0.2, H - 0.9, -D * 0.5)
	add_child(bulb)
	O.bulb_light = bulb

# ---------------------------------------------------------------- the room
func build() -> void:
	var plaster := mat("ghilli_new_0.jpg", "ghilli_new_1.jpg", Color(1.0, 0.9, 0.72), 3.0)
	var dado := mat("row_24.jpg", "row_25.jpg", Color(0.82, 0.95, 0.92), 3.0)
	var floor_m := mat("tile_0.jpg", "tile_1.jpg", Color(0.92, 0.86, 0.8), 1.8, 0.8)
	var ceil_m := mat("ghilli_new_0.jpg", "", Color(0.85, 0.8, 0.72), 3.0)
	var wood := mat("counter_0.jpg", "", Color(0.85, 0.7, 0.55), 1.5, 0.8)
	var door_m := mat("counter_0.jpg", "", Color(0.45, 0.65, 0.95), 1.0, 0.75)
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
	var dx := 1.55; var dw := 1.1; var dh := 2.3
	var wx := -1.6; var ww := 1.2; var wy0 := 1.5; var wy1 := 2.5
	_wall_with_holes(plaster, dado, bz, t, [[dx - dw / 2, dx + dw / 2, 0.0, dh], [wx - ww / 2, wx + ww / 2, wy0, wy1]])
	# door frame and the old blue wooden door, half open (swung into the room)
	var fr := flat(Color("#5a3e2a"))
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
	var sh := alpha("res://art/a3/shaft.png", Color(1, 1, 1, 0.55), true)
	for k in 3:
		quad(sh, Vector3(wx + 0.25 + k * 0.12, 1.15, -D + 1.15), Vector2(0.9 + k * 0.1, 2.7), Vector3(deg_to_rad(-38), deg_to_rad(-8 + k * 8), 0))
	for k in 3:
		quad(sh, Vector3(dx - 0.2 + k * 0.15, 1.0, -D + 1.0), Vector2(1.0, 2.6), Vector3(deg_to_rad(-34), deg_to_rad(-6 + k * 6), 0))
	# the hanging bulb
	var cord := flat(Color("#1d1d1f"), 0.6)
	box(cord, Vector3(0.2, H - 0.45, -D * 0.5), Vector3(0.015, 0.9, 0.015))
	var bm := flat(Color("#ffd9a0"), 0.3)
	bm.emission_enabled = true
	bm.emission = Color("#ffc070")
	bm.emission_energy_multiplier = 3.0
	var bs := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.07; sm.height = 0.16
	bs.mesh = sm
	bs.material_override = bm
	bs.position = Vector3(0.2, H - 0.95, -D * 0.5)
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
