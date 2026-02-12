extends Area2D

@onready var gun_point : Node2D = $"../gun_point"

func _process(delta) -> void:
	if gun_point.visible == true:
		visible = true
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED_HIDDEN)
		global_position = get_global_mouse_position()
	if gun_point.visible == false:
		visible = false
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
