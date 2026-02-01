extends Camera2D

@export var move_speed: float = 300.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

# World boundaries (based on TextureRect sizes)
# Two TextureRect side by side: 960 + 960 = 1920 width, 540 height
@export var world_left: float = 0.0
@export var world_right: float = 1920.0
@export var world_top: float = 0.0
@export var world_bottom: float = 540.0

func _process(delta):
	# Camera movement dengan arrow keys atau WASD
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	
	# Apply movement
	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * move_speed * delta
	
	# Clamp camera position to world boundaries
	# Calculate visible area based on zoom and viewport size
	var viewport_size = get_viewport_rect().size
	var visible_size = viewport_size / zoom
	
	var min_x = world_left + visible_size.x / 2.0
	var max_x = world_right - visible_size.x / 2.0
	var min_y = world_top + visible_size.y / 2.0
	var max_y = world_bottom - visible_size.y / 2.0
	
	# Ensure min is not greater than max (in case zoom out too much)
	min_x = min(min_x, (world_left + world_right) / 2.0)
	max_x = max(max_x, (world_left + world_right) / 2.0)
	min_y = min(min_y, (world_top + world_bottom) / 2.0)
	max_y = max(max_y, (world_top + world_bottom) / 2.0)
	
	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)
	
	# Zoom dengan Q dan E
	if Input.is_key_pressed(KEY_Q):
		zoom = zoom - Vector2(zoom_speed, zoom_speed) * delta * 5
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)
	if Input.is_key_pressed(KEY_E):
		zoom = zoom + Vector2(zoom_speed, zoom_speed) * delta * 5
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)
	
	# Reset ke posisi awal dengan R
	if Input.is_action_just_pressed("ui_cancel") or Input.is_key_pressed(KEY_R):
		position = Vector2(480, 269)
		zoom = Vector2(2, 2)
