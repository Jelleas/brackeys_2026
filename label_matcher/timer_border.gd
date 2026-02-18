extends Control

@export var duration: float = 5.0 # Seconds for full border to disappear
@export var border_thickness: float = 3.0
@export var border_color: Color = Color(0.3, 1.0, 0.3)
@export var corner_radius: float = 20.0 # Rounded corner radius in pixels
@export var corner_segments: int = 10 # More segments = smoother corners

var _time_left: float = 0.0
var _running: bool = false

var _on_timeout_callback: Callable


func _ready() -> void:
	# Always cover the parent (no need to find Layout → Full Rect)
	if get_parent() is Control:
		anchor_left = 0.0
		anchor_top = 0.0
		anchor_right = 1.0
		anchor_bottom = 1.0
		offset_left = 0.0
		offset_top = 0.0
		offset_right = 0.0
		offset_bottom = 0.0

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func start_timer(new_duration: float = -1.0, _on_timeout: Callable = func (): return) -> void:
	# Call this from the Label (or elsewhere) to start the border timer
	if new_duration > 0.0:
		duration = new_duration

	if duration <= 0.0:
		return
	
	_on_timeout_callback = _on_timeout
	_time_left = duration
	_running = true
	show()
	queue_redraw()

func stop_timer():
	_running = false

func set_color(color: Color):
	border_color = color

func _process(delta: float) -> void:
	if not _running:
		return

	_time_left -= delta
	if _time_left <= 0.0:
		_time_left = 0.0
		_running = false
		_on_timeout_callback.call()
		hide()  # Border fully gone when finished

	queue_redraw()


func _draw() -> void:
	if duration <= 0.0 or _time_left <= 0.0:
		return

	var fraction_left: float = clamp(_time_left / duration, 0.0, 1.0)

	# Rectangle we draw around (in this Control's local space)
	var rect := Rect2(Vector2.ZERO, size)

	# Inset so the stroke is fully inside the control
	var inset := border_thickness * 0.5
	rect.position += Vector2(inset, inset)
	rect.size -= Vector2(inset * 2.0, inset * 2.0)

	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return

	var r: float = min(corner_radius, rect.size.x * 0.5, rect.size.y * 0.5)
	var full_path: PackedVector2Array = _get_rounded_rect_path(rect, r, corner_segments)
	if full_path.size() < 2:
		return

	var visible_path: PackedVector2Array = _get_visible_path(full_path, fraction_left)
	if visible_path.size() >= 2:
		# One continuous stroked border, shortened based on time left
		draw_polyline(visible_path, border_color, border_thickness)


func _get_rounded_rect_path(rect: Rect2, radius: float, corner_segs: int) -> PackedVector2Array:
	var points := PackedVector2Array()

	var left := rect.position.x
	var top := rect.position.y
	var right := rect.position.x + rect.size.x
	var bottom := rect.position.y + rect.size.y
	var r := radius
	var segs = max(1, corner_segs)

	# Start on top edge, a bit right from the top-left corner
	points.append(Vector2(left + r, top))

	# Top edge
	points.append(Vector2(right - r, top))

	# Top-right corner (center: right - r, top + r), angles -PI/2 → 0
	var cx := right - r
	var cy := top + r
	for i in range(1, segs + 1):
		var t: float = float(i) / segs
		var angle := -PI / 2.0 + t * (PI / 2.0)
		points.append(Vector2(
			cx + cos(angle) * r,
			cy + sin(angle) * r
		))

	# Right edge
	points.append(Vector2(right, bottom - r))

	# Bottom-right corner (center: right - r, bottom - r), angles 0 → PI/2
	cx = right - r
	cy = bottom - r
	for i in range(1, segs + 1):
		var t: float = float(i) / segs
		var angle := 0.0 + t * (PI / 2.0)
		points.append(Vector2(
			cx + cos(angle) * r,
			cy + sin(angle) * r
		))

	# Bottom edge
	points.append(Vector2(left + r, bottom))

	# Bottom-left corner (center: left + r, bottom - r), angles PI/2 → PI
	cx = left + r
	cy = bottom - r
	for i in range(1, segs + 1):
		var t: float = float(i) / segs
		var angle := PI / 2.0 + t * (PI / 2.0)
		points.append(Vector2(
			cx + cos(angle) * r,
			cy + sin(angle) * r
		))

	# Left edge
	points.append(Vector2(left, top + r))

	# Top-left corner (center: left + r, top + r), angles PI → 3PI/2
	cx = left + r
	cy = top + r
	for i in range(1, segs + 1):
		var t: float = float(i) / segs
		var angle := PI + t * (PI / 2.0)
		points.append(Vector2(
			cx + cos(angle) * r,
			cy + sin(angle) * r
		))

	return points


func _get_visible_path(full_path: PackedVector2Array, fraction: float) -> PackedVector2Array:
	fraction = clamp(fraction, 0.0, 1.0)
	var visible := PackedVector2Array()

	if fraction <= 0.0:
		return visible

	if fraction >= 1.0:
		# Full border
		return full_path

	# Total length of the polyline
	var total_len := 0.0
	for i in range(full_path.size() - 1):
		total_len += full_path[i].distance_to(full_path[i + 1])

	if total_len == 0.0:
		return full_path

	var target_len := total_len * fraction
	var accum := 0.0

	visible.append(full_path[0])

	for i in range(full_path.size() - 1):
		var p0 := full_path[i]
		var p1 := full_path[i + 1]
		var seg_len := p0.distance_to(p1)

		if accum + seg_len >= target_len:
			var remain := target_len - accum
			var t := 0.0 if seg_len == 0.0 else remain / seg_len
			var cut_point := p0.lerp(p1, t)
			visible.append(cut_point)
			break
		else:
			visible.append(p1)
			accum += seg_len

	return visible
