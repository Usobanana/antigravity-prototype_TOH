extends Area3D
class_name EnemyProjectile

var direction: Vector3 = Vector3.ZERO
var speed: float = 8.0
var damage: int = 5
var lifetime: float = 3.0

func setup(dir: Vector3, dmg: int) -> void:
	direction = dir
	damage = dmg

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Follower"):
		if body.has_method("take_damage"):
			# TODO: プレイヤー側ダメージ処理が未実装の場合はここで実装するか、ログ出すだけに留める
			pass
		queue_free()
