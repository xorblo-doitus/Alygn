class_name TokenElement
extends TextureRect


const DISABLED_DARKNEST: float = 0.7
static var SPECIAL_DISABLED_COLOR = {
	Element.Type.HEAL: Element.get_color(Element.Type.HEAL).darkened(DISABLED_DARKNEST * 0.8)
}


func setup(type: Element.Type, active_types: Element.Type, p_texture: Texture2D) -> TokenElement:
	texture = p_texture
	
	if active_types & type:
		modulate = Element.get_color(type)
	else:
		if type in SPECIAL_DISABLED_COLOR:
			modulate = SPECIAL_DISABLED_COLOR[type]
		else:
			modulate = Element.get_color(type).darkened(DISABLED_DARKNEST)
	
	return self
