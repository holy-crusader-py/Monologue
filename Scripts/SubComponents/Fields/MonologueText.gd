class_name MonologueText extends MonologueField


@export var minimum_size := Vector2(200, 200)

@onready var label = $Label
@onready var text_edit = $TextEdit


func _ready():
	text_edit.custom_minimum_size = minimum_size


func set_label_text(text: String) -> void:
	label.text = text


func propagate(value: Variant) -> void:
	super.propagate(value)
	text_edit.text = str(value)


func _on_focus_exited() -> void:
	field_updated.emit(text_edit.text)


func _on_text_changed() -> void:
	field_changed.emit(text_edit.text)