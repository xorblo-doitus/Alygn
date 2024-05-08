class_name Element
extends Object


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
