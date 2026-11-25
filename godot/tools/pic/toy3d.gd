# dev (24 Nov): real 3D pictures of the new goal pieces, rendered once (fps-rules: phones only show pictures).
#   -- --toy=pambaram --spin=0.0 --tilt=0 --shot=/tmp/top.png      (512x512, transparent)
# The pambaram is a lathe (turned wood) mesh: brass knob, string groove, red/yellow/green painted spiral, steel tip.
extends Node

var a := {}

func _ready() -> void:
	for s in OS.get_cmdline_user_args():
		if s.begins_with("--") and "=" in s:
			a[s.substr(2, s.find("=") - 2)] = s.substr(s.find("=") + 1)
	var sv := SubViewport.new()
	sv.size = Vector2i(512, 512)
	sv.transparent_bg = true
	sv.msaa_3d = Viewport.MSAA_8X
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sv)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55, 0.5, 0.6)
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	sv.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-38, -35, 0)
	key.light_energy = 2.2
	sv.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-10, 150, 0)
	rim.light_energy = 1.4
	rim.light_color = Color(1.0, 0.85, 0.6)
	sv.add_child(rim)
	var cam := Camera3D.new()
	cam.fov = 30
	cam.position = Vector3(0, 0.55, 3.2)
	sv.add_child(cam)
	cam.look_at(Vector3(0, 0.01, 0))
	var kind: String = a.get("toy", "pambaram")
	var toy: Node3D
	if kind == "potli":
		toy = potli()
	elif kind == "mayil":
		toy = mayil()
		cam.position = Vector3(0, 0.9, 3.4)
		cam.look_at(Vector3(0, 0.0, 0))
	else:
		toy = pambaram()
		toy.scale = Vector3(1.35, 1.0, 1.35)   # chunky, the same bulk as the crackers on the board
	toy.rotation_degrees += Vector3(0, float(a.get("spin", 0)), float(a.get("tilt", 0)))
	sv.add_child(toy)
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	sv.get_texture().get_image().save_png(a.get("shot", "/tmp/toy.png"))
	get_tree().quit()

# radius profile from the top down to the nail tip (height, radius); like the real Tamil pambaram: a round painted
# top, then a bare wooden cone, then an iron nail
const PROF := [[0.64, 0.0], [0.635, 0.08], [0.62, 0.17], [0.58, 0.27], [0.52, 0.35], [0.44, 0.41], [0.34, 0.44],
	[0.24, 0.44], [0.14, 0.41], [0.02, 0.35], [-0.12, 0.27], [-0.26, 0.19], [-0.38, 0.12], [-0.46, 0.07],
	[-0.50, 0.045], [-0.52, 0.03], [-0.53, 0.024], [-0.64, 0.016], [-0.67, 0.0]]

func _smooth() -> Array:
	var out: Array = []
	for i in PROF.size() - 1:
		var a0: Array = PROF[maxi(i - 1, 0)]
		var a1: Array = PROF[i]
		var a2: Array = PROF[i + 1]
		var a3: Array = PROF[mini(i + 2, PROF.size() - 1)]
		var n := 8 if a1[0] > -0.52 else 1
		for k in n:
			var t := float(k) / n
			var y: float = lerpf(a1[0], a2[0], t)
			var r: float = 0.5 * ((2.0 * a1[1]) + (-a0[1] + a2[1]) * t + (2.0 * a0[1] - 5.0 * a1[1] + 4.0 * a2[1] - a3[1]) * t * t + (-a0[1] + 3.0 * a1[1] - 3.0 * a2[1] + a3[1]) * t * t * t)
			out.append([y, maxf(r, 0.0)])
	out.append(PROF[PROF.size() - 1])
	return out

func pambaram() -> Node3D:
	var P := _smooth()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var SEG := 96
	var rows: Array = []
	for p in P:
		var ring: Array = []
		for s2 in SEG + 1:
			var t := float(s2) / SEG * TAU
			ring.append(Vector3(cos(t) * p[1], p[0], sin(t) * p[1]))
		rows.append(ring)
	for i in P.size() - 1:
		for s2 in SEG:
			var q := [rows[i][s2], rows[i][s2 + 1], rows[i + 1][s2 + 1], rows[i + 1][s2]]
			var y: float = (P[i][0] + P[i + 1][0]) * 0.5
			st.set_color(_paint(y, float(s2) / SEG))
			st.add_vertex(q[0]); st.add_vertex(q[2]); st.add_vertex(q[1])
			st.add_vertex(q[0]); st.add_vertex(q[3]); st.add_vertex(q[2])
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = 0.3
	m.clearcoat_enabled = true
	m.clearcoat = 0.7
	mi.material_override = m
	var n := Node3D.new()
	n.add_child(mi)
	return n

