extends Node2D

@onready var path = $Path2D
@onready var timer = $Timer
@onready var label_equacao = $CanvasLayer/Label
@export var ball_scene: PackedScene

var bolas = []  # Lista das bolas (nós MathBall)
var game_over = false
var resultado_atual:int = 0
var spawn_delay = 2.0

func _ready():
	randomize()
	timer.timeout.connect(_on_Timer_timeout)
	timer.wait_time = spawn_delay
	timer.start()
	gerar_equacao_baseada_em_bolas()

func _on_Timer_timeout():
	if not game_over:
		spawn_ball()

func spawn_ball():
	var valor = randi_range(1, 10)
	var velocidade = 100
	
	# Criar um PathFollow2D só pra essa bola
	var follow = PathFollow2D.new()
	follow.rotates = false
	path.add_child(follow)
	follow.progress = 0
	
	# Instanciar a bola
	var ball = ball_scene.instantiate()
	
	# Configura a bola usando o método setup
	ball.setup(follow, valor, velocidade)
	
	# Conecta o sinal de destruição COM a nova assinatura
	ball.ball_destroyed.connect(_on_bola_destroyed)
	
	follow.add_child(ball)
	bolas.append(ball)
	
	print("🎱 Bola spawnada:", valor, "| Total bolas:", bolas.size())

func _process(delta):
	# Remove bolas inválidas da lista
	for i in range(bolas.size() - 1, -1, -1):
		if not is_instance_valid(bolas[i]):
			bolas.remove_at(i)
	
	# Ajusta frequência de spawn
	var bolas_count = bolas.size()
	var novo_delay = 2.0
	if bolas_count < 3:
		novo_delay = 1.0
	
	if timer.wait_time != novo_delay:
		timer.wait_time = novo_delay
		timer.start()
	
	# Se não tem equação ou ela não faz sentido, gera outra
	if resultado_atual == 0 or not valor_existe_em_bolas(resultado_atual):
		gerar_equacao_baseada_em_bolas()

func gerar_equacao_baseada_em_bolas():
	var valores_bolas = get_valores_bolas_em_campo()
	
	if valores_bolas.size() == 0:
		label_equacao.text = "Aguardando bolas..."
		resultado_atual = 0
		return
	
	# Filtra apenas valores entre 1 e 20 (para permitir resultados de soma até 20)
	var valores_validos = []
	for valor in valores_bolas:
		if valor >= 1 and valor <= 20:
			valores_validos.append(valor)
	
	if valores_validos.size() == 0:
		label_equacao.text = "Aguardando bolas válidas..."
		resultado_atual = 0
		return
	
	var valor_alvo = valores_validos.pick_random()
	resultado_atual = valor_alvo
	
	var a = 0
	var b = 0
	var operacao = ""
	
	# Garante que ambos os números sejam entre 1 e 10
	if randf() > 0.5 or valor_alvo <= 10:
		# Soma: a + b = valor_alvo (ambos entre 1-10)
		a = randi_range(1, min(10, valor_alvo - 1))
		b = valor_alvo - a
		# Garante que b também esteja entre 1-10
		if b > 10 or b < 1:
			a = randi_range(1, min(10, valor_alvo - 1))
			b = valor_alvo - a
			# Se ainda não der certo, força valores válidos
			if b > 10 or b < 1:
				a = min(10, max(1, valor_alvo - 5))
				b = valor_alvo - a
				a = max(1, min(10, a))
				b = max(1, min(10, b))
		operacao = "+"
	else:
		# Subtração: a - b = valor_alvo (a entre 2-20, b entre 1-10)
		b = randi_range(1, 10)
		a = valor_alvo + b
		# Garante que a não passe de 20
		a = min(20, a)
		operacao = "-"
	
	label_equacao.text = str(a, " ", operacao, " ", b, " = ?")
	print("📐 Equação:", a, operacao, b, "=", valor_alvo)
	print("🎯 Bolas em campo:", valores_bolas)

func get_valores_bolas_em_campo() -> Array:
	var valores = []
	for ball in bolas:
		if is_instance_valid(ball) and ball is MathBall:
			valores.append(ball.ball_value)
	return valores

func valor_existe_em_bolas(valor: int) -> bool:
	for ball in bolas:
		if is_instance_valid(ball) and ball is MathBall and ball.ball_value == valor:
			return true
	return false

func _on_bola_destroyed(value:int, ball_node: MathBall):
	print("💥 Sinal recebido - Bola destruída:", value)
	
	# Remove a bola específica que foi destruída
	for i in range(bolas.size() - 1, -1, -1):
		if bolas[i] == ball_node:
			bolas.remove_at(i)
			print("✅ Bola específica removida!")
			break
	
	print("Bolas restantes:", bolas.size())
	
	if value == resultado_atual:
		print("🎉 Acertou! Valor:", value)
		gerar_equacao_baseada_em_bolas()
	else:
		print("❌ Errou! Valor:", value, "| Esperado:", resultado_atual)
