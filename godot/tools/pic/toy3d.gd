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
	var toy := pambaram()
	toy.rotation_degrees = Vector3(0, float(a.get("spin", 0)), float(a.get("tilt", 0)))
	toy.scale = Vector3(1.35, 1.0, 1.35)   # chunky, the same bulk as the crackers on the board
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
