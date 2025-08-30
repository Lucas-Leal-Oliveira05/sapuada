extends Control
func _ready():
	$VBoxContainer/StartButton.grab_focus()
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/fase_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
