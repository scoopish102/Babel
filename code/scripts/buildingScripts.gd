class_name BuildingScripts extends Object

class Building extends Object:
	static var cost : Dictionary
	static var budget : Dictionary
	static var buildingName : String
	
	func _init():
		pass
	
	func update():
		pass

class ProductionBuilding extends Building:
	static var workerSlots : int
	var workers : int
	
	func update() -> Dictionary:
		var totalBudget : Dictionary
		for worker in range(self.workers):
			totalBudget = {}
			#totalBudget = totalBudget.merge(self.budget)
			#^^^ MERGE BUDGETS, WRITE A FUNCTION FOR THAT LATER LOL
		return totalBudget
	
class StationBuilding extends Building:
	func update() -> Dictionary:
		return self.budget

class City extends StationBuilding:
	func _init():
		cost = {&"Earth": -4}
		budget = {&"Food": -2, &"Labor": 2}
		buildingName = &"City"

class Farm extends ProductionBuilding:
	func _init():
		cost = {&"Earth": -4}
		budget = {&"Food": 2, &"Labor": -1}
		buildingName = &"Farm"
		workerSlots = 2

class Kiln extends ProductionBuilding:
	func _init():
		cost = {&"Earth": -4}
		budget = {&"Earth": 1, &"Labor": -1}
		buildingName = &"Kiln"
		workerSlots = 2
