extends Node2D
class_name HexPath

var _current_path = []

const _path_thickness = 10

func _init(path):
	if path == null:
		clear_path()
	else:
		_current_path = path
	update()

func _draw():
	if _current_path == null:
		return
	for i in range(0, _current_path.size() - 1):
		draw_line(_current_path[i].get_centre_point(), _current_path[i + 1].get_centre_point(), Color.red, _path_thickness)

func set_path(path):
	if path == null:
		clear_path()
	else:
		_current_path = path
		update()

func clear_path():
	_current_path = null
	update()
