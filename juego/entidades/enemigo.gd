## Infectado. Un solo script para los cinco tipos; el tipo decide qué modelo lo mueve:
##   Errante, Tosedor ... caminata aleatoria 2D sesgada por el ruido (Modelo 1)
##   Corredor ........... máquina de estados del Modelo 4 (PATRULLA → ALERTA → PERSECUCIÓN → BÚSQUEDA)
##   Masa ............... individuo de un enjambre boids (Modelo 4); el rumbo lo fija entidades/masa.gd
##   Paciente Cero ...... fases elegidas por una cadena de Markov
## Además, cada Errante/Tosedor puede empeorar con la cadena de Markov Errante → Tosedor → Corredor.
extends CharacterBody2D

const Sprites = preload("res://entidades/sprites.gd")
const Caminata = preload("res://modelos/Cruz_Castiblanco_modelo1_caminatas.gd")
const Agentes = preload("res://modelos/Ramirez_Camilo_modelo4_agentes.gd")
const Markov = preload("res://modelos/Ruiz_Sergio_markov.gd")

const CELDA := 32.0
const RADIO_AUDICION := 10.0   # casillas (r_a del Modelo 1)
const MINUTO_MARKOV := 20.0    # s reales por "minuto" de la cadena (ajuste: 60 s no se alcanza a ver en una partida)
const T_SEDADO := 60.0
const DURACION_FASE := [3.0, 1.1, 2.4, 1.6]  # Deambular, Embestida, Toser, Llamar a la Masa
## vel en px/s (GDD: px por cuadro × 60); dano y viral según GDD §5.4
const DATOS := {
	"Errante": {"hp": 30.0, "vel": 72.0, "dano": 8.0, "viral": 5.0, "pausa_golpe": 1.2, "alcance": 26.0,
		"carpetas": ["errante", "errante_b"], "anims": ["idle", "walk", "attack", "fall"], "mover": "walk", "quieto": "idle"},
	"Tosedor": {"hp": 20.0, "vel": 60.0, "dano": 0.0, "viral": 0.0, "pausa_golpe": 1.0, "alcance": 0.0,
		"carpetas": ["tosedor"], "anims": ["idle", "walk", "cough", "fall"], "mover": "walk", "quieto": "idle"},
	"Corredor": {"hp": 50.0, "vel": 210.0, "dano": 15.0, "viral": 8.0, "pausa_golpe": 0.9, "alcance": 28.0,
		"carpetas": ["corredor"], "anims": ["idle", "walk", "patrol", "alert", "chase", "attack", "fall"],
		"mover": "patrol", "quieto": "idle"},
	"Masa": {"hp": 15.0, "vel": 120.0, "dano": 5.0, "viral": 3.0, "pausa_golpe": 1.0, "alcance": 24.0,
		"carpetas": ["masa_a", "masa_b", "masa_c"], "anims": ["walk", "attack", "fall"], "mover": "walk", "quieto": "walk"},
	"Paciente Cero": {"hp": 400.0, "vel": 70.0, "dano": 20.0, "viral": 10.0, "pausa_golpe": 1.0, "alcance": 36.0,
		"carpetas": ["paciente_cero"], "anims": ["wander", "charge", "cough", "summon", "stun", "attack", "fall"],
		"mover": "wander", "quieto": "wander"},
}

var nivel
var tipo := "Errante"
var agitacion := 30.0
var agitacion_max := 30.0
var vida := "activo"            # activo, sedado, cargado
var mirando := Vector2.DOWN
var rumbo := Vector2.ZERO       # Masa: velocidad deseada que dicta el enjambre
var masa = null
var oleada := false             # nivel 2: la caminata se sesga hacia la puerta del hospital
var objetivo_oleada := Vector2.ZERO
var jefe_activo := false
var fase := 0                   # Paciente Cero: índice en Markov.FASES
var fsm = null                  # Corredor
var sprite: AnimatedSprite2D
var velocidad := 72.0
var huyendo := false

