extends Area2D


enum {SINGLE, AOE, SINGLE_REPEAT, AOE_REPEAT}
var targetingType = AOE

var areaFunc = ""
var bodyFunc = ""
var areaArgs = []
var bodyArgs = []

var sprite

var destroyedOnHit = false

var delay = 0.01
var speed = 100.0
var direction = null

var parent = null

var targetInfo = {}

func _init(parent, funcName, params, layers, masks, areaFunc = "", bodyFunc = "", areaArgs = [], bodyArgs = [], destroyedOnHit = false):
	self.parent = parent
	self.areaFunc = areaFunc
	self.bodyFunc = bodyFunc
	self.areaArgs = areaArgs
	self.bodyArgs = bodyArgs
	self.destroyedOnHit = destroyedOnHit
	set_as_toplevel(true)
	
	params.push_front(self)
	Utils.callv(funcName, params)
	
	# Layers & masks
	# Disable default layer
	set_collision_layer_bit(0, false)
	# Disable default mask
	set_collision_mask_bit(0, false)
	
	for layer in layers:
		set_collision_layer_bit(layer, true)
	
	for mask in masks:
		set_collision_mask_bit(mask, true)
		
func setTargeting(targetingType, delay = 0.01):
	self.targetingType = targetingType
	self.delay = delay
		
func setTimer(duration):
	Utils.addTimer(self, duration, true, true, self, "queue_free")
	
func setDirection(direction, speed = 100.0):
	self.direction = direction
	self.speed = speed

func setSprite(texture, scale):
	sprite = Sprite.new()
	add_child(sprite)
	sprite.texture = texture
	sprite.scale = scale
	
func setAnimation(frames, scale = Vector2(1,1)):
	sprite = AnimatedSprite.new()
	add_child(sprite)
	sprite.frames = frames
	sprite.playing = true
	sprite.scale = scale
	
	
func _onAreaEntered(area):
	match(targetingType):
		SINGLE:
			if targetInfo.size() == 0:
				# Setting to null because we don't need to store anything, just don't want the size to be 0
				targetInfo[area.name] = null
				parent.callv(areaFunc, [area] + areaArgs)
				if destroyedOnHit:
					queue_free()
		AOE:
			if not area.name in targetInfo:
				# Setting to null because we don't need to store anything, just have the name of the area in the dictionary
				targetInfo[area.name] = null
				parent.callv(areaFunc, [area] + areaArgs)
		SINGLE_REPEAT:
			if targetInfo.size() == 0:
				# Add a timer
				targetInfo[area.name] = Utils.addTimer(self, delay, true, true)
				# Call the corresponding function
				parent.callv(areaFunc, [area] + areaArgs)
			elif area.name in targetInfo:
				# If the timer is done
				if targetInfo[area.name].is_stopped():
					# Call the corresponding function again
					parent.callv(areaFunc, [area] + areaArgs)
					# Start the timer again
					targetInfo[area.name].start()
		AOE_REPEAT:
			# If the area is not in the dictionary
			if not area.name in targetInfo:
				# Add a timer
				targetInfo[area.name] = Utils.addTimer(self, delay, true, true)
				# Call the corresponding function
				parent.callv(areaFunc, [area] + areaArgs)
			# Else, if it is inside the dictionary and the timer is stopped
			elif targetInfo[area.name].is_stopped():
				# Call the corresponding function again
				parent.callv(areaFunc, [area] + areaArgs)
				# Start the timer again
				targetInfo[area.name].start()
				
				
func _onBodyEntered(body):
	match(targetingType):
		SINGLE:
			if targetInfo.size() == 0:
				# Setting to null because we don't need to store anything, just don't want the size to be 0
				targetInfo[body.name] = null
				parent.callv(bodyFunc, [body] + bodyArgs)
				if destroyedOnHit:
					queue_free()
		AOE:
			if not body.name in targetInfo:
				# Setting to null because we don't need to store anything, just have the name of the body in the dictionary
				targetInfo[body.name] = null
				parent.callv(bodyFunc, [body] + bodyArgs)
				
		SINGLE_REPEAT:
			if targetInfo.size() == 0:
				# Add a timer
				targetInfo[body.name] = Utils.addTimer(self, delay, true, true)
				# Call the corresponding function
				parent.callv(bodyFunc, [body] + bodyArgs)
			elif body.name in targetInfo:
				# If the timer is done
				if targetInfo[body.name].is_stopped():
					# Call the corresponding function again
					parent.callv(bodyFunc, [body] + bodyArgs)
					# Start the timer again
					targetInfo[body.name].start()
		AOE_REPEAT:
			# If the body is not in the dictionary
			if not body.name in targetInfo:
				# Add a timer
				targetInfo[body.name] = Utils.addTimer(self, delay, true, true)
				# Call the corresponding function
				parent.callv(bodyFunc, [body] + bodyArgs)
			# Else, if it is inside the dictionary and the timer is stopped
			elif targetInfo[body.name].is_stopped():
				# Call the corresponding function again
				parent.callv(bodyFunc, [body] + bodyArgs)
				# Start the timer again
				targetInfo[body.name].start()
			
	
	
func _physics_process(delta):
	
	if direction != null:
		position += direction * speed * delta
	
	if areaFunc != "":
		for area in get_overlapping_areas():
			_onAreaEntered(area)
	if bodyFunc != "":
		for body in get_overlapping_bodies():
			_onBodyEntered(body)