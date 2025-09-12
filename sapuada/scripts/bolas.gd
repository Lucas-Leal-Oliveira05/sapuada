extends Area2D
class_name MathBall

signal ball_destroyed(value: int, ball_node: MathBall)  # usado só para "acerto/erro" ao ser atingida

var ball_value: int = 0
var movement_speed: float = 80.0
var path_follow: PathFollow2D

@onready var label: Label = $numero

func _ready():
	add_to_group("bolas")
	if ball_value != 0:
		label.text = str(ball_value)

func _process(delta):
	if path_follow:
		path_follow.progress += movement_speed * delta
		global_position = path_follow.global_position
		# sem rotação: path_follow.rotates = false já está setado na fase

		# chegou ao fim do caminho → apenas destruir, sem emitir "ball_destroyed"
		if path_follow.progress_ratio >= 1.0:
			_clean_and_free()

func setup(path_follow_node: PathFollow2D, value: int, speed: float):
	path_follow = path_follow_node
	ball_value = value
	movement_speed = speed
	if label:
		label.text = str(ball_value)

# <<< IMPORTANTE: NÃO emitir sinal aqui >>>
func destroy():
	_clean_and_free()

func _clean_and_free():
	if is_instance_valid(path_follow):
		path_follow.queue_free()
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("lingua"):
		# avisa a fase que a bola foi atingida
		ball_destroyed.emit(ball_value, self)
		
		# a língua deve desaparecer sempre, independente se acertou ou não
		area.queue_free()
