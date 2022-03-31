extends Node2D



var last_mouse_hex
var zoom_level = 2
#camera constants
const min_zoom = 1
const max_zoom = 5
const camera_movement_mult = 1200
#ferret constants
const ferret_sprite_location = "art/ferret/png/test_1.png"
const ferret_coords = Vector2(-4, 0)
#hedgehog constants
const hedgehog_sprite_location = "art/hedgehog/png/test_1.png"
const hedgehog_coords = Vector2(4, 0)
#store the hex the ferret is in so pathing can start from there
var ferret_hex
var hedgehog_hex

var path = HexPath.new(null)
var camera = Camera2D.new()
var grid = HexGrid.new()
var ferret = Node2D.new()
var hedgehog = Node2D.new()

func _ready():
	ferret_hex = grid.get_hex_at_coords(ferret_coords)
	hedgehog_hex = grid.get_hex_at_coords(hedgehog_coords)
	#add all of the children
	add_child(grid)
	add_child(path)
	_set_up_camera()
	_set_up_critters()

func _set_up_camera():
	add_child(camera)
	#set the camera as the current one so it is actually used
	camera.current = true
	#centre the camera on hex (0,0)
	camera.set_global_position(grid.get_hex_at_coords(Vector2(0, 0)).get_centre_point())
	camera.zoom = Vector2(zoom_level, zoom_level)

func _set_up_critters():
	add_child(ferret)
	ferret.position = ferret_hex.get_centre_point()
	var ferret_sprite = Sprite.new()
	ferret_sprite.texture = load(ferret_sprite_location)
	ferret.add_child(ferret_sprite)
	#make sure that the ferret is not in water
	grid.set_hex_terrain(ferret_hex, 0)
	add_child(hedgehog)
	hedgehog.position = hedgehog_hex.get_centre_point()
	var hedgehog_sprite = Sprite.new()
	hedgehog_sprite.texture = load(hedgehog_sprite_location)
	hedgehog.add_child(hedgehog_sprite)
	grid.set_hex_terrain(hedgehog_hex, 0)

func _process(delta):
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.move_local_x(movement_vector.x * camera_movement_mult * delta * zoom_level)
	camera.move_local_y(movement_vector.y * camera_movement_mult * delta * zoom_level)
	
	if Input.is_action_pressed("left_click"):
		var mouse_hex = grid.get_hex_at_coords(grid.hex_coords_of_point(get_global_mouse_position()))
		if last_mouse_hex != mouse_hex and mouse_hex != null:
			var path_start = ferret_hex
			var path_end = mouse_hex
			path.set_path(grid.find_path_between(path_start, path_end))
			last_mouse_hex = mouse_hex

	if Input.is_action_just_released("zoom_out") and zoom_level < max_zoom:
		zoom_level += 0.25
		camera.zoom = Vector2(zoom_level, zoom_level)

	if Input.is_action_just_released("zoom_in") and zoom_level > min_zoom:
		zoom_level -= 0.25
		camera.zoom = Vector2(zoom_level, zoom_level)
