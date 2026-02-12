class_name EnemySlimeBasic
extends Area2D

@onready var live_bar = $live_bar

func _input(event):
	if Input.is_action_just_pressed("attack"):
		live_bar.emit_damage.emit(2)
	if Input.is_action_just_pressed("b"):
		live_bar.emit_damage.emit(1)


func _on_live_bar_health_depleted():
	queue_free()
