extends Node2D
class_name Battle

var last_mouse_hex
#camera constants
const min_zoom = 1
const max_zoom = 5
const zoom_increment = 0.25
const default_zoom_level = 2
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
var current_critter = ferret

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
	camera.zoom = Vector2(default_zoom_level, default_zoom_level)

func _set_up_critter(critter: Critter):
	add_child(critter)
	grid.set_hex_terrain(critter.get_location(), 0)

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.move_local_x(movement_vector.x * camera_movement_mult * delta * camera.zoom.x)
	camera.move_local_y(movement_vector.y * camera_movement_mult * delta * camera.zoom.y)
	
	if Input.is_action_just_pressed("left_click"):
		_move_critter_to_mouse(current_critter)

	if Input.is_action_just_pressed("right_click"):
		_turn_critter(current_critter)

	if Input.is_action_just_released("zoom_out"):
		zoom(zoom_increment)

	if Input.is_action_just_released("zoom_in"):
		zoom(-zoom_increment)

	if Input.is_action_just_pressed("change_critter"):
		if current_critter == ferret:
			current_critter = hedgehog
		else:
			current_critter = ferret

func _move_critter_to_mouse(critter: Critter):
	var mouse_hex = grid.get_hex_at_mouse()
	if mouse_hex != null:
		var path_start = critter.get_location()
		var path_end = mouse_hex
		if mouse_hex != last_mouse_hex:
			path.set_path(grid.find_path_between(path_start, path_end, critter.get_direction()))
		elif path.get_path_length() != 0:
			critter.move(path.get_end()[0])
			critter.set_direction(path.get_end()[1])
			path.clear_path()
		last_mouse_hex = mouse_hex

func _turn_critter(critter: Critter):
	if grid.get_hex_at_mouse() != null:
		var direction = grid.get_hex_at_mouse().get_coords() - critter.get_location().get_coords()
		if grid.directions.has(direction):
			critter.set_direction(direction)
			#once critter time units are tracked this will also have to subtract the correct number
			# based on grid.directions_costs

func zoom(zoom: float):
	if zoom > 0:
		if zoom + camera.zoom.x > max_zoom:
			camera.zoom.x = max_zoom
			camera.zoom.y = max_zoom
		else:
			camera.zoom.x += zoom
			camera.zoom.y += zoom
	else:
		if zoom + camera.zoom.x < min_zoom:
			camera.zoom.x = min_zoom
			camera.zoom.y = min_zoom
		else:
			camera.zoom.x += zoom
			camera.zoom.y += zoom
