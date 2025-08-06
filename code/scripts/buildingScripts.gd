class_name BuildingScripts extends Object

func _ready():
	print("Hello World")

class Building extends Object:
	var cost : Dictionary[StringName, int]
	var budget : Dictionary[StringName, int]
	var buildingName : StringName
	
	func _init():
		pass
	
	func update():
		pass

class ProductionBuilding extends Building:
	var workerSlots : int
	var workers : int
	
	func update() -> Dictionary[StringName, int]:
		var totalBudget : Dictionary[StringName, int] = {}
		for worker in range(self.workers):
			totalBudget = ResourceScripts.mergeTickets(totalBudget, self.budget)
			#^^^ MERGE BUDGETS, WRITE A FUNCTION FOR THAT LATER LOL
		return totalBudget
	
class StationBuilding extends Building:
	func update() -> Dictionary[StringName, int]:
		return self.budget

class City extends StationBuilding:
	func _init():
		self.cost = {&"Earth": -2, &"Labor": -1}
		self.budget = {&"Food": -2, &"Labor": 2}
		self.buildingName = &"City"

class Farm extends ProductionBuilding:
	func _init():
		self.cost = {&"Earth": -2, &"Labor": -1}
		self.budget = {&"Food": 2, &"Labor": -1}
		self.buildingName = &"Farm"
		self.workerSlots = 2

class Kiln extends ProductionBuilding:
	func _init():
		self.cost = {&"Earth": -2, &"Labor": -1}
		self.budget = {&"Earth": 1, &"Labor": -1}
		self.buildingName = &"Kiln"
		self.workerSlots = 2
