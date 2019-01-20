extends KinematicBody2D

signal death(enemy)

enum {CHASE,PRE_ATTACK, ATTACK,DIE}
var state = CHASE

var sprite

var health

var key
var info
var attackTimer
var preAttackTimer

var acceleration = Vector2()
var velocity = Vector2()
var speed
var friction = 0.95

func _init(enemyKey):
	self.key = enemyKey
	self.info = Cfg.enemies[enemyKey]
	
	initCollision()
	
func initCollision():
	Utils.addCollisionCircle(self, info.size.x/2.0)
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	set_collision_layer_bit(Cfg.layer_enemy, true)
	set_collision_mask_bit(Cfg.layer_player, true)
	set_collision_mask_bit(Cfg.layer_enemy, true)

func _ready():
	add_to_group("restartable")
	add_to_group("enemies")
	health = Refs.scripts["healthComponent"].new(info.health)
	add_child(health)
	health.connect("death", self, "_onDeath")
	health.connect("hit", self, "_onHit")
	
	attackTimer = Utils.addTimer(self, info.attackDelay, true, true)
	preAttackTimer = Utils.addTimer(self, info.preAttackDelay, true, false)
	
	health.addHealthbar(self, Vector2(64,64), Vector2(64,16))
	
	self.speed = info.speed
	
	call_deferred("initSprite")
	
func initSprite():
	sprite = AnimatedSprite.new()
	add_child(sprite)
	sprite.frames = Refs.resources.enemyFrames
	sprite.playing = true
	Utils.sizeSprite(info.size, sprite)
	sprite.animation = key + "Idle"
	
func _physics_process(delta):
	
	match(state):
		CHASE:
			chasePlayer()
			
	rotation = (Refs.player.position - position).angle() + PI + PI /2
	
	velocity += acceleration
	move_and_slide(velocity)
	acceleration *= 0
	velocity *= friction
	
	flatVelocity(5)
	
	var player = get_tree().get_nodes_in_group("player")[0]
	match(state):
		CHASE:
			if position.distance_to(player.position) <= info["attackRange"]:
				velocity *= 0.1
				state = PRE_ATTACK
				preAttackTimer.start()
		PRE_ATTACK:
			if preAttackTimer.is_stopped():
				preAttackTimer.start()
				state = ATTACK
		ATTACK:
			if attackTimer.is_stopped():
				attack()
				attackTimer.start()
			if position.distance_to(player.position) > info["attackRange"]:
				state = CHASE
		DIE:
			pass
	
	
func attack():
	var player = get_tree().get_nodes_in_group("player")[0]
	
	
	match(key):
		"melee":
			var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [info.attackRadius], [], [Cfg.layer_player], "", "_onPlayerHit")
			add_child(hitbox)
			hitbox.setTimer(info.attackDuration)
			hitbox.position = position + (player.position - position).normalized() * info.range
			hitbox.setAnimation(Refs.resources.enemyHitFrames)
			
		"tank":
			var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [info.attackRadius], [], [Cfg.layer_player], "", "_onPlayerHit")
			add_child(hitbox)
			hitbox.setTimer(info.attackDuration)
			hitbox.position = position + (player.position - position).normalized() * info.range
			hitbox.setAnimation(Refs.resources.enemyHitFrames)
			
		"ranged":
			var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [info.attackRadius], [], [Cfg.layer_player], "", "_onPlayerHit")
			add_child(hitbox)
			hitbox.position = position + (player.position - position).normalized() * info.range
			hitbox.setTimer(info.attackDuration)
			hitbox.setDirection((player.position - position).normalized(), info.projectileSpeed)
			hitbox.setTargeting(hitbox.SINGLE)
			hitbox.setSprite(Refs.textures.projectile, Vector2(0.5,0.5))
			hitbox.destroyedOnHit = true
		"boss":
			# choose ranged or melee
			var choice = randi() % 2
			# melee
			if choice == 0:
				var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [info.attackRadius], [], [Cfg.layer_player], "", "_onPlayerHit")
				add_child(hitbox)
				hitbox.position = position + (player.position - position).normalized() * info.range
				hitbox.setTimer(info.attackDuration)
				hitbox.setAnimation(Refs.resources.enemyHitFrames, Vector2(2,2))
			# ranged
			else:
				var angle = (player.position - position).angle()
				var shoots = 5
				var spread = PI*2 / shoots
				for i in range(shoots):
					var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [info.attackRadius/3.0], [], [Cfg.layer_player], "", "_onPlayerHit")
					add_child(hitbox)
					hitbox.position = position
					hitbox.setTimer(info.attackDuration * 50.0)
					hitbox.setDirection(Vector2(1,0).rotated(angle), info.projectileSpeed)
					hitbox.setTargeting(hitbox.SINGLE)
					hitbox.setSprite(Refs.textures.projectile, Vector2(0.5,0.5))
					hitbox.destroyedOnHit = true
					angle += spread
	
func _onPlayerHit(player):
	player.takeDamage(info.damage)
	var knockback = (player.position - position).normalized() * info.knockback
	player.knockback(knockback)
	
func flatVelocity(limit):
	if velocity.x > 0 and velocity.x < limit:
		velocity.x = 0
	elif velocity.x < 0 and velocity.x > -limit:
		velocity.x = 0
	if velocity.y > 0 and velocity.y < limit:
		velocity.y = 0
	elif velocity.y < 0 and velocity.y > -limit:
		velocity.y = 0
	
func chasePlayer():
	var player = get_tree().get_nodes_in_group("player")[0]
	var movement = (player.position - position).normalized() * speed
	acceleration += movement
	
func knockback(knockback):
	acceleration += knockback * info.knockbackMultiplier
	
func takeDamage(damage):
	health.takeDamage(damage)
	
func _onDeath():
	if not health.dead:
		emit_signal("death", self)
		queue_free()
	
func fallOff():
	if not health.dead:
		emit_signal("death", self)
		queue_free()
	
func _onHit():
	pass