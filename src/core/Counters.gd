# This class contains the methods needed to manipulate counters in a game
#
# It is meant to be extended and attached to a customized scene.
#
# In the extended script, the various values should be filled during
# the _ready() method
class_name Counters
extends Control

# Hold the actual values of the various counters requested
var counters := {}
# Holds the label nodes which display the counter values to the user
var _labels := {}
# Each entry in this dictionary will specify one counter to be added
# The key will be the name of the node holding the counter
# The value is a dictionary where each key is a label node path relative
# to the counter_scene
# and each value, is the text value for the label
var needed_counters: Dictionary

# Holds the counter scene which has been created by the developer
export(PackedScene) var counter_scene

# This variable should hold the path to the Control container
# Which will hold the counter objects. 
#
# It should be set in the _ready() function of the script which extends this class
var counters_container : Container
# This variable should hold which needed_counters dictionary key is the path
# to the label which holds the values for the counter
#
# It should be set in the _ready() function of the script which extends this class
var value_node: String


func _ready() -> void:
	pass


# This function should be called by the _ready() function of the script which
# extends thic class, after it has set all the necessary variables.
#
# It creates and initiates all the necessary counters required by this game.
func spawn_needed_counters() -> void:
	for counter_name in needed_counters:
		var counter = counter_scene.instance()
		counter.name = counter_name
		var counter_labels = needed_counters[counter_name]
		for label in counter_labels:
			counter.get_node(label).text = str(counter_labels[label])
			# The value_node is also used determine the initial values 
			# of the counters dictionary
			if label == value_node:
				counters[counter_name] = counter_labels[label]
				# _labels stores the label node which displays the value
				# of the counter
				_labels[counter_name] = counter.get_node(label)
		counters_container.add_child(counter)


# Modifies the value of a counter. The counter has to have been specified
# in the `needed_counters`
# 
# * Returns CFConst.ReturnCode.CHANGED if a modification happened
# * Returns CFConst.ReturnCode.OK if the modification requested is already the case
# * Returns CFConst.ReturnCode.FAILED if for any reason the modification cannot happen
#
# If check is true, no changes will be made, but will return
# the appropriate return code, according to what would have happened
#
# If set_to_mod is true, then the counter will be set to exactly the value
# requested. otherwise the value will be modified from the current value
func mod_counter(counter_name: String, 
		value: int,
		set_to_mod := false,
		check := false) -> int:
	var retcode = CFConst.ReturnCode.CHANGED
	if counters.get(counter_name, null) == null:
		retcode = CFConst.ReturnCode.FAILED
	else:
		if set_to_mod and counters[counter_name] == value:
			retcode = CFConst.ReturnCode.OK
		elif set_to_mod and counters[counter_name] < 0:
			retcode = CFConst.ReturnCode.FAILED
		else:
			if counters[counter_name] + value < 0:
				retcode = CFConst.ReturnCode.FAILED
				value = -counters[counter_name]
			if not check:
				if set_to_mod:
					counters[counter_name] = value
				else:
					counters[counter_name] += value
			_labels[counter_name].text = str(counters[counter_name])
	return(retcode)


# Returns the value of the specified counter.
func get_counter(counter_name: String) -> int:
	return(counters[counter_name])