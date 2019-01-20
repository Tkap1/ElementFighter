extends Control

const TWEEN_DURATION = 0.5

var size
var percent = 1.0
var interpPercent = 1.0
var tween
var parent = null
var parentSize = null

func _init(parent, parentSize, size):
	self.parent = parent
	self.parentSize = parentSize
	self.size = size
	mouse_filter = MOUSE_FILTER_IGNORE
	tween = Tween.new()
	add_child(tween)
	rect_size = size
	rect_position = parent.position
	
func _physics_process(delta):
	rect_position = parent.position - parentSize/2 - Vector2(0,size.y)
	update()
	
func setPercent(percent):
	self.percent = percent
	tween.remove_all()
	tween.interpolate_property(self, "interpPercent", interpPercent, percent, TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _draw():
	# Background
	draw_rect(Rect2(Vector2(0,0), size), Color(0.2,0.2,0.2))
	# Under
	draw_rect(Rect2(Vector2(0,0), Vector2(size.x * interpPercent, size.y)), Color(1,0,0))
	# Over
	draw_rect(Rect2(Vector2(0,0), Vector2(size.x * percent, size.y)), Color(0,1,0))