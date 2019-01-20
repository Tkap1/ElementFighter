extends Node

signal finished

var funcRef

func _init(funcRef):
	self.funcRef = funcRef
	
func start():
	funcRef.call_func(self)
