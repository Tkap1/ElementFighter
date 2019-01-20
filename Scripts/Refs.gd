extends Node

var scripts = {
    "stateMachine": preload("res://Scripts/StateMachine.gd"),
    "healthComponent": preload("res://Scripts/HealthComponent.gd"),
    "healthBar": preload("res://Scripts/HealthBar.gd"),
    "array2D": preload("res://Scripts/Array2D.gd"),
    "customCamera": preload("res://Scripts/CustomCamera.gd"),
    "hitbox": preload("res://Scripts/Hitbox.gd"),
    "level": preload("res://Scripts/Level.gd"),
    "enemy": preload("res://Scripts/Enemy.gd"),
    "disaster": preload("res://Scripts/Disaster.gd"),
}

var sounds = {
    "outOfCooldown": preload("res://Assets/outOfCooldown.wav"),
    "lightningBolt": preload("res://Assets/lightningBolt.wav"),
    "flamethrower": preload("res://Assets/flamethrower.wav"),
    "aquaBeam": preload("res://Assets/aquaBeam.wav"),
    "earthquake": preload("res://Assets/earthquake.wav"),
}

var scenes = {
    "lossUI": preload("res://Scenes/LossUI.tscn"),
    "winUI": preload("res://Scenes/GameWonUI.tscn"),
}

var textures = {
    "icon": preload("res://Assets/icon.png"),
    "projectile": preload("res://Assets/projectile.png"),
    "background": preload("res://Assets/background.png"),
    "playArea": preload("res://Assets/playArea.png"),
    "warning": preload("res://Assets/warning.png"),
}

var resources = {
    "baseTheme": preload("res://Assets/baseTheme.tres"),
    "playerFrames": preload("res://Assets/playerFrames.tres"),
    "lightningBoltFrames": preload("res://Assets/lightningBoltFrames.tres"),
    "flamethrowerFrames": preload("res://Assets/flamethrowerFrames.tres"),
    "aquaBeamFrames": preload("res://Assets/aquaBeamFrames.tres"),
    "enemyFrames": preload("res://Assets/enemyFrames.tres"),
    "enemyHitFrames": preload("res://Assets/enemyHitFrames.tres"),
}

var main
var stateMachine
var camera
var player
var game