var _marcador: AnimatedSprite2D = null
var _marca := ""
var _anim_mover := "walk"
var _anim_quieto := "idle"
var _destino := Vector2.ZERO    # caminata: centro de la casilla a la que va
var _t_paso := 0.0
var _t_tos := 3.0
var _t_golpe := 0.0
var _t_anim := 0.0
var _t_aturdido := 0.0
var _empuje := Vector2.ZERO
var _t_sedado := 0.0
var _t_alerta := 0.0
var _sesgo := 0.0
var _t_markov := 0.0
var _t_vista := 0.0
var _ve := false
var _ultimo_estimulo := Vector2.ZERO
var _t_atasco := 0.0
var _t_desvio := 0.0
var _desvio := Vector2.ZERO
var _t_fase := 1.5
var _dir_embestida := Vector2.ZERO
var _t_huir := 4.0
var _t_accion := 0.0


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 4
	collision_mask = 1   # solo choca con el escenario: los personajes no se bloquean entre sí
	var caja := RectangleShape2D.new()
	caja.size = Vector2(14, 10)
	var forma := CollisionShape2D.new()
	forma.shape = caja
	forma.position = Vector2(0, -5)
	add_child(forma)
	add_to_group("enemigos")
	_destino = position
	_ultimo_estimulo = position
	_t_markov = randf() * MINUTO_MARKOV
	_t_tos = 2.0 + randf() * 3.0
	_vestir()
	agitacion = agitacion_max


## Carga las hojas y los parámetros del tipo actual (también al mutar con la cadena de Markov).
func _vestir() -> void:
	var d: Dictionary = DATOS[tipo]
	var carpetas: Array = d["carpetas"]
	var carpeta: String = carpetas[randi() % carpetas.size()]
	if sprite != null:
		sprite.queue_free()
	sprite = Sprites.personaje(carpeta, d["anims"])
	add_child(sprite)
	_anim_mover = d["mover"]
	_anim_quieto = d["quieto"]
	velocidad = d["vel"]
	agitacion_max = d["hp"]
	fsm = Agentes.Corredor.new() if tipo == "Corredor" else null
	Sprites.animar(sprite, _anim_quieto, mirando)
	queue_redraw()


func activo() -> bool:
	return vida == "activo"


## ¿Ha detectado a Elena? Un ataque por la espalda a un infectado que no la detecta tiene +0,25 de crítico.
func detecta() -> bool:
	if _t_alerta > 0.0:
		return true
	match tipo:
		"Corredor":
			return fsm.estado == "PERSECUCION"
		"Masa":
			return masa != null and is_instance_valid(masa) and masa.persigue
		"Paciente Cero":
			return jefe_activo
	return _sesgo > 0.1


## El atacante está detrás si el infectado mira en el mismo sentido en que llega el golpe.
func de_espaldas(desde: Vector2) -> bool:
	return mirando.dot((position - desde).normalized()) > 0.3


func _physics_process(delta: float) -> void:
	if nivel == null or nivel.elena == null:
		return
	if vida == "sedado":
		_t_sedado -= delta
		if _t_sedado <= 0.0:
			_despertar()
		return
	if vida == "cargado":
		return
	_t_golpe = maxf(0.0, _t_golpe - delta)
	_t_anim = maxf(0.0, _t_anim - delta)
	_t_alerta = maxf(0.0, _t_alerta - delta)
	if _t_aturdido > 0.0:
		_t_aturdido -= delta
		velocity = _empuje
		_empuje = _empuje.move_toward(Vector2.ZERO, 400.0 * delta)
		move_and_slide()
		_destino = position
		return
	if huyendo:
		_huir(delta)
		return

	var elena: CharacterBody2D = nivel.elena
	var a_elena: Vector2 = elena.position - position
	var dist := a_elena.length()
	match tipo:
		"Errante":
			_caminar(delta, elena, false)
		"Tosedor":
			_caminar(delta, elena, false)
			_toser(delta, dist)
		"Corredor":
			_ia_corredor(delta, elena, a_elena, dist)
		"Masa":
			_ia_masa()
		"Paciente Cero":
			_ia_jefe(delta, elena, a_elena, dist)
	_morder(elena, a_elena, dist)
	_progresar(delta)


# ------------------------------------------------------------------------------------- Modelo 1: caminata sesgada

