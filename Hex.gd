extends Resource
class_name Hex

var coords: Vector2
var passable: bool setget , is_passable
var transparent: bool setget , is_transparent
var terrain_type : int setget set_terrain_type, get_terrain_type

#constants for hex size, cannot get these from tilemap because the size used for scaling is not the actual size
const hex_width = 192
const hex_height = 128
const graphical_hex_size = Vector2(192, 94)

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
	passable = true
	transparent = true
	match terrain_type:
		0:
			pass
		1:
			passable = false
		2:
			pass
		3:
			passable = false
			transparent = false

func get_terrain_type():
	return terrain_type

func get_movement_cost():
	var movement_cost = 0
	if terrain_type == 0:
		movement_cost = 6
	elif terrain_type == 2:
		movement_cost = 12
	return movement_cost

func is_passable():
	return passable

func is_transparent():
	return transparent

func get_centre_point() -> Vector2:
	var point: Vector2 = Vector2()
	point.x = 192 * coords.x + 96 * coords.y + hex_width / 2.0
	point.y = 0 * coords.x + 94 * coords.y  + hex_height / 2.0
	return point
