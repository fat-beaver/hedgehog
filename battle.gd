extends Node2D

onready var camera = $HexGrid/Camera2D

func _ready():
	pass

func _process(_delta):
	if Input.is_key_pressed(KEY_LEFT):
		camera.move_local_x(-20)
	elif Input.is_key_pressed(KEY_RIGHT):
		camera.move_local_x(20)
	elif Input.is_key_pressed(KEY_UP):
		camera.move_local_y(-20)
	elif Input.is_key_pressed(KEY_DOWN):
		camera.move_local_y(20)
