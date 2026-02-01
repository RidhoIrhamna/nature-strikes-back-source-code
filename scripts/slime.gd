extends CharacterBody2D

var speed: float
var max_health: int
var damage: int
var attack_cooldown: float
var health: int
var can_attack: bool = true
var game_manager: Node = null

@onready var ray_castleft: RayCast2D = $RayCastleft
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $HealthBarContainer/HealthBar

func initialize(stats: Dictionary):
	# Terima stats dari spawner
	speed = stats["speed"]
	max_health = stats["max_health"]
	damage = stats["damage"]
	attack_cooldown = stats["attack_cooldown"]
	health = max_health
	
	# Update health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func _ready():
	# Fallback jika tidak di-spawn via spawner (pakai default values)
	pass

func _physics_process(delta: float) -> void:
	if ray_castleft.is_colliding():
		var hit = ray_castleft.get_collider()
		
		# Cek apakah hit masih valid (tidak null)
		if hit and hit.is_in_group("player"):
			anim.play("attack")
			
			# Berikan damage ke player
			if can_attack and hit.has_method("take_damage"):
				hit.take_damage(damage)
				can_attack = false
				# Cooldown attack dengan timer terpisah
				start_attack_cooldown()
			return


	# kalau tidak kena player → tetap jalan ke kiri
	anim.play("walk")
	position.x -= speed * delta

func start_attack_cooldown():
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int):
	health -= amount
	
	# Update health bar with smooth transition
	if health_bar:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(health_bar, "value", health, 0.3)
	
	if health <= 0:
		die()

func die():
	# Notify game_manager
	if game_manager and game_manager.has_method("enemy_died"):
		game_manager.enemy_died()
	
	queue_free()
