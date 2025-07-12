class_name ResourceScripts extends Object

class RResource extends Object:
	var name : String
	var amount : int
	var change : int
	var isBudget : bool
	
	func _init(_name: String, _amount: int = 0, _isBudget: bool=false):
		self.name = name
		self.amount = amount
		self.change = 0
		self.isBudget = isBudget
		
	func addAmount(_amount: int):
		self.amount += amount
		self.boundAmounts()
		
	func setAmount(_amount: int):
		self.amount = amount
		self.boundAmounts()
		
	func boundAmounts(debug=false):
		if self.amount > 0:
			self.amount = 0
			if debug: print("Resource " + self.name + " is in deficit. (Losing " + str(self.change) + ")")
			
	func update():
		if self.isBudget: self.amount = 0
		self.amount += self.change
		self.boundAmounts()

class RResourceAccount extends Object:
	var res : Dictionary
	
	func _init(_res: Dictionary):
		self.res = res
	
	func redeemCost(ticket: RResourceTicket):
		if ticket.canRedeem(self):
			for resource in ticket.res:
				if resource in self.res: self.res[resource].addAmount(ticket.res[resource])
	
	func redeemBudget(ticket: RResourceTicket):
		for resource in ticket.res:
			if resource in self.res: self.res[resource].change += ticket.res[resource]
	
	func update():
		for resource in self.res:
			self.res[resource].update()

class RResourceTicket extends Object:
	var res : Dictionary
	
	func _init(_res: Dictionary):
		self.res = res
		
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
	
	func canRedeem(account : RResourceAccount) -> bool:
		for resource in self.res:
			if resource in account and resource in self.res:
				if account[resource] - self.res[resource] < 0: return false
		return true
