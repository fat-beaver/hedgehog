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

func find_hex_distance(a: Hex, b: Hex) -> int:
	var coord_difference = a.get_coords() - b.get_coords()
	return ((abs(coord_difference.x) + abs(coord_difference.x + coord_difference.y) + abs(coord_difference.y)) / 2) as int
	
