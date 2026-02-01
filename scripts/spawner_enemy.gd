extends Node2D

@onready var slime_scene = preload("res://scenes/slime (1).tscn")
@onready var sulaime_scene = preload("res://scenes/slime (2).tscn")
@onready var slim_scene = preload("res://scenes/slime (3).tscn")
@onready var timer: Timer = $Timer
@onready var game_manager: Node = %GameManager

@export var min_spawn_time: float = 12.0
@export var max_spawn_time: float = 18.0
@export var max_waves: int = 3
@export var enemies_per_wave: int = 4

var current_wave: int = 1
var enemies_spawned_this_wave: int = 0
var wave_active: bool = true

func _ready():
	# Konfigurasi timer
	timer.one_shot = false
	timer.autostart = true
	
	# Set random wait time pertama kali
	timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	
	# Koneksi signal
	timer.timeout.connect(_on_timer_timeout)
	
	# Start timer
	timer.start()

func _on_timer_timeout() -> void:
	# Check if wave spawning is complete
	var max_enemies_this_wave = enemies_per_wave if current_wave < max_waves else 1
	if enemies_spawned_this_wave >= max_enemies_this_wave:
		enemies_spawned_this_wave = 0
		
		# Check if this was the last wave
		if current_wave >= max_waves:
			timer.stop()
			wave_active = false
			# Notify game_manager that all waves are done spawning
			if game_manager and game_manager.has_method("all_waves_completed"):
				game_manager.all_waves_completed()
			return
		
		# Wait for current wave to be cleared before starting next wave
		# Pause spawning until wave is cleared
		timer.stop()
		# Check every frame if wave is cleared
		await get_tree().create_timer(0.5).timeout
		_wait_for_wave_clear()
		return
	
	if not wave_active:
		return
	
	# Random Y offset to prevent stacking (range: -40 to +40)
	var y_offset = randf_range(-5.0, 5.0)
	var spawn_pos = global_position + Vector2(0, y_offset)
	
	# FINAL WAVE: Hanya spawn Slim (Boss)
	if current_wave == max_waves:
		# Show FINAL WAVE text and play sound on first spawn
		if enemies_spawned_this_wave == 0:
			Sfx.play_notif_final_wave()
			show_final_wave_text()
		
		# Spawn Slim (Boss)
		var slim = slim_scene.instantiate()
		slim.position = spawn_pos
		slim.z_index = int(spawn_pos.y)
		
		var stats = game_manager.get_slim_stats()
		slim.initialize(stats)
		slim.game_manager = game_manager
		
		get_parent().add_child(slim)
		if game_manager and game_manager.has_method("enemy_spawned"):
			game_manager.enemy_spawned()
	else:
		# Wave 1 dan 2: Random pilih spawn
		var random_choice = randf()
		
		# Play spawn sound
		Sfx.play_spawn_bulldozer()
		
		if current_wave == 1:
			# Wave 1: 70% Slime, 30% Sulaime
			if random_choice < 0.7:
				# Spawn Slime
				var slime = slime_scene.instantiate()
				slime.position = spawn_pos
				slime.z_index = int(spawn_pos.y)
				
				var stats = game_manager.get_slime_stats()
				slime.initialize(stats)
				slime.game_manager = game_manager
				
				get_parent().add_child(slime)
				if game_manager and game_manager.has_method("enemy_spawned"):
					game_manager.enemy_spawned()
			else:
				# Spawn Sulaime
				var sulaime = sulaime_scene.instantiate()
				sulaime.position = spawn_pos
				sulaime.z_index = int(spawn_pos.y)
				
				var stats = game_manager.get_sulaime_stats()
				sulaime.initialize(stats)
				sulaime.game_manager = game_manager
				
				get_parent().add_child(sulaime)
				if game_manager and game_manager.has_method("enemy_spawned"):
					game_manager.enemy_spawned()
		else:
			# Wave 2: 40% Slime, 60% Sulaime
			if random_choice < 0.4:
				# Spawn Slime
				var slime = slime_scene.instantiate()
				slime.position = spawn_pos
				slime.z_index = int(spawn_pos.y)
				
				var stats = game_manager.get_slime_stats()
				slime.initialize(stats)
				slime.game_manager = game_manager
				
				get_parent().add_child(slime)
				if game_manager and game_manager.has_method("enemy_spawned"):
					game_manager.enemy_spawned()
			else:
				# Spawn Sulaime
				var sulaime = sulaime_scene.instantiate()
				sulaime.position = spawn_pos
				sulaime.z_index = int(spawn_pos.y)
				
				var stats = game_manager.get_sulaime_stats()
				sulaime.initialize(stats)
				sulaime.game_manager = game_manager
				
				get_parent().add_child(sulaime)
				if game_manager and game_manager.has_method("enemy_spawned"):
					game_manager.enemy_spawned()
	
	enemies_spawned_this_wave += 1
	
	# Set random wait time untuk spawn berikutnya
	timer.wait_time = randf_range(min_spawn_time, max_spawn_time)

func _wait_for_wave_clear():
	# Wait until all enemies from current wave are dead
	while game_manager and not game_manager.is_current_wave_cleared():
		await get_tree().create_timer(0.5).timeout
	
	# Wave cleared! Move to next wave
	current_wave += 1
	
	# Sync wave with game_manager
	if game_manager:
		game_manager.start_next_wave()
	
	# Resume spawning
	timer.start()

func show_final_wave_text():
	# Buat label untuk "FINAL WAVE!"
	var label = Label.new()
	label.text = "FINAL WAVE!"
	label.add_theme_font_size_override("font_size", 72)
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Set posisi di tengah layar
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().root.add_child(canvas_layer)
	
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(label)
	
	# Hapus setelah 3 detik
	await get_tree().create_timer(3.0).timeout
	canvas_layer.queue_free()
