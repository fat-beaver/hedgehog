extends Node2D
class_name HexPath

var _current_path = []

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
		draw_string(_font, _current_path[i][0].get_centre_point(), _current_path[i][2] as String)

func set_path(path: Array):
	if path == null:
		clear_path()
	else:
		_current_path = path
		update()

func clear_path():
	_current_path = null
	update()

func get_path_length() -> int:
	return _current_path.size()

func get_end() -> Array:
	return _current_path[_current_path.size() - 1]
