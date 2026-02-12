class_name Gun
extends Node2D

@export var flip_axis: String = "y" # y for vertical flix, x for horizontal flip
@export var base_rotation_offset: float = 0.0
@export var flip_y_offset: float = 0.0

@export_category("Bullet Category")
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15
@export var bullet_speed : float = 400.0
@export var bullet_damaga: int = 10
@export var spawn_position: Marker2D
@export var can_shoot : bool = true

var mouse_pos : Vector2
var direction: Vector2
var parent = null

func _ready() -> void:
	parent = get_parent()

func _process(delta : float) -> void:
	look_at_target()
	
	if parent.is_in_group("Gun"):
		if Input.is_action_just_pressed("shoot") and can_shoot:
			shoot(direction, spawn_position.global_position)

func look_at_target():
	if parent.is_in_group("Gun"):
		mouse_pos = get_global_mouse_position()
		direction = (mouse_pos - global_position).normalized()
		
		# calculate rotation, compansiting for paren'ts rotation
		var angle = direction.angle()
		var parent_rotation = get_parent().rotation
		rotation = angle + deg_to_rad(base_rotation_offset) - parent_rotation
		
		var sprite = $Sprite2D
		if direction.x < 0:
			if flip_axis == "y":
				sprite.scale.y = -1
				sprite.position.y = flip_y_offset
			elif flip_axis == "x":
				sprite.scale.x = -1 
		else: # mouse is to the right
			if flip_axis == "y":
				sprite.scale.y = 1
				sprite.position.y = 0
			elif flip_axis == "x":
				sprite.scale.x = 1
	else:
		return

func _fire(direction: Vector2, spawn_position) -> void:
	pass

func shoot(direction: Vector2, spawn_position: Vector2) -> void:
	if Globals.gun_equipped:
	
		if not can_shoot:
			return
		
		can_shoot = false
		_fire(direction, spawn_position)
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true
	else:
		return
