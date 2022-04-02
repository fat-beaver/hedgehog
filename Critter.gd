extends Node2D
class_name Critter

enum {FERRET, HEDGEHOG}

const ferret_sprite_location = "art/ferret/png/test_1.png"
const hedgehog_sprite_location = "art/hedgehog/png/test_1.png"

var _type
var _location
var _direction

func _init(new_critter_type: int, hex: Hex, direction: Vector2):
	_type = new_critter_type
	_location = hex
	_direction = direction
	move(_location)
	var sprite = Sprite.new()
	match _type:
		FERRET:
			sprite.texture = load(ferret_sprite_location)
		HEDGEHOG:
			sprite.texture = load(hedgehog_sprite_location)
	add_child(sprite)

func move(hex: Hex):
	_location = hex
	position = _location.get_centre_point()

func get_location() -> Hex:
	return _location

func set_direction(direction: Vector2):
	_direction = direction

func get_direction() -> Vector2:
	return _direction
