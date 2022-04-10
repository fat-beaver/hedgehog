extends Node2D
class_name Critter

enum {FERRET, HEDGEHOG}

const _directions = [Vector2(1,0), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,-1)]

const _view_range = 7

const _ferret_sprites_location = "art/ferret/"
const _hedgehog_sprites_location = "art/hedgehog/"
#movement vars
var max_time_units
var time_units

var _textures = {}
var sprite = Sprite.new()

var _type
var _location
var _direction
var _team

func _init(new_critter_type: int, hex: Hex, direction: Vector2, speed: int, team: Team):
	hex.set_terrain_type(Hex.GRASS)
	team.add_critter(self)
	_type = new_critter_type
	max_time_units = speed
	refresh_time_units()
	load_textures()
	move(hex, direction, 0)
	_team = team
	add_child(sprite)

func move(hex: Hex, direction: Vector2, movement_cost: int):
	if time_units >= movement_cost:
		time_units -= movement_cost
		if _location != null:
			_location.set_critter(null)
		_location = hex
		hex.set_critter(self)
		set_direction(direction, 0)
		position = _location.get_centre_point()

func get_location() -> Hex:
	return _location

func set_direction(direction: Vector2, cost: int):
	if time_units >= cost:
		time_units -= cost
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

func refresh_time_units():
	time_units = max_time_units

func get_view_range():
	return _view_range

func get_team():
	return _team

func get_type():
	return _type

func get_time_units():
	return time_units
