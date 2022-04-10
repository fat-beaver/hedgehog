extends Node2D
class_name HexGrid

var _tile_map = TileMap.new()
var _explored_tile_map = TileMap.new()
#tilemap constants
const tileset_name = "testing_tileset.tres"
const graphical_hex_size = Vector2(192, 94)

#offset vector for finding hex under mouse
const _mouse_offset_vector = Vector2(-98, -62)

var _map: Map

func _init(new_map: Map):
	_map = new_map
	_set_up_tilemap(_explored_tile_map)
	_set_up_tilemap(_tile_map)
	_explored_tile_map.set_modulate(Color(0.6, 0.6, 0.6, 1))

func _set_up_tilemap(tile_map: TileMap):
	add_child(tile_map)
	tile_map.tile_set = load(tileset_name)
	tile_map.cell_size = graphical_hex_size
	tile_map.cell_half_offset = 0
	tile_map.cell_y_sort = true

func _draw_map(team: Team):
	_tile_map.clear()
	_explored_tile_map.clear()
	for hex in team.get_explored_tiles():
		if !team.get_visible_tiles().has(hex):
			_explored_tile_map.set_cell(hex.get_offset_coords().x, hex.get_offset_coords().y, hex.get_terrain_type())
	for hex in team.get_visible_tiles():
		_tile_map.set_cell(hex.get_offset_coords().x, hex.get_offset_coords().y, hex.get_terrain_type())

func get_hex_at_mouse() -> Hex:
	var adjusted_mouse_point = get_global_mouse_position() + _mouse_offset_vector
	return _map.get_hex_at_point(adjusted_mouse_point)
