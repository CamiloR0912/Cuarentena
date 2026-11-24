## Controlador de nivel. Un solo script para los cuatro niveles: carga el mapa de Tiled, lee los marcadores,
## crea a Elena, los infectados y los ciudadanos, y enlaza los cinco modelos durante la partida:
##   SIR (I/N) → ritmo de aparición de infectados → caminatas y agentes → Monte Carlo (daño, críticos, drops)
##   → sedados y rescatados → cola M/M/c del hospital → pacientes atendidos (+γ) y abandonos (+I) → SIR.
extends Node2D

const Sprites = preload("res://entidades/sprites.gd")
const Elena = preload("res://entidades/elena.gd")
const Enemigo = preload("res://entidades/enemigo.gd")
const Masa = preload("res://entidades/masa.gd")
const Ciudadano = preload("res://entidades/ciudadano.gd")
const Nube = preload("res://entidades/nube.gd")
const Hud = preload("res://escenas/hud.gd")
const Pausa = preload("res://escenas/pausa.gd")
const PanelSim = preload("res://escenas/panel_simulacion.gd")
const Kit = preload("res://escenas/ui_kit.gd")
const Dialogo = preload("res://escenas/dialogo.gd")

const CELDA := 32
const AZUL := Color("#4FA3D1")
const AMBAR := Color("#E0A030")
const VERDE := Color("#B5C95A")
const ROJO := Color("#C0392B")
const BLANCO := Color("#EAF2F5")
# aparición de infectados: intervalo base (s) y máximo simultáneo por nivel (el nivel 2 usa oleadas)
const INTERVALO_APARICION := [16.0, 0.0, 12.0, 14.0]
const MAX_INFECTADOS := [16, 0, 14, 12]
const MEZCLA := [
	[["Errante", 0.85], ["Tosedor", 0.15]],
	[["Errante", 1.0]],
	[["Errante", 0.5], ["Tosedor", 0.2], ["Corredor", 0.3]],
	[["Errante", 0.5], ["Tosedor", 0.2], ["Corredor", 0.3]],
]
const TUTORIAL := [
	[1.0, "WASD para moverte. El ratón apunta; clic izquierdo o Espacio ataca."],
	[8.0, "Radio: «El retén del hospital solo abre si trae 3 pacientes sedados y el antiviral de la farmacia»."],
	[16.0, "Shift: agacharte. Haces menos ruido y los errantes no se sesgan hacia ti."],
	[24.0, "Ataca por la espalda sin que te detecten: +25 % de probabilidad de crítico."],
	[32.0, "Al sedar a un infectado, cárgalo con E y llévalo a la ambulancia (zona azul, al este)."],
	[42.0, "Cargando vas lenta y no puedes atacar: despeja la ruta antes. Un sedado despierta a los 60 s."],
	[52.0, "F usa el consumible; R cambia de consumible. F1 abre el panel de simulación."],
	[62.0, "La barra superior es la epidemia. Si I/N cruza la marca roja, la ciudad colapsa."],
]
# hospital (nivel 2)
const T_DIA := 35.0
const T_NOCHE := 50.0
const NOCHES := 3
const COLA_LLENA := 10
const T_COLAPSO := 20.0

var cfg := {}
var mapa: Node2D
var capa: Node2D           # nodo "props" del mapa: ordena por y a personajes y objetos
var elena
var hud
var panel_sim
var zonas := {}            # nombre -> [Rect2, ...]
var puntos := {}           # nombre -> [Vector2, ...]
var datos := {}            # nombre -> [metadatos del marcador, ...]
var objetos := []
var estaciones := []       # [{pos, tipo, usado}]
var terminado := false
var rescatados := 0
var jefe = null
var jefe_vencido := false
var mena: AnimatedSprite2D = null
# nivel 1: triaje de calle (la salida está cerrada hasta cumplirlo)
var entregas_triaje := 0
var antiviral_recogido := false
var salida_abierta := false
var _marcas_salida := []   # [relleno, borde] de cada zona de salida, para cambiarles el color

var _fuente: FontFile
var _t := 0.0
var _t_aparicion := 8.0
var _paso_tutorial := 0
var _cache := []
var _cache_cuadro := -1
# hospital
var fase := "dia"
var noche := 0
var _t_fase := T_DIA
var _t_oleada := 0.0
var _n_oleada := 0
var _t_colapso := 0.0
var _puerta := Vector2.ZERO
var _oscuridad: CanvasModulate
var _camillas := []        # Sprite2D de las camillas del mapa, de izquierda a derecha
var _personal := []
var _fila := []            # Sprite2D de los pacientes en las sillas de espera
var _tex_camilla := {}


