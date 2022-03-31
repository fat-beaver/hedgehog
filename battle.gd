extends Node2D

onready var camera = $HexGrid/Camera2D
onready var grid = $HexGrid
onready var path = $HexGrid/HexPath

var last_mouse_hex

const ferret_hex_coords = Vector2(-4, 0)
onready var ferret_hex = grid.get_hex_at_coords(ferret_hex_coords)

func _ready():
	pass

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.move_local_x(movement_vector.x * 1600 * delta)
	camera.move_local_y(movement_vector.y * 1600 * delta)
	
	var hex_coords_of_mouse = grid.hex_coords_of_point(get_global_mouse_position())
	if Input.is_action_pressed("left_click"):
		grid.set_hex_terrain(grid.get_hex_at_coords(hex_coords_of_mouse), 3)
	
	if Input.is_action_pressed("right_click"):
		grid.set_terrain_all_tiles(0)
	
	var mouse_hex = grid.get_hex_at_coords(grid.hex_coords_of_point(get_global_mouse_position()))
	if last_mouse_hex != mouse_hex and mouse_hex != null:
		var path_start = ferret_hex
		var path_end = mouse_hex
		if path_start.is_passable() and path_end.is_passable():
			path.set_path(grid.find_path_between(path_start, path_end))
			last_mouse_hex = mouse_hex
		else:
			path.clear_path()
