extends CanvasLayer

@export var spawner_path: NodePath
@onready var spawner: Node = get_node(spawner_path)
@onready var game_manager: Node = %GameManager
@onready var coin_label: Label = $Container/CoinLabel
@onready var wave_label: Label = $Container/WaveLabel
@onready var spawner_health_bar: TextureProgressBar = $Container/SpawnerHealthBarContainer/SpawnerHealthBar
#@onready var player_label: Label = $Panel/PlayerButton

# Button references (AnimatedSprite2D dengan area click)
@onready var player_button: AnimatedSprite2D = $Container/PlayerButton
@onready var pemain_button: AnimatedSprite2D = $Container/PemainButton
@onready var pulayer_button: AnimatedSprite2D = $Container/PulayerButton

# Button states
enum ButtonState { IDLE, HOVER, COOLDOWN }
var player_button_state: ButtonState = ButtonState.IDLE
var pemain_button_state: ButtonState = ButtonState.IDLE
var pulayer_button_state: ButtonState = ButtonState.IDLE

func _ready():
	# Set initial animations
	player_button.play("idle")
	pemain_button.play("idle")
	pulayer_button.play("idle")
	
	# Connect to coin changes
	if game_manager:
		game_manager.coins_changed.connect(_on_coins_changed)
		game_manager.wave_changed.connect(_on_wave_changed)
		_update_ui()
		# Set initial wave display
		set_wave(game_manager.get_current_wave(), game_manager.get_total_waves())
	
	# Connect to spawner cooldown timers (with null checks)
	if spawner:
		if spawner.get("player_cooldown_timer") and spawner.player_cooldown_timer:
			spawner.player_cooldown_timer.timeout.connect(_on_player_cooldown_finished)
		if spawner.get("pemain_cooldown_timer") and spawner.pemain_cooldown_timer:
			spawner.pemain_cooldown_timer.timeout.connect(_on_pemain_cooldown_finished)
		if spawner.get("pulayer_cooldown_timer") and spawner.pulayer_cooldown_timer:
			spawner.pulayer_cooldown_timer.timeout.connect(_on_pulayer_cooldown_finished)

func set_spawner_health(current: int, maximum: int):
	if spawner_health_bar:
		spawner_health_bar.max_value = maximum
		spawner_health_bar.value = current

func set_wave(current_wave: int, total_waves: int):
	if wave_label:
		wave_label.text = "Wave: %d/%d" % [current_wave, total_waves]

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_viewport().get_mouse_position()
		
		# Check player button click
		if _is_mouse_over_sprite(player_button, mouse_pos):
			_on_player_button_pressed()
		# Check pemain button click
		elif _is_mouse_over_sprite(pemain_button, mouse_pos):
			_on_pemain_button_pressed()
		# Check pulayer button click
		elif _is_mouse_over_sprite(pulayer_button, mouse_pos):
			_on_pulayer_button_pressed()

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Handle player button hover
	if _is_mouse_over_sprite(player_button, mouse_pos):
		if player_button_state != ButtonState.COOLDOWN and player_button_state != ButtonState.HOVER:
			_on_player_button_hover()
	elif player_button_state == ButtonState.HOVER:
		_on_player_button_unhover()
	
	# Handle pemain button hover
	if _is_mouse_over_sprite(pemain_button, mouse_pos):
		if pemain_button_state != ButtonState.COOLDOWN and pemain_button_state != ButtonState.HOVER:
			_on_pemain_button_hover()
	elif pemain_button_state == ButtonState.HOVER:
		_on_pemain_button_unhover()
	
	# Handle pulayer button hover
	if _is_mouse_over_sprite(pulayer_button, mouse_pos):
		if pulayer_button_state != ButtonState.COOLDOWN and pulayer_button_state != ButtonState.HOVER:
			_on_pulayer_button_hover()
	elif pulayer_button_state == ButtonState.HOVER:
		_on_pulayer_button_unhover()

func _is_mouse_over_sprite(sprite: AnimatedSprite2D, mouse_pos: Vector2) -> bool:
	if not sprite or not sprite.sprite_frames:
		return false
	
	var texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if not texture:
		return false
	
	var sprite_rect = Rect2(sprite.global_position - texture.get_size() / 2, texture.get_size())
	return sprite_rect.has_point(mouse_pos)