func _ready() -> void:
	cfg = Juego.cfg_nivel()
	_fuente = Kit.fuente()
	Juego.nivel_actual = self
	Juego.resultado = ""
	Juego.causa = ""
	Juego.lam_factor = 1.0
	var escena: PackedScene = load("res://assets/maps/%s.tmx" % cfg["mapa"])
	mapa = escena.instantiate()
	add_child(mapa)
	capa = mapa.get_node("props")
	capa.y_sort_enabled = true
	mapa.y_sort_enabled = true
	if mapa.has_node("overhead"):
		mapa.get_node("overhead").z_index = 5  # tejados y copas por encima de los personajes
	_leer_marcadores()

	Juego.iniciar_nivel()   # punto de reintento: antes de repartir el equipo del nivel
	_equipar()

	elena = Elena.new()
	elena.nivel = self
	elena.position = _punto("player_spawn", Vector2(96, 96))
	capa.add_child(elena)
	elena.camara.limit_left = 0
	elena.camara.limit_top = -32          # deja ver la primera fila bajo la barra superior del HUD
	elena.camara.limit_right = int(cfg["ancho"]) * CELDA
	elena.camara.limit_bottom = int(cfg["alto"]) * CELDA + 64
	elena.camara.reset_smoothing()

	hud = Hud.new()
	add_child(hud)
	panel_sim = PanelSim.new()
	add_child(panel_sim)
	add_child(Pausa.new())

	_poblar()
	if Juego.nivel == 2:
		_preparar_hospital()
	Juego.musica(cfg["musica"])
	hud.titulo(cfg["titulo"], cfg["modelos"])
	Juego.registrar("M5 SIR", "día %.0f, I/N = %.2f %%" % [Juego.dia, Juego.fraccion_infectados() * 100.0])
	hud.objetivo(_texto_objetivo())   # el diálogo pausa el juego: el HUD debe quedar completo desde ya
	hud.refrescar(0.0, false)
	_dialogo("nivel%d" % Juego.nivel)


## Diálogo con retratos (pausa el juego mientras dura). Cada uno se ve una sola vez por partida.
func _dialogo(clave: String) -> void:
	if not Juego.marcar_dialogo(clave):
		return
	var d = Dialogo.abrir(self, Juego.DIALOGOS[clave])
	await d.terminado


# ================================================================================================= preparación

## YATI importa los puntos como Marker2D y los rectángulos como StaticBody2D "<nombre> (SB)" con su forma.
## Aquí se convierten en datos (puntos y zonas) y se retiran los cuerpos para que no bloqueen el paso.
func _leer_marcadores() -> void:
	for nodo in mapa.get_node("markers").get_children():
		var nombre := String(nodo.name).replace(" (SB)", "").rstrip("0123456789")
		var meta := {}
		for clave in nodo.get_meta_list():
			meta[String(clave)] = nodo.get_meta(clave)
		if nodo is StaticBody2D:
			nodo.collision_layer = 0
			nodo.collision_mask = 0
			for hijo in nodo.get_children():
				if hijo is CollisionShape2D and hijo.shape is RectangleShape2D:
					var tam: Vector2 = hijo.shape.size
					var origen: Vector2 = nodo.position + hijo.position - tam / 2.0
					if not zonas.has(nombre):
						zonas[nombre] = []
						datos[nombre] = []
					zonas[nombre].append(Rect2(origen, tam))
					datos[nombre].append(meta)
			nodo.queue_free()
		else:
			if not puntos.has(nombre):
				puntos[nombre] = []
				datos[nombre] = []
			puntos[nombre].append(nodo.position)
			datos[nombre].append(meta)


func _punto(nombre: String, defecto: Vector2) -> Vector2:
	if puntos.has(nombre) and not puntos[nombre].is_empty():
		return puntos[nombre][0]
	return defecto


func _en_zona(nombre: String, p: Vector2) -> bool:
	if not zonas.has(nombre):
		return false
	for r in zonas[nombre]:
		if r.has_point(p):
			return true
	return false


func _centro_zona(nombre: String, defecto: Vector2) -> Vector2:
	if zonas.has(nombre) and not zonas[nombre].is_empty():
		var r: Rect2 = zonas[nombre][0]
		return r.get_center()
	return defecto


## Equipo que se entrega al empezar cada nivel (el extintor se recarga siempre).
func _equipar() -> void:
	match Juego.nivel:
		2:
			Juego.tiene["extintor"] = true
			Juego.tiene["dardos"] = true
			Juego.cargas_extintor = 10
			Juego.dardos = maxi(Juego.dardos, 6)
			Juego.inv["cubrebocas"] += 2   # el hospital reparte cubrebocas: bajan β al usarlos
		3:
			Juego.tiene["extintor"] = true
			Juego.tiene["dardos"] = true
			Juego.cargas_extintor = 10
			Juego.dardos += 4
			Juego.inv["cubrebocas"] += 2
			Juego.jeringas = maxi(Juego.jeringas, 2)
		4:
			Juego.tiene["extintor"] = true
			Juego.tiene["dardos"] = true
			Juego.cargas_extintor = 10
			Juego.dardos += 6
			Juego.jeringas = maxi(Juego.jeringas, 3)


