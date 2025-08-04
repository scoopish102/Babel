class_name EventScripts extends Object

#&"Great Storm", &"Flash Flood", &"Famine", &"City Fire", &"Plague", &"Furious Waves"

class Event extends Object:
	static var eventContents: Dictionary[StringName, String] = {
	&"Calm Waters": "The waves seem slower, and the rain calmer. \nLess flood progress per turn for the next 10 turns. ",
	&"Great Storm": "Heaven rumbles in anger. Prepare yourself! \nGreater flood progress per turn for the next 10 turns. ",
	&"Furious Waves": "Calamity overtakes you like a storm, disaster sweeps over you like a whirlwind, distress and trouble overwhelm you... \
	\nFlood progress next turn increased by 20%.",
	&"Divine Favor": "The mercy of Heaven is as great as its wrath. \nFlood progress for this layer reset to 0. ",
	&"Flash Flood": "A flood will carry off the houses, rushing waters on the day of Heaven’s wrath. \nFlood progress next turn increased by 10%. ",
	&"Heaven\'s Mercy": "Heaven has heard thy cry for mercy, and Heaven accepts thy prayer. \nNo flood progress for the next 5 turns.",
	&"Heaven\'s Wrath": "Heaven's wrath is upon your people! \nThe flood resumes before the promised time.",
	&"Bountiful Harvests": ("You crown the year with your bounty, and your carts overflow with abundance. \n+4 " + Global.FIP[&"Food"] + " this turn."),
	&"Exceeding Quotas": "Your people, in their industry, have exceeded the quota for the kilns. \n+4 " + Global.FIP[&"Earth"] + " this turn.",
	&"Industrious Spirit": ("Work the clay, tread the mortar, repair the brickwork! \n+4 " + Global.FIP[&"Labor"] + " this turn."),
	&"Famine": "The abundance in the land will not be remembered, for the famine that follows is severe. \nHalved " + Global.FIP[&"Food"] + " stores.",
	&"City Fire": "A warehouse full of construction materials erupts into flames. \nHalved " + Global.FIP[&"Earth"] + " stores.",
	&"Plague": "Heaven prepared a path for its anger. It did not spare us from death; it gave us over to plague. \n-2 free " + Global.FIP[&"Labor"] + " for 5 turns.",
	&"Bumper Crop": "The grain, the new wine and the olive oil, the young of the flocks and herds...\n+4 " + Global.FIP[&"Food"] + " per turn for the next 5 turns.",
	&"Bring the Heat": "The fire beneath the kilns burns hotter than ever before...\n+4 " + Global.FIP[&"Earth"] + " per turn for the next 5 turns.",
	&"Refugees": "People on boats from distant lands have fled to your lands seeking refuge. \n+1 " + Global.FIP[&"Labor"] + " permanently."
	}
	var eventName: StringName
	var notification: Notification
	
	func blueprint(ui: GUI, eventName: StringName) -> Event:
		createNotification(ui, eventName, eventContents[eventName], "Okay")
		return self
	
	func createNotification(ui: GUI, title: String, content: String, option: String = "Okay") -> Notification:
		self.eventName = title
		notification = ui.singleOptionNotificationBlueprint.instantiate()
		ui.notifBox.add_child(notification)
		ui.notifications.append(notification)
		notification.size = Vector2(64*4.5, 64*3)# - Vector2(16, 16)
		notification.centerOnScreen()
		notification.setContent(title, content)
		notification.setOption(option)
		notification.content.set_horizontal_alignment(1)
		return notification

class EventPath extends Event:
	var confirmEvent: StringName
	var denyEvent: StringName
	var result: bool
	
	func awaitChoice(ui: GUI) -> Event:
		result = await self.notification.result
		var newEvent: Event
		if result:
			newEvent = Event.new().blueprint(ui, confirmEvent)
		else:
			newEvent = Event.new().blueprint(ui, denyEvent)
		return newEvent
