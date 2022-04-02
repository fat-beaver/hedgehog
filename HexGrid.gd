extends Node2D
class_name HexGrid


var _tile_map = TileMap.new()
#tilemap constants
const tileset_name = "testing_tileset.tres"
const graphical_hex_size = Vector2(192, 94)

var _map_size
const _mouse_offset_x = -98
const _mouse_offset_y = -62
#a multiplier for the pathing heuristic equal to the movement cost of a "standard" tile so that the
# heuristic is still a significant part of the priority when added to the cost, significantly improving
# performance (especially in terrain with few obstacles)
const _pathing_heuristic_multiplier = 6

var _current_path = []

#the hexes are stored in a dictionary for most uses as well as an array for when iteration is required
var _hexes: Dictionary = {}
var _hexes_array: Array = []

const directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,-1)]
#store the number of turns that need to be made to turn between two given directions, there's probably
# a better way to do this but this shouldn't be too slow
var directions_costs = {}

func _init(map_size):
	_map_size = map_size
	#generate the map
	randomize()
	_generate_turning_costs()
	_set_up_tilemap()
	_generate_map()
	_draw_map()

func _set_up_tilemap():
	add_child(_tile_map)
	_tile_map.tile_set = load(tileset_name)
	_tile_map.cell_size = graphical_hex_size
	_tile_map.cell_half_offset = 0
	_tile_map.cell_y_sort = true

func _generate_map():
	#create all of the hexes to fill a sample map
	for q in range(-_map_size, _map_size + 1):
		for r in range(-_map_size, _map_size + 1):
			for s in range(-_map_size, _map_size + 1):
				#check if this particular cell could actually exist (all cube-coordinate cells have
				# the constraint q + r + s = 0)
				if q + r + s == 0:
					var hex = Hex.new(Vector2(q,r), 0)
					#set the terrain of the hex to its distance from the centre, as a demonstration
					#hex.set_terrain_type(find_hex_distance(tempCentreHex, hex) / 2 %4)
					var hex_terrain_raw = rand_range(0,12)
					
					if hex_terrain_raw >= 0 and hex_terrain_raw < 6:
						hex.set_terrain_type(0)
					elif hex_terrain_raw >= 6 and hex_terrain_raw < 11:
						hex.set_terrain_type(2)
					else:
						hex.set_terrain_type(1)
					
					add_hex(hex)

func _generate_turning_costs():
	for i in range(directions.size()):
		directions_costs[directions[i]] = {}
		for j in range(i, i + directions.size() / 2):
			directions_costs[directions[i]][directions[j % directions.size()]] = j - i
		for j in range(i + directions.size() / 2, i + directions.size()):
			directions_costs[directions[i]][directions[j % directions.size()]] = directions.size() - j + i

func add_hex(hex: Hex):
	if hex == null:
		return
	_hexes[hex.get_coords()] = hex
	_hexes_array.append(hex)

func _draw_map():
	for hex in _hexes_array:
		_tile_map.set_cell(hex.get_offset_coords().x, hex.get_offset_coords().y, hex.get_terrain_type())

func get_hex_at_coords(coords: Vector2) -> Hex:
	if _hexes.has(coords):
		return _hexes[coords]
	return null

func find_hex_distance(a: Hex, b: Hex) -> int:
	var coord_difference = a.get_coords() - b.get_coords()
	return ((abs(coord_difference.x) + abs(coord_difference.x + coord_difference.y) + abs(coord_difference.y)) / 2) as int

#a priority queue to keep track of which cells on the frontier are most likely to lead to the goal
#yes this is a really slow implementation, shush 
class PriorityQueue:
	class QueueElement:
		var _priority: float setget , get_priority
		var _element setget , get_element

		func _init(element, priority: float):
			_element = element
			_priority = priority

		func get_priority() -> float:
			return _priority

		func get_element():
			return _element
	
	var queue = []
	
	func push(cell: Hex, priority: float):
		var new_element = QueueElement.new(cell, priority)
		queue.append(new_element)

	func is_empty() -> bool:
		if queue.size() == 0:
			return true
		return false

	func pop() -> Hex:
		var lowest_priority = 0
		for i in range(1, queue.size()):
			if queue[i].get_priority() < queue[lowest_priority].get_priority():
				lowest_priority = i
		var to_remove = queue[lowest_priority]
		queue.remove(lowest_priority)
		return to_remove.get_element()

	func get_size():
		return queue.size()

