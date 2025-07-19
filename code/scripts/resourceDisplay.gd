class_name RResourceDisplay extends HBoxContainer

@onready var amount = $VBoxContainer/Count
@onready var change = $VBoxContainer/Increase

func setLabels(amount: int, change: int):
	self.amount.get_child(0).set_text(str(amount))
	self.change.get_child(0).set_text(str(change))
	#self.amount.custom_minimum_size.x = self.amount.get_child(0).size.x
	#self.change.custom_minimum_size.x = self.change.get_child(0).size.x
