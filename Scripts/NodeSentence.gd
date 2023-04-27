extends GraphNode


@onready var comment_box: HBoxContainer = $MarginContainer/HBoxContainer/MainColumn/Comment
@onready var main: VBoxContainer = $MarginContainer/HBoxContainer/MainColumn
@onready var more: VBoxContainer = $MarginContainer/HBoxContainer/AddColumn
@onready var text: HBoxContainer =  $MarginContainer/HBoxContainer/MainColumn/Text
@onready var display_name: HBoxContainer = $MarginContainer/HBoxContainer/MainColumn/DisplayName
@onready var character: HBoxContainer = $MarginContainer/HBoxContainer/MainColumn/Character
@onready var character_drop: OptionButton = $MarginContainer/HBoxContainer/MainColumn/Character/CharacterDrop
@onready var line_asset: HBoxContainer = $MarginContainer/HBoxContainer/MainColumn/LineAsset
@onready var add_column = $MarginContainer/HBoxContainer/AddColumn

@onready var conditionals_stack_node = preload("res://Objects/ConditionalsStack.tscn")

var id = UUID.v4()
var loaded_text = ""

var if_stack
var profiles = ["Santa", "Elf"]

var conditionals_list = []
var node_type = "NodeSentence"

func _ready():
	title = node_type + " (" + id + ")"

	if loaded_text:
		text.get_node("TextEdit").text = loaded_text

func _to_dict() -> Dictionary:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	
	return {
		"$type": node_type,
		"ID": id,
		"NextID": next_id_node[0].id if next_id_node else -1,
		"Sentence": text.get_node("TextEdit").text,
		"SpeaketID": "",
		"Conditions": [],
		"Actions": [],
		"Flags": [],
		"CustomProperties": []
	}


func _on_GraphNode_close_request():
	queue_free()


func _on_Conditional_pressed():
	var conditionals_stack = conditionals_stack_node.instantiate()
	main.add_child(conditionals_stack)


func _on_DisplayName_toggled(button_pressed):
	if button_pressed:
		display_name.visible = true
	else:
		display_name.visible = false


func _on_Comment_toggled(button_pressed):
	if button_pressed:
		comment_box.visible = true
	else:
		comment_box.visible = false


func _on_More_toggled(button_pressed):	
	if button_pressed:
		add_column.visible = true
	else:
		add_column.visible = false


func _on_LineAsset_toggled(button_pressed):
	if button_pressed:
		line_asset.visible = true
	else:
		line_asset.visible = false


func _on_Text_toggled(button_pressed):
	if button_pressed:
		text.visible = true
	else:
		text.visible = false