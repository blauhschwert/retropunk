class_name LiveBar
extends Control

signal emit_damage(amount)
signal health_depleted

@onready var live_label = $live_label
@onready var progress_bar = $ProgressBar

#func _input(event) -> void:
	#if Input.is_action_just_pressed("b"):
		#Globals.cur_health -= 1


func _ready() -> void:
	emit_damage.connect(_set_health)
	progress_bar.max_value = Globals.max_health
	progress_bar.value = Globals.get_health()

func _process(delta):
	display_hp_label()
	
	progress_bar.value = Globals.cur_health
	
	if not progress_bar.value > 0:
		health_depleted.emit()

func display_hp_label() -> void:
	live_label.text = "  HP  " + str(int(progress_bar.max_value)) + " / " + str(int(Globals.cur_health))

func _set_health(amount : int) -> void:
	if progress_bar.value >= 0:
		progress_bar.value -= amount
