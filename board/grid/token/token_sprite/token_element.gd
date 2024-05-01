class_name TokenElement
extends TextureRect


const disabled_darknest: float = 0.7


func setup(type: Token.Type, active_types: Token.Type, p_texture: Texture2D) -> TokenElement:
	texture = p_texture
	
	if active_types & type:
		modulate = Token.get_color(type)
	else:
		modulate = Token.get_color(type).darkened(disabled_darknest)
	
	#if active_types & type:
		#modulate = Token.get_color(type)
	#else:
		#modulate = Color(disabled_lightning, disabled_lightning, disabled_lightning)
	
	return self
