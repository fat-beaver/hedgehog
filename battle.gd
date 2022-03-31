extends Node2D

onready var camera = $HexGrid/Camera2D
onready var grid = $HexGrid
onready var path = $HexGrid/HexPath

var last_mouse_hex
var zoom_level = 2

const min_zoom = 1
const max_zoom = 5
const camera_movement_mult = 1200

const ferret_hex_coords = Vector2(-4, 0)
onready var ferret_hex = grid.get_hex_at_coords(ferret_hex_coords)

func _ready():
	#centre the camera on hex (0,0)
	camera.set_global_position(grid.get_hex_at_coords(Vector2(0, 0)).get_centre_point())
	camera.zoom = Vector2(zoom_level, zoom_level)

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.move_local_x(movement_vector.x * camera_movement_mult * delta * zoom_level)
	camera.move_local_y(movement_vector.y * camera_movement_mult * delta * zoom_level)
	
	if Input.is_action_pressed("left_click"):
		var mouse_hex = grid.get_hex_at_coords(grid.hex_coords_of_point(get_global_mouse_position()))
		if last_mouse_hex != mouse_hex and mouse_hex != null:
			var path_start = ferret_hex
			var path_end = mouse_hex
			if path_start.is_passable() and path_end.is_passable():
				path.set_path(grid.find_path_between(path_start, path_end))
				last_mouse_hex = mouse_hex
			else:
				path.clear_path()

	if Input.is_action_just_released("zoom_out") and zoom_level < max_zoom:
		zoom_level += 0.25
		camera.zoom = Vector2(zoom_level, zoom_level)

	if Input.is_action_just_released("zoom_in") and zoom_level > min_zoom:
		zoom_level -= 0.25
		camera.zoom = Vector2(zoom_level, zoom_level)
