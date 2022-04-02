extends Node2D
class_name Critter

enum {FERRET, HEDGEHOG}

const _directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,-1)]

const _ferret_sprites_location = "art/ferret/"
const _hedgehog_sprites_location = "art/hedgehog/"

var _textures = {}
var sprite = Sprite.new()

var _type
var _location
var _direction

func _init(new_critter_type: int, hex: Hex, direction: Vector2):
	_type = new_critter_type
	load_textures()
	set_direction(direction)
	move(hex)
	add_child(sprite)

func move(hex: Hex):
	_location = hex
	position = _location.get_centre_point()

func get_location() -> Hex:
	return _location

func set_direction(direction: Vector2):
	_direction = direction
	sprite.texture = _textures[direction]

func get_direction() -> Vector2:
	return _direction

func load_textures():
	var texture_location
	match _type:
		FERRET:
			texture_location = _ferret_sprites_location
		HEDGEHOG:
			texture_location = _hedgehog_sprites_location
	_textures[_directions[0]] = load(texture_location + "0_deg.png")
	_textures[_directions[1]] = load(texture_location + "45_deg.png")
	_textures[_directions[2]] = load(texture_location + "135_deg.png")
	_textures[_directions[3]] = load(texture_location + "180_deg.png")
	_textures[_directions[4]] = load(texture_location + "225_deg.png")
	_textures[_directions[5]] = load(texture_location + "315_deg.png")

