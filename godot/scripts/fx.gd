# Light effects for the board: spark bursts (pooled CPU particles), shock rings, lightning bolts, flashes.
extends Node2D
class_name Fx

var pool: Array[CPUParticles2D] = []
var lite := false
var dot: Texture2D

func _ready() -> void:
	dot = _make_dot()
	for i in 24:
		var p := CPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.explosiveness = 0.95
		p.lifetime = 0.55
		p.texture = dot
		p.direction = Vector2(0, -1)
		p.spread = 180.0
		p.gravity = Vector2(0, 520)
		p.initial_velocity_min = 90.0
		p.initial_velocity_max = 260.0
		p.scale_amount_min = 0.25
		p.scale_amount_max = 0.7
		p.damping_min = 20.0
		p.damping_max = 60.0
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		p.color_ramp = g
		add_child(p)
		pool.append(p)

func _make_dot() -> Texture2D:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	for y in 24:
		for x in 24:
			var d := Vector2(x - 11.5, y - 11.5).length() / 11.5
			var a := clampf(1.0 - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return ImageTexture.create_from_image(img)

func _free_emitter() -> CPUParticles2D:
	for p in pool:
		if not p.emitting:
			return p
	return pool[randi() % pool.size()]

func burst(pos: Vector2, col: Color, amount: int = 14, speed: float = 1.0) -> void:
	if lite:
		amount = maxi(4, amount / 2)
	var p := _free_emitter()
	p.position = pos
	p.amount = amount
	p.color = col
	p.initial_velocity_min = 80.0 * speed
	p.initial_velocity_max = 240.0 * speed
	p.restart()
	p.emitting = true

func ring(pos: Vector2, col: Color, radius: float, time: float = 0.35, width: float = 6.0) -> void:
	var r := Ring.new()
	r.position = pos
	r.col = col
	r.max_r = radius
	r.w = width
	add_child(r)
	var tw := create_tween()
	tw.tween_property(r, "t", 1.0, time)
	tw.tween_callback(r.queue_free)

func flash(pos: Vector2, col: Color, radius: float, time: float = 0.25) -> void:
	var f := Flash.new()
	f.position = pos
	f.col = col
	f.rad = radius
	add_child(f)
	var tw := create_tween()
	tw.tween_property(f, "t", 1.0, time)
	tw.tween_callback(f.queue_free)

func bolt(a: Vector2, b: Vector2, time: float = 0.22) -> void:
	var l := Line2D.new()
	l.width = 5.0
	l.default_color = Color(1.0, 0.95, 0.6, 1.0)
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	var n := 7
	for i in n + 1:
		var t := float(i) / n
		var p := a.lerp(b, t)
		if i > 0 and i < n:
			p += Vector2(randf_range(-9, 9), randf_range(-9, 9))
		l.add_point(p)
	var glow := l.duplicate() as Line2D
	glow.width = 13.0
	glow.default_color = Color(1.0, 0.75, 0.2, 0.35)
	add_child(glow)
	add_child(l)
	var tw := create_tween().set_parallel()
	tw.tween_property(l, "modulate:a", 0.0, time)
	tw.tween_property(glow, "modulate:a", 0.0, time)
	tw.chain().tween_callback(l.queue_free)
	tw.chain().tween_callback(glow.queue_free)

class Ring extends Node2D:
	var col := Color.WHITE
	var max_r := 60.0
	var w := 6.0
	var t := 0.0:
		set(v):
			t = v
			queue_redraw()
	func _draw() -> void:
		var r := max_r * (0.2 + 0.8 * t)
		draw_arc(Vector2.ZERO, r, 0, TAU, 40, Color(col, 1.0 - t), w * (1.0 - t * 0.6), true)

class Flash extends Node2D:
	var col := Color.WHITE
	var rad := 60.0
	var t := 0.0:
		set(v):
			t = v
			queue_redraw()
	func _draw() -> void:
		draw_circle(Vector2.ZERO, rad * (0.6 + 0.4 * t), Color(col, 0.55 * (1.0 - t)))
