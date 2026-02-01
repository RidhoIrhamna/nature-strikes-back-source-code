extends StaticBody2D

@onready var player_scene = preload("res://scenes/player (1).tscn")
@onready var pemain_scene = preload("res://scenes/player (2).tscn")
@onready var pulayer_scene = preload("res://scenes/player (3).tscn")

@onready var pemain_cooldown_timer: Timer = $PemainCooldownTimer
@onready var player_cooldown_timer: Timer = $PlayerCooldownTimer
@onready var pulayer_cooldown_timer: Timer = $PulayerCooldownTimer

@onready var game_manager: Node = %GameManager
@onready var health_bar: TextureProgressBar = $HealthBarContainer/HealthBar

# Spawner health stats
var max_health: int = 50
var current_health: int = 50

var player_can_spawn: bool = true
var pemain_can_spawn: bool = true
var pulayer_can_spawn: bool = true

@export var player_cooldown: float = 3.0
@export var pemain_cooldown: float = 2.0
@export var pulayer_cooldown: float = 4.0

func _ready():
	# Setup player cooldown timer
	player_cooldown_timer.one_shot = true
	player_cooldown_timer.autostart = false
	player_cooldown_timer.timeout.connect(_on_player_cooldown_timeout)
	
	# Setup pemain cooldown timer
	pemain_cooldown_timer.one_shot = true
	pemain_cooldown_timer.autostart = false
	pemain_cooldown_timer.timeout.connect(_on_pemain_cooldown_timeout)
	
	# Setup pulayer cooldown timer
	pulayer_cooldown_timer.one_shot = true
	pulayer_cooldown_timer.autostart = false
	pulayer_cooldown_timer.timeout.connect(_on_pulayer_cooldown_timeout)
	
	# Initialize health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	
	# Update spawn_ui health bar
	await get_tree().process_frame
	var spawn_ui = get_tree().get_first_node_in_group("spawn_ui")
	if spawn_ui and spawn_ui.has_method("set_spawner_health"):
		spawn_ui.set_spawner_health(current_health, max_health)

func take_damage(amount: int):
	current_health -= amount
	current_health = max(0, current_health)
	
	Sfx.play_hit_tower()
	
	if health_bar:
		health_bar.value = current_health
	
	# Update spawn_ui health bar
	var spawn_ui = get_tree().get_first_node_in_group("spawn_ui")
	if spawn_ui and spawn_ui.has_method("set_spawner_health"):
		spawn_ui.set_spawner_health(current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	if game_manager and game_manager.has_method("lose_game"):
		game_manager.lose_game()
	queue_free()

func kemah_take_damage(amount: int):
	# Backward compatibility
	take_damage(amount)

func kemah_destroyed():
	# Backward compatibility
	die()

func _on_player_cooldown_timeout() -> void:
	player_can_spawn = true
	
func _on_pemain_cooldown_timeout() -> void:
	pemain_can_spawn = true
	
func _on_pulayer_cooldown_timeout() -> void:
	pulayer_can_spawn = true

func spawn_player():
	if not player_can_spawn:
		return
	
	if not game_manager:
		return
	
	# Check if player has enough coins
	if not game_manager.can_afford_player():
		return
	
	# Spend coins
	if not game_manager.spend_coins(game_manager.get_player_spawn_cost()):
		return
	
	# Random Y offset to prevent stacking
	var y_offset = randf_range(-5.0, 5.0)
	var spawn_pos = global_position + Vector2(0, y_offset)
	
	var player = player_scene.instantiate()
	player.position = spawn_pos
	player.z_index = int(spawn_pos.y)

	var stats = game_manager.get_player_stats()
	player.initialize(stats)
	player.player_type = "macan"
	
	Sfx.play_spawn_macan()

	get_parent().add_child(player)
	
	# Start cooldown
	player_can_spawn = false
	player_cooldown_timer.wait_time = player_cooldown
	player_cooldown_timer.start()

func spawn_pemain():
	if not pemain_can_spawn:
		return
	
	if not game_manager:
		return
	
	# Check if player has enough coins
	if not game_manager.can_afford_pemain():
		return
	
	# Spend coins
	if not game_manager.spend_coins(game_manager.get_pemain_spawn_cost()):
		return
	
	# Random Y offset to prevent stacking
	var y_offset = randf_range(-40.0, 40.0)
	var spawn_pos = global_position + Vector2(0, y_offset)
	
	var pemain = pemain_scene.instantiate()
	pemain.position = spawn_pos
	pemain.z_index = int(spawn_pos.y)

	var stats = game_manager.get_pemain_stats()
	pemain.initialize(stats)
	pemain.player_type = "gajah"
	
	Sfx.play_spawn_gajah()

	get_parent().add_child(pemain)
	
	# Start cooldown
	pemain_can_spawn = false
	pemain_cooldown_timer.wait_time = pemain_cooldown
	pemain_cooldown_timer.start()

func spawn_pulayer():
	if not pulayer_can_spawn:
		return
	
	if not game_manager:
		return
	
	# Check if player has enough coins
	if not game_manager.can_afford_pulayer():
		return
	
	# Spend coins
	if not game_manager.spend_coins(game_manager.get_pulayer_spawn_cost()):
		return
	
	# Random Y offset to prevent stacking
	var y_offset = randf_range(-40.0, 40.0)
	var spawn_pos = global_position + Vector2(0, y_offset)
	
	var pulayer = pulayer_scene.instantiate()
	pulayer.position = spawn_pos
	pulayer.z_index = int(spawn_pos.y)

	var stats = game_manager.get_pulayer_stats()
	pulayer.initialize(stats)
	pulayer.player_type = "badak"
	
	Sfx.play_spawn_badak()

	get_parent().add_child(pulayer)
	
	# Start cooldown
	pulayer_can_spawn = false
	pulayer_cooldown_timer.wait_time = pulayer_cooldown
	pulayer_cooldown_timer.start()
