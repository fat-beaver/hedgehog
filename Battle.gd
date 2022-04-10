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
	_set_up_camera()
	Critter.new(Critter.FERRET, map.get_hex_at_coords(ferret_one_coords), default_unit_direction, default_time_units, teams[Critter.FERRET])
	Critter.new(Critter.FERRET, map.get_hex_at_coords(ferret_two_coords), default_unit_direction, default_time_units, teams[Critter.FERRET])
	Critter.new(Critter.HEDGEHOG, map.get_hex_at_coords(hedgehog_coords), default_unit_direction, default_time_units, teams[Critter.HEDGEHOG])
	find_team_visibility(current_team)

func _set_up_camera():
	add_child(camera)
	#set the camera as the current one so it is actually used
	camera.current = true
	#centre the camera on hex (0,0)
	camera.set_global_position(map.get_hex_at_coords(Vector2(0, 0)).get_centre_point())
	camera.zoom = Vector2(default_zoom_level, default_zoom_level)

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
	var visible_tiles = Array()
	visible_tiles.append(critter.get_location())
	for hex in map.get_hexes_array():
		if map.find_hex_distance(critter.get_location(), hex) == critter.get_view_range():
			var distance: Vector2 = hex.get_centre_point() - critter.get_location().get_centre_point()
			#check if the first hex to check is the hex the critter is facing
			var first_point_check = (distance / critter.get_view_range()) + critter.get_location().get_centre_point() - map.get_hex_at_coords(Vector2(0, 0)).get_centre_point()
			var first_hex_check = map.get_hex_at_point(first_point_check)
			if critter.get_direction() == first_hex_check.get_coords() - critter.get_location().get_coords():
				for i in range(critter.get_view_range()):
					#need to adjust for the fact that hex axial(0,0) does not have the centre point point(0,0)
					var point_to_check = (distance * (i + 1) / critter.get_view_range()) + critter.get_location().get_centre_point() - map.get_hex_at_coords(Vector2(0, 0)).get_centre_point()
					var hex_to_check = map.get_hex_at_point(point_to_check)
					if !visible_tiles.has(hex_to_check):
						visible_tiles.append(hex_to_check)
					if !hex_to_check.is_transparent():
						break
	return visible_tiles
