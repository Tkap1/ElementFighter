extends Node

var states
var currentState

func _init(states):
	add_to_group("toClean")
	self.states = states
	
func process(delta):
	currentState.process(delta)
	
func input(event):
	currentState.input(event)
	
func setState(stateKey, options = {}):
	if currentState != null:
		currentState.onLeave()
		remove_child(currentState)
	currentState = states[stateKey]
	# Set params to the state
	for key in options:
		currentState.set(key, options[key])
	# Add it as a child of this StateMachine
	add_child(currentState)
	# Call the "onEnter" function of the new state
	currentState.onEnter()
	
func cleanup():
	for key in states:
		var state = states[key]
		state.queue_free()