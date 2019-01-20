extends Camera2D

func shake(intensity, duration):
	offset += intensity
	yield(get_tree().create_timer(duration/2.0),"timeout")
	offset -= intensity*2
	yield(get_tree().create_timer(duration/2.0),"timeout")
	offset += intensity
	
# Check wether a Rect2 is on screen
func isOnScreen(rect):
	pass