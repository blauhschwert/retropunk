extends Node

var gun_equipped = false
var max_health = 6
var cur_health = max_health

func get_health() -> int:
	return cur_health

func set_health(amount) -> void:
	cur_health = amount

func create_healt_system(amount) -> void:
	max_health = clampi(amount,0,max_health)
