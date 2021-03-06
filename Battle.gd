extends Node2D
class_name Battle

var last_mouse_hex
#camera constants
const min_zoom = 1
const max_zoom = 5
const zoom_increment = 0.25
const default_zoom_level = 2
const camera_movement_mult = 1200
#critter constants
const ferret_one_coords = Vector2(-4, 0)
const ferret_two_coords = Vector2(-6, 0)
const hedgehog_coords = Vector2(4, 0)
const default_time_units = 80
#map constants
const map_size = 40
const default_unit_direction = Vector2(1,0)
#children
var path = HexPath.new()
var camera = Camera2D.new()
var map = Map.new(map_size)
var grid = HexGrid.new(map)

var teams = {}
var current_team: Team

func _ready():
	teams[Critter.FERRET] = Team.new()
	teams[Critter.HEDGEHOG] = Team.new()
	current_team = teams[Critter.FERRET]
	#add all of the children
	add_child(grid)
	add_child(path)
	add_child(teams[Critter.FERRET])
	add_child(teams[Critter.HEDGEHOG])
	Critter.new(Critter.FERRET, map.get_hex_at_coords(ferret_one_coords), default_unit_direction, default_time_units, teams[Critter.FERRET])
	Critter.new(Critter.FERRET, map.get_hex_at_coords(ferret_two_coords), default_unit_direction, default_time_units, teams[Critter.FERRET])
	Critter.new(Critter.HEDGEHOG, map.get_hex_at_coords(hedgehog_coords), default_unit_direction, default_time_units, teams[Critter.HEDGEHOG])
	find_team_visibility(current_team)
	_set_up_camera()

func _set_up_camera():
	add_child(camera)
	#set the camera as the current one so it is actually used
	camera.current = true
	camera.zoom = Vector2(default_zoom_level, default_zoom_level)
	camera.set_global_position(current_team.get_current_critter().get_location().get_centre_point())

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.move_local_x(movement_vector.x * camera_movement_mult * delta * camera.zoom.x)
	camera.move_local_y(movement_vector.y * camera_movement_mult * delta * camera.zoom.y)
	
	if Input.is_action_just_pressed("left_click"):
		var critter = grid.get_hex_at_mouse().get_critter()
		if critter != null and critter.get_team() == current_team:
			current_team.set_current_critter(critter)
			last_mouse_hex = null
			path.clear_path()
		else:
			_move_critter_to_mouse(current_team.get_current_critter())

	if Input.is_action_just_pressed("right_click"):
		_turn_critter(current_team.get_current_critter())

	if Input.is_action_just_released("zoom_out"):
		zoom(zoom_increment)

	if Input.is_action_just_released("zoom_in"):
		zoom(-zoom_increment)

	if Input.is_action_just_pressed("end_turn"):
		_end_turn()

func _move_critter_to_mouse(critter: Critter):
	var mouse_hex = grid.get_hex_at_mouse()
	if mouse_hex != null and mouse_hex.get_critter() == null:
		var path_start = critter.get_location()
		var path_end = mouse_hex
		if mouse_hex != last_mouse_hex:
			path.set_path(PathFinder.find_path_between(path_start, path_end, map, critter), critter)
			last_mouse_hex = mouse_hex
		else:
			if path.get_path_length() != 0:
				var movement_cost_so_far = 0
				for entry in path.get_path():
					if !entry[0] == path_start:
						critter.move(entry[0], entry[1], entry[2] - movement_cost_so_far)
						movement_cost_so_far += (entry[2] - movement_cost_so_far)
						find_team_visibility(critter.get_team())
			last_mouse_hex = null
			path.clear_path()

func _turn_critter(critter: Critter):
	if grid.get_hex_at_mouse() != null:
		var direction = grid.get_hex_at_mouse().get_coords() - critter.get_location().get_coords()
		if map.directions.has(direction):
			var turning_cost = map.get_turning_costs(critter.get_direction(), direction)
			critter.set_direction(direction, turning_cost)
			find_team_visibility(critter.get_team())

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

func _end_turn():
	current_team.new_turn()
	if current_team == teams[Critter.FERRET]:
		current_team = teams[Critter.HEDGEHOG]
	else:
		current_team = teams[Critter.FERRET]
	find_team_visibility(current_team)
	camera.position = current_team.get_current_critter().get_location().get_centre_point()
	last_mouse_hex = null

func find_critter_visibility(team: Team):
	for critter in teams[Critter.FERRET].get_critters():
		critter.set_visible(false)
	for critter in teams[Critter.HEDGEHOG].get_critters():
		critter.set_visible(false)
	for hex in team.get_visible_tiles():
		var critter = hex.get_critter()
		if critter != null:
			critter.set_visible(true)

func find_team_visibility(team: Team):
	team.clear_visible_tiles()
	for critter in team.get_critters():
		var critter_visible_tiles = find_visible_tiles(critter)
		for hex in critter_visible_tiles:
			team.add_visible_tile(hex)
	find_critter_visibility(team)
	grid._draw_map(team)

func find_visible_tiles(critter: Critter) -> Array:
	var visible_tiles = []
	visible_tiles.append(critter.get_location())
	var candidate_tiles = []
	var view_range = critter.get_view_range()
	#create an array of vectors to represent the coords of all of the tiles at the edge of the critter's vision
	for i in range(0, view_range):
		candidate_tiles.append(Vector2(i, -view_range))
		candidate_tiles.append(Vector2(view_range, i - view_range))
		candidate_tiles.append(Vector2(view_range - i, i))
		candidate_tiles.append(Vector2(-i, view_range))
		candidate_tiles.append(Vector2(-view_range, view_range - i))
		candidate_tiles.append(Vector2(i - view_range, -i))
	for coords in candidate_tiles:
		var step = (Hex.centre_point_of_coords(coords) - Hex.centre_point_of_coords(Vector2(0, 0))) / view_range
		#check if the first hex to check is the hex the critter is facing, if it is not, skip
		var first_point_check = Map.hex_coords_of_point(step)
		if first_point_check == critter.get_direction():
			#start at 1 because there is no point in checking the tile the critter is in
			for i in range(1, view_range + 1):
				var hex_to_check = map.get_hex_at_point((step * i) + critter.get_location().get_centre_point() - Hex.centre_point_of_coords(Vector2(0, 0)))
				if hex_to_check != null:
					if !visible_tiles.has(hex_to_check):
						visible_tiles.append(hex_to_check)
					if !hex_to_check.is_transparent():
						break
	return visible_tiles
