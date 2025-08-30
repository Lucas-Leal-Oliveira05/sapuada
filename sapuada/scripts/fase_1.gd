extends Node2D

@export var bolas_scene: PackedScene
@onready var path = $Path2D
@onready var timer = $Timer
@onready var label_equacao = $CanvasLayer/Label

var resultado_atual:int
var bolas_em_campo = []
var spawn_delay = 2.0

func _ready():
	randomize()
	timer.wait_time = spawn_delay
	timer.start()
	# Gera a primeira equação
	gerar_equacao_baseada_em_bolas()

func _process(delta):
	# Ajusta a frequência de spawn
	var bolas_count = get_tree().get_nodes_in_group("bolas").size()
	var novo_delay = 2.0
	if bolas_count < 3:
		novo_delay = 1.0
	
	if timer.wait_time != novo_delay:
		timer.wait_time = novo_delay
		timer.start()
	
	# Se não tem equação ou ela não faz sentido, gera outra
	if resultado_atual == 0 or not valor_existe_em_bolas(resultado_atual):
		gerar_equacao_baseada_em_bolas()

func spawn_bola_aleatoria():
	var valor = randi_range(1, 10)
	
	# Criar um PathFollow2D só pra essa bola
	var pathfollow = PathFollow2D.new()
	path.add_child(pathfollow)
	pathfollow.progress = 0.0
	
	# Instanciar a bola
	var bola = bolas_scene.instantiate()
	bola.setup(pathfollow, valor, randf_range(60, 100))
	bola.connect("ball_destroyed", Callable(self, "_on_bola_destroyed"))
	pathfollow.add_child(bola)
	
	bolas_em_campo.append(valor)
	print("🎱 Bola spawnada:", valor, "| Total bolas:", get_tree().get_nodes_in_group("bolas").size())

func gerar_equacao_baseada_em_bolas():
	var valores_bolas = get_valores_bolas_em_campo()
	
	if valores_bolas.size() == 0:
		label_equacao.text = "Aguardando bolas..."
		return
	
	var valor_alvo = valores_bolas.pick_random()
	resultado_atual = valor_alvo
	
	var a = 0
	var b = 0
	var operacao = ""
	
	if randf() > 0.5:
		a = randi_range(1, max(1, valor_alvo - 1))
		b = valor_alvo - a
		operacao = "+"
	else:
		b = randi_range(1, 10)
		a = valor_alvo + b
		operacao = "-"
	
	label_equacao.text = str(a, " ", operacao, " ", b, " = ?")
	print("📐 Equação:", a, operacao, b, "=", valor_alvo)

func get_valores_bolas_em_campo() -> Array:
	var valores = []
	for node in get_tree().get_nodes_in_group("bolas"):
		if node is MathBall and is_instance_valid(node):
			valores.append(node.ball_value)
	return valores

func valor_existe_em_bolas(valor: int) -> bool:
	for node in get_tree().get_nodes_in_group("bolas"):
		if node is MathBall and is_instance_valid(node) and node.ball_value == valor:
			return true
	return false

func _on_timer_timeout():
	spawn_bola_aleatoria()

func _on_bola_destroyed(value:int):
	var index = bolas_em_campo.find(value)
	if index != -1:
		bolas_em_campo.remove_at(index)
	
	print("💥 Bola destruída:", value, "| Restantes:", get_tree().get_nodes_in_group("bolas").size())
	
	if value == resultado_atual:
		print("✅ Acertou! Valor:", value)
		gerar_equacao_baseada_em_bolas()
	else:
		print("❌ Errou! Valor:", value, "| Esperado:", resultado_atual)
