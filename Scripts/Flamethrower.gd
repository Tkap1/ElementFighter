extends "res://Scripts/Skill.gd"
	
func _ready():
	set_as_toplevel(true)
	skillInfo = Cfg.skills.flamethrower
	setInfo("flamethrower")
	
func cast(casterPosition, targetPosition):
	var castPos = casterPosition + (targetPosition - casterPosition).normalized() * skillInfo.range
	# var sprite = Utils.addSprite(self, Refs.textures.icon, true)
	# sprite.position = castPos
	
	var sprite = AnimatedSprite.new()
	add_child(sprite)
	sprite.frames = Refs.resources.flamethrowerFrames
	sprite.playing = true
	sprite.position = castPos - Vector2(15,15) * (targetPosition - casterPosition).normalized()
	sprite.rotation = (targetPosition - casterPosition).angle() + PI/2
	sprite.scale.y *= 2
	Utils.addTimer(self, skillInfo.duration, true, true, self, "cleanup", [sprite], true)
	
	for i in range(skillInfo.amount):
		var angle = -skillInfo.spread + i * (skillInfo.spread / (skillInfo.amount-1)) * 2
		var newPos = Utils.rotateAroundPoint(casterPosition, castPos, angle)
		var newDir = (newPos-casterPosition).normalized()
		var knockback = newDir * skillInfo.knockback
		var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [skillInfo.radius], [], [Cfg.layer_enemy], "", "_onHit", [], [knockback])
		add_child(hitbox)
		hitbox.position = casterPosition + newDir * 40
		hitbox.setTargeting(hitbox.AOE)
		hitbox.setTimer(skillInfo.duration)
		hitbox.setDirection(newDir, skillInfo.speed)
	
		
func _onHit(body, knockback):
	body.takeDamage(skillInfo.damage)
	body.knockback(knockback)
	
func cleanup(timer, sprite):
	timer.queue_free()
	sprite.queue_free()