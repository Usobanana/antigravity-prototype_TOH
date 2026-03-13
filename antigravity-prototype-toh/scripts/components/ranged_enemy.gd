extends Enemy
class_name RangedEnemy

@export var projectile_scene: PackedScene
@export var shoot_interval: float = 2.0
var shoot_timer: float = 0.0

func _ready() -> void:
	super._ready()
	# 遠距離型なので近づきすぎないようにパラメータ上書き
	move_speed = 1.5
	attack_range = 6.0
	aggro_range = 10.0
	max_health = 20
	current_health = max_health

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if current_state == State.ATTACK:
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			_shoot()
			shoot_timer = shoot_interval

func _shoot() -> void:
	if not projectile_scene: return
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() == 0: return
	
	var target = players[0]
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	
	proj.global_position = global_position
	var dir = (target.global_position - global_position).normalized()
	dir.y = 0
	if proj.has_method("setup"):
		proj.setup(dir, attack_damage)
