extends CanvasLayer

func _ready():
	$Control/CenterContainer/Button.connect("pressed", self, "restartGame")
	Utils.addButtonShortcut($Control/CenterContainer/Button, KEY_SPACE)
	
func restartGame():
	get_tree().paused = false
	Refs.game.restartGame()
	queue_free()