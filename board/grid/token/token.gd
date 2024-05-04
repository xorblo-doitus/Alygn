class_name Token
extends RefCounted


signal type_changed
signal ghostly_changed
signal active_type_changed


enum Type {
	## Not an ingame type, used as null for static typing.
	NULL,
	PLANT,
	WATER = 1 << 1,
	FIRE = 1 << 2,
	HEAL = 1 << 3,
	ANY = (1 << MAX_TYPE_INDEX) - 1,
}
const MAX_TYPE_INDEX: int = 4


var type: Type = Type.NULL:
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


var active_type: Type = Type.NULL:
	set(new):
		active_type = new
		active_type_changed.emit()


func _init(i_type: Type = type, i_active_type: Type = active_type) -> void:
	type = i_type
	active_type = i_active_type


func randomize_type() -> void:
	var new_type: Type = type
	while new_type == type:
		if randf() < 0.1:
			new_type = Type.ANY
		else:
			@warning_ignore("int_as_enum_without_cast")
			new_type = 1 << randi_range(0, 3)
	type = new_type


static func get_color(for_type: Type) -> Color:
	match for_type:
		Type.PLANT:
			return Color.GREEN
		Type.WATER:
			return Color.BLUE
		Type.FIRE:
			return Color.RED
		Type.HEAL:
			return Color(1, 0.5, 0.5)
		Type.ANY:
			return Color(2, 2, 2)
	
	var result: Color = Color.BLACK
	
	if for_type & Type.PLANT:
		result += Color(0, 1, 0, 0)
	if for_type & Type.WATER:
		result += Color(0, 0, 1, 0)
	if for_type & Type.FIRE:
		result += Color(1, 0, 0, 0)
	if for_type & Type.HEAL:
		result += Color(1, 0.5, 0.5, 0)
	
	return result


## returns self and set [member temporary_ghostly] to true.
func temporary_ghosted() -> Token:
	temporary_ghostly = true
	return self
