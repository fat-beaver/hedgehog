extends Node2D
class_name HexGrid


onready var _tile_map = $TileMap
onready var _camera = $Camera2D

var map_size = 6
var _hexes = []
var _directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,-1)]

func _ready():
	#generate the map
	_generate_map()
	_draw_map()
	#position the camera
	_camera.set_global_position(Vector2(0,0))
	
	var path_start = get_hex_at_coords(Vector2(-4, 0))
	var path_end = get_hex_at_coords(Vector2(2, -4))
	_draw_map()
	var path = find_path_between(path_start, path_end)
	for hex in path:
		hex.set_terrain_type(3)
	_draw_map()

func _generate_map():
	#create all of the hexes to fill a sample map
	var tempCentreHex = Hex.new(Vector2(0,0), 0)
	for q in range(-map_size, map_size + 1):
		for r in range(-map_size, map_size + 1):
			for s in range(-map_size, map_size + 1):
				#check if this particular cell could actually exist (all cube-coordinate cells have
				# the constraint q + r + s = 0)
				if q + r + s == 0:
					var hex = Hex.new(Vector2(q,r), 0)
					#set the terrain of the hex to its distance from the centre, as a demonstration
					hex.set_terrain_type(find_hex_distance(tempCentreHex, hex) / 2%4)
					_hexes.append(hex)

func _draw_map():
	for hex in _hexes:
		_tile_map.set_cell(hex.get_offset_coords().x, hex.get_offset_coords().y, hex.get_terrain_type())

func get_hex_at_coords(coords: Vector2) -> Hex:
	for hex in _hexes:
		if hex.get_coords() == coords:
			return hex
	return null

func find_neighbours_of(cell: Hex) -> Array:
	var neighbours = []
	var cell_coords = cell.get_coords()
	for direction in _directions:
		var neighbour = get_hex_at_coords(cell_coords + direction)
		if neighbour != null:
			neighbours.append(neighbour)
	return neighbours

func find_passable_neighbours(cell: Hex) -> Array:
	var all_neighbours = find_neighbours_of(cell)
	var passable_neighbours = []
	for neighbour in all_neighbours:
		if neighbour.get_passable():
			passable_neighbours.append(neighbour)
	return passable_neighbours

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
		var lowest_priority = queue[0]
		for element in queue:
			if element.get_priority() < lowest_priority.get_priority():
				lowest_priority = element
		queue.remove(queue.find(lowest_priority))
		return lowest_priority.get_element()
	func get_size():
		return queue.size()

func find_path_between(start: Hex, goal: Hex) -> Array:
	var frontier = PriorityQueue.new()
	frontier.push(start, 0)
	#create dictionaries to hold where the path came from to reach each cell and how much it cost
	var came_from: Dictionary = {}
	var cost_to: Dictionary = {}
	came_from[start] = null
	cost_to[start] = 0
	#while there are still unchecked hexes, keep looking for a path
	while !frontier.is_empty():
		var current_cell: Hex = frontier.pop()
		#check that we're not at the goal
		if current_cell == goal:
			break
		for neighbour in find_passable_neighbours(current_cell):
			var new_cost = cost_to[current_cell] + neighbour.get_movement_cost()
			if !cost_to.has(neighbour) or new_cost < cost_to[neighbour]:
				cost_to[neighbour] = new_cost
				var priority = new_cost + find_hex_distance(neighbour, goal)
				frontier.push(neighbour, priority)
				came_from[neighbour] = current_cell
	#once a path has been found (or not found) turn it into an array of hexes
	var path = null
	if came_from.has(goal):
		path = []
		var current_cell = goal
		while current_cell != start:
			path.append(current_cell)
			current_cell = came_from[current_cell]
		path.append(start)
		path.invert()
	return path
