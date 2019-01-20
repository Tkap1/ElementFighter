extends Node2D

var font
var fontScale
var camera = null
var label

func _init(font, fontScale, camera = null):
	self.font = font
	self.fontScale = fontScale
	self.camera = camera
	
func _ready():
	z_index = 999
	
	# Set up the label
	label = RichTextLabel.new()
	add_child(label)
	label.add_font_override("normal_font", font)
	label.scroll_active = false
	label.bbcode_enabled = true
	label.mouse_filter = label.MOUSE_FILTER_IGNORE
	
	label.rect_scale = fontScale
	
func setText(lines):
	for line in lines:
		label.bbcode_text += line + "\n"
		
func getBoxSize():
	var tLines = label.text.split("\n")
	
	# Get width of the longest string and assing to boxWidth
	var boxWidth = 0
	for line in tLines:
		var tempWidth = font.get_string_size(line).x * fontScale.x
		if tempWidth > boxWidth:
			boxWidth = tempWidth
			
	# Get box height by multiplying the font height by the amount of lines - 1
	var boxHeight = font.get_height() * fontScale.y * (tLines.size() - 1)
	
	return Vector2(boxWidth,boxHeight)
	
func _physics_process(delta):
	update()
	
func _draw():
	var mouse = get_global_mouse_position()
	global_position = Vector2(mouse.x + 16, mouse.y + 16)
	
	var size = getBoxSize()
	label.rect_position = Vector2(0,0)
	label.rect_size = size / fontScale
	var rect = Rect2(Vector2(0,0),size)
	
	# Check bounds
	var xBorder = Cfg.width
	var yBorder = Cfg.height
	if camera != null:
		xBorder += camera.offset.x
		yBorder += camera.offset.y
		
	# X Bounds
	var xDiff = xBorder - (global_position.x + rect.size.x)
	if xDiff < 0:
		rect.position.x += xDiff
		label.rect_position.x += xDiff
		
	# Y bounds
	var yDiff = yBorder - (global_position.y + rect.size.y)
	if yDiff < 0:
		rect.position.y += yDiff
		label.rect_position.y += yDiff
	
	# Draw the box
	draw_rect(rect, Color(0,0,0))


