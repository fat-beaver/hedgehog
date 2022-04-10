extends Node2D
class_name HexPath

var _current_path = []
var _critter = null

var _font
const _path_thickness = 10

func _init():
	_font = DynamicFont.new()
	_font.font_data = load("droid_sans.ttf")
	_font.size = 50
	clear_path()

func _draw():
	if _current_path == null:
		return
	for i in range(0, _current_path.size() - 1):
		draw_line(_current_path[i][0].get_centre_point(), _current_path[i + 1][0].get_centre_point(), Color.red, _path_thickness)
	for i in range(0, _current_path.size()):
		draw_string(_font, _current_path[i][0].get_centre_point(), max(_critter.get_time_units() - _current_path[i][2], 0) as String)

func set_path(path: Array, critter: Critter):
	#each array element is 0:hex, 1:direction, 2:cost
	if path == null:
		clear_path()
	else:
		_current_path = path
		_critter = critter
		update()

func clear_path():
	_current_path.clear()
	_critter = null
	update()

func get_path_length() -> int:
	return _current_path.size()

func get_end():
	if _current_path.size() == 0:
		return null
	return _current_path[_current_path.size() - 1]

func get_path():
	return _current_path
