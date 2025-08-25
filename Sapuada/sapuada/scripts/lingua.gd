extends Area2D

var distancia = 0

func _physics_process(delta):
	const velocidade = 1000
	const range = 500
	#movimento do projetil
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * velocidade * delta
	
	distancia += velocidade * delta
	
	#faz projetil sumir (substuir por fazer a lingua voltar)
	if distancia > range:
		queue_free()
	
	
