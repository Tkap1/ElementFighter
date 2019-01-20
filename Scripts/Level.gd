extends Node

var enemyInfo

func _init(enemyInfo):
	self.enemyInfo = enemyInfo
	
func getEnemies():
	var enemies = []
	for key in enemyInfo:
		for i in range(enemyInfo[key]["amount"]):
			var enemy = Refs.scripts["enemy"].new(key)
			enemy.position = enemyInfo[key]["position"][i]
			enemies.append(enemy)
			
	return enemies