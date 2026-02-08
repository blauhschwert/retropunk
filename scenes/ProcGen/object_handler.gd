extends Node2D

@export var ground_layer: TileMapLayer
@export var exit_handler: Node2D
@export var upgrade_count: int = 3
@export var upgrade_scene: PackedScene
@export var enemy_count: int = 6
@export var enemy_scene: Array[PackedScene]
@export var energy_count: int = 3
@export var misc_count: int = 8
@export var tile_size = 32

func _ready() -> void:
	var parent = get_parent()
	if parent.has_signal("ground_tilemap_completed"):
		parent.ground_tilemap_completed.connect(_on_ground_tilemap_completed)
	else:
		push_error("parent node doesent have signal on ground tilemap completed")

func _on_reset_started():
	pass

func _on_ground_tilemap_completed():
	if ground_layer:
		place_objects()
	else:
		return

func clear_objects():
	for child in get_children():
		child.queue_free()

func place_objects():
	clear_objects()
	
	var ground_cells = ground_layer.get_used_cells()
	var ground_positions = []
	
	var exit_tile = exit_handler.exit_tile_pos if exit_handler and exit_handler.exit_tile_pos else null
	for cell in ground_cells:
		if exit_tile == null or cell != exit_tile:
			var global_pos = ground_layer.map_to_local(cell)
			ground_positions.append(global_pos)
		
	var total_objects = upgrade_count + enemy_count + energy_count + misc_count
	if ground_positions.size() < total_objects:
		push_warning("not enough ground tile to place all object without overlap " % [ground_positions.size(), total_objects])
	if ground_positions.size() == 0:
		push_warning("no ground tile found")
		
	ground_positions.shuffle()
	
	place_object_type(ground_positions,upgrade_count, Color.ORANGE, Vector2(8,8),"Ram")
	place_object_type(ground_positions,energy_count, Color.GREEN_YELLOW, Vector2(32,32), "Energy")
	place_object_type(ground_positions,energy_count, Color.AQUAMARINE, Vector2(32,32), "Miscellanous")
	place_object_type(ground_positions,enemy_count, Color.BLUE_VIOLET, Vector2(32,32), "Enemy")
	

func place_object_type(positions: Array, count: int, color : Color, size: Vector2, object_name: String):
	var placement_count = min(count, positions.size())
	for i in range(placement_count):
		var pos = positions.pop_front()
		var color_rect = ColorRect.new()
		color_rect.color = color
		color_rect.size = size
		
		# Center the ColorRect on the tile
		color_rect.position = pos - size / 2
		color_rect.name = object_name + "_" + str(i)
		add_child(color_rect)
	

func pick_random_number():
	pass
