class_name Tutorial extends Control

var progress: int = 0
@export var totalPages: int
@export var pageIndex: Array[TutorialNotification]

func _ready():
	for page in pageIndex:
		page.nextPage.connect(startNextPage)
		page.previousPage.connect(startPreviousPage)
	pageIndex[0].backButton.disabled = true

func startNextPage():
	progress += 1
	if progress == len(pageIndex): 
		self.queue_free()
		return
	pageIndex[progress-1].visible = false
	pageIndex[progress].visible = true

func startPreviousPage():
	if progress == 0: return
	progress -= 1
	pageIndex[progress+1].visible = false
	pageIndex[progress].visible = true