func find_path_between(start: Hex, goal: Hex, initial_direction: Vector2) -> Array:
	#cannot find a path between cells that do not exist
	if start == null or goal == null or !start.is_passable() or !goal.is_passable():
		return Array()
	var frontier = PriorityQueue.new()
	frontier.push(start, 0)
	#create dictionaries to hold where the path came from to reach each cell and how much it cost
	var came_from: Dictionary = {}
	var cost_to: Dictionary = {}
	var arriving_direction: Dictionary = {}
	came_from[start] = null
	cost_to[start] = 0
	arriving_direction[start] = initial_direction
	#while there are still unchecked hexes, keep looking for a path
	while !frontier.is_empty():
		var current_cell: Hex = frontier.pop()
		#check that we're not at the goal
		if current_cell == goal:
			break
		for direction in directions:
			var neighbour = get_hex_at_coords(current_cell.get_coords() + direction)
			if neighbour != null and neighbour.is_passable():
				var new_cost = cost_to[current_cell] + neighbour.get_movement_cost() + directions_costs[arriving_direction[current_cell]][direction]
				if !cost_to.has(neighbour) or new_cost < cost_to[neighbour]:
					came_from[neighbour] = current_cell
					cost_to[neighbour] = new_cost
					arriving_direction[neighbour] = direction
					var priority = new_cost + _pathing_heuristic_multiplier * find_hex_distance(neighbour, goal)
					frontier.push(neighbour, priority)
	#once a path has been found (or not found) turn it into an array of hexes
	var path = null
	if came_from.has(goal):
		path = []
		var current_cell = goal
		while current_cell != start:
			var path_entry = []
			path_entry.append(current_cell)
			path_entry.append(arriving_direction[current_cell])
			path_entry.append(cost_to[current_cell])
			path.append(path_entry)
			current_cell = came_from[current_cell]
		var path_entry = []
		path_entry.append(start)
		path_entry.append(arriving_direction[start])
		path_entry.append(cost_to[start])
		path.append(path_entry)
		path.invert()
	return path

func hex_coords_of_point(point: Vector2) -> Vector2:
	var coords: Vector2 = Vector2()
	#adjust the points a bit to make them line up with the tilemap placement
	point.x += _mouse_offset_x
	point.y += _mouse_offset_y
	#a slight multiplier to improve detection when far from the origin
	point.y *= 0.978
	coords.x = 1.0 / 192.0 * point.x - (1.0 / 184.0) * point.y
	coords.y = 0 * point.x + 1.0 / 92.0 * point.y
	return round_hex_coords(coords)

func round_hex_coords(coords: Vector2) -> Vector2:
	#round each coord and extract s
	var q = round(coords.x)
	var r = round(coords.y)
	var s = round(- coords.x - coords.y)
	#determine which coord had the greatest change due to rounding
	var q_difference = abs(q - coords.x)
	var r_difference = abs(r - coords.y)
	var s_difference = abs(s - (- coords.x - coords.y))
	
	if q_difference > r_difference and q_difference > s_difference:
		q = - r - s
	elif r_difference > s_difference:
		r = - q - s
	else:
		s = - q - r
	return Vector2(q, r)

func set_hex_terrain(hex: Hex, terrain_type: int):
	if hex == null:
		return
	hex.set_terrain_type(terrain_type)
	_tile_map.set_cell(hex.get_offset_coords().x, hex.get_offset_coords().y, terrain_type)

func set_terrain_all_tiles(terrain: int):
	for hex in _hexes_array:
		set_hex_terrain(hex, terrain)

func get_hex_at_mouse() -> Hex:
	return get_hex_at_coords(hex_coords_of_point(get_global_mouse_position()))
