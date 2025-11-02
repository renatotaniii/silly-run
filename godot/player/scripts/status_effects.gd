class_name StatusEffects
extends Resource

var current_status_effects = []
var speed = []
var turn_rate = []


signal status_updated()

func add_status_effect(effect_name: String):
	current_status_effects.append(effect_name)
	status_updated.emit()

func remove_status_effect(effect_name: String):
	current_status_effects.erase(effect_name)
	status_updated.emit()

## -- Movement Speed related functions --
	
func add_speed_modifier(modifier: float):
	speed.append(modifier)
	status_updated.emit()
	

func remove_speed_modifier(modifier: float):
	speed.erase(modifier)
	status_updated.emit()


func get_speed_modifier():
	return get_modifier("speed")

## -- Turn Rate related functions --

func add_turn_rate_modifier(modifier: float):
	turn_rate.append(modifier)
	status_updated.emit()
	

func remove_turn_rate_modifier(modifier: float):
	turn_rate.erase(modifier)
	status_updated.emit()
	

func get_turn_rate_modifier():
	return get_modifier("turn_rate")

## -- Utility functions --

func get_modifier(target_array: String):
	var property_array = get(target_array)
	var has_haste = property_array.any(greater_than_one)
	var has_slow = property_array.any(less_than_one)
	
	# Check if the player has both speed buffs and debuffs
	# If so, just cancel them out
	if has_haste and has_slow:
		return property_array.max() - property_array.min()
	# Check if the player only has buffs (multiple speed buffs will not stack)
	# Return the strongest speed buff
	elif has_haste:
		return property_array.max()	
	# Check if the player only has buffs (multiple slows will not stack)
	# Return the strongest slow
	elif has_slow:
		return property_array.min()
	# If there is nothing, then return 1
	else:
		return 1

func greater_than_one(value):
	return value > 1.0
	
func less_than_one(value):
	return value < 1.0
