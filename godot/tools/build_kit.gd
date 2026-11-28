# Run once (headless): turns the street model kit (street/models.json + models.bin, the packed Medieval Village,
# Fantasy Props, Stylized Nature and Halloween Bits kits used by street/kit2.js) into Godot meshes in street/kit/.
#   godot --headless --path . --script res://tools/build_kit.gd
extends SceneTree

const ART := "res://street/art/"

func tex(n: String, srgb := true) -> Texture2D:
	var t: Texture2D = load(ART + n + ".webp")
	return t

func std(base: String, normal = null, o := {}) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex(base)
	if normal != null:
		m.normal_enabled = true
		m.normal_texture = tex(normal, false)
	m.roughness = o.get("roughness", 0.85)
	m.metallic = o.get("metalness", 0.0)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if o.has("alphaTest"):
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		m.alpha_scissor_threshold = o.alphaTest
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return m

func plain(col: Color, o := {}) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = o.get("roughness", 0.85)
	m.metallic = o.get("metalness", 0.0)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if o.has("opacity"):
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color.a = o.opacity
	return m

func _init() -> void:
	var M := {
		"MI_Plaster": std("T_Plaster_BaseColor", "T_Plaster_Normal"), "MI_WoodTrim": std("T_WoodTrim_BaseColor", "T_WoodTrim_Normal", {"roughness": 0.75}),
		"MI_UnevenBrick": std("T_UnevenBrick_BaseColor", "T_UnevenBrick_Normal"), "MI_RoundTiles": std("T_RoundTiles_BaseColor", "T_RoundTiles_Normal", {"roughness": 0.7}),
		"MI_RockTrim": std("T_RockTrim_BaseColor", "T_RockTrim_Normal"), "MI_Brick": std("T_Brick_BaseColor", "T_Brick_Normal"), "MI_RedBrick": std("T_RedBrick_BaseColor", "T_Brick_Normal"),
		"MI_WindowGlass": plain(Color("#bfe0ff"), {"opacity": 0.35, "roughness": 0.1, "metalness": 0.2}),
		"MI_MetalOrnaments": plain(Color("#2a2a30"), {"roughness": 0.45, "metalness": 0.8})}
	var vine := std("T_VineLeaf", null, {"alphaTest": 0.5, "roughness": 0.8})
	vine.albedo_color = Color("#7fbf4a")
	M["MI_Vine"] = vine
	M["MI_WoodTrim_Wear"] = M["MI_WoodTrim"]
	var cl := std("T_Trim_Cloth_BaseColor", "T_Trim_Cloth_Normal")
	var fu := std("T_Trim_Furniture_BaseColor", "T_Trim_Furniture_Normal", {"roughness": 0.75})
	var me := std("T_Trim_Metal_BaseColor", "T_Trim_Metal_Normal", {"roughness": 0.5, "metalness": 0.5})
	var pr := std("T_Trim_Props_BaseColor", "T_Trim_Props_Normal", {"roughness": 0.7})
	M.merge({"MI_Banner": cl, "MI_Trim_Cloth": cl, "MI_Trim_Furniture": fu, "MI_Trim_Metal": me, "MI_Trim_Metal_Vertex": me, "MI_Trim_Props": pr, "MI_Trim_Props_Vertex": pr, "MI_Page_Empty": std("T_Page_Noise"),
		"Bark_DeadTree": std("Bark_DeadTree", "Bark_DeadTree_Normal"), "Bark_NormalTree": std("Bark_NormalTree", "Bark_NormalTree_Normal"), "Bark_TwistedTree": std("Bark_TwistedTree", "Bark_TwistedTree_Normal"),
		"Flowers": std("Flowers", null, {"alphaTest": 0.5}), "Grass": std("Grass", null, {"alphaTest": 0.5}), "Leaves": std("Leaves", null, {"alphaTest": 0.5}), "Leaves_NormalTree": std("Leaves_NormalTree_C", null, {"alphaTest": 0.5}),
		"Leaves_Pine": std("Leaf_Pine_C", null, {"alphaTest": 0.5}), "Leaves_TwistedTree": std("Leaves_TwistedTree_C", null, {"alphaTest": 0.5}), "Mushrooms": std("Mushrooms"), "PathRocks": std("PathRocks_Diffuse"),
		"Rocks": std("Rocks_Diffuse"), "HalloweenBits": std("halloweenbits_texture", null, {"roughness": 0.6})})
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://street/kit"))
	# save the materials once, so every piece shares them (and the game can tint copies)
	var saved := {}
	for k in M:
		var m: Material = M[k]
		if not saved.has(m):
			var path := "res://street/kit/mat_%s.tres" % k
			ResourceSaver.save(m, path)
			saved[m] = path
	var VC := {}
	var J: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/street_kit/models.json"))
	var B := FileAccess.get_file_as_bytes("res://street/models.bin")
	var names := []
	for n in J:
		var mesh := ArrayMesh.new()
		var parts: Array = J[n]
		for p in parts:
			var nv: int = p.n
			var o: int = p.o
			var pos := B.slice(o, o + nv * 12).to_float32_array()
			var nor := B.slice(o + nv * 12, o + nv * 24).to_float32_array()
			var uvs := B.slice(o + nv * 24, o + nv * 32).to_float32_array()
			var V := PackedVector3Array()
			var N := PackedVector3Array()
			var U := PackedVector2Array()
			V.resize(nv)
			N.resize(nv)
			U.resize(nv)
			for i in nv:
				V[i] = Vector3(pos[i * 3], pos[i * 3 + 1], pos[i * 3 + 2])
				N[i] = Vector3(nor[i * 3], nor[i * 3 + 1], nor[i * 3 + 2])
				U[i] = Vector2(uvs[i * 2], uvs[i * 2 + 1])
			var arr := []
			arr.resize(Mesh.ARRAY_MAX)
			arr[Mesh.ARRAY_VERTEX] = V
			arr[Mesh.ARRAY_NORMAL] = N
			arr[Mesh.ARRAY_TEX_UV] = U
			if p.c:
				var cf := B.slice(o + nv * 32, o + nv * 44).to_float32_array()
				var C := PackedColorArray()
				C.resize(nv)
				for i in nv:
					C[i] = Color(cf[i * 3], cf[i * 3 + 1], cf[i * 3 + 2])
				arr[Mesh.ARRAY_COLOR] = C
			var io: int = o + nv * (44 if p.c else 32)
			var I := PackedInt32Array()
			if p.b:
				I = B.slice(io, io + int(p.i) * 4).to_int32_array()
			else:
				var b16 := B.slice(io, io + int(p.i) * 2)
				I.resize(int(p.i))
				for i in int(p.i):
					I[i] = b16.decode_u16(i * 2)
			# three.js faces are counter-clockwise, Godot's are clockwise
			for t in range(0, I.size() - 2, 3):
				var a := I[t + 1]
				I[t + 1] = I[t + 2]
				I[t + 2] = a
			arr[Mesh.ARRAY_INDEX] = I
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
			var mk: String = p.m
			var mat: Material = M.get(mk, M["MI_Plaster"])
			if p.c:
				if not VC.has(mk):
					var c: StandardMaterial3D = mat.duplicate()
					c.vertex_color_use_as_albedo = true
					ResourceSaver.save(c, "res://street/kit/matvc_%s.tres" % mk)
					VC[mk] = load("res://street/kit/matvc_%s.tres" % mk)
				mat = VC[mk]
			else:
				mat = load(saved[M.get(mk, M["MI_Plaster"])])
			mesh.surface_set_material(mesh.get_surface_count() - 1, mat)
			mesh.surface_set_name(mesh.get_surface_count() - 1, mk)
		ResourceSaver.save(mesh, "res://street/kit/%s.res" % n)
		names.append(n)
	print("kit: ", names.size(), " pieces")
	quit()
