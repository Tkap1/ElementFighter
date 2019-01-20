extends "res://Scripts/Skill.gd"
	
var hitbox
var knockback
var casterPosition
var active = false
var timer = null
var sprite

func _ready():
	set_as_toplevel(true)
	skillInfo = Cfg.skills.aquaBeam
	setInfo("aquaBeam")
	
func cast(casterPosition, targetPosition):
	self.casterPosition = casterPosition
	
	sprite = AnimatedSprite.new()
	add_child(sprite)
	sprite.frames = Refs.resources.aquaBeamFrames
	sprite.playing = true
	sprite.scale *= 2
	
	
	
	hitbox = Refs.scripts.hitbox.new(self, "addCollisionRect", [Vector2(skillInfo.width,skillInfo.height)], [],[Cfg.layer_enemy], "", "_onHit")
	add_child(hitbox)
	hitbox.setTargeting(hitbox.AOE_REPEAT, skillInfo.damageDelay)
	timer = Utils.addTimer(self,skillInfo.duration, true, true, self, "cleanup", [], true)
	active = true
	
	
func _physics_process(delta):
	if active:
		var m = get_global_mouse_position()
		var pos = (m - casterPosition).normalized()
		knockback = pos * skillInfo.knockback
		hitbox.position = casterPosition + Vector2(skillInfo.height,skillInfo.height) * pos
		hitbox.rotation = pos.angle() + PI/2
		sprite.position = casterPosition + Vector2(skillInfo.height,skillInfo.height) * pos
		sprite.rotation = pos.angle() + PI/2
		
	
	
		
func _onHit(body):
	body.takeDamage(skillInfo.damage)
	body.knockback(knockback)
	
func cancel():
	if active:
		cleanup(timer)
	
func cleanup(timer):
	yield(get_tree(), "idle_frame")
	castSound.stop()
	if timer != null:
		timer.queue_free()
		timer = null
	if hitbox != null:
		hitbox.queue_free()
		hitbox = null
	knockback = null
	casterPosition = null
	active = false
	if sprite != null:
		sprite.queue_free()
		sprite = null