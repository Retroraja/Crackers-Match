# Start of Area 2 (17 Nov, v2): three still shots like the intro story, no camera motion.
# 1 the loaded red truck in front of our finished Crackers Factory (Area 1 street)
# 2 the same truck on Bunder Street, Chennai (the world switches to Area 2 behind a fade)
# 3 the truck stopped in front of our closed, rusty shop      then the "AREA 2" title card.
extends AreaEndScene
class_name AreaStartScene

func play(height: float) -> void:
	super.play(height)
	(card.get_node("a") as Label).text = "A R E A   2"
	(card.get_node("t") as Label).text = "Bunder Street, Chennai"
	(card.get_node("u") as Label).text = "our first shop in the big city"

func _shot(n: int) -> void:
	shot = n
	sid += 1
	var id := sid
	match n:
		1: _at_factory(id)
		2: _fade(id, _in_chennai)
		3: _fade(id, _at_shop)
		4: _title(id)
		_: _finish()

func _road() -> void:
	path = PackedVector3Array([Vector3.ZERO, Vector3(0, 0, 1)])
	plen = PackedFloat32Array([0.0, 1.0])

# park the truck at a spot, facing a direction (radians around Y; 0 = +z)
func _park(p: Vector3, rot: float, s: float) -> void:
	_make_truck()
	if truck == null:
		return
	drive = -1.0
	chase = false
	truck.visible = true
	truck.global_position = p
	truck.rotation.y = rot
	(truck.get_child(0) as Node3D).scale = Vector3.ONE * s
	var b: Node3D = truck.get_child(0).get_node_or_null("box4")
	if b:
		b.visible = true

func _still(p: Vector3, l: Vector3) -> void:
	street.CAMID += 1
	street.camP = p
	street.camL = l

# a quick fade to black and back, changing the picture in the middle
func _fade(id: int, f: Callable) -> void:
	_tw().tween_property(cap, "modulate:a", 0.0, 0.25)
	var t := _tw()
	t.tween_property(dim, "color:a", 1.0, 0.35)
	t.tween_callback(func():
		if id == sid:
			f.call(id))
	t.tween_property(dim, "color:a", 0.0, 0.45)

func _at_factory(id: int) -> void:
	if street:
		street.night(0.35)
		_park(Vector3(2.5, 0, -44.0), 0.0, 1.6)
		_still(Vector3(-5.5, 5.8, -27.0), Vector3(0.5, 2.6, -50.0))
	_later(0.5, id, func(): say("The first load of crackers\nis ready!", id, 3.0))
	_later(3.8, id, func(): _shot(2))

func _in_chennai(id: int) -> void:
	if street:
		street.night(0.0)
		street.set_area(2)
		_park(Vector3(-16.0, 0, 4.4), PI / 2, 2.2)
		_still(Vector3(-24.0, 5.5, 24.0), Vector3(-15.0, 2.2, 3.0))
	_later(0.6, id, func(): say("Chennai.  Bunder Street,\nwhere the big city buys its crackers.", id, 3.2))
	_later(4.2, id, func(): _shot(3))

func _at_shop(id: int) -> void:
	if street:
		_park(Vector3(-3.5, 0, 4.4), PI / 2, 2.2)
		_still(Vector3(0, 6.5, 30), Vector3(0, 4.4, -2))
	man.mood("smile", 99)
	man.base = "idle"
	man.position.x = 2
	_tw().tween_property(man, "position:y", H - BOT - 236, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_later(0.5, id, func(): say("“Our first shop…\na little rusty, but it's ours.”", id, 3.2))
	_later(4.2, id, func():
		_tw().tween_property(man, "position:y", H + 40, 0.5)
		_shot(4))

func _process(_dt: float) -> void:
	pass

func _cleanup() -> void:
	if is_instance_valid(truck):
		truck.queue_free()
	if street:
		street.cam_home(true)
