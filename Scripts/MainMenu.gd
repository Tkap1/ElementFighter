extends "res://Scripts/BaseState.gd"

var ui

func onEnter():
	ui = load("res://Scenes/MainMenuUI.tscn").instance()
	add_child(ui)
	
	var startButton = ui.get_node("StartButton")
	startButton.connect("pressed", self, "_onStartButtonPressed")
	Utils.addButtonShortcut(startButton, KEY_SPACE)
	
func onLeave():
	cleanup()
	
func _onStartButtonPressed():
	Refs.stateMachine.setState("game")