func _update_ui():
	if not is_instance_valid(spawner):
		return
		
	if game_manager:
		var player_cost = game_manager.get_player_spawn_cost()
		var pemain_cost = game_manager.get_pemain_spawn_cost()
		var pulayer_cost = game_manager.get_pulayer_spawn_cost()
		var coins = game_manager.get_coins()
		
		# Update coin display
		coin_label.text = str(coins)
		
		# Update button states based on cooldown
		# Player button
		if not spawner.player_can_spawn and player_button_state != ButtonState.COOLDOWN:
			player_button_state = ButtonState.COOLDOWN
			player_button.play("on_click")
		elif spawner.player_can_spawn and player_button_state == ButtonState.COOLDOWN:
			player_button_state = ButtonState.IDLE
			player_button.play("idle")
		
		# Pemain button
		if not spawner.pemain_can_spawn and pemain_button_state != ButtonState.COOLDOWN:
			pemain_button_state = ButtonState.COOLDOWN
			pemain_button.play("on_click")
		elif spawner.pemain_can_spawn and pemain_button_state == ButtonState.COOLDOWN:
			pemain_button_state = ButtonState.IDLE
			pemain_button.play("idle")
		
		# Pulayer button
		if not spawner.pulayer_can_spawn and pulayer_button_state != ButtonState.COOLDOWN:
			pulayer_button_state = ButtonState.COOLDOWN
			pulayer_button.play("on_click")
		elif spawner.pulayer_can_spawn and pulayer_button_state == ButtonState.COOLDOWN:
			pulayer_button_state = ButtonState.IDLE
			pulayer_button.play("idle")

func _on_coins_changed(new_amount: int):
	_update_ui()

func _on_wave_changed(current: int, total: int):
	set_wave(current, total)

# Button hover callbacks
func _on_player_button_hover():
	if player_button_state != ButtonState.COOLDOWN:
		player_button_state = ButtonState.HOVER
		player_button.play("hover")

func _on_player_button_unhover():
	if player_button_state == ButtonState.HOVER:
		player_button_state = ButtonState.IDLE
		player_button.play("idle")

func _on_pemain_button_hover():
	if pemain_button_state != ButtonState.COOLDOWN:
		pemain_button_state = ButtonState.HOVER
		pemain_button.play("hover")

func _on_pemain_button_unhover():
	if pemain_button_state == ButtonState.HOVER:
		pemain_button_state = ButtonState.IDLE
		pemain_button.play("idle")

func _on_pulayer_button_hover():
	if pulayer_button_state != ButtonState.COOLDOWN:
		pulayer_button_state = ButtonState.HOVER
		pulayer_button.play("hover")

func _on_pulayer_button_unhover():
	if pulayer_button_state == ButtonState.HOVER:
		pulayer_button_state = ButtonState.IDLE
		pulayer_button.play("idle")

# Cooldown finished callbacks
func _on_player_cooldown_finished():
	player_button_state = ButtonState.IDLE
	player_button.play("idle")
	_update_ui()

func _on_pemain_cooldown_finished():
	pemain_button_state = ButtonState.IDLE
	pemain_button.play("idle")
	_update_ui()

func _on_pulayer_cooldown_finished():
	pulayer_button_state = ButtonState.IDLE
	pulayer_button.play("idle")
	_update_ui()

func _on_player_button_pressed():
	if not is_instance_valid(spawner):
		return
	if spawner and spawner.player_can_spawn:
		var player_cost = game_manager.get_player_spawn_cost()
		var coins = game_manager.get_coins()
		
		if coins >= player_cost:
			Sfx.play_click()
			spawner.spawn_player()
			player_button_state = ButtonState.COOLDOWN
			player_button.play("on_click")
			_update_ui()
	else:
		pass

func _on_pemain_button_pressed():
	if not is_instance_valid(spawner):
		return
	if spawner and spawner.pemain_can_spawn:
		var pemain_cost = game_manager.get_pemain_spawn_cost()
		var coins = game_manager.get_coins()
		
		if coins >= pemain_cost:
			Sfx.play_click()
			spawner.spawn_pemain()
			pemain_button_state = ButtonState.COOLDOWN
			pemain_button.play("on_click")
			_update_ui()
	else:
		pass

func _on_pulayer_button_pressed():
	if not is_instance_valid(spawner):
		return
	if spawner and spawner.pulayer_can_spawn:
		var pulayer_cost = game_manager.get_pulayer_spawn_cost()
		var coins = game_manager.get_coins()
		
		if coins >= pulayer_cost:
			Sfx.play_click()
			spawner.spawn_pulayer()
			pulayer_button_state = ButtonState.COOLDOWN
			pulayer_button.play("on_click")
			_update_ui()
	else:
		pass
