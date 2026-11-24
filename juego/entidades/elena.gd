## Dra. Elena Ruiz: movimiento cenital (CharacterBody2D flotante), sigilo y ruido, y las cuatro armas.
## El daño de cada ataque lo decide el Modelo 3 (Monte Carlo) a través de nivel.golpear().
extends CharacterBody2D

const Sprites = preload("res://entidades/sprites.gd")
const Dardo = preload("res://entidades/dardo.gd")
const VEL_CAMINAR := 180.0   # 3,0 px por cuadro a 60 Hz (GDD §3.1)
const VEL_CORRER := 270.0
const VEL_AGACHADA := 90.0   # 1,5 px por cuadro
const RUIDO_CAMINAR := 30.0
const RUIDO_CORRER := 70.0
const RUIDO_AGACHADA := 10.0
const RUIDO_COMBATE := 90.0
const ANIMS := ["idle", "walk", "run", "crouch", "hurt", "death", "attack_pipe", "attack_syringe", "attack_dart",
	"attack_extinguisher", "carry_walk", "interact", "use_item", "cheer"]

var nivel
var sprite: AnimatedSprite2D
var camara: Camera2D
var mirando := Vector2.DOWN
var ruido := 0.0
var agachada := false
var cargando = null     # infectado sedado que lleva a cuestas
var muerta := false
var trauma := 0.0       # sacudida de cámara (0..1), decae sola
var _t_ataque := 0.0
var _t_anim := 0.0
var _t_combate := 0.0
var _t_invulnerable := 0.0
var _t_sacudida := 0.0


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING  # vista cenital: sin gravedad ni suelo
	collision_layer = 2
	collision_mask = 1
	var caja := RectangleShape2D.new()
	caja.size = Vector2(14, 10)
	var forma := CollisionShape2D.new()
	forma.shape = caja
	forma.position = Vector2(0, -5)
	add_child(forma)
	sprite = Sprites.personaje("elena", ANIMS)
	add_child(sprite)
	Sprites.animar(sprite, "idle", mirando)
	camara = Camera2D.new()
	camara.position_smoothing_enabled = true
	camara.position_smoothing_speed = 8.0
	add_child(camara)
	add_to_group("jugador")


func _physics_process(delta: float) -> void:
	if muerta:
		return
	_t_ataque = maxf(0.0, _t_ataque - delta)
	_t_anim = maxf(0.0, _t_anim - delta)
	_t_combate = maxf(0.0, _t_combate - delta)
	_t_invulnerable = maxf(0.0, _t_invulnerable - delta)

	var dir := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	agachada = Input.is_action_pressed("agacharse")
	var corre := Input.is_action_pressed("correr") and not agachada and cargando == null
	var vel := VEL_AGACHADA if agachada else (VEL_CORRER if corre else VEL_CAMINAR)
	if cargando != null:
		vel *= 0.7
	if Juego.t_adrenalina > 0.0:
		vel *= 1.3
	velocity = dir * vel
	move_and_slide()

	var moviendo := dir.length() > 0.1
	if moviendo and _t_anim <= 0.0:
		mirando = dir
	if _t_combate > 0.0:
		ruido = RUIDO_COMBATE
	elif not moviendo:
		ruido = 0.0
	elif agachada:
		ruido = RUIDO_AGACHADA
	else:
		ruido = RUIDO_CORRER if corre else RUIDO_CAMINAR

	if Input.is_action_pressed("atacar") and _t_ataque <= 0.0 and cargando == null:
		_atacar()
	if Input.is_action_just_pressed("interactuar"):
		nivel.interactuar()

	if _t_anim <= 0.0:
		sprite.speed_scale = 1.0
		if cargando != null:
			Sprites.animar(sprite, "carry_walk", mirando)
			sprite.speed_scale = 1.0 if moviendo else 0.0
		elif agachada:
			Sprites.animar(sprite, "crouch", mirando)
		elif moviendo:
			Sprites.animar(sprite, "run" if corre else "walk", mirando)
		else:
			Sprites.animar(sprite, "idle", mirando)


func _process(delta: float) -> void:
	# Sacudida por "trauma": mueve el desplazamiento de la cámara, nunca el cuerpo.
	if trauma > 0.0:
		trauma = maxf(0.0, trauma - 1.5 * delta)
		_t_sacudida += delta * 30.0
		var s := trauma * trauma
		camara.offset = Vector2(10.0 * s * sin(_t_sacudida * 1.7), 7.0 * s * sin(_t_sacudida * 2.3))
	else:
		camara.offset = Vector2.ZERO


func sacudir(cantidad: float) -> void:
	trauma = clampf(trauma + cantidad, 0.0, 1.0)


