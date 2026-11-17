# Start of Area 2 (17 Nov): the red truck arrives on Bunder Street, Chennai, and stops at our closed, rusty shop.
# Then the title card "AREA 2 · Bunder Street, Chennai · our first shop in the big city". Reuses the end-scene truck.
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
		1: _arrive(id)
		2: _shop(id)
		3: _title(id)
		_: _finish()

# a straight road along the shop front, from the left edge to the shutter
func _road() -> void:
	path = PackedVector3Array([Vector3(-34, 0, 4.2), Vector3(-2.5, 0, 4.2)])
	plen = PackedFloat32Array([0.0, 31.5])

func _arrive(id: int) -> void:
	if street:
		street.camP = Vector3(-6, 4.0, 17)
		street.camL = Vector3(-8, 1.6, 2)
		street.cam_to(Vector3(0, 4.5, 15), Vector3(0, 2.4, -1), 5.0)
		_make_truck()
		_later(0.4, id, func():
			drive = 0.0
			_sfx("swoosh", 0.4, 0.6))
	_later(0.6, id, func(): say("Chennai.  Bunder Street,\nwhere the big city buys its crackers.", id, 3.6))
	_later(4.6, id, func(): _shot(2))

func _process(dt: float) -> void:
	# the truck slows to a stop at the shop
	if truck and drive >= 0.0 and drive >= plen[plen.size() - 1] - 0.2:
		drive = -1.0
		_sfx("bk_thud", 0.5)
		return
	super._process(dt)

func _shop(id: int) -> void:
	man.mood("worried", 99)
	man.base = "worried"
	man.position.x = 2
	_tw().tween_property(man, "position:y", H - BOT - 236, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_sfx("story_sigh", 0.6, 1.0, 0.8)
	_later(0.6, id, func(): say("“Our first shop…\na little rusty, but it's ours.”", id, 3.4))
	_later(2.6, id, func(): man.mood("smile", 99))
	_later(4.4, id, func():
		_tw().tween_property(man, "position:y", H + 40, 0.6)
		_shot(3))

func _cleanup() -> void:
	if is_instance_valid(truck):
		truck.queue_free()
	if street:
		street.cam_home(true)
