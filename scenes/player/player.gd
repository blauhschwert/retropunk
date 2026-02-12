class_name Player
extends CharacterBody2D

signal player_dead

@export_category("Player Data")
@export var max_health := 5

@export_category("Movement References")
@export var max_speed: float = 200.0
@export var min_speed: float = 30.0

var input_dir: Vector2
var key_pressed : int = 0
var is_attacking = false

@onready var animation_player = $AnimationPlayer
@onready var gun_point = $gun_point
@onready var health := max_health : set = set_health

func _ready():
	animation_player.play("idle")

func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("gun_key") and key_pressed <= 0:
		Globals.gun_equipped = true
		key_pressed = 2
	elif Input.is_action_just_pressed("gun_key") and key_pressed == 2:
		Globals.gun_equipped = false
		key_pressed = 0
		
	elif Input.is_action_just_pressed("b"):
		set_health(3)
	
	# TODO : to create a meele attack
	#if Input.is_action_just_pressed("shoot") and !Globals.gun_equipped:
		#is_attacking = true

func gun_visible():
	if Globals.gun_equipped == true:
		gun_point.visible = true
	else:
		gun_point.visible = false

func movement():
	input_dir = Input.get_vector("left","right","up","down")
	if input_dir != Vector2.ZERO:
		velocity = input_dir * max_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, min_speed)
	
	match input_dir:
		Vector2(1,0):
			animation_player.play("move_right")
		Vector2(-1,0):
			animation_player.play("move_left")
		Vector2(0,1):
			animation_player.play("move_down")
		Vector2(0,-1):
			animation_player.play("move_up")
		_:
			animation_player.play("idle")

func flip_toward_mouse():
	var mouse_pos = get_global_mouse_position()
	var player_pos = global_position
	if mouse_pos.x < player_pos.x:
		$Sprite2D.scale.x = -1
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.scale.x = 1
		$Sprite2D.flip_h = false 

func _create_hammer_swing() -> void:
	if is_attacking:
		animation_player.play("hammer_swing_around")

func _physics_process(delta: float):
	if health <= 0:
		dead()
	else:
		movement()
		move_and_slide()
		gun_visible()
		flip_toward_mouse()
		_create_hammer_swing()

func set_health(amount : int) -> void:
	health = clampi(amount, 0, max_health)

func dead():
	print(health)
	animation_player.play("die")
	await animation_player.animation_finished
	player_dead.emit()
