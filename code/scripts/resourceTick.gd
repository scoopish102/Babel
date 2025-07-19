class_name ResourceTick extends HBoxContainer

@onready var label := $Amount

func setResource(type: String):
	for icon in $ResourceIcon.get_children():
		icon.visible = false
	if type in ["Food", "Earth", "Labor"]:
		match type:
			"Food":
				$ResourceIcon/Food.visible = true
			"Earth":
				$ResourceIcon/Earth.visible = true
			"Labor":
				$ResourceIcon/Labor.visible = true
	else: label.set_text(label.text + " " + type)

func setAmount(amount: int):
	label.set_text(str(amount))

func init(type: String, amount: int, color: Color):
	setAmount(amount)
	setResource(type)
	label.modulate = color