## Un paso de casilla cada vez que llega a su destino. La dirección sale del Modelo 1 con el generador lineal:
## p = 0,25 por dirección, y la dirección hacia la fuente de ruido recibe p + b (las demás p − b/3).
func _caminar(delta: float, elena: CharacterBody2D, sin_sesgo: bool) -> void:
	if position.distance_to(_destino) > 1.0:
		var hacia := _destino - position
		position = position.move_toward(_destino, velocidad * delta)
		mirando = hacia.normalized()
		if _t_anim <= 0.0:
			Sprites.animar(sprite, _anim_mover, mirando)
		return
	_t_paso -= delta
	if _t_paso > 0.0:
		if _t_anim <= 0.0:
			Sprites.animar(sprite, _anim_quieto, mirando)
		return
	_t_paso = 0.08
	var fuente_px: Vector2 = objetivo_oleada if oleada else elena.position
	var b := 0.0
	if oleada:
		b = Caminata.sesgo_por_ruido(100.0, 0.0, RADIO_AUDICION)
	elif not sin_sesgo:
		b = Caminata.sesgo_por_ruido(elena.ruido, position.distance_to(fuente_px) / CELDA, RADIO_AUDICION)
	_sesgo = 0.0 if oleada else b
	# el modelo usa +y hacia el norte; en pantalla +y baja
	var celda := Vector2i(floori(position.x / CELDA), -floori(position.y / CELDA))
	var fuente := Vector2i(floori(fuente_px.x / CELDA), -floori(fuente_px.y / CELDA))
	var probs: Dictionary = Caminata.probabilidades_con_sesgo(celda, fuente, b)
	var d: String = Juego.caminata.direccion(probs)
	var paso: Vector2 = Vector2(Caminata.DIRECCIONES[d]) * Vector2(CELDA, -CELDA)
	Juego.stats["pasos"][d] += 1
	Juego.stats["sesgo_ultimo"] = b
	if b > 0.0:
		Juego.stats["pasos_sesgados"] += 1
		if probs[d] > 0.25:
			Juego.stats["pasos_hacia_fuente"] += 1
	if not test_move(global_transform, paso):  # si la casilla es un obstáculo, el paso se deshace
		_destino = position + paso


func _toser(delta: float, dist: float) -> void:
	_t_tos -= delta
	if _t_tos > 0.0:
		return
	_t_tos = 5.0
	_t_anim = 0.5
	Sprites.animar(sprite, "cough", mirando, true)
	nivel.crear_nube(position + Vector2(0, -10))
	if dist < 420.0:
		Juego.sonido("tos")


# ------------------------------------------------------------------------------------ Modelo 4: Corredor (FSM)

func _ia_corredor(delta: float, elena: CharacterBody2D, a_elena: Vector2, dist: float) -> void:
	var ruido_percibido: float = elena.ruido * maxf(0.0, 1.0 - dist / 384.0)
	_t_vista -= delta
	if _t_vista <= 0.0:
		_t_vista = 0.15
		_ve = _puede_ver(elena, a_elena, dist)
	if _ve or ruido_percibido > Agentes.Corredor.UMBRAL_RUIDO:
		_ultimo_estimulo = elena.position
	if fsm.actualizar(delta, ruido_percibido, _ve):
		_al_cambiar_estado()
	match fsm.estado:
		"PATRULLA":
			_caminar(delta, elena, true)
		"ALERTA":
			_ir_hacia(_ultimo_estimulo, 110.0, "walk", delta)
		"PERSECUCION":
			_ir_hacia(elena.position, velocidad, "chase", delta)
		"BUSQUEDA":
			_ir_hacia(_ultimo_estimulo, 130.0, "walk", delta)


func _puede_ver(elena: CharacterBody2D, a_elena: Vector2, dist: float) -> bool:
	if dist > 260.0:
		return false
	if elena.agachada and dist > 120.0:
		return false  # agachada se la ve desde mucho más cerca
	if dist > 60.0 and mirando.dot(a_elena / dist) < 0.3:
		return false  # fuera del cono de visión
	return nivel.linea_de_vista(position + Vector2(0, -6), elena.position + Vector2(0, -6))


func _al_cambiar_estado() -> void:
	var estado: String = fsm.estado
	_destino = position
	match estado:
		"ALERTA":
			_marcar("alert")
		"PERSECUCION":
			_marcar("chase")
			Juego.sonido("grunido")
		"BUSQUEDA":
			_marcar("search")
		_:
			_marcar("")
	Juego.registrar("M4 Agentes", "Corredor -> %s" % estado)


