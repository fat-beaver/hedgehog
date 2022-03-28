extends Node2D

onready var camera = $HexGrid/Camera2D

func _ready():
	pass

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	camera.move_local_x(movement_vector.x * 1600 * delta)
	camera.move_local_y(-movement_vector.y * 1600 * delta)
