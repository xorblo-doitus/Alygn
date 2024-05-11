class_name Token
extends RefCounted


signal type_changed
signal ghostly_changed
signal active_type_changed


var type: Element.Type = Element.Type.NULL:
	set(new):
		type = new
		type_changed.emit()

var permanently_ghostly: bool = false:
	set(new):
		permanently_ghostly = new
		ghostly_changed.emit()
var temporary_ghostly: bool = false:
	set(new):
		temporary_ghostly = new
		ghostly_changed.emit()
func is_ghostly() -> bool:
	return permanently_ghostly or temporary_ghostly


var active_type: Element.Type = Element.Type.NULL:
	set(new):
		active_type = new
		active_type_changed.emit()


func _init(i_type: Element.Type = type, i_active_type: Element.Type = active_type) -> void:
	type = i_type
	active_type = i_active_type


func randomize_type() -> void:
	var new_type: Element.Type = type
	while new_type == type:
		if randf() < 0.1:
			new_type = Element.Type.ANY
		else:
			@warning_ignore("int_as_enum_without_cast")
			new_type = 1 << randi_range(0, 3)
	type = new_type


## returns self and set [member temporary_ghostly] to true.
func temporary_ghosted() -> Token:
	temporary_ghostly = true
	return self
