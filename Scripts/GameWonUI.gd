extends CanvasLayer

func _ready():
	$Control/Button.connect("pressed", get_tree(), "quit")