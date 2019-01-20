extends "res://Scripts/Skill.gd"
	
func _ready():
	set_as_toplevel(true)
	skillInfo = Cfg.skills.lightningBolt
	setInfo("lightningBolt")
	
func cast(casterPosition, targetPosition):
	var castPos = casterPosition + (targetPosition - casterPosition).normalized() * skillInfo.range
	var knockback = (targetPosition - casterPosition).normalized() * skillInfo.knockback
	var sprite = AnimatedSprite.new()
	add_child(sprite)
	sprite.frames = Refs.resources.lightningBoltFrames
	sprite.playing = true
	sprite.position = castPos - Vector2(0, 20)
	var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [skillInfo.radius], [], [Cfg.layer_enemy], "", "_onHit", [], [knockback])
	add_child(hitbox)
	hitbox.position = castPos
	
	Utils.addTimer(self, skillInfo.duration, true, true, self, "cleanup", [sprite,hitbox], true)
	hitbox.setTargeting(hitbox.AOE)
		
func _onHit(body, knockback):
	body.takeDamage(skillInfo.damage)
	body.knockback(knockback)
	
func cleanup(timer, sprite, hitbox):
	timer.queue_free()
	sprite.queue_free()
	hitbox.queue_free()