extends Area2D

@export var velocidade := 1000
var direcao := Vector2.ZERO

func _ready():
	# faz a língua andar para frente na direção inicial
	direcao = Vector2.RIGHT.rotated(rotation)

func _process(delta):
	position += direcao * velocidade * delta
	
	if position.length() > 2000:
		queue_free()

func _on_area_entered(area: Area2D):
	if area is MathBall:
		# só dispara o sinal se for bola
		area.verificar_acerto()  # método no MathBall que decide se some ou não
		# depois de encostar em qualquer bola → some
		queue_free()

func _on_body_entered(body: Node):
	# caso colida com algo sólido, também some
	queue_free()