# 24 Nov (his reference photo + flag): wooden top cap, painted bands red / yellow / red on the round top,
# bare wood cone below with fine grain, an iron nail tip
func _paint(y: float, t: float) -> Color:
	var wood := Color(0.84, 0.68, 0.46)
	if y < -0.52:
		return Color(0.35, 0.36, 0.38)
	if y > 0.585:
		return wood.darkened(0.06)
	if y > 0.18:
		var k: float = (0.585 - y) / 0.405
		if k < 0.36:
			return Color(0.78, 0.02, 0.02)
		if k < 0.66:
			return Color(1.0, 0.82, 0.12)
		return Color(0.78, 0.02, 0.02)
	var g: float = sin(y * 140.0 + sin(t * TAU * 3.0) * 0.6) * 0.5 + 0.5
	return wood.darkened(0.05 + 0.08 * g)

# ---------------------------------------------------------------- 25 Nov: potli bag (red velvet, gold string)
# lathe profile (height, radius): round soft bottom, pinched neck, a ruffled frill on top
const POT := [[-0.62, 0.0], [-0.61, 0.16], [-0.56, 0.32], [-0.44, 0.45], [-0.26, 0.53], [-0.06, 0.55], [0.12, 0.5],
	[0.26, 0.4], [0.34, 0.27], [0.38, 0.17], [0.40, 0.15], [0.43, 0.17], [0.48, 0.25], [0.55, 0.32], [0.6, 0.33],
	[0.63, 0.28], [0.62, 0.0]]
func potli() -> Node3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var SEG := 120
	var P: Array = []
	# Catmull-Rom through the profile points: a smooth round cloth, no rings
	for i in POT.size() - 1:
		var a0: Array = POT[maxi(i - 1, 0)]
		var a1: Array = POT[i]
		var a2: Array = POT[i + 1]
		var a3: Array = POT[mini(i + 2, POT.size() - 1)]
		for k in 10:
			var t := float(k) / 10
			var yy := []
			for j in 2:
				yy.append(0.5 * ((2.0 * a1[j]) + (-a0[j] + a2[j]) * t + (2.0 * a0[j] - 5.0 * a1[j] + 4.0 * a2[j] - a3[j]) * t * t + (-a0[j] + 3.0 * a1[j] - 3.0 * a2[j] + a3[j]) * t * t * t))
			P.append([yy[0], maxf(yy[1], 0.0)])
	P.append(POT[POT.size() - 1])
	var rows: Array = []
	for p in P:
		var ring: Array = []
		for s2 in SEG + 1:
			var t := float(s2) / SEG * TAU
			var r: float = p[1]
			# soft cloth folds on the body, deeper ruffles on the frill
			if p[0] > 0.42:
				r *= 1.0 + 0.09 * sin(t * 14.0)
			elif p[0] > -0.5:
				r *= 1.0 + 0.025 * sin(t * 7.0 + p[0] * 4.0)
			ring.append(Vector3(cos(t) * r, p[0], sin(t) * r))
		rows.append(ring)
	for i in P.size() - 1:
		for s2 in SEG:
			var q := [rows[i][s2], rows[i][s2 + 1], rows[i + 1][s2 + 1], rows[i + 1][s2]]
			st.add_vertex(q[0]); st.add_vertex(q[2]); st.add_vertex(q[1])
			st.add_vertex(q[0]); st.add_vertex(q[3]); st.add_vertex(q[2])
	st.index()
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.5, 0.015, 0.04)
	m.roughness = 0.8
	m.metallic_specular = 0.2
	m.rim_enabled = true      # soft velvet sheen on the edges
	m.rim = 0.12
	m.rim_tint = 0.9
	mi.material_override = m
	var n := Node3D.new()
	n.add_child(mi)
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(1.0, 0.76, 0.22)
	gold.metallic = 0.85
	gold.roughness = 0.28
	# gold string round the neck, two hanging ends with knots
	var tor := TorusMesh.new()
	tor.inner_radius = 0.145
	tor.outer_radius = 0.19
	tor.rings = 48
	var tm := MeshInstance3D.new()
	tm.mesh = tor
	tm.position.y = 0.39
	tm.material_override = gold
	n.add_child(tm)
	for sx in [-1.0, 1.0]:
		var cy := CylinderMesh.new()
		cy.top_radius = 0.018
		cy.bottom_radius = 0.018
		cy.height = 0.2
		var c := MeshInstance3D.new()
		c.mesh = cy
		c.material_override = gold
		c.position = Vector3(0.035 * sx, 0.3, 0.2)
		c.rotation_degrees = Vector3(22, 0, 12 * sx)
		n.add_child(c)
		var sp := SphereMesh.new()
		sp.radius = 0.034
		sp.height = 0.068
		var k := MeshInstance3D.new()
		k.mesh = sp
		k.material_override = gold
		k.position = Vector3(0.058 * sx, 0.2, 0.235)
		n.add_child(k)
	# small gold dots sewn on the front
	for d in [Vector2(0, -0.1), Vector2(-0.18, -0.2), Vector2(0.18, -0.2), Vector2(-0.1, -0.36), Vector2(0.1, -0.36), Vector2(0, 0.08)]:
		var dot := SphereMesh.new()
		dot.radius = 0.018
		dot.height = 0.036
		var dm := MeshInstance3D.new()
		dm.mesh = dot
		dm.material_override = gold
		var ang := asin(clampf(d.x / 0.5, -1, 1))
		var y: float = d.y
		var rr := 0.0
		for i in POT.size() - 1:
			if y >= POT[i][0] and y <= POT[i + 1][0]:
				rr = lerpf(POT[i][1], POT[i + 1][1], (y - POT[i][0]) / (POT[i + 1][0] - POT[i][0]))
		dm.position = Vector3(sin(ang) * rr, y, cos(ang) * rr)
		n.add_child(dm)
	return n

