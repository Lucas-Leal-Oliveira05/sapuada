extends Area2D
class_name MathBall

signal ball_destroyed(value: int)

@export var ball_value: int = 1
@export var movement_speed: float = 80.0
var path_follow: PathFollow2D

#⭐⭐ MUDANÇA AQUI: Verificação de null ⭐⭐
@onready var label = $Label

func _ready():
	if label:
		label.text = str(ball_value)
	else:
		print("ERRO: Label não encontrado! Filhos: ", get_children())

	add_to_group("bolas")

func _process(delta):
	if path_follow:
		path_follow.progress += movement_speed * delta
		global_position = path_follow.global_position
		global_rotation = path_follow.global_rotation

		if path_follow.progress_ratio >= 1.0:
			destroy()

func setup(path_follow_node: PathFollow2D, value: int, speed: float):
	path_follow = path_follow_node
	ball_value = value
	movement_speed = speed
	if label:  # ⬅️ Verificação aqui também
		label.text = str(ball_value)

func destroy():
	ball_destroyed.emit(ball_value)
	queue_free()
