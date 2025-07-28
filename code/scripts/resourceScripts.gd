class_name ResourceScripts extends Object

class RResource extends Object:
	var name : StringName
	var amount : int
	var change : int
	var isBudget : bool
	
	func _init(name: String, amount: int = 0, isBudget: bool=false):
		self.name = name
		self.amount = amount
		self.change = 0
		self.isBudget = isBudget
		
	func addAmount(amount: int):
		self.amount += amount
		self.boundAmounts()
	
	func addChange(change: int):
		self.change += change
		
	func setAmount(amount: int):
		self.amount = amount
		self.boundAmounts()
	
	func setChange(change: int):
		self.change = change
	
	func getAmount() -> int:
		return self.amount
	
	func getChange() -> int:
		return self.change
		
	func boundAmounts(debug=false):
		if self.amount < 0:
			self.amount = 0
			if debug: print("Resource " + self.name + " is in deficit. (Losing " + str(self.change) + ")")
			
	func update():
		if self.isBudget: self.amount = 0
		self.amount += self.change
		self.boundAmounts()

static func mergeTickets(ticket1: Dictionary[StringName, int], ticket2: Dictionary[StringName, int]) -> Dictionary[StringName, int]:
	var result : Dictionary[StringName, int]
	for res in ticket1.keys(): 
		if not res in result.keys(): result[res] = 0
		result[res] += ticket1[res]
	for res in ticket2.keys():
		if not res in result.keys(): result[res] = 0 
		result[res] += ticket2[res]
	#print(result)
	return result

static var FIPLarge = {
	&"Food": "res://code/resources/miniResourceIcons/foodLarge.tres",
	&"Earth": "res://code/resources/miniResourceIcons/earthLarge.tres",
	&"Labor": "res://code/resources/miniResourceIcons/laborLarge.tres"
}

static func ticketToText(ticket: Dictionary[StringName, int]) -> String:
	var text: String = ""
	var i = 1
	for res in ticket.keys():
		text += str(ticket[res]) + " [img]" + FIPLarge[res] + "[/img]"
		if i < len(ticket.keys()): text += ", "
		else: text += " "
		i += 1
	return text

"""class RResourceTicket extends Object:
	var res : Dictionary
	
	func _init(_res: Dictionary):
		self.res = res.duplicate(true)
		
	func read(debug=false) -> Dictionary:
		if debug:
			for resource in self.res: print(resource + ": " + self.res[resource]) 
		return res
		
	func merge(ticket: RResourceTicket) -> RResourceTicket:
		#Creates a new ResourceTicket from a merger between this ResourceTicket
		# and one other ResourceTicket
		var newRes = self.res.duplicate(true)
		for resource in ticket.res:
			newRes[resource] += ticket.res[resource]
		var newTicket = RResourceTicket.new(self.res)
		return newTicket
	
	func canBeRedeemed(account : Dictionary) -> bool:
		print("qq")
		for resource in self.res.keys():
			if resource in account:
				print(account)
				if account[resource].amount - self.res[resource] < 0: 
					print("Out of resource: " + account[resource].name)
					return false
		return true"""
