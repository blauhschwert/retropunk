extends Node2D

signal ground_tilemap_completed # this is a signal sent when the walker is ground is finished
signal reset_started # sent when restarting the level

@export_category("Debug Helpers")
@export var is_debug : bool = false

@export_category("Procedual Data")
@export var is_instant: bool
@export var num_walker: int = 3
@export var max_iterations: int =  1000
@export var costum_viewport_size: Vector2 = Vector2(1920, 1080)
@export var step_size: int = 32
@export_range(0.0, 1.0) var ground_chance: float = 1.0
@export var tile_size: int = 32
@export var borders: int = 3
@export var step_per_frame: int = 10

@export_category("TileMapLaver Data")
@export var ground_tile_coords: Vector2i = Vector2i(0,0)
@export var background_tile_coords: Vector2i = Vector2i(1,1)

@onready var ground_layer: TileMapLayer = $Ground
@onready var background_layer: TileMapLayer = $background
@onready var camera_2d: Camera2D  = $Camera2D
@onready var player_handler = $PlayerHandler

var walkers: Array[Vector2i] = []
var iteration_count : int = 0
var is_simulation_running: bool = false
var viewport_size: Vector2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("Resetting simulation")
		emit_signal("reset_started")
		reset_simulation() 
	if Input.is_action_just_released("ui_cancel"):
		print("Quitting game")
		get_tree().quit()

func _ready() -> void:
	viewport_size = costum_viewport_size
	
	if camera_2d:
		var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
		camera_2d.position = Vector2(grid_size * tile_size) / 2
		camera_2d.zoom = Vector2(1, 1)
		
	reset_simulation()
	
	

func _process(delta: float) -> void:
	choose_generation()

func create_level():
	if not is_simulation_running:
		return
	for i in range(step_per_frame): #perform multiple steps for the generation
		if iteration_count >= max_iterations:
			break # stop if the maximum iteration are reached
		update_walkers() # Moves walkers and place tiles
		iteration_count += 1
	if iteration_count >= max_iterations:
		emit_signal("ground_tilemap_completed")
		fill_background_terrain()
		is_simulation_running = false


func reset_simulation():
	ground_layer.clear()
	background_layer.clear()
	walkers.clear()
	
	var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
	var center: Vector2i = grid_size / 2
	
	for i in range(num_walker):
		walkers.append(center)
		ground_layer.set_cell(Vector2i(center.x, center.y), 0, ground_tile_coords)
	
	iteration_count = 0
	is_simulation_running = true

func update_walkers():
	var tiles_placed: int = 0
	for i in range(walkers.size()):
		var direction: Vector2i = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT][randi() % 4]
		var new_pos: Vector2i = walkers[i] + direction * (step_size / tile_size)
		
		# Ensure the walkers stay within the grid boundaries
		var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
		var min_bound: Vector2i = Vector2i(borders, borders)
		var max_bound: Vector2i = grid_size - Vector2i(borders, borders)
		if (new_pos.x >= min_bound.x and new_pos.x < max_bound.x and
			new_pos.y >= min_bound.y and new_pos.y < max_bound.y):
				walkers[i] = new_pos # update walker position
				if randf() < ground_chance: # Place ground tile based on probability
					ground_layer.set_cell(new_pos, 0, ground_tile_coords)
					tiles_placed += 1

#func fill_background() -> void:
	#var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
	#var placed_tiles: int = 0
	#for x in range(grid_size.x):
		#for y in range(grid_size.x):
			#var cell_pos: Vector2i = Vector2i(x,y)
			#if ground_layer.get_cell_source_id(cell_pos) == -1: # check if th ecell is empty
				#background_layer.set_cell(cell_pos, 0, background_tile_coords)
				#placed_tiles += 1
	#
	#if is_debug:
		## print the number of background tiles placed for debugging
		#print("Background tiles placed : ", placed_tiles)

func fill_background_terrain() -> void:
	var grid_size: Vector2i = Vector2i(viewport_size) / tile_size
	var cells: Array[Vector2i] = []
	var placed_tile: int = 0
		
	if is_debug:
		print("The number of cell is ", grid_size)
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell_pos: Vector2i = Vector2i(x,y)
			if ground_layer.get_cell_source_id(cell_pos) == -1:
				cells.append(cell_pos)
				placed_tile += 1
	
	if not cells.is_empty():
		background_layer.set_cells_terrain_connect(cells, 0,0)
	else:
		print("No cells to fill with terrain")
	
	if is_debug:
		print("Background terrain tiles palced : ", placed_tile)
	

func choose_generation():
	if is_instant:
		create_level_instant()
	else:
		create_level()

# TODO : improve that feature to create faster levels
# - not working
func create_level_instant():
	if not is_simulation_running:
		return
	
	iteration_count = 0
	while iteration_count < max_iterations:
		update_walkers() # move walker and place tiles
		iteration_count += 1
	
	if is_simulation_running:
		emit_signal("ground_tilemap_completed")
		fill_background_terrain()
		is_simulation_running = false
	
	# complete the map by filling the background
	emit_signal("ground_tilemap_completed")
	fill_background_terrain()
