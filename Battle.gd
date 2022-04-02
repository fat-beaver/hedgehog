extends Node2D
class_name Battle

var last_mouse_hex
var zoom_level = 2
#camera constants
const min_zoom = 1
const max_zoom = 5
const camera_movement_mult = 1200
#ferret location
const ferret_coords = Vector2(-4, 0)
#hedgehog location
const hedgehog_coords = Vector2(4, 0)
#map constants
const map_size = 40
const default_unit_direction = Vector2(1,0)
#children
var path = HexPath.new()
var camera = Camera2D.new()
var grid = HexGrid.new(map_size)
var ferret = Critter.new(Critter.FERRET, grid.get_hex_at_coords(ferret_coords), default_unit_direction)
var hedgehog = Critter.new(Critter.HEDGEHOG, grid.get_hex_at_coords(hedgehog_coords), default_unit_direction)

func _ready():
	#add all of the children
	add_child(grid)
	add_child(path)
	_set_up_camera()
	_set_up_critter(ferret)
	_set_up_critter(hedgehog)

func _set_up_camera():
	add_child(camera)
	#set the camera as the current one so it is actually used
	camera.current = true
	#centre the camera on hex (0,0)
	camera.set_global_position(grid.get_hex_at_coords(Vector2(0, 0)).get_centre_point())
	camera.zoom = Vector2(zoom_level, zoom_level)

func _set_up_critter(critter: Critter):
	add_child(critter)
	grid.set_hex_terrain(critter.get_location(), 0)

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.move_local_x(movement_vector.x * camera_movement_mult * delta * zoom_level)
	camera.move_local_y(movement_vector.y * camera_movement_mult * delta * zoom_level)
	
	if Input.is_action_pressed("left_click"):
		_find_path_to_mouse()

	if Input.is_action_just_released("left_click"):
		_move_critter_to_mouse(ferret)

	if Input.is_action_just_released("zoom_out") and zoom_level < max_zoom:
		zoom_level += 0.25
		camera.zoom = Vector2(zoom_level, zoom_level)

	if Input.is_action_just_released("zoom_in") and zoom_level > min_zoom:
		zoom_level -= 0.25
		camera.zoom = Vector2(zoom_level, zoom_level)

func _find_path_to_mouse():
	var mouse_hex = grid.get_hex_at_coords(grid.hex_coords_of_point(get_global_mouse_position()))
	if last_mouse_hex != mouse_hex and mouse_hex != null:
		var path_start = ferret.get_location()
		var path_end = mouse_hex
		path.set_path(grid.find_path_between(path_start, path_end, default_unit_direction))
		last_mouse_hex = mouse_hex

func _move_critter_to_mouse(critter: Critter):
	var mouse_hex = grid.get_hex_at_coords(grid.hex_coords_of_point(get_global_mouse_position()))
	if mouse_hex != null:
		var path_start = ferret.get_location()
		var path_end = mouse_hex
		path.set_path(grid.find_path_between(path_start, path_end, default_unit_direction))
		if path.get_path_length() != 0:
			critter.move(path_end)
			critter.set_direction(path.get_end()[1])
			path.clear_path()
		last_mouse_hex = mouse_hex
