extends Node


func randomColor():
	return Color(rand_range(0,1),rand_range(0,1),rand_range(0,1))
	
func randomBoolean():
	return true if randi() % 2 == 0 else false
	
func getColorText(text,color):
	return "[color=#"+color.to_html(false)+"]"+ text + "[/color]"
	
func printFPS():
	print(Performance.get_monitor(Performance.TIME_FPS))
	
func copy2DDict(dictToCopy):
	var newDict = {}
	for key in dictToCopy.keys():
		newDict[key] = dictToCopy[key].duplicate()
	return newDict
	
func addKeybind(action,key):
	var event = InputEventKey.new()
	event.scancode = key
	InputMap.add_action(action)
	InputMap.action_add_event(action,event)
	
func addMousebind(action,button):
	var event = InputEventMouseButton.new()
	event.button_index = button
	InputMap.add_action(action)
	InputMap.action_add_event(action, event)
	
func addAction(actionName):
	InputMap.add_action(actionName)
	
func addKeyToAction(actionName, key):
	var event = InputEventKey.new()
	event.scancode = key
	InputMap.action_add_event(actionName, event)
	
func addButtonToAction(actionName, button):
	var event = InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(actionName, event)
		
func mouseColl(parent, rect):
	var mouse = parent.get_global_mouse_position()
	var mRect = Rect2(mouse.x,mouse.y,1,1)
	if mRect.intersects(rect):
		return true
	return false
	
func centerRect(pos,size):
	var rect = Rect2(pos-size/2, size)
	return rect
	
func rotateAroundPoint(pivot, target, rotation):
	var newPos = target - pivot
	newPos = newPos.rotated(rotation)
	newPos += pivot
	return newPos
	
func vecTo3(vector2):
	return Vector3(vector2.x, vector2.y, 0)
	
func vecTo2(vector3):
	return Vector2(vector3.x, vector3.y)
	
func randPosition():
	var x = round(rand_range(0, Cfg.width))
	var y = round(rand_range(0, Cfg.height))
	return Vector2(x,y)
	
func getRandomVector2():
	return Vector2(rand_range(-1,1),rand_range(-1,1)).normalized()
	
func getScreenCenter(rect):
	return Vector2(rect.position.x+rect.size.x/2,rect.position.y+rect.size.y/2)
	
func scaleSprite(newSize, sprite):
	# Calculate sprite scale
	var textureSize = sprite.texture.get_size()
	var newScale = newSize / textureSize
	sprite.scale = newScale
	
func sizeSprite(newSize, sprite):
	var newScale = newSize / Cfg.spriteSize
	sprite.scale = newScale
	
func index_1d_to_2d(index, arraySize):
	var newIndex = Vector2(int(index) % int(arraySize.x),int(index) / int(arraySize.x))
	return newIndex
	
func index_2d_to_1d(index, arrayWidth):
	var newIndex = int(index.x) + int(index.y) * int(arrayWidth)
	return newIndex
	
func centerControl(control, size, offset = Vector2(0,0)):
	control.anchor_left = 0.5 + offset.x
	control.anchor_right = 0.5 + offset.x
	control.anchor_top = 0.5 + offset.y
	control.anchor_bottom = 0.5 + offset.y
	control.margin_left = -size.x
	control.margin_right = size.x
	control.margin_top = -size.y
	control.margin_bottom = size.y
	
func getControlCenter(control):
	return control.rect_position + control.rect_size / 2
	
func sizeControl(control, from, to):
	control.rect_position.x = Cfg.width * from.x
	control.rect_position.y = Cfg.height * from.y
	control.rect_size.x = Cfg.width * to.x - control.rect_position.x
	control.rect_size.y = Cfg.height * to.y - control.rect_position.y
	
func addSprite(parent, texture, centered = true, scale = Vector2(1,1)):
	var sprite = Sprite.new()
	parent.add_child(sprite)
	sprite.texture = texture
	sprite.centered = centered
	sprite.scale = scale
	return sprite
	
func getSpriteSize(sprite):
	return sprite.texture.get_size() * sprite.scale
	
func addCollisionRect(parent, extents):
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.extents = extents
	parent.add_child(collision)
	
func addCollisionCircle(parent, radius):
	var collision = CollisionShape2D.new()
	collision.shape = CircleShape2D.new()
	collision.shape.radius = radius
	parent.add_child(collision)
	
func windowedBorderless():
	OS.set_borderless_window(true)
	OS.set_window_size(OS.get_screen_size())
	OS.set_window_position(Vector2(0, 0))
	
func addTimer(parent, waitTime, oneShot, autoStart, object=null, funcName="", binds=[], bindSelf=false):
	var timer = Timer.new()
	timer.one_shot = oneShot
	timer.autostart = autoStart
	timer.wait_time = waitTime
	parent.add_child(timer)
	
	if bindSelf:
		binds.push_front(timer)
	
	if object != null:
		timer.connect("timeout", object, funcName, binds)
		
	return timer
	
func addLabel(parent, text):
	var label = Label.new()
	parent.add_child(label)
	label.theme = Refs.resources["baseTheme"]
	label.text = text
	
	return label
	
func addButton(parent, text, object=null, funcName="", binds=[], bindSelf=false):
	var button = Button.new()
	parent.add_child(button)
	button.theme = Refs.resources["baseTheme"]
	button.text = text
	
	if bindSelf:
		binds.push_front(button)
	
	if object != null:
		button.connect("pressed", object, funcName, binds)
		
	return button
	
func addTween(parent, object, propertyName, startVal, endVal, duration):
	var tween = Tween.new()
	parent.add_child(tween)
	tween.interpolate_property(object, propertyName, startVal, endVal, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	return tween
	
func addButtonShortcut(button, keyCode):
	button.shortcut = ShortCut.new()
	var event = InputEventKey.new()
	event.scancode = keyCode
	button.shortcut.shortcut = event
	
func moveToCenter(control):
	control.rect_position = getScreenCenter(control.get_viewport_rect()) - control.rect_size / 2