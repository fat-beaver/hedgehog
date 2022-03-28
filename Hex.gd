extends Resource
class_name Hex

var coords
var terrain_type setget set_terrain_type, get_terrain_type

func _ready():
	pass

func _init(new_coords: Vector2, new_terrain_type: int):
	coords = new_coords
	terrain_type = new_terrain_type

func get_coords() -> Vector2:
	return coords

func get_offset_coords() -> Vector2:
	var x = coords.x + (coords.y - (coords.y as int&1)) / 2
	var y = coords.y
	return Vector2(x, y)
	
func set_terrain_type(new_terrain_type: int):
	terrain_type = new_terrain_type

func get_terrain_type():
	return terrain_type