## Dirección directa con desvío lateral si se queda atascado contra un obstáculo.
func _ir_hacia(objetivo: Vector2, vel: float, anim: String, delta: float) -> void:
	var v := objetivo - position
	if v.length() < 10.0:
		velocity = Vector2.ZERO
		if _t_anim <= 0.0:
			Sprites.animar(sprite, _anim_quieto, mirando)
		return
	var dir := v.normalized()
	if _t_desvio > 0.0:
		_t_desvio -= delta
		dir = (dir + _desvio).normalized()
	velocity = dir * vel
	move_and_slide()
	if get_real_velocity().length() < vel * 0.25:
		_t_atasco += delta
		if _t_atasco > 0.35:
			_t_atasco = 0.0
			_t_desvio = 0.7
			_desvio = dir.orthogonal() * (1.5 if randf() < 0.5 else -1.5)
	else:
		_t_atasco = 0.0
	mirando = dir
	if _t_anim <= 0.0:
		Sprites.animar(sprite, anim, dir)


# --------------------------------------------------------------------------------------- Modelo 4: Masa (boids)

func _ia_masa() -> void:
	velocity = rumbo
	move_and_slide()
	if rumbo.length() > 1.0:
		mirando = rumbo.normalized()
	if _t_anim <= 0.0:
		Sprites.animar(sprite, "walk", mirando)


## La masa se dispersó: este individuo escapa de Elena y desaparece.
func huir() -> void:
	huyendo = true
	_marcar("")


func _huir(delta: float) -> void:
	var lejos: Vector2 = position - nivel.elena.position
	velocity = lejos.normalized() * 160.0
	move_and_slide()
	mirando = velocity.normalized()
	Sprites.animar(sprite, _anim_mover, mirando)
	_t_huir -= delta
	modulate.a = clampf(_t_huir / 2.0, 0.0, 1.0)
	if _t_huir <= 0.0:
		queue_free()


# -------------------------------------------------------------------------- Paciente Cero: fases por Markov

func _ia_jefe(delta: float, elena: CharacterBody2D, a_elena: Vector2, dist: float) -> void:
	if not jefe_activo:
		Sprites.animar(sprite, "wander", Vector2.DOWN)
		sprite.speed_scale = 0.0
		return
	sprite.speed_scale = 1.0
	_t_fase -= delta
	if _t_fase <= 0.0:
		_cambiar_fase(a_elena, dist)
	match fase:
		0:  # Deambular: acecha despacio
			_ir_hacia(elena.position, velocidad, "wander", delta)
		1:  # Embestida: carga en línea recta
			velocity = _dir_embestida * 300.0
			move_and_slide()
			mirando = _dir_embestida
			Sprites.animar(sprite, "charge", mirando)
			if get_slide_collision_count() > 0:  # choca con un muro: queda aturdido
				empujar(-_dir_embestida * 60.0, 1.2)
				Sprites.animar(sprite, "stun", mirando, true)
				nivel.elena.sacudir(0.3)
				_t_fase = 0.0
		2:  # Toser: suelta nubes
			velocity = Vector2.ZERO
			_t_accion -= delta
			if _t_accion <= 0.0:
				_t_accion = 0.8
				nivel.crear_nube(position + Vector2(randf_range(-40.0, 40.0), randf_range(-30.0, 30.0)))
				Juego.sonido("tos")
		3:  # Llamar a la Masa
			velocity = Vector2.ZERO


func _cambiar_fase(a_elena: Vector2, dist: float) -> void:
	fase = Markov.paso(Juego.gen_lineal, Markov.P_JEFE, fase)
	_t_fase = DURACION_FASE[fase]
	Juego.stats["fases_jefe"][fase] += 1
	Juego.stats["fase_jefe"] = fase
	Juego.registrar("Markov", "Paciente Cero -> %s" % Markov.FASES[fase])
	match fase:
		1:
			_dir_embestida = a_elena / dist if dist > 1.0 else Vector2.DOWN
			Juego.sonido("grunido")
		2:
			_t_accion = 0.0
			Sprites.animar(sprite, "cough", mirando, true)
		3:
			Sprites.animar(sprite, "summon", mirando, true)
			nivel.invocar_masa(position, 4)
			Juego.sonido("alarma")


# --------------------------------------------------------------------------------------------------- combate

func _morder(elena: CharacterBody2D, a_elena: Vector2, dist: float) -> void:
	var d: Dictionary = DATOS[tipo]
	var dano: float = d["dano"]
	var alcance: float = d["alcance"]
	if dano <= 0.0 or _t_golpe > 0.0 or dist > alcance:
		return
	_t_golpe = d["pausa_golpe"]
	_t_anim = 0.4
	Sprites.animar(sprite, "attack", a_elena, true)
	elena.recibir(dano, d["viral"], position)


