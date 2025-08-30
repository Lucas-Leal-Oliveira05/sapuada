extends Area2D
class_name MathBall

signal ball_destroyed(value: int, ball_node: MathBall)  # Adiciona parâmetro

@export var ball_value: int = 1
@export var movement_speed: float = 80.0

@onready var label = $Label
var path_follow: PathFollow2D

func _ready():
	add_to_group("bolas")
	label.text = str(ball_value)
	path_follow = get_parent() as PathFollow2D
	print("Ball ready! Value: ", ball_value, " | Parent: ", path_follow)

func _process(delta):
	if path_follow:
		path_follow.progress += movement_speed * delta
		
		if path_follow.progress_ratio >= 0.99:
			print("Bola chegou ao final!")
			destroy()

func setup(follow_node: PathFollow2D, value: int, speed: float):
	path_follow = follow_node
	ball_value = value
	movement_speed = speed
	if label:
		label.text = str(ball_value)
	print("Ball setup! Value: ", value, " | Speed: ", speed)

func destroy():
	ball_destroyed.emit(ball_value, self)  # Envia a referência desta bola
	queue_free()
