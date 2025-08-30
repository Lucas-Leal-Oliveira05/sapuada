extends Node2D

func _process(delta):
	# Faz o sapo olhar para o mouse
	look_at(get_global_mouse_position())
	
func linguada():
	const lingua = preload("res://scenes/lingua.tscn")
	var new_lingua = lingua.instantiate()
	new_lingua.global_position = %boca.global_position
	new_lingua.global_rotation = %boca.global_rotation
	%boca.add_child(new_lingua)
	
func _input(event):
	#clique do mouse faz dar linguada
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		linguada()
