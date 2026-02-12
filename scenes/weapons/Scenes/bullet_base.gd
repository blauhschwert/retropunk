extends Area2D

@export var speed : float = 2.0
@export var damage: int = 10

var direction : Vector2 = Vector2.RIGHT

func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_entered.connect(queue_free)

func _physics_process(delta: float) -> void:
	$anim.play("active")
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	pass # Replace with function body.