func recibir(dano: float, critico: bool, desde: Vector2) -> void:
	if vida != "activo":
		return
	agitacion -= dano
	_t_alerta = 4.0
	_ultimo_estimulo = desde
	if tipo != "Paciente Cero":
		_empuje = (position - desde).normalized() * (150.0 if critico else 80.0)
		_t_aturdido = maxf(_t_aturdido, 0.12)
	sprite.modulate = Color(1.0, 0.45, 0.4)  # destello de impacto
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	queue_redraw()
	if agitacion <= 0.0:
		sedar()


func empujar(vel: Vector2, aturdir: float) -> void:
	if vida != "activo":
		return
	_empuje = vel
	_t_aturdido = maxf(_t_aturdido, aturdir)


func sedar() -> void:
	vida = "sedado"
	_t_sedado = T_SEDADO
	agitacion = 0.0
	velocity = Vector2.ZERO
	huyendo = false
	sprite.speed_scale = 1.0
	Sprites.animar(sprite, "fall", mirando, true)
	_marcar("sleep")
	queue_redraw()
	Juego.stats["sedados"] += 1
	Juego.sonido("sedado")
	nivel.al_sedar(self)


## Si nadie lo carga, despierta con la mitad de agitación y más probabilidad de empeorar (GDD §5.1).
func _despertar() -> void:
	if tipo == "Paciente Cero":
		_t_sedado = T_SEDADO
		return
	vida = "activo"
	_marcar("")
	_destino = position
	_avanzar_markov()
	_avanzar_markov()
	agitacion = agitacion_max * 0.5
	Sprites.animar(sprite, _anim_quieto, mirando)
	queue_redraw()


func cargar() -> void:
	vida = "cargado"
	visible = false


func soltar(pos: Vector2) -> void:
	position = pos
	_destino = pos
	visible = true
	vida = "sedado"


# ---------------------------------------------------------------- Cadena de Markov: Errante → Tosedor → Corredor

func _progresar(delta: float) -> void:
	if oleada or masa != null:
		return
	_t_markov += delta
	if _t_markov >= MINUTO_MARKOV:
		_t_markov = 0.0
		_avanzar_markov()


func _avanzar_markov() -> void:
	var idx: int = Markov.ESTADOS.find(tipo)
	if idx < 0 or idx == 2:
		return  # Corredor es absorbente; Masa y jefe no usan esta cadena
	var nuevo: int = Markov.paso(Juego.gen_lineal, Markov.P, idx)
	if nuevo != idx:
		transformar(Markov.ESTADOS[nuevo])


func transformar(nuevo_tipo: String) -> void:
	var fraccion := agitacion / agitacion_max
	var anterior := tipo
	tipo = nuevo_tipo
	_vestir()
	agitacion = maxf(1.0, agitacion_max * fraccion)
	_destino = position
	Juego.stats["transiciones_markov"] += 1
	Juego.registrar("Markov", "%s empeora -> %s" % [anterior, nuevo_tipo])
	Juego.sonido("mutacion")
	nivel.efecto("res://assets/vfx/markers/mutation_pulse.png", position + Vector2(0, -24))


# ------------------------------------------------------------------------------------------------------- dibujo

func _marcar(nombre: String) -> void:
	if nombre == _marca:
		return
	_marca = nombre
	if _marcador != null:
		_marcador.queue_free()
		_marcador = null
	if nombre == "":
		return
	_marcador = Sprites.tira("res://assets/vfx/markers/marker_%s.png" % nombre, 4.0, true)
	_marcador.position = Vector2(0, -66)
	add_child(_marcador)


## Barra de agitación sobre la cabeza (solo cuando ya recibió daño; el jefe siempre).
func _draw() -> void:
	if vida != "activo":
		return
	if agitacion >= agitacion_max and tipo != "Paciente Cero":
		return
	var ancho := 40.0 if tipo == "Paciente Cero" else 22.0
	var f := clampf(agitacion / agitacion_max, 0.0, 1.0)
	draw_rect(Rect2(-ancho / 2.0 - 1.0, -61.0, ancho + 2.0, 5.0), Color("#121417"))
	draw_rect(Rect2(-ancho / 2.0, -60.0, ancho * f, 3.0), Color("#C0392B") if tipo == "Corredor" else Color("#7A8F4E"))
