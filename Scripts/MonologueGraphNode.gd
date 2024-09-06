## Abstract graph node class for Monologue dialogue nodes. This should not
## be used on its own, it should be overridden to replace [member node_type].
class_name MonologueGraphNode extends GraphNode


# field UI scene definitions that a graph node can have
const DROPDOWN = preload("res://Objects/SubComponents/Fields/MonologueDropdown.tscn")
const FILE = preload("res://Objects/SubComponents/Fields/FilePicker.tscn")
const LINE = preload("res://Objects/SubComponents/Fields/MonologueLine.tscn")
const OPERATOR = null
const OPTION = null
const SPINBOX = preload("res://Objects/SubComponents/Fields/MonologueSpinBox.tscn")
const SLIDER = preload("res://Objects/SubComponents/Fields/MonologueSlider.tscn")
const TOGGLE = preload("res://Objects/SubComponents/Fields/MonologueToggle.tscn")
const TEXT = preload("res://Objects/SubComponents/Fields/MonologueText.tscn")

var id: String = UUID.v4()
var node_type: String = "NodeUnknown"
var undo_redo: HistoryHandler


func _ready() -> void:
	title = node_type
	for property_name in get_property_names():
		get(property_name).undo_redo = get_parent().undo_redo
		get(property_name).connect("display", display)


func add_to(graph) -> Array[MonologueGraphNode]:
	graph.add_child(self, true)
	return [self]


func display() -> void:
	get_parent().set_selected(self)


func get_property_names() -> PackedStringArray:
	var names = PackedStringArray()
	for property in get_property_list():
		if property.class_name == "Property":
			names.append(property.name)
	return names


func _from_dict(dict: Dictionary) -> void:
	for key in dict.keys():
		var property = get(key.to_snake_case())
		if property is Property:
			property.value = dict.get(key)
	position_offset.x = dict.EditorPosition.get("x")
	position_offset.y = dict.EditorPosition.get("y")
	_update()  # refresh node UI after loading properties


func _load_connections(data: Dictionary, key: String = "NextID") -> void:
	var next_id = data.get(key)
	if next_id is String:
		var next_node = get_parent().get_node_by_id(next_id)
		get_parent().connect_node(name, 0, next_node.name, 0)


func _to_dict() -> Dictionary:
	var base_dict = {
		"$type": node_type,
		"ID": id,
		"EditorPosition": {
			"x": int(position_offset.x),
			"y": int(position_offset.y)
		}
	}
	_to_fields(base_dict)
	_to_next(base_dict)
	return base_dict


func _to_fields(dict: Dictionary) -> void:
	for property_name in get_property_names():
		dict[Util.to_key_name(property_name)] = get(property_name).value


func _to_next(dict: Dictionary, key: String = "NextID") -> void:
	var next_id_node = get_parent().get_all_connections_from_slot(name, 0)
	dict[key] = next_id_node[0].id if next_id_node else -1


func _update() -> void:
	size.y = 0
