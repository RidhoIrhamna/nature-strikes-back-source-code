extends Control

@onready var progress_bar: ProgressBar = $Panel/ProgressBar

# Batas kemenangan (0 = enemy menang, 100 = player menang)
const WIN_THRESHOLD_PLAYER: float = 100.0
const WIN_THRESHOLD_ENEMY: float = 0.0

# Reference area untuk perhitungan (batas map atau spawn area)
var map_left_boundary: float = 0.0 # Batas kiri (enemy spawn area)
var map_right_boundary: float = 1000.0  # Batas kanan (player goal)
var map_width: float
var game_over: bool = false

signal player_won
signal enemy_won

func _ready():
	# Calculate map width for progress calculation
	map_width = map_right_boundary - map_left_boundary
	
	# Set initial progress
	progress_bar.value = 50.0
	print("Battle Progress initialized!")
	print("Map boundaries: ", map_left_boundary, " to ", map_right_boundary)

func _process(_delta):
	if not game_over:
		update_progress()

func update_progress():
	# Get all players and enemies
	var players = get_tree().get_nodes_in_group("player")
	var enemies = get_tree().get_nodes_in_group("slime")
	
	if players.is_empty() and enemies.is_empty():
		return
	
	# Find frontmost characters (karakter paling depan)
	var frontmost_player_pos = map_left_boundary
	var frontmost_enemy_pos = map_right_boundary
	var has_player = false
	var has_enemy = false
	
	# Find frontmost player (paling ke kanan)
	for player in players:
		if is_instance_valid(player):
			has_player = true
			if player.global_position.x > frontmost_player_pos:
				frontmost_player_pos = player.global_position.x
	
	# Find frontmost enemy (paling ke kiri)
	for enemy in enemies:
		if is_instance_valid(enemy):
			has_enemy = true
			if enemy.global_position.x < frontmost_enemy_pos:
				frontmost_enemy_pos = enemy.global_position.x
	
	# Calculate progress (0-100) based on relative positions
	var progress = 50.0
	
	if has_player and has_enemy:
		# Normalize positions relative to map boundaries
		# Player: 0 (left boundary) to 100 (right boundary)
		var player_progress = ((frontmost_player_pos - map_left_boundary) / map_width) * 100.0
		player_progress = clamp(player_progress, 0.0, 100.0)
		
		# Enemy: 100 (left boundary) to 0 (right boundary) - inverted
		var enemy_progress = 100.0 - ((frontmost_enemy_pos - map_left_boundary) / map_width) * 100.0
		enemy_progress = clamp(enemy_progress, 0.0, 100.0)
		
		# Progress bar: rata-rata dari kedua posisi
		# Jika player lebih maju (ke kanan), bar ke kanan
		# Jika enemy lebih maju (ke kiri), bar ke kiri
		progress = (player_progress + (100.0 - enemy_progress)) / 2.0
		progress = clamp(progress, 0.0, 100.0)
	
	elif has_player:
		# Only players - normalize their position
		progress = ((frontmost_player_pos - map_left_boundary) / map_width) * 100.0
		progress = clamp(progress, 50.0, 100.0)
	
	elif has_enemy:
		# Only enemies - normalize their position (inverted)
		progress = ((frontmost_enemy_pos - map_left_boundary) / map_width) * 100.0
		progress = clamp(progress, 0.0, 50.0)
	
	# Update progress bar
	progress_bar.value = progress
	
	# Check win conditions
	check_win_condition(progress)

func check_win_condition(progress: float):
	if game_over:
		return
		
	if progress >= WIN_THRESHOLD_PLAYER:
		game_over = true
		player_won.emit()
		show_victory("PLAYER MENANG!")
	elif progress <= WIN_THRESHOLD_ENEMY:
		game_over = true
		enemy_won.emit()
		show_victory("ENEMY MENANG!")

func show_victory(message: String):
	print(message)
	# Pause game
	get_tree().paused = true
	
	# Get viewport size for centering
	var viewport_size = get_viewport_rect().size
	
	# Create fullscreen overlay untuk positioning yang tepat
	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 1000
	add_child(overlay)
	
	# Create victory panel
	var victory_panel = Panel.new()
	victory_panel.custom_minimum_size = Vector2(500, 200)
	victory_panel.set_anchors_preset(Control.PRESET_CENTER)
	victory_panel.position = Vector2(-250, -100)  # Offset setengah ukuran panel
	overlay.add_child(victory_panel)
	
	# Victory message label (centered in panel)
	var label = Label.new()
	label.text = message
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(label)
	
	# Restart hint (centered below)
	var hint = Label.new()
	hint.text = "Press ESC to Restart"
	hint.position = Vector2(0, 130)
	hint.size = Vector2(500, 40)
	hint.add_theme_font_size_override("font_size", 20)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(hint)

func _input(event):
	if game_over and event.is_action_pressed("ui_cancel"):
		# Restart game
		get_tree().paused = false
		get_tree().reload_current_scene()
