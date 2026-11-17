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
		street.camP = Vector3(-14, 7.0, 34)
		street.camL = Vector3(-8, 5.0, -2)
		street.cam_to(Vector3(0, 6.5, 30), Vector3(0, 5.2, -2), 5.0)
	_later(0.6, id, func(): say("Chennai.  Bunder Street,\nwhere the big city buys its crackers.", id, 3.6))
	_later(4.6, id, func(): _shot(2))

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
