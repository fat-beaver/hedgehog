extends Node2D
class_name HexGrid


var _tile_map = TileMap.new()
#tilemap constants
const tileset_name = "testing_tileset.tres"
const graphical_hex_size = Vector2(192, 94)

#offset vector for finding hex under mouse
const _mouse_offset_vector = Vector2(-98, -62)

var _map: Map

func _init(new_map: Map):
	_map = new_map
	_set_up_tilemap()
	_draw_map()

func _set_up_tilemap():
	add_child(_tile_map)
	_tile_map.tile_set = load(tileset_name)
	_tile_map.cell_size = graphical_hex_size
	_tile_map.cell_half_offset = 0
	_tile_map.cell_y_sort = true

func _draw_map():
	for hex in _map.get_hexes_array():
		_tile_map.set_cell(hex.get_offset_coords().x, hex.get_offset_coords().y, hex.get_terrain_type())

func set_hex_terrain(hex: Hex, terrain_type: int):
	if hex == null:
		return
	hex.set_terrain_type(terrain_type)
	_tile_map.set_cell(hex.get_offset_coords().x, hex.get_offset_coords().y, terrain_type)

func get_hex_at_mouse() -> Hex:
	var adjusted_mouse_point = get_global_mouse_position() + _mouse_offset_vector
	return _map.get_hex_at_point(adjusted_mouse_point)
