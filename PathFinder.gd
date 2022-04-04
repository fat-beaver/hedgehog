extends Resource
class_name PathFinder

#returns an array of arrays, each sub-array is a path entry comprising a hex, a direction, and the cost
# of moving there (in that order)

#the six valid directions that can be moved in from a hex
const directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,-1)]
#a multiplier for the pathing heuristic equal to the movement cost of a "standard" tile so that the
# heuristic is still a significant part of the priority when added to the cost, significantly improving
# performance (especially in terrain with few obstacles)
const _pathing_heuristic_multiplier = 6

#a priority queue to keep track of which cells on the frontier are most likely to lead to the goal
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

static func find_path_between(start: Hex, goal: Hex, map: Map, initial_direction: Vector2) -> Array:
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
			var neighbour = map.get_hex_at_coords(current_cell.get_coords() + direction)
			if neighbour != null and neighbour.is_passable():
				var new_cost = cost_to[current_cell] + neighbour.get_movement_cost() + map.get_turning_costs(arriving_direction[current_cell], direction)
				if !cost_to.has(neighbour) or new_cost < cost_to[neighbour]:
					came_from[neighbour] = current_cell
					cost_to[neighbour] = new_cost
					arriving_direction[neighbour] = direction
					var priority = new_cost + _pathing_heuristic_multiplier * map.find_hex_distance(neighbour, goal)
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
