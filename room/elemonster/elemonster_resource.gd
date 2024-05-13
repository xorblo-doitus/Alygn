@tool
class_name ElemonsterResource
extends Resource


var type: Element.Type


@export_group("sprite")
@export var sprite_texture: Texture2D = preload("uid://b4pa5shn6ohxp") #"res://room/elemonster/sprites/bush.png"

@export_group("shadow")
@export var shadow_color: Color = Color.BLACK
@export var shadow_size: Vector2 = Vector2(1, 0.4)
@export var shadow_texture: Texture2D = preload("uid://s8c1te6lnxg") #"res://room/elemonster/shadows/circle.svg"

@export_group("")

var debounce: bool = false
func _get_property_list() -> Array[Dictionary]:
	print("a")
	return [
		{
			"class_name": "ElemonsterResource", 
			"hint": PROPERTY_HINT_FLAGS, 
			"hint_string": "Plant,Water,Fire", 
			"name": "type", 
			"type": TYPE_INT, 
			"usage": PROPERTY_USAGE_DEFAULT
		},
	]
