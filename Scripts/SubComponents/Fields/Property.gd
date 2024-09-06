## Represents a graph node property and its UI controls in Monologue.
class_name Property extends RefCounted


## Emitted if the graph node of this property should be displayed in panel.
signal display
## Emitted when the field's value is being changed and is requesting a preview.
signal preview(value: Variant)

## Dictionary of field method names to argument list values.
var callers: Dictionary = {}
## Reference to UI instance.
var field: MonologueField
## Scene used to instantiate the field's UI control.
var scene: PackedScene
## Dictionary of field property names to set values.
var setters: Dictionary
## UndoRedo instance for tracking property change history.
var undo_redo: HistoryHandler
## Actual value of the property.
var value: Variant = ""
## Toggles visibility of the field instance.
var visible: bool : set = set_visible


func _init(ui_scene: PackedScene, ui_setters: Dictionary = {}) -> void:
	scene = ui_scene
	setters = ui_setters
	visible = true


## Change the property's UI scene and replace the active field instance.
func morph(new_scene: PackedScene) -> void:
	scene = new_scene
	if is_instance_valid(field):
		var panel = field.get_parent()
		field.queue_free()
		show(panel)


func propagate(new_value: Variant) -> void:
	preview.emit(new_value)
	if is_instance_valid(field):
		field.propagate(new_value)
	else:
		display.emit()


func save_value(new_value: Variant) -> void:
	if undo_redo and not Util.is_equal(value, new_value):
		undo_redo.create_action("%s => %s" % [value, new_value])
		undo_redo.add_do_property(self, "value", new_value)
		undo_redo.add_do_method(propagate.bind(new_value))
		undo_redo.add_undo_property(self, "value", value)
		undo_redo.add_undo_method(propagate.bind(value))
		undo_redo.commit_action()
	else:
		value = new_value


func set_visible(can_see: bool) -> void:
	visible = can_see
	_check_visibility()


func show(panel: Control) -> MonologueField:
	field = scene.instantiate()
	for property in setters.keys():
		field.set(property, setters.get(property))
	
	panel.add_child(field)
	for method in callers.keys():
		field.callv(method, callers.get(method, []))
	
	field.propagate(value)
	field.connect("field_changed", preview.emit)
	field.connect("field_updated", save_value)
	_check_visibility()
	return field


func _check_visibility():
	if is_instance_valid(field):
		field.visible = visible
