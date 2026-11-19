# Builds Godot controls from a layout captured from the web game (ui/*.json, made by the converter
# from the live page). Each web element becomes a Control at the same place and size with the same
# CSS box (shader), text (same font, size, colour, outline, shadow) and pictures.
extends RefCounted
class_name WebLayout

const BOX := preload("res://scripts/ui/box.gdshader")
const BAKED := preload("res://scripts/ui/baked.gdshader")

# ---------------------------------------------------------------- painted once (18 Nov speed fix)
# The CSS box shader (rounded corners, gradients, borders, soft shadows) is heavy per pixel. A level had 68 of
# them covering 4.3 screens, every frame. Now each box is painted ONCE into a picture in a hidden SubViewport,
# then shown with a plain picture shader. resize_box / set_bg / reskin call bake() again after a change.
const BAKE_SCALE := 2.0
static var _bk: Node
static var _bq: Array = []
static func bake(cr: ColorRect) -> void:
	# OFF (19 Nov): painting boxes once broke the instruction cards on phones (solid oval, late text)
	if not OS.get_cmdline_user_args().has("--bake=1"):
		return
	if cr == null or not is_instance_valid(cr) or not (cr.material is ShaderMaterial):
		return
	var m: ShaderMaterial = cr.material
	m.shader = BOX
	if not _bq.has(cr):
		_bq.append(cr)
	if _bk == null or not is_instance_valid(_bk):
		_bk = Node.new()
		_bk.name = "BoxBaker"
		(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(_bk)
		_bake_loop.call_deferred()

static func _bake_loop() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	while true:
		await tree.process_frame
		if _bq.is_empty() or not _bk.is_inside_tree():
			continue
		# only boxes that are on screen now are painted (hidden screens wait), 12 per frame
		var batch: Array = []
		var rest: Array = []
		for cr in _bq:
			if not is_instance_valid(cr):
				continue
			if batch.size() < 12 and cr.is_visible_in_tree():
				batch.append(cr)
			else:
				rest.append(cr)
		_bq = rest
		var jobs := []
		for cr in batch:
			if cr.size.x < 1 or cr.size.y < 1:
				continue
			var k := minf(BAKE_SCALE, 2048.0 / maxf(cr.size.x, cr.size.y))
			var vp := SubViewport.new()
			vp.transparent_bg = true
			vp.disable_3d = true
			vp.size = Vector2i(ceili(cr.size.x * k), ceili(cr.size.y * k))
			vp.render_target_update_mode = SubViewport.UPDATE_ONCE
			var c2 := ColorRect.new()
			c2.size = cr.size
			c2.scale = Vector2(k, k)
			var m2: ShaderMaterial = (cr.material as ShaderMaterial).duplicate()
			m2.shader = BOX
			c2.material = m2
			vp.add_child(c2)
			_bk.add_child(vp)
			jobs.append([cr, vp, cr.size])
		if jobs.is_empty():
			continue
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		for j in jobs:
			var cr: ColorRect = j[0]
			var vp: SubViewport = j[1]
			if is_instance_valid(cr) and cr.size == j[2] and not _bq.has(cr):
				var img := vp.get_texture().get_image()
				# an empty picture means the viewport did not draw yet: try again later, keep the live shader
				if img and img.is_invisible():
					_bq.append(cr)
				elif img:
					var m: ShaderMaterial = cr.material
					m.shader = BAKED
					m.set_shader_parameter("baked", ImageTexture.create_from_image(img))
			vp.queue_free()
const TGRAD := preload("res://scripts/ui/textgrad.gdshader")
static var _fonts := {}
static var _svg := {}
static var _tex := {}

var by_id := {}       # element id -> Control
var nodes: Array = [] # all element controls, by index
var data: Array = []
var root: Control

static func font(n: String) -> Font:
	# the web page declares "Titan" twice; the second face (Lilita One) is the one browsers use
	if n == "TitanOne":
		n = "LilitaOne"
	if not _fonts.has(n):
		var p := "res://fonts/%s.ttf" % n
		_fonts[n] = load(p) if ResourceLoader.exists(p) else load("res://fonts/Sora-500.ttf")
	return _fonts[n]

static func col(a) -> Color:
	if a == null:
		return Color(0, 0, 0, 0)
	return Color(a[0], a[1], a[2], a[3])

# SVG text by path ("svg/x.svg"). In the APK the raw .svg files are not packed (Godot imports them as textures),
# so all of them are kept in ui/svgs.json (made by tools/pack_svgs.py). The json wins; the file is the fallback.
static var _svgs = null
static func svg_text(path: String) -> String:
	if _svgs == null:
		_svgs = JSON.parse_string(FileAccess.get_file_as_string("res://ui/svgs.json"))
		if _svgs == null:
			_svgs = {}
	if _svgs.has(path):
		return _svgs[path]
	return FileAccess.get_file_as_string("res://ui/" + path)

# picture from svg_text(): SVG text, or "png:<base64>" for art that was drawn outside (soft shading)
static func svg_img(s: String, sc: float) -> Image:
	var img := Image.new()
	var err: int
	if s.begins_with("png:"):
		err = img.load_png_from_buffer(Marshalls.base64_to_raw(s.substr(4)))
	else:
		err = img.load_svg_from_string(s, sc)
	return img if err == OK else null

static func tex(src: String) -> Texture2D:
	if _tex.has(src):
		return _tex[src]
	var t: Texture2D = null
	if src.begins_with("ui:"):
		var p0 := "res://ui/" + src.substr(3)
		if p0.ends_with(".svg"):
			var img := svg_img(svg_text(src.substr(3)), 3.0)
			if img:
				t = ImageTexture.create_from_image(img)
		elif ResourceLoader.exists(p0):
			t = load(p0)
	elif src.begins_with("crk:"):
		var p := "res://art/crk/%s.webp" % src.substr(4)
		if ResourceLoader.exists(p):
			t = load(p)
	elif src.begins_with("art/brk/") and ResourceLoader.exists("res://" + src):
		t = load("res://" + src)
	else:
		var f := src.get_file()
		for p in ["res://art/web/" + f, "res://art/" + f]:
			if ResourceLoader.exists(p):
				t = load(p)
				break
	_tex[src] = t
	return t

static func svg_tex(path: String, w: float, h: float) -> Texture2D:
	var key := "%s@%d" % [path, int(w * 3)]
	if _svg.has(key):
		return _svg[key]
	var s := svg_text(path)
	# render at 3x so it stays sharp on phones
	# the picture's own width: the <svg> tag's width="" (not stroke-width), else its viewBox
	# (18 Nov: reading stroke-width here made the win title 4680x10128 = 181 MB and slowed every phone)
	var vb := 0.0
	var tag := s.substr(0, s.find(">"))
	var m := RegEx.create_from_string("\\swidth=\"([0-9.]+)").search(tag)
	if m:
		vb = float(m.get_string(1))
	else:
		var v := RegEx.create_from_string("viewBox=\"[-0-9.]+[ ,]+[-0-9.]+[ ,]+([0-9.]+)").search(tag)
		if v:
			vb = float(v.get_string(1))
	var sc := 3.0 * (w / vb if vb > 0.0 else 1.0)
	# never bigger than 2048 px on the long side (phones), about 3x the screen is plenty
	var img := svg_img(s, clampf(sc, 0.5, 12.0))
	if img and maxi(img.get_width(), img.get_height()) > 2048:
		var k := 2048.0 / maxi(img.get_width(), img.get_height())
		img = svg_img(s, clampf(sc * k, 0.1, 12.0))
	var t: Texture2D = ImageTexture.create_from_image(img) if img else null
	if img and OS.get_cmdline_user_args().has("--svglog=1"):
		print("SVGTEX %dx%d %.1fMB %s" % [img.get_width(), img.get_height(), img.get_width() * img.get_height() * 4 / 1048576.0, key])
	_svg[key] = t
	return t

# build all elements under `parent`; `origin` is the page position of the root element
func build(path: String, parent: Control, origin := Vector2.ZERO) -> Control:
	data = JSON.parse_string(FileAccess.get_file_as_string(path))
	nodes.resize(data.size())
	for n in data:
		var par: Control = parent
		var po := origin
		if int(n.p) >= 0 and nodes[int(n.p)] != null:
			par = nodes[int(n.p)]
			var pr: Array = data[int(n.p)].r
			po = Vector2(pr[0], pr[1])
		var c := make(n, po)
		par.add_child(c)
		nodes[int(n.i)] = c
		if n.id != "":
			by_id[n.id] = c
	root = nodes[0]
	return root

func make(n: Dictionary, po: Vector2) -> Control:
	var r: Array = n.r
	var c := Control.new()
	c.name = (n.id if n.id != "" else n.tag) + "_%d" % int(n.i)
	c.position = Vector2(r[0], r[1]) - po
	c.size = Vector2(r[2], r[3])
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.set_meta("web", n)
	if n.get("op", 1.0) < 1.0:
		c.modulate.a = n.op
	if n.has("clip"):
		c.clip_contents = true
	if n.has("tf"):
		var m: Array = n.tf
		var o: Array = n.get("tfo", [r[2] / 2, r[3] / 2])
		c.pivot_offset = Vector2(o[0], o[1])
		c.rotation = atan2(m[1], m[0])
		c.scale = Vector2(Vector2(m[0], m[1]).length(), Vector2(m[2], m[3]).length())
		c.position += Vector2(m[4], m[5])
	if n.has("box"):
		for g in n.box.get("bg", []):
			if g.t == "img":
				var src: String = g.src
				if n.has("blurimg"):
					src = n.blurimg
				var bt := tex(src)
				if bt:
					var br := TextureRect.new()
					br.texture = bt
					br.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
					br.stretch_mode = TextureRect.STRETCH_SCALE
					br.mouse_filter = Control.MOUSE_FILTER_IGNORE
					br.name = "bgimg"
					var ts := bt.get_size()
					var szs: String = g.get("size", "")
					var k := 1.0
					if "cover" in szs: k = maxf(c.size.x / ts.x, c.size.y / ts.y)
					elif "contain" in szs: k = minf(c.size.x / ts.x, c.size.y / ts.y)
					else: k = c.size.x / ts.x
					br.size = ts * k
					var pos: PackedStringArray = String(g.get("pos", "50% 50%")).split(" ")
					var fx := 0.5
					var fy := 0.5
					if pos.size() >= 2:
						fx = pos[0].trim_suffix("%").to_float() / 100.0 if pos[0].ends_with("%") else 0.0
						fy = pos[1].trim_suffix("%").to_float() / 100.0 if pos[1].ends_with("%") else 0.0
					br.position = Vector2((c.size.x - br.size.x) * fx, (c.size.y - br.size.y) * fy)
					c.clip_contents = true
					c.add_child(br)
		c.add_child(box(n.box, Vector2(r[2], r[3])))
	if n.has("img"):
		var t := tex(n.img.src)
		if t:
			var tr := TextureRect.new()
			tr.texture = t
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if n.img.get("fit", "") == "contain" else TextureRect.STRETCH_SCALE
			tr.size = c.size
			tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tr.name = "img"
			if n.has("filt"):
				apply_filter(tr, n.filt)
			c.add_child(tr)
	if n.has("svg"):
		var t2 := svg_tex(n.svg, r[2], r[3])
		if t2:
			var tr2 := TextureRect.new()
			tr2.texture = t2
			tr2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr2.size = c.size
			tr2.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tr2.name = "svg"
			c.add_child(tr2)
	if n.has("txt"):
		c.add_child(label(n.txt, Vector2(r[2], r[3])))
	return c

static func box(b: Dictionary, sz: Vector2) -> ColorRect:
	var m := 0.0
	for s in b.get("sh", []):
		if not s["in"]:
			m = maxf(m, absf(s.x) + absf(s.y) + s.b + absf(s.s) + 2.0)
	var cr := ColorRect.new()
	cr.name = "box"
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cr.position = Vector2(-m, -m)
	cr.size = sz + Vector2(m * 2, m * 2)
	var mat := ShaderMaterial.new()
	mat.shader = BOX
	cr.ready.connect(func(): bake(cr), CONNECT_ONE_SHOT)
	mat.set_shader_parameter("size", sz)
	mat.set_shader_parameter("margin", m)
	var rad: Array = b.get("rad", [0, 0, 0, 0])
	mat.set_shader_parameter("radius", Vector4(rad[0], rad[1], rad[2], rad[3]))
	mat.set_shader_parameter("bgc", col(b.get("bgc")))
	var layers: Array = b.get("bg", [])
	var li := 0
	for g in layers:
		if li > 1 or g.t == "img":
			continue
		var pre := "g%d_" % li
		mat.set_shader_parameter(pre + "type", 1 if g.t == "lin" else (3 if g.t == "con" else 2))
		if g.t == "lin":
			mat.set_shader_parameter(pre + "ang", g.ang)
		elif g.t == "con":
			mat.set_shader_parameter(pre + "cen", Vector2(g.cen[0], g.cen[1]))
			mat.set_shader_parameter(pre + "rad", Vector2(g.per, 0))
		else:
			mat.set_shader_parameter(pre + "cen", Vector2(g.cen[0], g.cen[1]))
			var shp: Array = g.shape
			var rv := Vector2(0.7071, 0.7071)
			if shp.size() == 3 and shp[0] is String:
				rv = Vector2(shp[1] / sz.x, shp[2] / sz.y)
			elif shp.size() >= 2:
				rv = Vector2(shp[0], shp[1])
			if g.get("circle", false):
				var rr := maxf(rv.x * sz.x, rv.y * sz.y)
				rv = Vector2(rr / sz.x, rr / sz.y)
			mat.set_shader_parameter(pre + "rad", rv)
		var st: Array = g.st
		var cs := []
		var ps := []
		for i in mini(st.size(), 6):
			cs.append(col(st[i][1]))
			ps.append(float(st[i][0]))
		while cs.size() < 6:
			cs.append(Color(0, 0, 0, 0))
			ps.append(1.0)
		mat.set_shader_parameter(pre + "n", mini(st.size(), 6))
		mat.set_shader_parameter(pre + "c", cs)
		mat.set_shader_parameter(pre + "p", PackedFloat32Array(ps))
		li += 1
	# CSS paints the first layer on top: our shader paints g0 over g1, so keep that order
	if b.has("bw"):
		var w: Array = b.bw
		mat.set_shader_parameter("bw", Vector4(w[0], w[1], w[2], w[3]))
		mat.set_shader_parameter("bcol", col(b.get("bcol")))
	var shs: Array = b.get("sh", [])
	var sg := []
	var sc := []
	var si := []
	for i in mini(shs.size(), 4):
		var s = shs[i]
		sg.append(Vector4(s.x, s.y, s.b, s.s))
		sc.append(col(s.c))
		si.append(1.0 if s["in"] else 0.0)
	while sg.size() < 4:
		sg.append(Vector4.ZERO)
		sc.append(Color(0, 0, 0, 0))
		si.append(0.0)
	mat.set_shader_parameter("sh_n", mini(shs.size(), 4))
	mat.set_shader_parameter("sh_g", sg)
	mat.set_shader_parameter("sh_c", sc)
	mat.set_shader_parameter("sh_in", PackedFloat32Array(si))
	cr.material = mat
	return cr

static func label(t: Dictionary, sz: Vector2) -> Label:
	var l := Label.new()
	l.name = "txt"
	l.text = t.s
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ls := LabelSettings.new()
	var f: Font = font(t.font)
	if absf(t.get("ls", 0.0)) >= 1.0:
		var fv := FontVariation.new()
		fv.base_font = f
		fv.spacing_glyph = int(round(t.ls))
		f = fv
	ls.font = f
	ls.font_size = int(round(t.fs))
	ls.font_color = col(t.col)
	var stroke: Array = t.get("stroke", [0, null])
	if stroke[0] > 0.0:
		ls.outline_size = int(round(stroke[0] * 2.0))
		ls.outline_color = col(stroke[1])
	var tsh: Array = t.get("ts", [])
	if not tsh.is_empty():
		# the shadow with the biggest offset reads as the 3D edge; keep that one
		var best = tsh[0]
		for s in tsh:
			if absf(s.y) + absf(s.x) > absf(best.y) + absf(best.x):
				best = s
		ls.shadow_color = col(best.c)
		ls.shadow_offset = Vector2(best.x, best.y)
		ls.shadow_size = int(round(best.b)) if best.b > 0 else (ls.outline_size if ls.outline_size > 0 else 0)
	l.label_settings = ls
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if t.ta == "center" else (HORIZONTAL_ALIGNMENT_RIGHT if t.ta in ["right", "end"] else HORIZONTAL_ALIGNMENT_LEFT)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# text that does not fit on one line wraps and starts at the top, like a paragraph
	if sz.y > t.fs * 1.75 and f.get_string_size(t.s, HORIZONTAL_ALIGNMENT_LEFT, -1, int(round(t.fs))).x > sz.x + 1.0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	l.size = sz
	l.clip_text = false
	if t.get("grad") != null:
		var g: Dictionary = t.grad
		ls.font_color = Color.WHITE
		var mat := ShaderMaterial.new()
		mat.shader = TGRAD
		var st: Array = g.st
		var cs := []
		var ps := []
		for i in mini(st.size(), 6):
			cs.append(col(st[i][1]))
			ps.append(float(st[i][0]))
		while cs.size() < 6:
			cs.append(Color(0, 0, 0, 0))
			ps.append(1.0)
		mat.set_shader_parameter("n", mini(st.size(), 6))
		mat.set_shader_parameter("c", cs)
		mat.set_shader_parameter("p", PackedFloat32Array(ps))
		mat.set_shader_parameter("h", sz.y)
		mat.set_shader_parameter("y0", 0.0)
		l.material = mat
	# several text-shadows (outlines, 3D extrusion): one copy of the text per shadow, drawn behind
	var tsh2: Array = t.get("ts", [])
	if tsh2.size() > 1:
		ls.shadow_size = 0
		ls.shadow_color = Color(0, 0, 0, 0)
		for k in range(tsh2.size() - 1, -1, -1):
			var sd: Dictionary = tsh2[k]
			var cl := Label.new()
			cl.name = "sh%d" % k
			cl.text = t.s
			var cs: LabelSettings = ls.duplicate()
			cs.font_color = col(sd.c)
			cs.outline_color = col(sd.c)
			cl.label_settings = cs
			cl.horizontal_alignment = l.horizontal_alignment
			cl.vertical_alignment = l.vertical_alignment
			cl.autowrap_mode = l.autowrap_mode
			cl.size = sz
			cl.position = Vector2(sd.x, sd.y)
			cl.show_behind_parent = true
			cl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			l.add_child(cl)
	return l

const FILT := preload("res://scripts/ui/filter.gdshader")
static func apply_filter(tr: CanvasItem, f: String) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = FILT
	var m := RegEx.create_from_string("grayscale\\(([0-9.]+)\\)").search(f)
	if m: mat.set_shader_parameter("gray", float(m.get_string(1)))
	m = RegEx.create_from_string("sepia\\(([0-9.]+)\\)").search(f)
	if m: mat.set_shader_parameter("sepia", float(m.get_string(1)))
	m = RegEx.create_from_string("saturate\\(([0-9.]+)\\)").search(f)
	if m: mat.set_shader_parameter("sat", float(m.get_string(1)))
	m = RegEx.create_from_string("hue-rotate\\(([-0-9.]+)deg\\)").search(f)
	if m: mat.set_shader_parameter("hue", float(m.get_string(1)))
	m = RegEx.create_from_string("brightness\\(([0-9.]+)\\)").search(f)
	if m: mat.set_shader_parameter("bright", float(m.get_string(1)))
	m = RegEx.create_from_string("drop-shadow\\(rgba?\\(([^)]*)\\) ([-0-9.]+)px ([-0-9.]+)px").search(f)
	if m:
		var p: PackedStringArray = m.get_string(1).split(",")
		var a := float(p[3]) if p.size() > 3 else 1.0
		mat.set_shader_parameter("ds_col", Color(float(p[0]) / 255.0, float(p[1]) / 255.0, float(p[2]) / 255.0, a))
		mat.set_shader_parameter("ds_off", Vector2(float(m.get_string(2)), float(m.get_string(3))))
	tr.material = mat
	tr.set_meta("filt", 1)

# helpers for live updates
func set_text(id: String, s: String) -> void:
	var c: Control = by_id.get(id)
	if c and c.has_node("txt"):
		(c.get_node("txt") as Label).text = s

func node(id: String) -> Control:
	return by_id.get(id)
