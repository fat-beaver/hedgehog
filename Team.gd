extends Node2D
class_name Team

var critters = []
var explored_tiles = []
var visible_tiles = []
var current_critter setget set_current_critter, get_current_critter

func add_critter(critter):
	add_child(critter)
	if critters.size() == 0:
		current_critter = critter
	critters.append(critter)

func add_visible_tile(hex: Hex):
	if !visible_tiles.has(hex):
		visible_tiles.append(hex)
		if !explored_tiles.has(hex):
			explored_tiles.append(hex)

func get_visible_tiles():
	return visible_tiles

func clear_visible_tiles():
	visible_tiles.clear()

func get_explored_tiles():
	return explored_tiles

func get_critter_count():
	return critters.size()

func get_critters():
	return critters

func get_current_critter():
	return current_critter

func set_current_critter(critter):
	if critters.has(critter):
		current_critter = critter

func new_turn():
	for critter in critters:
		critter.refresh_time_units()
	current_critter = critters[0]
