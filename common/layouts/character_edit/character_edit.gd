class_name CharacterEdit extends CharacterEditSection


@onready var main_section := %MainSettingsSection
@onready var portrait_list_section := %PortraitListSection
@onready var portrait_settings_section := %PortraitSettingsSection
@onready var preview_section := %PreviewSection
@onready var timeline_section := %TimelineSection
@onready var field_vbox := %FieldVBox

var nicknames := Property.new(MonologueGraphNode.LINE)
var display_name := Property.new(MonologueGraphNode.LINE)
var description := Property.new(MonologueGraphNode.TEXT)

var base_path: String


func _ready() -> void:
	_on_close_character_edit()
	GlobalSignal.add_listener("open_character_edit", _on_open_character_edit)
	GlobalSignal.add_listener("close_character_edit", _on_close_character_edit)
	GlobalSignal.add_listener("reload_character_edit", _on_reload_character_edit)
	
	portrait_list_section.connect("portrait_selected", _update_portrait)
	_update_portrait()


## Trickle down the setting of graph_edit and character_index.
func trickle() -> void:
	var child_sections = [portrait_list_section, portrait_settings_section, timeline_section]
	for section in child_sections:
		section.graph_edit = graph_edit
		section.character_index = character_index


func _on_open_character_edit(graph: MonologueGraphEdit, index: int) -> void:
	if index >= 0:
		graph_edit = graph
		character_index = index
		trickle()
		_from_dict(graph.speakers[index])
		show()
	else:
		_on_close_character_edit()


func _on_close_character_edit() -> void:
	# also triggered when 'Done' button is pressed
	if graph_edit:
		graph_edit.speakers[character_index]["Character"].merge(_to_dict(), true)
	hide()
	graph_edit = null
	character_index = -1


func _on_reload_character_edit(index: int) -> void:
	# triggered if character edit is opened but character index is different
	if character_index != index:
		_on_open_character_edit(graph_edit, index)


func _update_portrait() -> void:
	var selected_idx: int = portrait_list_section.selected
	
	var show_portrait_sections: bool = selected_idx >= 0
	portrait_settings_section.visible = show_portrait_sections
	preview_section.visible = show_portrait_sections
	if show_portrait_sections == false:
		timeline_section.hide()


func _from_dict(dict: Dictionary = {}) -> void:
	var character_dict: Dictionary = dict.get("Character", {})
	super._from_dict(character_dict)
	portrait_list_section._from_dict(character_dict)
	_update_portrait()


func _to_dict() -> Dictionary:
	var aggregate = super._to_dict()
	aggregate.merge(portrait_list_section._to_dict(), true)
	return aggregate
