extends Node2D

@export var ground_layer : TileMapLayer
@export var tile_size: int = 32
@export var exit_color : Color = Color.WHITE
@export var exit_size: Vector2 = Vector2(32,32)

var exit_tile_pos: Vector2i

func _ready():
	var parent = get_parent()
	if parent.has_signal("ground_tilemap_completed"):
		parent.ground_tilemap_completed.connect(_on_ground_tilemap_completed)
	else:
		push_error("parent node dosen't have signal on ground tilemap completed")
	
	if parent.has_signal("reset_started"):
		parent.reset_started.connect(_on_reset_started)
	

func _on_ground_tilemap_completed() -> void:
	if ground_layer:
		place_exit()
	else:
		push_error("Ground tilemap not assigend")

func _on_reset_started():
	pass

func clear_exit():
	for child in get_children():
		child.queue_free()

func place_exit():
	clear_exit()
	
	var ground_cells = ground_layer.get_used_cells()
	if ground_cells.is_empty():
		push_warning("no ground tile found")
		return
	
	var rightmost_tile = ground_cells[0]
	var max_x = rightmost_tile.x
	for cell in ground_cells:
		if cell.x > max_x:
			max_x = cell.x
			rightmost_tile = cell
	
	# store the exit tile position 
	exit_tile_pos = rightmost_tile
	
	# convert tile cordinate to global_position
	var global_pos = ground_layer.map_to_local(rightmost_tile)
	
	# Place the exit has Color Rect
	var color_rect = ColorRect.new()
	color_rect.color = exit_color
	color_rect.size = exit_size
	
	# Center the color rect on the tile
	color_rect.position = global_pos - exit_size / 2
	color_rect.name = "Exit"
	add_child(color_rect)
