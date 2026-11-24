## Ciudadano sano (Modelo 4): agente con pánico P ∈ [0, 1]. El pánico sube cerca de infectados y baja cerca de Elena.
## Con P < 0,5 sigue a Elena; con P ≥ 0,5 huye. Si un infectado lo toca, se contagia con probabilidad p_contagio
## por segundo (contagio emergente en la calle, comparable con la β del SIR).
extends CharacterBody2D

const Sprites = preload("res://entidades/sprites.gd")
const Agentes = preload("res://modelos/Ramirez_Camilo_modelo4_agentes.gd")
const VARIANTES := ["citizen_student", "citizen_vendor", "citizen_elder", "citizen_worker"]
const P_CONTAGIO := 0.2
const RADIO_MIEDO := 130.0
const VEL_SEGUIR := 160.0
const VEL_HUIR := 175.0

var nivel
var modelo
var sprite: AnimatedSprite2D
var decision := "sigue a Elena"
var salvado := false
var _t_contagio := 1.0
var _marcador: AnimatedSprite2D
var _mirando := Vector2.DOWN


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 8
	collision_mask = 1
	var caja := RectangleShape2D.new()
	caja.size = Vector2(14, 10)
	var forma := CollisionShape2D.new()
	forma.shape = caja
	forma.position = Vector2(0, -5)
	add_child(forma)
	var variante: String = VARIANTES[randi() % VARIANTES.size()]
	sprite = Sprites.personaje(variante, ["idle", "walk", "panic_run", "cower", "cheer"])
	add_child(sprite)
	Sprites.animar(sprite, "idle", _mirando)
	_marcador = Sprites.tira("res://assets/vfx/markers/marker_follow.png", 4.0, true)
	_marcador.position = Vector2(0, -64)
	_marcador.visible = false
	add_child(_marcador)
	modelo = Agentes.Ciudadano.new(0.3)
	add_to_group("ciudadanos")


func panico() -> float:
	return modelo.p


func _physics_process(delta: float) -> void:
	if salvado or nivel == null or nivel.elena == null:
		return
	var a_elena: Vector2 = nivel.elena.position - position
	var dist := a_elena.length()
	var cerca := 0
	var d_min := 1.0e9
	var amenaza := Vector2.ZERO
	for e in nivel.enemigos_activos():
		var d: float = position.distance_to(e.position)
		if d < RADIO_MIEDO:
			cerca += 1
		if d < d_min:
			d_min = d
			amenaza = e.position
	decision = modelo.actualizar(delta, cerca, dist < RADIO_MIEDO)

	var siguiendo := false
	if decision == "huye":
		if d_min < 230.0:
			velocity = (position - amenaza).normalized() * VEL_HUIR
			_mirando = velocity.normalized()
			Sprites.animar(sprite, "panic_run", _mirando)
		else:
			velocity = Vector2.ZERO
			Sprites.animar(sprite, "cower", _mirando)
	elif dist < 300.0 and dist > 42.0:
		siguiendo = true
		velocity = a_elena / dist * VEL_SEGUIR
		_mirando = velocity.normalized()
		Sprites.animar(sprite, "walk", _mirando)
	else:
		siguiendo = dist <= 42.0
		velocity = Vector2.ZERO
		Sprites.animar(sprite, "idle", _mirando)
	_marcador.visible = siguiendo
	move_and_slide()

	_t_contagio -= delta
	if _t_contagio <= 0.0:
		_t_contagio = 1.0
		if d_min < 32.0 and Juego.gen_lineal.bernoulli(P_CONTAGIO) == 1:
			nivel.contagiar_ciudadano(self)


func celebrar() -> void:
	salvado = true
	velocity = Vector2.ZERO
	_marcador.visible = false
	Sprites.animar(sprite, "cheer", Vector2.DOWN, true)
	var tw := create_tween()
	tw.tween_interval(0.9)
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	tw.tween_callback(queue_free)
