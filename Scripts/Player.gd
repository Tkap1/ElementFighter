extends KinematicBody2D

var sprite

var velocity = Vector2()
var inputVelocity = Vector2()
var acceleration = Vector2()
var speed = Cfg.playerSpeed
var skills = []

var health

func _ready():
	name = "player"
	add_to_group("player")
	add_to_group("restartable")
	pause_mode = PAUSE_MODE_STOP
	initSprite()
	initCollision()
	initSkills()
	call_deferred("initHealth")
	
func initHealth():
	health = Refs.scripts.healthComponent.new(Cfg.playerHealth)
	add_child(health)
	health.connect("death", self, "onDeath")
	health.connect("hit", self, "_onHit")
	health.addHealthbar(self, Vector2(64,64), Vector2(64,16))
	
func initSkills():
	var skill = load("res://Scripts/LightningBolt.gd").new()
	add_child(skill)
	skills.append(skill)
	
	skill = load("res://Scripts/AquaBeam.gd").new()
	add_child(skill)
	skills.append(skill)
	
	skill = load("res://Scripts/Flamethrower.gd").new()
	add_child(skill)
	skills.append(skill)
	
	
func initCollision():
	Utils.addCollisionCircle(self, Cfg.playerSize)
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	set_collision_layer_bit(Cfg.layer_player, true)
	set_collision_mask_bit(Cfg.layer_enemy, true)
	
func initSprite():
	sprite = AnimatedSprite.new()
	add_child(sprite)
	sprite.frames = Refs.resources.playerFrames
	sprite.playing = true
	sprite.scale *= 0.75
	
	
func _physics_process(delta):
	
	movementInput()
	
	velocity += acceleration
	
	# Get vectors that only contain the X component
	var velocityX = Vector2(velocity.x, 0)
	var inputVelocityX = Vector2(inputVelocity.x, 0)
	
	# Check if the X velocities are going in different directions
	if velocityX.dot(inputVelocityX) < 0:
		var vx = velocity.x
		# Adjust the X velocities
		velocity.x = max(0, velocity.x + inputVelocity.x) if velocity.x > 0 else min(0, velocity.x + inputVelocity.x)
		inputVelocity.x = min(0, inputVelocity.x + vx) if velocity.x > 0 else max(0, inputVelocity.x + vx)
		
	# Check again to see if the Y velocities are going in different directions
	if velocity.dot(inputVelocity) < 0:
		var vy = velocity.y
		# Adjust the Y velocities
		velocity.y = max(0, velocity.y + inputVelocity.y) if velocity.y > 0 else min(0, velocity.y + inputVelocity.y)
		inputVelocity.y = min(0, inputVelocity.y + vy) if velocity.y > 0 else max(0, inputVelocity.y + vy)
	
	# position += velocity * delta
	# position += inputVelocity * delta
	move_and_slide((velocity + inputVelocity))
	velocity *= 0.9
	
	# Stop all movement once it is below the limit
	flatVelocity(5)
	
	# Look at the mouse
	rotation = (get_global_mouse_position() - position).angle() + PI/2
	
	# Reset input velocity
	inputVelocity *= 0
	# Reset acceleration
	acceleration *= 0
	
func flatVelocity(limit):
	if velocity.x > 0 and velocity.x < limit:
		velocity.x = 0
	elif velocity.x < 0 and velocity.x > -limit:
		velocity.x = 0
	if velocity.y > 0 and velocity.y < limit:
		velocity.y = 0
	elif velocity.y < 0 and velocity.y > -limit:
		velocity.y = 0
		
func takeDamage(damage):
	skills[1].cancel()
	health.takeDamage(damage)
	
func knockback(knockback):
	acceleration += knockback
		
func _unhandled_input(event):
	for i in range(skills.size()):
		if event.is_action_pressed("skill%s" % (i+1)):
			skills[i].safeCast(position, get_global_mouse_position())
			
	if event.is_action_released("skill2"):
		skills[1].cancel()
	
func _onHit():
	pass

func movementInput():
	if not skills[1].active:
		if Input.is_action_pressed("move_left"):
			inputVelocity += Vector2(-1,0)
		if Input.is_action_pressed("move_right"):
			inputVelocity += Vector2(1,0)
		if Input.is_action_pressed("move_up"):
			inputVelocity += Vector2(0,-1)
		if Input.is_action_pressed("move_down"):
			inputVelocity += Vector2(0,1)
		inputVelocity = inputVelocity.normalized() * speed
	
	
func fallOff():
	onDeath()
	
func onDeath():
	yield(get_tree(), "idle_frame")
	var lossUI = Refs.scenes.lossUI.instance()
	Refs.game.add_child(lossUI)
	get_tree().paused = true