func _poblar() -> void:
	for p in puntos.get("spawn_errante", []):
		crear_enemigo("Errante", p)
	if Juego.nivel == 1:  # el GDD pide 8-12 errantes y el mapa trae 6 marcadores
		for p in puntos.get("spawn_errante", []).slice(0, 3):
			crear_enemigo("Errante", p + Vector2(64, 32))
	for p in puntos.get("spawn_tosedor", []):
		crear_enemigo("Tosedor", p)
	for p in puntos.get("spawn_corredor", []):
		crear_enemigo("Corredor", p)
	var masas: Array = puntos.get("spawn_masa", [])
	for k in masas.size():
		var cantidad := 10
		var meta: Dictionary = datos["spawn_masa"][k]
		if meta.has("count"):
			cantidad = clampi(int(str(meta["count"])), 8, 15)
		invocar_masa(masas[k], cantidad, true)
	for p in puntos.get("spawn_citizen", []):
		crear_ciudadano(p)
		crear_ciudadano(p + Vector2(24, 12))
	if puntos.has("boss_spawn"):
		jefe = crear_enemigo("Paciente Cero", puntos["boss_spawn"][0])
	if puntos.has("dra_mena"):
		mena = Sprites.personaje("dra_mena", ["idle", "treat", "cheer"])
		mena.position = puntos["dra_mena"][0]
		capa.add_child(mena)
		Sprites.animar(mena, "treat", Vector2.DOWN)

	for par in [["pharmacy", "antiviral"], ["medkit", "botiquin"], ["supplies", "suministros"],
			["supply_shelf", "suministros"]]:
		for p in puntos.get(par[0], []):
			estaciones.append({"pos": p, "tipo": par[1], "usado": false})
			var brillo: AnimatedSprite2D = Sprites.tira("res://assets/vfx/rare_sparkle.png", 6.0, true)
			brillo.position = p + Vector2(0, -20)
			brillo.z_index = 3
			capa.add_child(brillo)
			estaciones[-1]["brillo"] = brillo

	for r in zonas.get("dropoff_zone", []):
		_pintar_zona(r, AZUL)
	for r in zonas.get("level_exit", []):
		# en el nivel 1 el retén empieza cerrado (rojo) y pasa a ámbar al cumplir el triaje
		_marcas_salida.append(_pintar_zona(r, ROJO if Juego.nivel == 1 else AMBAR))
	for r in zonas.get("sample_delivery", []):
		_pintar_zona(r, VERDE)


func _pintar_zona(r: Rect2, color: Color) -> Array:
	var esquinas := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end,
		Vector2(r.position.x, r.end.y)])
	var relleno := Polygon2D.new()
	relleno.polygon = esquinas
	relleno.color = Color(color, 0.16)
	mapa.add_child(relleno)
	var borde := Line2D.new()
	borde.points = esquinas
	borde.closed = true
	borde.width = 2.0
	borde.default_color = Color(color, 0.8)
	mapa.add_child(borde)
	return [relleno, borde]


func crear_enemigo(tipo: String, pos: Vector2):
	var e := Enemigo.new()
	e.nivel = self
	e.tipo = tipo
	e.position = pos
	capa.add_child(e)
	return e


func crear_ciudadano(pos: Vector2) -> void:
	var c := Ciudadano.new()
	c.nivel = self
	c.position = pos
	capa.add_child(c)


func invocar_masa(pos: Vector2, cantidad: int, inicial := false) -> void:
	if not inicial:
		var individuos := 0
		for e in get_tree().get_nodes_in_group("enemigos"):
			if e.tipo == "Masa" and e.vida == "activo":
				individuos += 1
		if individuos >= 12:
			return  # el jefe no puede llenar la arena
	var m := Masa.new()
	add_child(m)
	m.crear(self, pos, cantidad)


# ======================================================================================================= bucle

func _physics_process(delta: float) -> void:
	if terminado or elena == null:
		return
	_t += delta
	var eventos: Array = Juego.avanzar_mundo(delta)

	if Juego.fraccion_infectados() > Juego.UMBRAL_COLAPSO:
		_derrota("ciudad")
		return
	if not elena.muerta:
		if Juego.hp <= 0.0:
			elena.morir("hp")
		elif Juego.viral >= 100.0:
			elena.morir("viral")

	_nubes(delta)
	_recoger_objetos()
	_zonas()
	_aparicion(delta)
	match Juego.nivel:
		1:
			_tutorial()
		2:
			_hospital(delta, eventos)
		4:
			_laboratorio()
	hud.objetivo(_texto_objetivo())


func _process(_delta: float) -> void:
	if hud != null and elena != null:
		hud.refrescar(elena.ruido, elena.agachada)


