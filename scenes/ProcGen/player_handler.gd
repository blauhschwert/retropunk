class_name PlayerHandler
extends Node2D

@export var ground_layer_path: NodePath = "../Ground"
@export var walker_path: NodePath = ".." # Path to walker (root procgen node2d)
@export var tile_size: int = 32
@export var player_scene: PackedScene # This is our player scene

var player : Node2D

func _ready():
	var walker = get_node_or_null(walker_path)
	if walker:
		if walker.has_signal("ground_tilemap_completed"):
			walker.ground_tilemap_completed.connect(_on_ground_tilemap_completed)
		if walker.has_signal("reset_started"):
			walker.reset_started.connect(_on_reset_started)
		else:
			push_error("Walker is missing signal")


func _on_ground_tilemap_completed():
	var ground_layer = get_node_or_null(ground_layer_path)
	if not ground_layer or not ground_layer is TileMapLayer:
		push_error("Ground layer not found")
		return
	
	# Get populated tiles
	var ground_cells = ground_layer.get_used_cells()
	if ground_cells.is_empty():
		return
	
	#Find leftmost tile (smallest.x , then smallest.y)
	var leftmost_tile: Vector2i = ground_cells[0]
	for cell in ground_cells:
		if cell.x < leftmost_tile.x or (cell.x == leftmost_tile.x and cell.y < leftmost_tile.y):
			leftmost_tile = cell
	
	# Instance the player
	if player_scene:
		player = player_scene.instantiate()
		add_child(player)
		var tile_position = ground_layer.map_to_local(leftmost_tile)
		player.position = tile_position
		
		# this is for connecting the playwer handler to the player signal
		if player.has_signal("player_dead"):
			player.player_dead.connect(_on_player_dead)
		
	else:
		push_error("Player Scene not assigned")

func get_player() -> Node:
	return player

func _on_reset_started():
	# remove player during reset
	for i in self.get_children():
		i.queue_free()

func _on_player_dead():
	var walker = get_node_or_null(walker_path)
	if walker and walker.has_method("reset_simulation"):
		walker.emit_signal("reset_started")
		walker.reset_simulation()
	else:
		push_error("Walker node or reset simulation method not found")
