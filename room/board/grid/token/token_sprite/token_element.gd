class_name TokenElement
extends TextureRect


const disabled_darknest: float = 0.7


func setup(type: Element.Type, active_types: Element.Type, p_texture: Texture2D) -> TokenElement:
	texture = p_texture
	
	if active_types & type:
		modulate = Element.get_color(type)
	else:
		modulate = Element.get_color(type).darkened(disabled_darknest)
	
	return self
