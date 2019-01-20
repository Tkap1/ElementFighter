extends Control

var stateMachine

func _ready():
	get_tree().set_auto_accept_quit(false)
	Refs.main = self
	initInput()
	
	stateMachine = Refs.scripts["stateMachine"].new({
		"main": load("res://Scripts/MainMenu.gd").new(),
		"game": load("res://Scripts/Game.gd").new(),
	})
	Refs.stateMachine = stateMachine
	add_child(stateMachine)
	stateMachine.setState("main")
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		for node in get_tree().get_nodes_in_group("toClean"):
			node.cleanup()
		get_tree().call_deferred("quit")
		
func initInput():
	Utils.addKeybind("pause", KEY_ESCAPE)
	Utils.addKeybind("jump", KEY_SPACE)
	Utils.addMousebind("skill1", BUTTON_LEFT)
	Utils.addMousebind("skill2", BUTTON_RIGHT)
	Utils.addKeybind("skill3", KEY_Q)
	
	Utils.addKeybind("move_left", KEY_A)
	Utils.addKeybind("move_right", KEY_D)
	Utils.addKeybind("move_up", KEY_W)
	Utils.addKeybind("move_down", KEY_S)