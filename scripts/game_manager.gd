extends Node

# Coin System
var coins: int = 25
signal coins_changed(new_amount)
var coin_timer: Timer

# Wave System
var current_wave: int = 1
var total_waves: int = 3
var all_waves_spawned: bool = false
var active_enemies: int = 0
var enemies_in_current_wave: int = 0
signal wave_changed(current: int, total: int)

# Game State
var game_over: bool = false
signal game_won
signal game_lost

# Stats buat player
var player_stats = {
	"max_health": 80,
	"damage": 12,
	"attack_cooldown": 1.0,
	"speed": 70
}
var pemain_stats = {
	"max_health": 150,
	"damage": 8,
	"attack_cooldown": 1.2,
	"speed": 50
}
var pulayer_stats = {
	"max_health": 100,
	"damage": 18,
	"attack_cooldown": 0.8,
	"speed": 65
}

# Stats buat enemy
var slime_stats = {
	"max_health": 60,
	"damage": 8,
	"attack_cooldown": 1.2,
	"speed": 55
}
var sulaime_stats = {
	"max_health": 90,
	"damage": 12,
	"attack_cooldown": 1.0,
	"speed": 60
}
var slim_stats = {
	"max_health": 300,
	"damage": 15,
	"attack_cooldown": 0.8,
	"speed": 70
}

# Spawn Costs
var player_spawn_cost: int = 8
var pemain_spawn_cost: int = 12
var pulayer_spawn_cost: int = 15

func _ready():
	# Setup auto coin timer
	coin_timer = Timer.new()
	coin_timer.wait_time = 1.2
	coin_timer.autostart = true
	coin_timer.timeout.connect(_on_coin_timer_timeout)
	add_child(coin_timer)
	
	# Play gameplay music
	var music = get_node_or_null("/root/Music")
	if music:
		music.play_music("gameplay")
	
	# Initialize wave
	wave_changed.emit(current_wave, total_waves)

func _on_coin_timer_timeout():
	add_coins(1)

# Untuk return stats ke spawner player
func get_player_stats() -> Dictionary:
	return player_stats
func get_pemain_stats() -> Dictionary:
	return pemain_stats
func get_pulayer_stats() -> Dictionary:
	return pulayer_stats
	
#Untuk return stats ke spawner enemy
func get_slime_stats() -> Dictionary:
	return slime_stats
func get_sulaime_stats() -> Dictionary:
	return sulaime_stats
func get_slim_stats() -> Dictionary:
	return slim_stats

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		return true
	return false

func get_coins() -> int:
	return coins

func get_player_spawn_cost() -> int:
	return player_spawn_cost

func get_pemain_spawn_cost() -> int:
	return pemain_spawn_cost
	
func get_pulayer_spawn_cost() -> int:
	return pulayer_spawn_cost

func can_afford_player() -> bool:
	return coins >= player_spawn_cost

func can_afford_pemain() -> bool:
	return coins >= pemain_spawn_cost

func can_afford_pulayer() -> bool:
	return coins >= pulayer_spawn_cost

# Wave management
func get_current_wave() -> int:
	return current_wave

func get_total_waves() -> int:
	return total_waves

# Enemy tracking
func enemy_spawned():
	active_enemies += 1
	enemies_in_current_wave += 1

func enemy_died():
	active_enemies -= 1
	enemies_in_current_wave -= 1
	
	# Check if current wave is cleared (for wave progression)
	if enemies_in_current_wave <= 0 and not all_waves_spawned:
		# Notify spawner that wave is cleared, can proceed to next wave
		pass
	
	# Check victory condition: all waves spawned and no enemies left
	if all_waves_spawned and active_enemies <= 0:
		win_game()

func is_current_wave_cleared() -> bool:
	return enemies_in_current_wave <= 0

func start_next_wave():
	if current_wave < total_waves:
		current_wave += 1
		enemies_in_current_wave = 0
		wave_changed.emit(current_wave, total_waves)

func all_waves_completed():
	all_waves_spawned = true
	# Check if already won (no enemies left)
	if active_enemies <= 0:
		win_game()

# Game Over Management
func win_game():
	if game_over:
		return
	game_over = true
	game_won.emit()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/victory.tscn")

func lose_game():
	if game_over:
		return
	game_over = true
	game_lost.emit()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/defeat.tscn")
