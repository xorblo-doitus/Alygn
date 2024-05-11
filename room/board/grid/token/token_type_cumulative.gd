class_name TokenTypeCumulative
extends RefCounted


## Warning: _fields = [1, 0, 1, 1] -> 0b1101
var _fields: Array[int] = []


func _init() -> void:
	_fields.resize(Element.MAX_TYPE_INDEX + 1)


## masked += mask
func add(type: Element.Type) -> void:
	var index: int = 0
	while type:
		_fields[index] += type%2
		index += 1
		@warning_ignore("int_as_enum_without_cast")
		type >>= 1


## masked -= mask
func remove(type: Element.Type) -> void:
	var index: int = 0
	while type:
		_fields[index] -= type%2
		index += 1
		@warning_ignore("int_as_enum_without_cast")
		type >>= 1


## masked -= masked & mask
func remove_if_enabled(type: Element.Type) -> void:
	var index: int = 0
	while type:
		_fields[index] = max(0, _fields[index] - type%2)
		index += 1
		@warning_ignore("int_as_enum_without_cast")
		type >>= 1


func get_type() -> Element.Type:
	@warning_ignore("int_as_enum_without_cast")
	var type: Element.Type = 0
	for index in _fields.size():
		if _fields[index]:
			@warning_ignore("int_as_enum_without_cast")
			type += 1 << index
	return type


func _to_string() -> String:
	return "0inf" + "|".join(_fields)
