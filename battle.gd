extends Node2D

onready var camera = $HexGrid/Camera2D
onready var grid = $HexGrid

func _ready():
	pass

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.move_local_x(movement_vector.x * 1600 * delta)
	camera.move_local_y(movement_vector.y * 1600 * delta)
	
	var hex_coords_of_mouse = grid.hex_coords_of_point(get_global_mouse_position())
	if Input.is_action_pressed("click"):
		grid.set_hex_terrain(grid.get_hex_at_coords(hex_coords_of_mouse), 3)
