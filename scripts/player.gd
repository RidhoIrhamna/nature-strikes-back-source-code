extends CharacterBody2D

var speed: float
var max_health: int
var damage: int
var attack_cooldown: float
var health: int
var can_attack: bool = true
var player_type: String = "macan" # "macan", "gajah", or "badak"

@onready var ray_castright: RayCast2D = $RayCastright
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
	if ray_castright.is_colliding():
		var hit = ray_castright.get_collider()
		
		# Cek apakah hit masih valid (tidak null)
		if hit and hit.is_in_group("slime"):
			anim.play("attack")
			
			# Berikan damage ke slime
			if can_attack and hit.has_method("take_damage"):
				hit.take_damage(damage)
				# Play attack sound based on player type
				match player_type:
					"macan":
						Sfx.play_serang_macan()
					"gajah":
						Sfx.play_serang_gajah()
					"badak":
						Sfx.play_serang_badak()
				can_attack = false
				# Cooldown attack
				await get_tree().create_timer(attack_cooldown).timeout
				can_attack = true
			return

	anim.play("walk")
	position.x += speed * delta

func take_damage(amount: int):
	health -= amount
	
	# Update health bar
	if health_bar:
		health_bar.value = health
	
	if health <= 0:
		die()

func die():
	print("Player mati!")
	queue_free()