# ---------------------------------------------------------------- 25 Nov: Mayil Matchbox (peacock blue/purple box,
# silver and gold edges, peacock-feather label), drawer half open with red-headed matches
func _tex_mat(path: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	var img := Image.load_from_file(ProjectSettings.globalize_path("res://tools/pic/tex/" + path))
	m.albedo_texture = ImageTexture.create_from_image(img)
	m.roughness = 0.5
	return m

func _bx(sz: Vector3, pos: Vector3, mat: Material, parent: Node3D) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = sz
	var mi := MeshInstance3D.new()
	mi.mesh = bm
	mi.position = pos
	mi.material_override = mat
	parent.add_child(mi)
	return mi

func mayil() -> Node3D:
	var n := Node3D.new()
	var Wd := 0.78
	var Hh := 1.08
	var Dp := 0.36
	var side := _tex_mat("mayil_side.png")
	var front := _tex_mat("mayil_front.png")
	var strike := _tex_mat("mayil_strike.png")
	strike.clearcoat_enabled = false
	strike.roughness = 0.9
	# outer sleeve: box, then a front quad with the label
	_bx(Vector3(Wd, Hh, Dp), Vector3.ZERO, side, n)
	var q := QuadMesh.new()
	q.size = Vector2(Wd, Hh)
	var fq := MeshInstance3D.new()
	fq.mesh = q
	fq.position = Vector3(0, 0, Dp / 2 + 0.002)
	fq.material_override = front
	n.add_child(fq)
	var sq := QuadMesh.new()
	sq.size = Vector2(Dp * 0.8, Hh * 0.82)
	var sm := MeshInstance3D.new()
	sm.mesh = sq
	sm.position = Vector3(Wd / 2 + 0.002, 0, 0)
	sm.rotation_degrees.y = 90
	sm.material_override = strike
	n.add_child(sm)
	# drawer pushed up out of the top, with matches
	var tray := StandardMaterial3D.new()
	tray.albedo_color = Color(0.62, 0.5, 0.82)
	tray.roughness = 0.7
	var dr := Node3D.new()
	dr.position.y = 0.30
	n.add_child(dr)
	_bx(Vector3(Wd - 0.06, Hh * 0.9, Dp - 0.05), Vector3(0, -0.02, 0), tray, dr)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.93, 0.8, 0.55)
	var head := StandardMaterial3D.new()
	head.albedo_color = Color(0.85, 0.08, 0.1)
	head.roughness = 0.5
	for i in 7:
		var x := -0.27 + i * 0.09
		var z := 0.04 * sin(i * 1.7)
		var c := CylinderMesh.new()
		c.top_radius = 0.018
		c.bottom_radius = 0.018
		c.height = 0.5
		var cm := MeshInstance3D.new()
		cm.mesh = c
		cm.material_override = wood
		cm.position = Vector3(x, 0.32, z)
		dr.add_child(cm)
		var sp := SphereMesh.new()
		sp.radius = 0.034
		sp.height = 0.08
		var hm := MeshInstance3D.new()
		hm.mesh = sp
		hm.material_override = head
		hm.position = Vector3(x, 0.58, z)
		dr.add_child(hm)
	# silver and gold edges round the sleeve
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(1.0, 0.78, 0.25)
	gold.metallic = 0.9
	gold.roughness = 0.25
	var silver := StandardMaterial3D.new()
	silver.albedo_color = Color(0.9, 0.92, 0.96)
	silver.metallic = 0.9
	silver.roughness = 0.2
	var e := 0.035
	for sy in [-1.0, 1.0]:
		_bx(Vector3(Wd + e, e, e), Vector3(0, sy * Hh / 2, Dp / 2), gold, n)
		_bx(Vector3(Wd + e, e, e), Vector3(0, sy * Hh / 2, -Dp / 2), silver, n)
		_bx(Vector3(e, e, Dp + e), Vector3(sy * Wd / 2, Hh / 2, 0), silver, n)
		_bx(Vector3(e, e, Dp + e), Vector3(sy * Wd / 2, -Hh / 2, 0), silver, n)
	for sx in [-1.0, 1.0]:
		_bx(Vector3(e, Hh + e, e), Vector3(sx * Wd / 2, 0, Dp / 2), gold, n)
		_bx(Vector3(e, Hh + e, e), Vector3(sx * Wd / 2, 0, -Dp / 2), silver, n)
	n.position.y = -0.2
	n.rotation_degrees = Vector3(0, -24, 0)
	return n
