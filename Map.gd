extends Resource
class_name Map

var _map_size: int
#the hexes are stored in a dictionary for most uses as well as an array for when iteration is required
var _hexes: Dictionary = {} 
var _hexes_array: Array = []

const directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,-1)]
#store the number of turns that need to be made to turn between two given directions, there's probably
# a better way to do this but this shouldn't be too slow
var directions_costs = {}

func _init(new_map_size: int):
	_map_size = new_map_size
	randomize()
	_generate_map()
	_generate_turning_costs()

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
						hex.set_terrain_type(3)
					else:
						hex.set_terrain_type(1)

					_hexes[hex.get_coords()] = hex
					_hexes_array.append(hex)

func _generate_turning_costs():
	for i in range(directions.size()):
		directions_costs[directions[i]] = {}
		for j in range(i, i + directions.size() / 2):
			directions_costs[directions[i]][directions[j % directions.size()]] = j - i
		for j in range(i + directions.size() / 2, i + directions.size()):
			directions_costs[directions[i]][directions[j % directions.size()]] = directions.size() - j + i

func get_map_size() -> int:
	return _map_size

func get_hexes_array() -> Array:
	return _hexes_array

func get_hex_at_coords(coords: Vector2) -> Hex:
	if _hexes.has(coords):
		return _hexes[coords]
	return null

func find_hex_distance(a: Hex, b: Hex) -> int:
	var coord_difference = a.get_coords() - b.get_coords()
	return ((abs(coord_difference.x) + abs(coord_difference.x + coord_difference.y) + abs(coord_difference.y)) / 2) as int

func _hex_coords_of_point(point: Vector2) -> Vector2:
	var coords: Vector2 = Vector2()
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

func get_hex_at_point(point: Vector2):
	return get_hex_at_coords(_hex_coords_of_point(point))

func get_turning_costs(initial_direction: Vector2, end_direction: Vector2):
	if directions_costs.has(initial_direction) and directions_costs[initial_direction].has(end_direction):
		return directions_costs[initial_direction][end_direction]
	return null