func _unhandled_input(event: InputEvent) -> void:
	if terminado:
		return
	if event.is_action_pressed("cambiar_arma"):
		Juego.cambiar_arma(1)
	elif event.is_action_pressed("arma_1"):
		Juego.elegir_arma(0)
	elif event.is_action_pressed("arma_2"):
		Juego.elegir_arma(1)
	elif event.is_action_pressed("arma_3"):
		Juego.elegir_arma(2)
	elif event.is_action_pressed("arma_4"):
		Juego.elegir_arma(3)
	elif event.is_action_pressed("usar"):
		var texto: String = Juego.usar_consumible()
		if texto != "":
			aviso(texto)
			efecto("res://assets/vfx/heal_plus.png", elena.position + Vector2(0, -30))
	elif event.is_action_pressed("siguiente_consumible"):
		Juego.siguiente_consumible()
	elif event.is_action_pressed("panel_simulacion"):
		panel_sim.alternar()
	elif event.is_action_pressed("prueba_ataques"):
		Juego.prueba_ataques()
		panel_sim.mostrar()
	elif event.is_action_pressed("prueba_drops"):
		Juego.prueba_drops()
		panel_sim.mostrar()
	elif event.is_action_pressed("camilla_mas"):
		_cambiar_camillas(1)
	elif event.is_action_pressed("camilla_menos"):
		_cambiar_camillas(-1)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Juego.cambiar_arma(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Juego.cambiar_arma(1)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.unicode == 43:    # "+" en cualquier distribución de teclado
			_cambiar_camillas(1)
		elif event.unicode == 45:  # "-"
			_cambiar_camillas(-1)


func _texto_objetivo() -> String:
	match Juego.nivel:
		1:
			if salida_abierta:
				return "Retén abierto: entra al hospital (zona ámbar, al este)"
			return "Triaje · Sedados entregados %d/%d (zona azul) · Antiviral de la farmacia %d/1" % [
				mini(entregas_triaje, Juego.META_ENTREGAS_N1), Juego.META_ENTREGAS_N1, int(antiviral_recogido)]
		2:
			if fase == "dia":
				return "Día %d/%d: gestiona las camillas (+ / -). Quedan %d s" % [noche + 1, NOCHES, ceili(_t_fase)]
			return "Noche %d/%d: defiende la entrada. Quedan %d s" % [noche, NOCHES, ceili(maxf(0.0, _t_fase))]
		3:
			return "Rescatados %d/%d · Muestras %d/%d · luego sal por el este (zona ámbar)" % [rescatados,
				Juego.META_RESCATES, Juego.muestras, Juego.META_MUESTRAS_N3]
		4:
			if not jefe_vencido:
				return "Neutraliza al Paciente Cero en el auditorio (noroeste)"
			return "Entrega las muestras a la Dra. Mena (zona verde, noreste): %d/%d" % [Juego.muestras,
				Juego.META_MUESTRAS_N4]
	return cfg["objetivo"]


# ============================================================================================ servicios del nivel

## Infectados en pie. Se calcula una vez por cuadro de física porque lo consultan muchas entidades.
func enemigos_activos() -> Array:
	var cuadro := Engine.get_physics_frames()
	if cuadro != _cache_cuadro:
		_cache_cuadro = cuadro
		_cache = []
		for e in get_tree().get_nodes_in_group("enemigos"):
			if e.vida == "activo" and not e.is_queued_for_deletion():
				_cache.append(e)
	return _cache


func linea_de_vista(a: Vector2, b: Vector2) -> bool:
	var consulta := PhysicsRayQueryParameters2D.create(a, b, 1)
	return get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()


## Un ataque de Elena. El daño y el crítico salen del Modelo 3 (Monte Carlo) con el generador aditivo:
## D = max(0, X) · (2 si crítico);  p_crit = base + 0,25 [espalda sin detección] + 0,10 [adrenalina].
func golpear(e, arma: String, desde: Vector2) -> void:
	if not is_instance_valid(e) or e.vida != "activo":
		return
	var espalda: bool = e.de_espaldas(desde) and not e.detecta()
	var adrenalina: bool = Juego.t_adrenalina > 0.0
	var r: Array = Juego.mc.dano(arma, espalda, adrenalina)
	var dano: float = r[0]
	var critico: bool = r[1]
	var s: Dictionary = Juego.stats
	s["ataques"] += 1
	s["dano"][arma][0] += 1
	s["dano"][arma][1] += dano
	if critico:
		s["criticos"] += 1
	if espalda:
		s["ataques_espalda"] += 1
		if critico:
			s["criticos_espalda"] += 1
	var pos: Vector2 = e.position
	e.recibir(dano, critico, desde)
	numero(pos + Vector2(0, -58), "%d" % roundi(dano), critico)
	if critico:
		efecto("res://assets/vfx/hit_critical_stealth.png" if espalda else "res://assets/vfx/hit_critical.png",
			pos + Vector2(0, -24))
		Juego.sonido("critico")
		elena.sacudir(0.45)
		Juego.hit_stop(0.07)
		Juego.registrar("M3 Monte Carlo", "CRÍTICO x2%s con %s: %.1f (p = %.2f)" % [" por la espalda" if espalda else "",
			arma, dano, Juego.mc.p_crit_efectiva(arma, espalda, adrenalina)])
	else:
		efecto("res://assets/vfx/hit_normal.png", pos + Vector2(0, -24))
		Juego.sonido("golpe")
		elena.sacudir(0.15)


func al_sedar(e) -> void:
	match e.tipo:
		"Paciente Cero":
			jefe_vencido = true
			Juego.muestras += 5
			aviso("Paciente Cero neutralizado: +5 muestras. Llévalas a la Dra. Mena")
			Juego.musica("tension")
			elena.sacudir(0.8)
		"Masa":
			pass  # la masa suelta su drop al dispersarse
		_:
			soltar_drop(e.tipo, e.position)
	if Juego.nivel == 2:
		# en el hospital el personal recoge a los sedados de la entrada
		get_tree().create_timer(2.5).timeout.connect(_ingresar_sedado.bind(e))


func _ingresar_sedado(e) -> void:
	if terminado or not is_instance_valid(e) or e.vida != "sedado":
		return
	efecto("res://assets/vfx/dropoff_confirm.png", e.position + Vector2(0, -24))
	e.queue_free()
	Juego.entregar_paciente("infectado")


## Drop por transformada inversa discreta sobre la tabla del tipo de enemigo (Modelo 3).
func soltar_drop(tipo_enemigo: String, pos: Vector2) -> void:
	var objeto: String = Juego.mc.drop(tipo_enemigo)
	var drops: Dictionary = Juego.stats["drops"]
	if not drops.has(tipo_enemigo):
		drops[tipo_enemigo] = {}
	drops[tipo_enemigo][objeto] = drops[tipo_enemigo].get(objeto, 0) + 1
	Juego.registrar("M3 Monte Carlo", "drop de %s: %s" % [tipo_enemigo, objeto])
	if objeto == "nada":
		efecto("res://assets/vfx/nothing_dropped.png", pos + Vector2(0, -20), 8.0)
	else:
		crear_objeto(objeto, pos)


func crear_objeto(tipo: String, pos: Vector2) -> void:
	var nombre: String = Juego.OBJETOS[tipo]["sprite"]
	var s: AnimatedSprite2D = Sprites.tira("res://assets/sprites/items/%s_world.png" % nombre, 6.0, true)
	s.position = pos + Vector2(0, -6)
	s.set_meta("tipo", tipo)
	s.scale = Vector2(0.2, 0.2)
	capa.add_child(s)
	objetos.append(s)
	var tw := s.create_tween()   # aparece con un pequeño rebote
	tw.tween_property(s, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	efecto("res://assets/vfx/drop_pop.png", pos + Vector2(0, -8))


func crear_nube(pos: Vector2) -> void:
	if get_tree().get_nodes_in_group("nubes").size() >= 14:
		return
	var n := Nube.new()
	n.position = pos
	capa.add_child(n)


func contagiar_ciudadano(c) -> void:
	var pos: Vector2 = c.position
	c.queue_free()
	crear_enemigo("Errante", pos)
	efecto("res://assets/vfx/markers/infection_flash.png", pos + Vector2(0, -24), 8.0)
	Juego.stats["contagios_calle"] += 1
	Juego.sumar_infectados()  # el contagio en la calle suma infectados al SIR
	Juego.registrar("M4 Agentes", "contagio en la calle: un ciudadano pasa a Errante (+I)")
	aviso("Un ciudadano se contagió")


func efecto(ruta: String, pos: Vector2, fps := 14.0) -> void:
	var s: AnimatedSprite2D = Sprites.tira(ruta, fps)
	s.position = pos
	s.z_index = 3
	capa.add_child(s)


## Número de daño flotante: rojo y más grande si fue crítico (GDD §10.2).
func numero(pos: Vector2, texto: String, critico: bool) -> void:
	var l := Kit.texto(texto + ("!" if critico else ""), Vector2.ZERO, _fuente, 16, ROJO if critico else BLANCO)
	l.add_theme_color_override("font_outline_color", Color("#121417"))
	l.add_theme_constant_override("outline_size", 4)
	l.position = pos + Vector2(-8, 0)
	l.z_index = 4
	if critico:
		l.scale = Vector2(1.6, 1.6)
	capa.add_child(l)
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", pos.y - 26.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(l.queue_free)


func aviso(texto: String) -> void:
	hud.aviso(texto)


func al_herir(_dano: float) -> void:
	hud.destello_dano()


## Tecla E: soltar lo que carga, cargar un sedado cercano o usar una estación (farmacia, botiquín, estante).
func interactuar() -> void:
	if elena.cargando != null:
		elena.soltar()
		return
	var mejor = null
	var d_mejor := 44.0
	for e in get_tree().get_nodes_in_group("enemigos"):
		if e.vida == "sedado" and e.tipo != "Paciente Cero":
			var d: float = e.position.distance_to(elena.position)
			if d < d_mejor:
				d_mejor = d
				mejor = e
	if mejor != null:
		elena.cargar(mejor)
		aviso("Llévalo a la ambulancia (zona azul) o suéltalo con E")
		return
	for est in estaciones:
		var pos: Vector2 = est["pos"]
		if not est["usado"] and pos.distance_to(elena.position) < 52.0:
			est["usado"] = true
			if est.has("brillo") and is_instance_valid(est["brillo"]):
				est["brillo"].queue_free()
			var nombre: String = Juego.recoger(est["tipo"])
			aviso("Recogido: %s" % nombre)
			if est["tipo"] == "antiviral":
				antiviral_recogido = true
				_revisar_triaje()
			efecto("res://assets/vfx/pickup_collect.png", elena.position + Vector2(0, -30))
			return


func _recoger_objetos() -> void:
	for k in range(objetos.size() - 1, -1, -1):
		var o = objetos[k]
		if not is_instance_valid(o):
			objetos.remove_at(k)
			continue
		var p: Vector2 = o.position
		if p.distance_to(elena.position) < 24.0:
			var nombre: String = Juego.recoger(o.get_meta("tipo"))
			aviso("+ %s" % nombre)
			efecto("res://assets/vfx/pickup_collect.png", p)
			o.queue_free()
			objetos.remove_at(k)


## Nube del Tosedor: +2 % de carga viral por segundo según la concentración de partículas alrededor de Elena.
func _nubes(delta: float) -> void:
	var total := 0
	var pecho: Vector2 = elena.position + Vector2(0, -8)
	for n in get_tree().get_nodes_in_group("nubes"):
		total += n.concentracion(pecho)
	if total >= 2:
		elena.sumar_viral(2.0 * minf(1.0, total / 4.0) * delta)


func _zonas() -> void:
	if elena.cargando != null and _en_zona("dropoff_zone", elena.position):
		var e = elena.cargando
		elena.cargando = null
		if is_instance_valid(e):
			e.queue_free()
		Juego.entregar_paciente("infectado")
		efecto("res://assets/vfx/dropoff_confirm.png", elena.position + Vector2(0, -24))
		aviso("Paciente entregado: entra a la fila del hospital. +1 muestra")
		entregas_triaje += 1
		_revisar_triaje()
	for c in get_tree().get_nodes_in_group("ciudadanos"):
		if not c.salvado and _en_zona("dropoff_zone", c.position):
			c.celebrar()
			rescatados += 1
			Juego.entregar_paciente("ciudadano")
			aviso("Ciudadano a salvo")
	if _en_zona("level_exit", elena.position):
		match Juego.nivel:
			1:
				if salida_abierta:
					_completar("Llegaste al Hospital San Rafael")
				else:
					aviso("Retén: «Sin pacientes ni antiviral no pasa». Faltan %d entregas%s" % [
						maxi(0, Juego.META_ENTREGAS_N1 - entregas_triaje),
						"" if antiviral_recogido else " y el antiviral de la farmacia"])
			3:
				if rescatados >= Juego.META_RESCATES and Juego.muestras >= Juego.META_MUESTRAS_N3:
					_completar("Cuota cumplida: rumbo a la universidad")
				else:
					aviso("Aún falta: %d rescates y %d muestras" % [maxi(0, Juego.META_RESCATES - rescatados),
						maxi(0, Juego.META_MUESTRAS_N3 - Juego.muestras)])
			2:
				aviso("El convoy aún no llega: resiste las %d noches" % NOCHES)


## Acople SIR → calle: el intervalo entre apariciones se acorta cuando sube I/N.
func _aparicion(delta: float) -> void:
	var base: float = INTERVALO_APARICION[Juego.nivel - 1]
	if base <= 0.0:
		return
	_t_aparicion -= delta
	if _t_aparicion > 0.0:
		return
	var fi: float = Juego.fraccion_infectados()
	_t_aparicion = base / (1.0 + 12.0 * fi)
	var sueltos := 0
	for e in get_tree().get_nodes_in_group("enemigos"):
		if e.masa == null and e.tipo != "Paciente Cero":
			sueltos += 1
	if sueltos >= MAX_INFECTADOS[Juego.nivel - 1]:
		return
	var candidatos := []
	for nombre in ["spawn_errante", "spawn_tosedor", "spawn_corredor", "spawn_masa"]:
		for p in puntos.get(nombre, []):
			var pos: Vector2 = p
			if pos.distance_to(elena.position) > 340.0:
				candidatos.append(pos)
	if candidatos.is_empty():
		return
	var tipo: String = Juego.gen_lineal.categorica(MEZCLA[Juego.nivel - 1])
	crear_enemigo(tipo, candidatos[randi() % candidatos.size()])
	Juego.registrar("M5 SIR", "I/N = %.1f %% -> aparece un %s (cada %.1f s)" % [fi * 100.0, tipo, _t_aparicion])


## Nivel 1: abre el retén cuando se cumplen las entregas y se recogió el antiviral.
func _revisar_triaje() -> void:
	if Juego.nivel != 1 or salida_abierta:
		return
	if entregas_triaje < Juego.META_ENTREGAS_N1 or not antiviral_recogido:
		return
	salida_abierta = true
	for par in _marcas_salida:
		par[0].color = Color(AMBAR, 0.16)
		par[1].default_color = Color(AMBAR, 0.8)
	Juego.sonido("sirena")
	Juego.registrar("M2 Cola", "triaje de calle completo: %d pacientes en el hospital" % entregas_triaje)
	aviso("Radio: «Triaje completo, doctora. El retén está abierto: entre al hospital»")
	elena.sacudir(0.2)


func _tutorial() -> void:
	if _paso_tutorial < TUTORIAL.size() and _t >= TUTORIAL[_paso_tutorial][0]:
		aviso(TUTORIAL[_paso_tutorial][1])
		_paso_tutorial += 1


func _completar(texto: String) -> void:
	if terminado:
		return
	terminado = true
	aviso(texto)
	Juego.sonido("entrega")
	if elena.cargando != null:
		elena.soltar()
	await get_tree().create_timer(1.6).timeout
	if is_inside_tree():
		Juego.completar_nivel()


func _derrota(causa: String) -> void:
	if terminado:
		return
	terminado = true
	Juego.sonido("alarma")
	Juego.derrota(causa)


# ============================================================================================ nivel 2: hospital

func _preparar_hospital() -> void:
	_puerta = _centro_zona("dropoff_zone", elena.position + Vector2(0, 160))
	_oscuridad = CanvasModulate.new()
	_oscuridad.color = Color.WHITE
	add_child(_oscuridad)
	for nombre in ["stretcher", "stretcher_occupied", "stretcher_occupied_citizen", "stretcher_closed"]:
		_tex_camilla[nombre] = load("res://assets/tilesets/props/%s.png" % nombre)
	# las camillas dibujadas en el mapa pasan a reflejar el estado de la cola
	var cuerpos := []
	for nodo in capa.get_children():
		if String(nodo.name).begins_with("stretcher") and nodo is Node2D:
			cuerpos.append(nodo)
	cuerpos.sort_custom(func(a, b): return a.position.x < b.position.x)
	for cuerpo in cuerpos:
		var sprite: Sprite2D = null
		if cuerpo is Sprite2D:
			sprite = cuerpo
		else:
			for hijo in cuerpo.get_children():
				if hijo is Sprite2D:
					sprite = hijo
		if sprite != null:
			_camillas.append(sprite)
	var sitios: Array = puntos.get("staff_spot", [])
	for k in sitios.size():
		var p := Sprites.personaje("staff_nurse" if k % 2 == 0 else "staff_doctor", ["idle", "treat"])
		p.position = sitios[k]
		capa.add_child(p)
		_personal.append(p)
	var hoja: Texture2D = load("res://assets/sprites/characters/citizen_worker/citizen_worker_sit.png")
	for p in puntos.get("queue_slot", []):
		var s := Sprite2D.new()
		var cuadro := AtlasTexture.new()
		cuadro.atlas = hoja
		cuadro.region = Rect2(0, 0, 64, 64)
		s.texture = cuadro
		s.offset = Vector2(0, -30)
		s.position = p
		s.visible = false
		capa.add_child(s)
		_fila.append(s)
	Juego.lam_factor = 1.6
	aviso("Día 1: abre o cierra camillas con + y -. Cada camilla gasta suministros.")


func _cambiar_camillas(paso: int) -> void:
	if Juego.nivel != 2:
		return
	var c: int = clampi(Juego.cola.c + paso, 1, Juego.CAMILLAS_MAX)
	if paso > 0 and Juego.suministros <= 0.0:
		aviso("Sin suministros: no se pueden abrir más camillas")
		Juego.sonido("vacio")
		return
	if c != Juego.cola.c:
		Juego.cola.fijar_camillas(c)
		Juego.sonido("clic")
		var teo: Dictionary = Juego.Cola.teoria(Juego.cola.lam, Juego.cola.mu, c)
		Juego.registrar("M2 Cola", "c = %d camillas -> rho = %.2f" % [c, teo["rho"]])


func _hospital(delta: float, eventos: Array) -> void:
	for ev in eventos:
		if ev[0] == "abandono":
			aviso("Un paciente se cansó de esperar y volvió a la calle")
	# cada camilla abierta consume suministros por minuto
	var c: int = Juego.cola.c
	Juego.suministros = maxf(0.0, Juego.suministros - 0.2 * c * delta / Juego.SEG_POR_MINUTO)
	if Juego.suministros <= 0.0 and c > 1:
		Juego.cola.fijar_camillas(1)
		aviso("Se acabaron los suministros: solo queda 1 camilla abierta")

	_t_fase -= delta
	if fase == "dia":
		if _t_fase <= 0.0:
			_empezar_noche()
	else:
		_oleadas(delta)
		if _t_fase <= 0.0:
			_terminar_noche()

	# colapso: la sala de espera llena durante demasiado tiempo
	if Juego.cola.en_cola() >= COLA_LLENA:
		_t_colapso += delta
		if _t_colapso >= T_COLAPSO:
			_derrota("hospital")
			return
	else:
		_t_colapso = maxf(0.0, _t_colapso - 2.0 * delta)
	_dibujar_hospital()
	hud.hospital(fase, _t_colapso / T_COLAPSO)


func _empezar_noche() -> void:
	fase = "noche"
	noche += 1
	_t_fase = T_NOCHE
	_t_oleada = 2.0
	_n_oleada = 0
	Juego.lam_factor = 1.0
	Juego.musica("tension")
	Juego.sonido("alarma")
	aviso("Noche %d: los infectados vienen por la entrada sur. Los que sedes entran a la fila." % noche)
	var tw := create_tween()
	tw.tween_property(_oscuridad, "color", Color(0.52, 0.6, 0.85), 2.0)
	if noche == NOCHES:
		var entradas: Array = puntos.get("spawn_night_wave", [])
		if not entradas.is_empty():
			invocar_masa(entradas[0], 8, true)


func _oleadas(delta: float) -> void:
	_t_oleada -= delta
	if _t_oleada <= 0.0 and _t_fase > 6.0:
		_t_oleada = [5.0, 4.0, 3.2][clampi(noche - 1, 0, 2)]
		_n_oleada += 1
		var entradas: Array = puntos.get("spawn_night_wave", [])
		if not entradas.is_empty():
			var pos: Vector2 = entradas[randi() % entradas.size()]
			if noche >= 2 and _n_oleada % 4 == 0:
				crear_enemigo("Corredor", pos)
			else:
				var tipo := "Tosedor" if (noche >= 2 and _n_oleada % 3 == 0) else "Errante"
				var e = crear_enemigo(tipo, pos)
				e.oleada = true   # caminata sesgada hacia la puerta (b máximo)
				e.objetivo_oleada = _puerta
	for e in enemigos_activos():
		if e.oleada and e.position.distance_to(_puerta) < 44.0:
			# irrumpe en el hospital: contagia a quienes esperan
			e.queue_free()
			Juego.cola.llegada_externa("ciudadano")
			Juego.cola.llegada_externa("ciudadano")
			Juego.sumar_infectados()
			Juego.sonido("alarma")
			aviso("Un infectado entró al hospital: dos pacientes más en la fila")


func _terminar_noche() -> void:
	for e in enemigos_activos():
		if e.oleada or e.tipo == "Corredor":
			e.huir()
	var tw := create_tween()
	tw.tween_property(_oscuridad, "color", Color.WHITE, 2.0)
	if noche >= NOCHES:
		terminado = true
		Juego.suministros += 30.0
		Juego.sonido("sirena")
		aviso("Amanece. Llega el convoy de suministros: el hospital sigue en pie.")
		await get_tree().create_timer(4.0).timeout
		if is_inside_tree():
			Juego.completar_nivel()
		return
	fase = "dia"
	_t_fase = T_DIA
	Juego.lam_factor = 1.6
	Juego.musica("hospital")
	for est in estaciones:  # el estante se repone cada mañana
		if est["tipo"] == "suministros":
			est["usado"] = false
	aviso("Día %d: llegan pacientes. Ajusta las camillas y repón suministros en el estante (E)." % (noche + 1))


func _dibujar_hospital() -> void:
	var c: int = Juego.cola.c
	var ocupadas: int = Juego.cola.ocupados
	for k in _camillas.size():
		var nombre := "stretcher"
		if k >= c and k >= ocupadas:
			nombre = "stretcher_closed"
		elif k < ocupadas:
			nombre = "stretcher_occupied" if k % 2 == 0 else "stretcher_occupied_citizen"
		var sprite: Sprite2D = _camillas[k]
		if sprite.texture != _tex_camilla[nombre]:
			sprite.texture = _tex_camilla[nombre]
	for k in _personal.size():
		var p: AnimatedSprite2D = _personal[k]
		p.visible = k < c
		Sprites.animar(p, "treat" if k < ocupadas else "idle", Vector2.UP)
	var tipos: Array = Juego.cola.tipos_en_cola()
	for k in _fila.size():
		var s: Sprite2D = _fila[k]
		s.visible = k < tipos.size()
		if s.visible:
			s.modulate = Color(0.75, 0.9, 0.6) if tipos[k] == "infectado" else Color.WHITE


# ========================================================================================= nivel 4: laboratorio

func _laboratorio() -> void:
	if jefe != null and is_instance_valid(jefe) and not jefe.jefe_activo and not jefe_vencido:
		if _en_zona("boss_arena", elena.position) or jefe.position.distance_to(elena.position) < 200.0 \
				or jefe.agitacion < jefe.agitacion_max:
			jefe.jefe_activo = true
			Juego.musica("jefe")
			Juego.sonido("grunido")
			aviso("PACIENTE CERO: sus fases cambian según una cadena de Markov")
			_dialogo("jefe")
	if jefe != null and is_instance_valid(jefe) and jefe.jefe_activo and not jefe_vencido:
		hud.jefe(jefe.agitacion / jefe.agitacion_max, jefe.fase)
	else:
		hud.jefe(-1.0, 0)
	if _en_zona("sample_delivery", elena.position):
		if not jefe_vencido:
			aviso("Dra. Mena: «Necesito las muestras del Paciente Cero»")
		elif Juego.muestras < Juego.META_MUESTRAS_N4:
			aviso("Dra. Mena: «Faltan %d muestras»" % (Juego.META_MUESTRAS_N4 - Juego.muestras))
		else:
			_victoria()


## El sintetizador del laboratorio se ilumina mientras la Dra. Mena prepara la cura.
func _encender_sintetizador() -> void:
	if not puntos.has("cure_synthesizer"):
		return
	var brillo: AnimatedSprite2D = Sprites.tira("res://assets/sprites/props/lab/cure_synthesizer_glow.png", 8.0, true)
	brillo.position = puntos["cure_synthesizer"][0] + Vector2(-15, -12)   # centro del sintetizador del mapa
	brillo.process_mode = Node.PROCESS_MODE_ALWAYS   # sigue animado durante el diálogo final
	brillo.z_index = 2
	capa.add_child(brillo)
	Juego.sonido("raro")


func _victoria() -> void:
	if terminado:
		return
	terminado = true
	Juego.muestras -= Juego.META_MUESTRAS_N4
	Juego.sir.f_cub = 1.0
	Juego.musica("victoria")
	_encender_sintetizador()
	await _dialogo("final")
	aviso("La Dra. Mena sintetiza la cura. Tunja vuelve a respirar.")
	elena.celebrar()
	if mena != null:
		Sprites.animar(mena, "cheer", Vector2.DOWN, true)
	for e in enemigos_activos():
		e.huir()
	await get_tree().create_timer(3.0).timeout
	if is_inside_tree():
		Juego.completar_nivel()