func _atacar() -> void:
	var arma: String = Juego.arma
	var apunta: Vector2 = get_global_mouse_position() - global_position
	if apunta.length() < 4.0:
		apunta = mirando
	apunta = apunta.normalized()
	var info: Dictionary = Juego.ARMAS_INFO[arma]
	match arma:
		"tubo":
			_cuerpo_a_cuerpo(apunta, 48.0, 0.5, 3, "tubo")
			_animar_ataque("attack_pipe", apunta, 0.35)
		"extintor":
			if Juego.cargas_extintor <= 0:
				_sin_municion()
				return
			Juego.cargas_extintor -= 1
			Juego.sonido("extintor")
			var chorro: AnimatedSprite2D = Sprites.tira("res://assets/vfx/extinguisher_spray.png", 12.0)
			chorro.position = position + apunta * 56.0 + Vector2(0, -16)
			chorro.rotation = apunta.angle()
			chorro.z_index = 2
			nivel.capa.add_child(chorro)
			for e in nivel.enemigos_activos():
				var v: Vector2 = e.position - position
				# cono de 90° y 3 casillas: empuja 2 casillas y aturde 1,5 s (GDD §5.2)
				if v.length() < 100.0 and apunta.dot(v.normalized()) > 0.707:
					nivel.golpear(e, "extintor", position)
					e.empujar(apunta * 240.0, 1.5)
			_animar_ataque("attack_extinguisher", apunta, 0.4)
		"dardos":
			if Juego.dardos <= 0:
				_sin_municion()
				return
			Juego.dardos -= 1
			Juego.sonido("dardo")
			var dardo := Dardo.new()
			dardo.nivel = nivel
			dardo.dir = apunta
			dardo.origen = position
			dardo.position = position + Vector2(0, -16) + apunta * 12.0
			nivel.capa.add_child(dardo)
			_animar_ataque("attack_dart", apunta, 0.4)
		"jeringa":
			if Juego.jeringas <= 0:
				_sin_municion()
				return
			# un solo uso: solo se gasta si acierta
			if _cuerpo_a_cuerpo(apunta, 38.0, 0.35, 1, "jeringa") > 0:
				Juego.jeringas -= 1
			_animar_ataque("attack_syringe", apunta, 0.35)
	_t_ataque = info["cadencia"]
	_t_combate = 0.6
	mirando = apunta


## Golpea hasta `maximo` infectados dentro del alcance y del arco (coseno mínimo). Devuelve cuántos golpeó.
func _cuerpo_a_cuerpo(apunta: Vector2, alcance: float, coseno: float, maximo: int, arma: String) -> int:
	var golpeados := 0
	for e in nivel.enemigos_activos():
		var v: Vector2 = e.position - position
		var d := v.length()
		if d < alcance and (d < 14.0 or apunta.dot(v / d) > coseno):
			nivel.golpear(e, arma, position)
			golpeados += 1
			if golpeados >= maximo:
				break
	if golpeados == 0 and arma == "tubo":
		Juego.sonido("vacio")
	return golpeados


func _animar_ataque(anim: String, apunta: Vector2, duracion: float) -> void:
	sprite.speed_scale = 1.0
	Sprites.animar(sprite, anim, apunta, true)
	_t_anim = duracion


func _sin_municion() -> void:
	Juego.sonido("vacio")
	nivel.aviso("Sin munición: cambia de arma (Q)")
	_t_ataque = 0.3


## Daño de un infectado. La carga viral se reduce a la mitad con cubrebocas (GDD §5.4).
func recibir(dano: float, carga: float, _desde: Vector2) -> void:
	if muerta or _t_invulnerable > 0.0:
		return
	_t_invulnerable = 0.6
	Juego.hp -= dano
	sumar_viral(carga)
	Juego.sonido("dano")
	sacudir(0.35)
	nivel.al_herir(dano)
	sprite.modulate = Color(1.0, 0.35, 0.3)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	if cargando != null:
		soltar()


func sumar_viral(carga: float) -> void:
	Juego.viral = clampf(Juego.viral + carga * (0.5 if Juego.t_mascara > 0.0 else 1.0), 0.0, 100.0)


func cargar(enemigo) -> void:
	cargando = enemigo
	enemigo.cargar()


func soltar() -> void:
	if cargando != null and is_instance_valid(cargando):
		cargando.soltar(position + Vector2(0, 6))
	cargando = null


func morir(causa: String) -> void:
	if muerta:
		return
	muerta = true
	velocity = Vector2.ZERO
	soltar()
	sprite.speed_scale = 1.0
	Sprites.animar(sprite, "death", mirando, true)
	await get_tree().create_timer(1.4).timeout
	Juego.derrota(causa)


func celebrar() -> void:
	muerta = true  # deja de aceptar controles
	velocity = Vector2.ZERO
	sprite.speed_scale = 1.0
	Sprites.animar(sprite, "cheer", Vector2.DOWN, true)
