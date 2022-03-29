extends Resource
class_name Hex

var coords: Vector2
var passable: bool setget set_passable, get_passable
var terrain_type :int setget set_terrain_type, get_terrain_type

func _ready():
	pass

func _init(new_coords: Vector2, new_terrain_type: int):
	coords = new_coords
	set_terrain_type(new_terrain_type)

func get_coords() -> Vector2:
	return coords

func get_offset_coords() -> Vector2:
	var x = coords.x + (coords.y - (coords.y as int&1)) / 2
	var y = coords.y
	return Vector2(x, y)
	
func set_terrain_type(new_terrain_type: int):
	terrain_type = new_terrain_type
	if terrain_type == 1 or terrain_type == 3:
		passable = false
	else:
		passable = true

func get_terrain_type():
	return terrain_type

func get_movement_cost():
	var movement_cost = 0
	if terrain_type == 0 or terrain_type == 2 :
		movement_cost = 6
	return movement_cost

func set_passable(passablility: bool):
	passable = passablility

func get_passable():
	return passable
