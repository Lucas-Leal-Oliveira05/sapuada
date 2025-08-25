extends Node2D

@export var bolas_scene: PackedScene
@onready var path = $Path2D
@onready var timer = $Timer
@onready var label_equacao = $CanvasLayer/Label

var resultado_atual:int

func _ready():
	randomize()
	timer.start()
	gerar_nova_expressao()

func gerar_nova_expressao():
	var a = randi_range(1,10)
	var b = randi_range(1,10)
	resultado_atual = a + b
	label_equacao.text = str(a, " + ", b, " = ?")

	# valores das bolas
	var valores = [resultado_atual]
	while valores.size() < 4:
		var n = randi_range(resultado_atual-5, resultado_atual+5)
		if n != resultado_atual and not valores.has(n):
			valores.append(n)
	valores.shuffle()

	for v in valores:
		spawn_bola(v)

func spawn_bola(valor:int):
	var pathfollow = PathFollow2D.new()
	path.add_child(pathfollow)
	var bola = bolas_scene.instantiate()
	bola.setup(pathfollow, valor, 80)
	bola.connect("ball_destroyed", Callable(self, "_on_bola_destroyed"))
	pathfollow.add_child(bola)

func _on_bola_destroyed(value:int):
	if value == resultado_atual:
		print("Acertou!")
		gerar_nova_expressao()
	else:
		print("Errou!")
