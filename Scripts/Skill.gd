extends Node2D

var cooldownTimer
var skillInfo
var cooldownSound
var castSound

func setInfo(key):
	skillInfo = Cfg.skills[key]
	cooldownTimer = Utils.addTimer(self, skillInfo["cooldown"], true, false)
	if skillInfo.cooldownSound != null:
		cooldownTimer.connect("timeout", self, "_outOfCooldown")
		cooldownSound = AudioStreamPlayer.new()
		cooldownSound.stream = skillInfo.cooldownSound
		add_child(cooldownSound)
	if skillInfo.castSound != null:
		castSound = AudioStreamPlayer.new()
		castSound.stream = skillInfo.castSound
		add_child(castSound)

func safeCast(casterPosition, targetPosition):
	if cooldownTimer.is_stopped():
		cooldownTimer.start()
		cast(casterPosition, targetPosition)
		if castSound != null:
			castSound.play()
		
func cast(casterPosition, targetPosition):
	pass
	
func _outOfCooldown():
	cooldownSound.play()