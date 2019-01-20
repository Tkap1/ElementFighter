extends Control

func _init():
	rect_size = Vector2(Cfg.width,Cfg.height)
	mouse_filter = MOUSE_FILTER_IGNORE
	
func process(delta):
	pass
	
func input(event):
	pass
	
func onEnter():
	pass
	
func onLeave():
	pass
	
func cleanup():
	for child in get_children():
		child.queue_free()