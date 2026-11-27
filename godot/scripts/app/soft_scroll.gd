# 26 Nov: a soft list scroll (Daily sheet, Areas, Trophy Room). Godot's own scroll jumped and flung too hard on the
# phone. This one follows the finger 1:1, then glides a little and slows down smoothly; it stops at the ends with
# no bounce. A drag never counts as a tap on the button under the finger (SoftScroll.block_until, checked by tap()).
# The first child is the moving content; set content height with set_height().
extends Control
class_name SoftScroll

static var block_until := 0
var content_h := 0.0
var _down := false
var _drag := false
var _y0 := 0.0
var _p0 := 0.0
var _vel := 0.0
var _last_y := 0.0
var _last_t := 0

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS

func content() -> Control:
	return get_child(0) as Control if get_child_count() > 0 else null

func set_height(h: float) -> void:
	content_h = h
	_clamp()

func reset() -> void:
	_vel = 0.0
	if content():
		content().position.y = 0.0

func _min_y() -> float:
	return minf(0.0, size.y - content_h)

func _clamp() -> void:
	var c := content()
	if c:
		c.position.y = clampf(c.position.y, _min_y(), 0.0)

func _local_y(p: Vector2) -> float:
	return (get_global_transform_with_canvas().affine_inverse() * p).y

func _input(e: InputEvent) -> void:
	if not is_visible_in_tree() or content() == null:
		return
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			var lp: Vector2 = get_global_transform_with_canvas().affine_inverse() * e.position
			if Rect2(Vector2.ZERO, size).has_point(lp):
				_down = true
				_drag = false
				_vel = 0.0
				_y0 = lp.y
				_p0 = content().position.y
				_last_y = lp.y
				_last_t = Time.get_ticks_msec()
		elif _down:
			_down = false
			if _drag:
				block_until = Time.get_ticks_msec() + 120
				# glide: at most 1600 px/s, so a quick flick never throws the list too far
				_vel = clampf(_vel, -1600.0, 1600.0)
	elif e is InputEventMouseMotion and _down:
		var y: float = _local_y(e.position)
		if not _drag and absf(y - _y0) > 9.0:
			_drag = true
			_y0 = y
			_p0 = content().position.y
		if _drag:
			content().position.y = clampf(_p0 + (y - _y0), _min_y(), 0.0)
			var t := Time.get_ticks_msec()
			var dt := maxf(1.0, float(t - _last_t)) / 1000.0
			_vel = lerpf(_vel, (y - _last_y) / dt, 0.4)
			_last_y = y
			_last_t = t

func _process(dt: float) -> void:
	if _down or absf(_vel) < 8.0 or content() == null:
		return
	var c := content()
	c.position.y += _vel * dt
	_vel *= exp(-5.0 * dt)
	var y0 := c.position.y
	_clamp()
	if c.position.y != y0:
		_vel = 0.0
