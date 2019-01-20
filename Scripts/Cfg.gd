extends Node

var width
var height

var playAreaRadius = 300

var spriteSize = Vector2(128,128)

var playerSize = 32
var playerSpeed = 300
var playerHealth = 100

var layer_player = 0
var layer_enemy = 1

var nextLevelDelay = 3.0

var disasterDelay = 10.0

var skills = {
    "lightningBolt":
    {
        "damage": 10.0,
        "cooldown": 0.25,
        "range": 64.0,
        "radius": 50.0,
        "duration": 0.25,
        "knockback": 200.0,
        "cooldownSound": null,
        "castSound": Refs.sounds.lightningBolt,
    },
    "flamethrower":
    {
        "damage": 10.0,
        "cooldown": 3.0,
        "range": 64.0,
        "radius": 10.0,
        "duration": 1.0,
        "knockback": 100.0,
        "amount": 7.0,
        "speed": 50.0,
        "spread": PI/4,
        "cooldownSound": Refs.sounds.outOfCooldown,
        "castSound": Refs.sounds.flamethrower,
    },
    "aquaBeam":
    {
        "damage": 7.0,
        "cooldown": 3.0,
        "range": 64.0,
        "radius": 10.0,
        "duration": 3.0,
        "knockback": 0.0,
        "amount": 7.0,
        "speed": 50.0,
        "damageDelay": 0.1,
        "width": 20,
        "height": 100,
        "cooldownSound": Refs.sounds.outOfCooldown,
        "castSound": Refs.sounds.aquaBeam,
    },
}

var enemies = {
    "melee":
    {
        "attackRange": 100,
        "health": 50,
        "attackDelay": 1.0,
        "range": 64.0,
        "attackRadius": 32.0,
        "damage": 25,
        "attackDuration": 0.1,
        "preAttackDelay": 0.4,
        "knockback": 800.0,
        "speed": 15.0,
        "size": Vector2(64,64),
        "knockbackMultiplier": 0.5, 
    },
    "ranged":
    {
        "attackRange": 300,
        "health": 40,
        "attackDelay": 1.5,
        "range": 64.0,
        "attackRadius": 16.0,
        "damage": 20,
        "attackDuration": 5.0,
        "preAttackDelay": 0.4,
        "knockback": 100.0,
        "projectileSpeed": 250,
        "speed": 20.0,
        "size": Vector2(64,64),
        "knockbackMultiplier": 1.0,
    },
    "tank":
    {
        "attackRange": 100,
        "health": 200,
        "attackDelay": 1.0,
        "range": 64.0,
        "attackRadius": 64.0,
        "damage": 30,
        "attackDuration": 0.1,
        "preAttackDelay": 0.4,
        "knockback": 800.0,
        "speed": 20.0,
        "size": Vector2(64,64),
        "knockbackMultiplier": 0.2,
    },
    "boss":
    {
        "attackRange": 100,
        "health": 1000,
        "attackDelay": 1.0,
        "range": 64.0,
        "attackRadius": 64.0,
        "damage": 49,
        "attackDuration": 0.1,
        "preAttackDelay": 0.4,
        "knockback": 800.0,
        "speed": 30.0,
        "size": Vector2(128,128),
        "knockbackMultiplier": 0.1,
        "projectileSpeed": 250,
    },
}

var disasters = {
    "earthquake": Refs.scripts.disaster.new(funcref(self, "earthquake")),
    "lightningStorm": Refs.scripts.disaster.new(funcref(self, "lightningStorm")),
}

var earthquakeTotalDuration = 5.0
var earthquakeSplitDuration = 0.2
var earthquakeForce = 350.0
var earthquakeSound = AudioStreamPlayer.new()

var lightningStormHits = 10
var lightningStormHitDelay = 1.0
var lightningStormNextDelay = 0.25
var lightningStormDamage = 20.0
var lightningStormSize = Vector2(32,32)
var lightningStrikeSound = AudioStreamPlayer.new()

func earthquake(disaster, timer = null):
    if timer == null:
        timer = Utils.addTimer(self, earthquakeSplitDuration, false, true)
        timer.connect("timeout", self, "earthquake", [disaster, timer])
        timer.add_to_group("restartable")
        timer.set_meta("iterations", 0)
        earthquakeSound.play()
    elif timer.get_meta("iterations") == int(earthquakeTotalDuration / earthquakeSplitDuration):
        timer.queue_free()
        disaster.emit_signal("finished")
        earthquakeSound.stop()
        
    Refs.camera.shake(Vector2(2.0,2.0), earthquakeSplitDuration)
    Refs.player.acceleration += Utils.getRandomVector2() * earthquakeForce
    Refs.player.skills[1].cancel()
    timer.set_meta("iterations", timer.get_meta("iterations") + 1)
    
    
func lightningStorm(disaster, timer = null):
    
    # create the repeat timer
    if timer == null:
        timer = Utils.addTimer(self, lightningStormNextDelay, false, true)
        timer.connect("timeout", self, "lightningStorm", [disaster, timer])
        timer.add_to_group("restartable")
        timer.set_meta("iterations", 0)
    elif timer.get_meta("iterations") == lightningStormHits-1:
        timer.queue_free()
        disaster.emit_signal("finished")
    
    
    # pick a random spot
    var r = rand_range(0, playAreaRadius)
    var angle = rand_range(0, PI*2)
    var pos = polar2cartesian(r,angle) + Utils.getScreenCenter(Refs.game.get_viewport_rect())
    
    
    # create a warning (timer)
    var sprite = Utils.addSprite(Refs.game, Refs.textures.warning, true, Vector2(0.5,0.5))
    sprite.position = pos
    sprite.add_to_group("restartable")
    var lightningTimer = Utils.addTimer(self, lightningStormHitDelay, true, true)
    lightningTimer.add_to_group("restartable")
    lightningTimer.connect("timeout", self, "lightningStrike", [pos, sprite, lightningTimer])
    
    timer.set_meta("iterations", timer.get_meta("iterations") + 1)
    
func lightningStrike(pos, sprite, timer):
    yield(get_tree(), "idle_frame")
    if timer != null:
        timer.queue_free()
    if sprite != null:
        sprite.queue_free()
    var hitbox = Refs.scripts.hitbox.new(self, "addCollisionCircle", [lightningStormSize.x], [], [layer_player], "", "_lightningStrikeHit")
    Refs.game.add_child(hitbox)
    hitbox.position = pos
    hitbox.setAnimation(Refs.resources.lightningBoltFrames)
    hitbox.setTimer(0.25)
    lightningStrikeSound.play()
    
func _lightningStrikeHit(body):
    body.takeDamage(lightningStormDamage)
        
    
func _ready():
    randomize()
    var size = OS.get_window_size()
    width = size.x
    height = size.y
    earthquakeSound.stream = Refs.sounds.earthquake
    add_child(earthquakeSound)
    lightningStrikeSound.stream = Refs.sounds.lightningBolt
    add_child(lightningStrikeSound)