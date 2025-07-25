class_name InfoBox extends VBoxContainer

@onready var minimize := $Tab/Caption/Open
@onready var content := $Content
@onready var tabCaption := $Tab/Caption
@onready var tabLabel := $Tab/Caption/Label
@onready var title := $Content/Content/Caption/Label
@onready var info := $Content/Content/Info
@onready var infoText := $Content/Content/Info/Label
@onready var icon := $Content/Content/Caption/Icon
@onready var build := $Content/Content/Buttons/Build
@onready var cancel := $Content/Content/Buttons/Cancel
