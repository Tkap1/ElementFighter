extends "res://Scripts/BaseState.gd"

var playArea
var player

var camera

var levels = []
var levelIndex = 0

var nextLevelTimer

var background
var playAreaSprite

var disasterTimer = null

func onEnter():
	# pause_mode = PAUSE_MODE_PROCESS
	
	call_deferred("initPlayArea")
	call_deferred("initLevels")
	call_deferred("initCamera")
	call_deferred("initDisasterTimer")
	call_deferred("initPlayer")
	
	call_deferred("startLevelTimer")
	
	Refs.game = self
	
func initCamera():
	camera = Refs.scripts.customCamera.new()
	add_child(camera)
	camera.current = true
	camera.global_position = Utils.getScreenCenter(get_viewport_rect())
	Refs.camera = camera
	
func initDisasterTimer():
	disasterTimer = Utils.addTimer(self, Cfg.disasterDelay, true, true, self, "_onDisasterTimerTimeout")
	disasterTimer.add_to_group("restartable")
	
func restartGame():
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.disconnect("death", self, "_onEnemyDeath")
	
	for node in get_tree().get_nodes_in_group("restartable"):
		node.queue_free()
		
	Cfg.earthquakeSound.stop()
		
	initDisasterTimer()
	initPlayer()
	startLevelTimer()

func _onDisasterTimerTimeout():
	var disasterKey = Cfg.disasters.keys()[randi() % Cfg.disasters.size()]
	var disaster = Cfg.disasters[disasterKey]
	disaster.connect("finished", self, "_onDisasterFinished", [disasterKey])
	disaster.start()
	
func _onDisasterFinished(disasterKey):
	Cfg.disasters[disasterKey].disconnect("finished", self, "_onDisasterFinished")
	disasterTimer.start()
	
func startLevel(levelIndex):
	player.skills[1].cancel()
	player.position = Utils.getScreenCenter(get_viewport_rect())
	player.takeDamage(-1000)
	playArea.connect("body_exited", self, "_playAreaLeft")
	nextLevelTimer.queue_free()
	var currentLevel = levels[levelIndex]
	var enemies = currentLevel.getEnemies()
	for enemy in enemies:
		add_child(enemy)
		enemy.connect("death", self, "_onEnemyDeath")
		
func startLevelTimer():
	playArea.disconnect("body_exited", self, "_playAreaLeft")
	nextLevelTimer = Utils.addTimer(self, Cfg.nextLevelDelay, true, true, self, "startLevel", [levelIndex])
		
func _onEnemyDeath(enemy):
	yield(get_tree(), "idle_frame")
	# If all enemies are dead
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		levelIndex += 1
		# If all levels are completed, show game won screen
		if levelIndex == levels.size():
			playArea.disconnect("body_exited", self, "_playAreaLeft")
			for node in get_tree().get_nodes_in_group("restartable"):
				node.queue_free()
			Refs.main.add_child(Refs.scenes.winUI.instance())
			queue_free()
		# Else start the next a timer which upon timeout will start the next level
		else:
			startLevelTimer()
	
	
	
func onLeave():
	cleanup()
	
func _unhandled_input(event):
	pass
	# if event.is_action_pressed("pause"):
	# 	pause()
		
func pause():
	get_tree().paused = !get_tree().paused
	
func initLevels():
	var levelGD = Refs.scripts.level
	
	# Level 1
	var level = levelGD.new({
		"melee":
		{
			"amount": 1,
			"position": [Utils.getScreenCenter(get_viewport_rect()) - Vector2(0, 200)],
		}
	})
	levels.append(level)
	
	# Level 2
	level = levelGD.new({
		"melee":
		{
			"amount": 2,
			"position": [Utils.getScreenCenter(get_viewport_rect()) - Vector2(200, 0), Utils.getScreenCenter(get_viewport_rect()) + Vector2(200, 0)],
		}
	})
	levels.append(level)
	
	# Level 3
	level = levelGD.new({
		"melee":
		{
			"amount": 2,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) - Vector2(200, 0),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(200, 0)],
		},
		"ranged":
		{
			"amount": 1,
			"position": [Utils.getScreenCenter(get_viewport_rect()) - Vector2(0, 200)],
		}
	})
	levels.append(level)
	
	# Level 4
	level = levelGD.new({
		"melee":
		{
			"amount": 4,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(-100, -100),
			 	Utils.getScreenCenter(get_viewport_rect()) + Vector2(100, -100),
			 	Utils.getScreenCenter(get_viewport_rect()) + Vector2(-100, 100),
			 	Utils.getScreenCenter(get_viewport_rect()) + Vector2(100, 100),
			],
		},
	})
	levels.append(level)
	
	# Level 5
	level = levelGD.new({
		"ranged":
		{
			"amount": 3,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) - Vector2(200, 0),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(200, 0),
				Utils.getScreenCenter(get_viewport_rect()) - Vector2(0, 200),
			],
		},
	})
	levels.append(level)
	
	# Level 6
	level = levelGD.new({
		"tank":
		{
			"amount": 1,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(0, -200),
			],
		},
	})
	levels.append(level)
	
	# Level 7
	level = levelGD.new({
		"tank":
		{
			"amount": 1,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(0, -200),
			],
		},
		"ranged":
		{
			"amount": 2,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(-200, 0),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(200, 0),
			],
		},
	})
	levels.append(level)
	
	# Level 8
	level = levelGD.new({
		"tank":
		{
			"amount": 1,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(0, -250),
			],
		},
		"melee":
		{
			"amount": 4,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(-250, -250),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(-200, -250),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(250, -250),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(200, -250),
			],
		},
	})
	levels.append(level)
	
	# Level 9
	level = levelGD.new({
		"tank":
		{
			"amount": 3,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(0, -250),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(-250, 0),
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(250, 0),
			],
		},
	})
	levels.append(level)
	
	# Level 10
	level = levelGD.new({
		"boss":
		{
			"amount": 1,
			"position": [
				Utils.getScreenCenter(get_viewport_rect()) + Vector2(0, -250),
			],
		},
	})
	levels.append(level)
	
	
	# TODO: testing, remove
	levelIndex = 0
	
	
func initPlayArea():
	background = Utils.addSprite(self, Refs.textures.background, true, Vector2(2,2))
	background.position = Utils.getScreenCenter(get_viewport_rect())
	playArea = Area2D.new()
	add_child(playArea)
	var coll = CollisionShape2D.new()
	coll.shape = CircleShape2D.new()
	coll.shape.radius = Cfg.playAreaRadius
	playArea.add_child(coll)
	playArea.position = Utils.getScreenCenter(get_viewport_rect())
	playArea.connect("body_exited", self, "_playAreaLeft")
	playAreaSprite = Utils.addSprite(self, Refs.textures.playArea, true, Vector2(1,1))
	playAreaSprite.position = Utils.getScreenCenter(get_viewport_rect()) - Vector2(15,0)
	
func initPlayer():
	player = load("res://Scripts/Player.gd").new()
	add_child(player)
	player.position = Utils.getScreenCenter(get_viewport_rect())
	Refs.player = player
	
func _playAreaLeft(body):
	body.fallOff()