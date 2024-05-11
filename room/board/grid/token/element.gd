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
const MAX_TYPE_WITH_ADVANTAGE_INDEX: int = MAX_TYPE_INDEX - 1


static var advantages: Array[PackedFloat64Array] = []


static func _static_init() -> void:
	var file := FileAccess.open("res://room/board/grid/token/elements.csv", FileAccess.READ)
	file.get_csv_line()
	
	for __ in MAX_TYPE_WITH_ADVANTAGE_INDEX:
		var line := file.get_csv_line()
		var advantages_line: PackedFloat64Array = PackedFloat64Array()
		advantages_line.resize(MAX_TYPE_WITH_ADVANTAGE_INDEX)
		
		for i_column in MAX_TYPE_WITH_ADVANTAGE_INDEX:
			advantages_line[i_column] = 1 + float(line[i_column + 1])
		
		advantages.push_back(advantages_line)


static func get_avantage(of: Type, on: Type) -> float:
	var result = 1
	
	for of_type in MAX_TYPE_WITH_ADVANTAGE_INDEX:
		if (1 << of_type) & of:
			for on_type in MAX_TYPE_WITH_ADVANTAGE_INDEX:
				if (1 << on_type) & on:
					result *= advantages[of_type][on_type]
	
	return result


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
