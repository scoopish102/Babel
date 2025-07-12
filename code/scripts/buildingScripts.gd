class_name BuildingScripts extends Object

class Building extends Object:
	static var cost : ResourceScripts.RResourceTicket
	static var budget : ResourceScripts.RResourceTicket
	static var buildingName : String
	
	func _init():
		pass
	
	func update():
		pass

class ProductionBuilding extends Building:
	static var workerSlots : int
	var workers : int
	
	func update() -> ResourceScripts.RResourceTicket:
		var totalBudget = ResourceScripts.RResourceTicket.new({})
		for worker in range(self.workers):
			totalBudget = totalBudget.merge(self.budget)
		return totalBudget
	
class StationBuilding extends Building:
	func update() -> ResourceScripts.RResourceTicket:
		return self.budget

class House extends StationBuilding:
	func _init():
		cost = ResourceScripts.RResourceTicket.new({"Earth": 4})
		budget = ResourceScripts.RResourceTicket.new({"Food": -2, "Labor": 2})
		buildingName = "House"

class Farm extends ProductionBuilding:
	func _init():
		cost = ResourceScripts.RResourceTicket.new({"Earth": 4})
		budget = ResourceScripts.RResourceTicket.new({"Food": 2, "Labor": -1})
		buildingName = "Farm"
		workerSlots = 2

class Kiln extends ProductionBuilding:
	func _init():
		cost = ResourceScripts.RResourceTicket.new({"Earth": 4})
		budget = ResourceScripts.RResourceTicket.new({"Earth": 1, "Labor": -1})
		buildingName = "Kiln"
		workerSlots = 2
