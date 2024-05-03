class_name TokenLine
extends RefCounted


signal scored


var index: Array[int] = []
var type: Token.Type = Token.Type.NULL


func _init(i_index: Array[int] = index, i_type: Token.Type = Token.Type.NULL) -> void:
	index = i_index
	type = i_type


func _to_string() -> String:
	return "TokenLine(%s)[%s]" % [Token.Type.find_key(type), index]
