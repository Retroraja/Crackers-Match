# Camera-facing glow and smoke sprites for the 3D street (street/index.html part(), sprite(), firework points),
# drawn with four MultiMeshes: soft or glow texture, normal or additive blending.
extends Node3D
class_name StreetFx

const MAX := 700
var MM := {}        # key -> MultiMeshInstance3D
var P: Array = []   # particles {key, pos, v, g, s0, s1, op, col, t, d, s(cur)}

static func radial(stops: Array) -> GradientTexture2D:
	var g := Gradient.new()
	var o := PackedFloat32Array()
	var c := PackedColorArray()
	for s in stops:
		o.append(s[0])
		c.append(s[1])
	g.offsets = o
	g.colors = c
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 64
	t.height = 64
	return t

static var GLOW: Texture2D
static var SOFT: Texture2D

static func textures() -> void:
	if GLOW:
		return
	GLOW = radial([[0.0, Color(1, 1, 1, 1)], [0.35, Color(1, 235 / 255.0, 180 / 255.0, 0.55)], [1.0, Color(0, 0, 0, 0)]])
	SOFT = radial([[0.0, Color(1, 1, 1, 0.9)], [1.0, Color(1, 1, 1, 0)]])

static func sprite_material(tex: Texture2D, add: bool, fog := true) -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded, depth_draw_never, cull_disabled, %s%s;
uniform sampler2D tex : source_color, filter_linear;
void vertex() {
	float s = length(MODEL_MATRIX[0].xyz);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0] * s, INV_VIEW_MATRIX[1] * s, INV_VIEW_MATRIX[2] * s, MODEL_MATRIX[3]);
}
void fragment() {
	vec4 t = texture(tex, UV);
	ALBEDO = COLOR.rgb * t.rgb;
	ALPHA = COLOR.a * t.a;
}
""" % ["blend_add" if add else "blend_mix", "" if fog else ", fog_disabled"]
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("tex", tex)
	return m

func _ready() -> void:
	textures()
	for k in ["glow_add", "glow_mix", "soft_add", "soft_mix"]:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_colors = true
		var q := QuadMesh.new()
		q.size = Vector2(1, 1)
		mm.mesh = q
		mm.instance_count = MAX
		mm.visible_instance_count = 0
		var mi := MultiMeshInstance3D.new()
		mi.multimesh = mm
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.material_override = sprite_material(GLOW if k.begins_with("glow") else SOFT, k.ends_with("add"))
		mi.custom_aabb = AABB(Vector3(-500, -100, -500), Vector3(1000, 400, 1000))
		add_child(mi)
		MM[k] = mi

# part(texture, pos, {s0, s1, col, op, v, g, d, add})
func part(soft: bool, pos: Vector3, o: Dictionary) -> void:
	if P.size() >= MAX * 2:
		return
	var k := ("soft_" if soft else "glow_") + ("add" if o.get("add", false) else "mix")
	P.append({"k": k, "p": pos, "v": o.get("v", Vector3.ZERO), "g": o.get("g", 0.0), "s0": o.get("s0", 1.0), "s1": o.get("s1", o.get("s0", 1.0)), "op": o.get("op", 1.0),
		"col": o.get("col", Color.WHITE), "t": 0.0, "d": o.get("d", 1.0), "in": o.get("in", 0.0), "fl": o.get("fl", 0.0)})

func step(dt: float) -> void:
	var cnt := {"glow_add": 0, "glow_mix": 0, "soft_add": 0, "soft_mix": 0}
	var keep: Array = []
	for o in P:
		o.t += dt
		var q: float = minf(1.0, o.t / o.d)
		o.p += o.v * dt
		o.v.y -= o.g * dt
		if q >= 1.0:
			continue
		keep.append(o)
		var mm: MultiMesh = MM[o.k].multimesh
		var i: int = cnt[o.k]
		if i >= MAX:
			continue
		cnt[o.k] = i + 1
		var s: float = maxf(0.001, o.s0 + (o.s1 - o.s0) * q)
		if o.get("in", 0.0) > 0.0:
			# grows to s1 in "in" seconds, then a gentle flame flicker
			s = maxf(0.001, lerpf(o.s0, o.s1, minf(1.0, o.t / float(o["in"]))))
			if o.get("fl", 0.0) > 0.0:
				s *= 1.0 + sin(o.t * o.fl) * 0.05 + sin(o.t * o.fl * 2.3) * 0.03
		mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(s, s, s)), o.p))
		var c: Color = o.col
		c.a = o.op * (1.0 - q * q)
		mm.set_instance_color(i, c)
	P = keep
	for k in cnt:
		MM[k].multimesh.visible_instance_count = cnt[k]

func clear() -> void:
	P.clear()
	for k in MM:
		MM[k].multimesh.visible_instance_count = 0
