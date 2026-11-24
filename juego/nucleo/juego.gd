## Autoload "Juego": estado global de la partida y servicios compartidos.
## Aquí viven los modelos que persisten entre niveles (SIR, cola del hospital, Monte Carlo), el inventario,
## las estadísticas que muestra el panel F1, el audio (generado por código) y los cambios de escena.
extends Node

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const Caminata = preload("res://modelos/Cruz_Castiblanco_modelo1_caminatas.gd")
const Cola = preload("res://modelos/Cabra_Coy_modelo2_colas.gd")
const MonteCarlo = preload("res://modelos/Sanchez_Diego_modelo3_montecarlo.gd")
const SIR = preload("res://modelos/Ramirez_Camilo_modelo5_dinamica.gd")

const ESCENA_MENU := "res://escenas/menu_principal.tscn"
const ESCENA_INTRO := "res://escenas/intro.tscn"
const ESCENA_BRIEFING := "res://escenas/briefing.tscn"
const ESCENA_NIVEL := "res://escenas/nivel.tscn"
const ESCENA_FIN := "res://escenas/fin.tscn"
const ESCENA_INFO := "res://escenas/info.tscn"
const PARTIDA := "user://partida.cfg"

# --- Parámetros de integración (ajustes respecto al GDD documentados en el README) ---
const UMBRAL_COLAPSO := 0.20      # I/N de derrota (con ℛ0 = 3 el pico teórico es 0,30; 0,60 nunca se alcanza)
const DIAS_POR_SEGUNDO := 0.05    # ritmo del SIR: 1 día de epidemia cada 20 s reales
const SEG_POR_MINUTO := 4.0       # 1 minuto del hospital (cola M/M/c) = 4 s reales
const MU_CAMILLA := 1.0           # pacientes/min por camilla
const PACIENCIA := 6.0            # min que espera un paciente antes de abandonar
const CAMILLAS_MAX := 6
const GAMMA_POR_PACIENTE := 0.015 # aumento de γ por cada paciente/min que atiende el hospital
const FRACCION_REBROTE := 0.01    # un abandono o un contagio en la calle pasa de S a I el 1 % de I (mínimo 5 personas)
const ESCALA_PERSONAS := 400.0    # personas que representa cada ciudadano rescatado
const F_CUB_POR_CUBREBOCAS := 0.08
const ARMAS_ORDEN := ["tubo", "extintor", "dardos", "jeringa"]
const ARMAS_INFO := {
	"tubo": {"nombre": "TUBO", "icono": "pipe_hud", "cadencia": 0.5},
	"extintor": {"nombre": "EXTINTOR", "icono": "extinguisher_hud", "cadencia": 1.0},
	"dardos": {"nombre": "DARDOS", "icono": "dart_pistol_hud", "cadencia": 1.2},
	"jeringa": {"nombre": "JERINGA", "icono": "syringe_hud", "cadencia": 0.6},
}
const CONSUMIBLES := ["vendas", "cubrebocas", "adrenalina", "antiviral"]
const OBJETOS := {
	"vendas": {"nombre": "Vendas", "sprite": "bandage"},
	"dardos": {"nombre": "Dardos x3", "sprite": "darts"},
	"cubrebocas": {"nombre": "Cubrebocas", "sprite": "facemask"},
	"muestra": {"nombre": "Muestra viral", "sprite": "sample"},
	"adrenalina": {"nombre": "Adrenalina", "sprite": "adrenaline"},
	"botiquin": {"nombre": "Botiquín", "sprite": "medkit"},
	"antiviral": {"nombre": "Antiviral", "sprite": "antiviral"},
	"suministros": {"nombre": "Suministros", "sprite": "supplies"},
}
const NIVELES := [
	{
		"titulo": "NIVEL 1 · EL BARRIO", "mapa": "level1_barrio", "tarjeta": "level_1_barrio", "ancho": 64, "alto": 40,
		"musica": "barrio", "modelos": "Caminata aleatoria · Monte Carlo · SIR",
		"objetivo": "Triaje de calle: entrega 3 infectados sedados en la ambulancia y trae el antiviral de la farmacia",
		"historia": "Tunja, 2031. Tras un turno de 36 horas, la doctora Elena Ruiz despierta con la ciudad cerrada por la Fiebre Gris. Los infectados deambulan desorientados: no son monstruos, son pacientes. El hospital queda al otro lado del barrio.",
		"radio": "Doctora, el retén del hospital no deja pasar a nadie con las manos vacías: traiga tres pacientes sedados y el antiviral de la farmacia.",
		"encuentros": {"Errante": 8, "Tosedor": 2},
	},
	{
		"titulo": "NIVEL 2 · HOSPITAL SAN RAFAEL", "mapa": "level2_hospital", "tarjeta": "level_2_hospital", "ancho": 48, "alto": 34,
		"musica": "hospital", "modelos": "Cola M/M/c · Agentes · Monte Carlo · SIR",
		"objetivo": "Resiste 3 noches hasta que llegue el convoy",
		"historia": "El hospital es el corazón de la ciudad. De día llegan pacientes y hay que decidir cuántas camillas abrir: cada una gasta suministros. De noche los infectados atacan la entrada; los que sede entran a la fila.",
		"radio": "El convoy tarda tres noches. Si la fila se llena, los pacientes se van... y vuelven a la calle enfermos.",
		"encuentros": {"Errante": 10, "Corredor": 1},
	},
	{
		"titulo": "NIVEL 3 · EL CENTRO", "mapa": "level3_centro", "tarjeta": "level_3_centro", "ancho": 60, "alto": 44,
		"musica": "tension", "modelos": "Los cinco modelos y la cadena de Markov",
		"objetivo": "Rescata ciudadanos y reúne muestras; luego sal por el este",
		"historia": "La Plaza de Bolívar está tomada. Hay corredores que persiguen el ruido y masas que se mueven como un enjambre. Entre ellos quedan vecinos sanos: llévelos a la ambulancia y traiga muestras para la doctora Mena.",
		"radio": "Doctora, en el centro hay gente atrapada, pero la zona está caliente.",
		"encuentros": {"Errante": 4, "Corredor": 2, "Masa": 4},
	},
	{
		"titulo": "NIVEL 4 · EL LABORATORIO", "mapa": "level4_laboratorio", "tarjeta": "level_4_laboratorio", "ancho": 60, "alto": 44,
		"musica": "jefe", "modelos": "Los cinco modelos; Markov rige las fases del jefe",
		"objetivo": "Neutraliza al Paciente Cero y entrega 10 muestras a la Dra. Mena",
		"historia": "La universidad. En el auditorio está el Paciente Cero, el primer caso: sus muestras completan la cura. La doctora Mena espera en el laboratorio del ala este.",
		"radio": "Es la última salida. El Paciente Cero cambia de conducta sin aviso: embiste, tose, llama a la masa.",
		"encuentros": {"Errante": 3, "Corredor": 2, "Masa": 6},
	},
]
const CONTROLES := [
	["Movimiento", "W A S D / flechas", "Desplaza a Elena"],
	["Apuntar", "Ratón", "Orienta el ataque"],
	["Ataque", "Clic izquierdo / Espacio", "Ataca con el arma equipada"],
	["Agacharse (sigilo)", "Shift", "Menos ruido y menos velocidad"],
	["Correr", "Ctrl", "Más velocidad y más ruido"],
	["Interactuar / cargar", "E", "Cargar o soltar un sedado, usar estaciones"],
	["Cambiar arma", "Q / rueda / 1-4", "Tubo, extintor, dardos, jeringa"],
	["Usar consumible", "F", "Usa el consumible seleccionado"],
	["Cambiar consumible", "R / Tab", "Vendas, cubrebocas, adrenalina, antiviral"],
	["Abrir camilla", "+", "(Hospital) aumenta c"],
	["Cerrar camilla", "-", "(Hospital) disminuye c"],
	["Panel de simulación", "F1", "Métricas en vivo de los cinco modelos"],
	["Casos de prueba", "F2 / F3", "1 000 ataques por la espalda / 500 drops"],
	["Pausa", "Esc", "Abre el menú de pausa"],
]
## Diálogos lineales (escenas/dialogo.gd). Cada línea: quien (alvaro, elena, mena o "" para narración), animo
## (el retrato: neutral, worried, confident · neutral, determined, hurt · neutral, urgent, hopeful), radio y texto.
## Se muestran una sola vez por partida (dialogos_vistos); los reintentos no los repiten.
const DIALOGOS := {
	"intro": [
		{"quien": "", "titulo": "TUNJA · 2031", "subtitulo": "Día 1 de la cuarentena",
			"texto": "Un virus respiratorio que la prensa llama «la Fiebre Gris» se propagó en pocos días. Primero tos y fiebre; después, los enfermos pierden el juicio. El gobierno cerró la ciudad: nadie entra y nadie sale."},
		{"quien": "alvaro", "animo": "worried", "radio": true,
			"texto": "¿Doctora Ruiz? ¿Me copia? Habla Álvaro, desde la radio del San Rafael. Los infectados no son monstruos, doctora: están enfermos y todavía se pueden salvar."},
		{"quien": "elena", "animo": "determined",
			"texto": "Acabo de salir de un turno de 36 horas, Álvaro. No tengo armas: un tubo, unas jeringas con sedante y lo que sé de medicina."},
		{"quien": "alvaro", "animo": "confident", "radio": true,
			"texto": "Con eso basta. Sédelos y tráigalos al hospital: cada paciente que atendamos le quita fuerza a la epidemia. En la universidad, la doctora Mena cree estar cerca de una cura."},
	],
	"nivel1": [
		{"quien": "alvaro", "animo": "neutral", "radio": true,
			"texto": "Doctora, el retén del hospital no deja pasar a nadie con las manos vacías: tres pacientes sedados en la ambulancia y el antiviral de la farmacia."},
		{"quien": "elena", "animo": "determined",
			"texto": "Entendido. Primero los que anden solos, agachada y por la espalda. Si hago ruido, se me vienen encima."},
	],
	"nivel2": [
		{"quien": "alvaro", "animo": "worried",
			"texto": "Bienvenida al San Rafael. Tenemos seis camillas y pocos suministros: cada camilla abierta gasta material."},
		{"quien": "elena", "animo": "neutral",
			"texto": "Y si la sala de espera se llena, la gente se cansa y vuelve a la calle enferma. ¿Cuánto tarda el convoy?"},
		{"quien": "alvaro", "animo": "worried",
			"texto": "Tres noches. De noche atacan la entrada sur; a los que usted sede, el personal los pasa a la fila."},
	],
	"nivel3": [
		{"quien": "alvaro", "animo": "worried", "radio": true,
			"texto": "La Plaza de Bolívar está tomada. Los corredores siguen el ruido y las masas se mueven en bloque, como un enjambre."},
		{"quien": "elena", "animo": "determined",
			"texto": "Quedan vecinos atrapados. Los llevo a la ambulancia y, de paso, reúno muestras para la doctora Mena."},
		{"quien": "alvaro", "animo": "neutral", "radio": true,
			"texto": "Si alguno entra en pánico, no la va a seguir: aléjelo primero de los infectados."},
	],
	"nivel4": [
		{"quien": "mena", "animo": "urgent", "radio": true,
			"texto": "Doctora Ruiz, habla Mena. Con diez muestras puedo sintetizar la cura, pero me faltan las del primer caso: el Paciente Cero está en el auditorio."},
		{"quien": "elena", "animo": "determined",
			"texto": "Voy para allá. Tenga listo el sintetizador."},
	],
	"jefe": [
		{"quien": "mena", "animo": "urgent", "radio": true,
			"texto": "¡Es él! Cambia de conducta sin aviso: embiste, tose y llama a la masa. No lo lastime de más: si lo seda, tendremos sus muestras."},
		{"quien": "elena", "animo": "determined",
			"texto": "Entonces lo leo fase por fase... y lo sedo."},
	],
	"final": [
		{"quien": "mena", "animo": "hopeful",
			"texto": "Diez muestras, y entre ellas las del Paciente Cero. Es suficiente, doctora."},
		{"quien": "mena", "animo": "neutral",
			"texto": "El sintetizador ya está trabajando. Mañana mismo podemos empezar a vacunar en el San Rafael."},
		{"quien": "elena", "animo": "neutral",
			"texto": "Cada infectado que sedamos era una persona que podía volver a casa. Ahora van a poder hacerlo."},
		{"quien": "alvaro", "animo": "confident", "radio": true,
			"texto": "Doctora, la barra de la ciudad está bajando. Tunja vuelve a respirar. Lo logró."},
	],
}

const META_ENTREGAS_N1 := 3  # triaje de calle: sedados entregados en la ambulancia para abrir el retén
const META_RESCATES := 8   # nivel 3 (el GDD pedía 10; el mapa tiene 6 puntos de aparición de ciudadanos)
const META_MUESTRAS_N3 := 5
const META_MUESTRAS_N4 := 10

# --- Audio procedural: [f0, f1, duración, mezcla de ruido, volumen, onda cuadrada] ---
const SFX := {
	"golpe": [180.0, 60.0, 0.12, 0.5, 0.7, false],
	"critico": [520.0, 90.0, 0.22, 0.35, 0.8, true],
	"dardo": [900.0, 300.0, 0.10, 0.2, 0.5, false],
	"extintor": [400.0, 200.0, 0.45, 0.95, 0.5, false],
	"recoger": [520.0, 880.0, 0.12, 0.0, 0.5, false],
	"raro": [660.0, 1320.0, 0.35, 0.0, 0.5, false],
	"tos": [160.0, 90.0, 0.25, 0.8, 0.5, false],
	"grunido": [110.0, 70.0, 0.40, 0.3, 0.6, true],
	"dano": [140.0, 50.0, 0.20, 0.6, 0.8, true],
	"sedado": [300.0, 120.0, 0.35, 0.1, 0.5, false],
	"radio": [1200.0, 1100.0, 0.50, 0.9, 0.3, false],
	"alarma": [700.0, 500.0, 0.50, 0.0, 0.5, true],
	"clic": [800.0, 700.0, 0.05, 0.0, 0.4, true],
	"curar": [440.0, 660.0, 0.25, 0.0, 0.5, false],
	"entrega": [500.0, 1000.0, 0.30, 0.0, 0.5, false],
	"vacio": [200.0, 180.0, 0.06, 0.3, 0.4, true],
	"sirena": [600.0, 900.0, 0.80, 0.0, 0.4, false],
	"mutacion": [90.0, 240.0, 0.50, 0.4, 0.6, true],
	"voz": [380.0, 360.0, 0.035, 0.0, 0.18, true],
}
## Pistas: notas (Hz, 0 = silencio), duración de cada paso (s), bajo (Hz) y pulso (latido de monitor).
const PISTAS := {
	"menu": {"notas": [220.0, 261.6, 329.6, 261.6, 196.0, 246.9, 293.7, 246.9], "paso": 0.8, "bajo": 55.0, "pulso": false},
	"barrio": {"notas": [146.8, 0.0, 174.6, 0.0, 164.8, 0.0, 130.8, 0.0], "paso": 0.9, "bajo": 73.4, "pulso": false},
	"hospital": {"notas": [880.0, 0.0, 0.0, 0.0, 880.0, 0.0, 659.3, 0.0], "paso": 0.5, "bajo": 110.0, "pulso": true},
	"tension": {"notas": [110.0, 110.0, 130.8, 110.0, 103.8, 110.0, 146.8, 123.5], "paso": 0.35, "bajo": 55.0, "pulso": true},
	"jefe": {"notas": [146.8, 174.6, 220.0, 293.7, 277.2, 220.0, 174.6, 164.8], "paso": 0.3, "bajo": 73.4, "pulso": true},
	"victoria": {"notas": [261.6, 329.6, 392.0, 523.3, 392.0, 440.0, 523.3, 659.3], "paso": 0.45, "bajo": 130.8, "pulso": false},
	"derrota": {"notas": [196.0, 0.0, 185.0, 0.0, 174.6, 0.0, 146.8, 0.0], "paso": 0.9, "bajo": 49.0, "pulso": false},
}

# --- Generadores del taller anterior (uno por familia de modelos, como en la tabla de mapeo) ---
var semilla := 2026
var gen_lineal        # caminatas, agentes, Markov
var gen_mult          # llegadas y servicios de la cola
var gen_adit          # Monte Carlo: daño, críticos, drops, radio

# --- Modelos persistentes ---
var sir
var cola
var mc
var caminata

# --- Partida ---
var nivel := 1
var hp := 100.0
var viral := 0.0
var tiene := {"tubo": true, "extintor": false, "dardos": false, "jeringa": true}
var arma := "tubo"
var dardos := 0
var cargas_extintor := 0
var jeringas := 2
var inv := {"vendas": 1, "cubrebocas": 0, "adrenalina": 0, "antiviral": 0}
var consumible := 0
var muestras := 0
var suministros := 30.0
var t_mascara := 0.0
var t_adrenalina := 0.0
var dia := 0.0
var t_juego := 0.0
var lam_factor := 1.0
var tasa_atencion := 0.0   # pacientes/min atendidos (ventana de 10 min)
var historial := []        # [[día, S, I, R], ...] para las gráficas
var stats := {}
var feed := []             # últimos eventos de los modelos (texto superpuesto para el video)
var resultado := ""        # "derrota" o "victoria"
var causa := ""            # hp, viral, ciudad, hospital
var nivel_actual: Node = null
var dialogos_vistos := {}      # claves de Juego.DIALOGOS ya mostradas en esta partida
var dialogos_activos := true   # las pruebas automáticas los apagan
var info_modo := "controles"   # qué muestra escenas/info.tscn: controles o creditos
var _instantanea := {}
var _acum_sir := 0.0
var _t_atendidos := []
var _dia_hist := 0.0

var _sfx := {}
var _pistas := {}
var _voces: Array[AudioStreamPlayer] = []
var _voz := 0
var _musica: AudioStreamPlayer
var _pista_actual := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_crear_acciones()
	for k in 6:
		var p := AudioStreamPlayer.new()
		p.volume_db = -8.0
		add_child(p)
		_voces.append(p)
	_musica = AudioStreamPlayer.new()
	_musica.volume_db = -16.0
	add_child(_musica)
	nueva_partida()


# ======================================================================================================== partida

func nueva_partida(semilla_ := 2026) -> void:
	semilla = semilla_
	gen_lineal = Prng.lcg(semilla)
	gen_mult = Prng.minstd(semilla)
	gen_adit = Prng.aditivo(semilla)
	sir = SIR.new(180000.0, 10.0, 0.3, 0.1)
	cola = Cola.new(gen_mult, 0.4, MU_CAMILLA, 2, PACIENCIA)
	cola.iniciar()
	mc = MonteCarlo.new(gen_adit)
	caminata = Caminata.new(gen_lineal)
	nivel = 1
	hp = 100.0
	viral = 0.0
	tiene = {"tubo": true, "extintor": false, "dardos": false, "jeringa": true}
	arma = "tubo"
	dardos = 0
	cargas_extintor = 0
	jeringas = 2
	inv = {"vendas": 1, "cubrebocas": 0, "adrenalina": 0, "antiviral": 0}
	consumible = 0
	muestras = 0
	suministros = 30.0
	t_mascara = 0.0
	t_adrenalina = 0.0
	dia = 0.0
	t_juego = 0.0
	lam_factor = 1.0
	tasa_atencion = 0.0
	historial = [[0.0, sir.s, sir.i, sir.r]]
	feed = []
	dialogos_vistos = {}
	resultado = ""
	causa = ""
	_acum_sir = 0.0
	_t_atendidos = []
	_dia_hist = 0.0
	stats = {
		"sedados": 0, "entregados": 0, "rescatados": 0, "atendidos": 0, "abandonos": 0, "muertes": 0,
		"pasos": {"N": 0, "S": 0, "E": 0, "O": 0}, "pasos_sesgados": 0, "pasos_hacia_fuente": 0, "sesgo_ultimo": 0.0,
		"ataques": 0, "criticos": 0, "ataques_espalda": 0, "criticos_espalda": 0,
		"dano": {"tubo": [0, 0.0], "extintor": [0, 0.0], "dardos": [0, 0.0], "jeringa": [0, 0.0]},
		"drops": {}, "radio": [0.0, 0.0, 0.0, 0],
		"contagios_calle": 0, "phi": 0.0, "transiciones_markov": 0, "fases_jefe": [0, 0, 0, 0], "fase_jefe": -1,
		"prueba": "",
	}
	_instantanea = _capturar()


func _capturar() -> Dictionary:
	return {
		"nivel": nivel, "hp": hp, "viral": viral, "tiene": tiene.duplicate(), "arma": arma, "dardos": dardos,
		"cargas": cargas_extintor, "jeringas": jeringas, "inv": inv.duplicate(), "muestras": muestras,
		"suministros": suministros, "dia": dia, "t_juego": t_juego,
		"sir": [sir.s, sir.i, sir.r, sir.f_cub, sir.atendidos_dia], "camillas": cola.c,
		"historial": historial.duplicate(true), "stats": stats.duplicate(true),
	}


func _restaurar(d: Dictionary) -> void:
	nivel = d["nivel"]
	hp = d["hp"]
	viral = d["viral"]
	tiene = d["tiene"].duplicate()
	arma = d["arma"]
	dardos = d["dardos"]
	cargas_extintor = d["cargas"]
	jeringas = d["jeringas"]
	inv = d["inv"].duplicate()
	muestras = d["muestras"]
	suministros = d["suministros"]
	dia = d["dia"]
	t_juego = d["t_juego"]
	var e: Array = d["sir"]
	sir.s = e[0]
	sir.i = e[1]
	sir.r = e[2]
	sir.f_cub = e[3]
	sir.atendidos_dia = e[4]
	historial = d["historial"].duplicate(true)
	stats = d["stats"].duplicate(true)
	# la cola se reinicia vacía con las mismas camillas (su estado interno no se guarda)
	cola.c = d["camillas"]
	cola.iniciar()
	t_mascara = 0.0
	t_adrenalina = 0.0
	_t_atendidos = []
	tasa_atencion = 0.0
	_dia_hist = dia
	Engine.time_scale = 1.0


## Lo llama cada nivel al empezar: fija el punto de reintento y guarda la partida.
## true la primera vez que se pide un diálogo en la partida (y lo marca como visto).
func marcar_dialogo(clave: String) -> bool:
	if not dialogos_activos or dialogos_vistos.has(clave) or not DIALOGOS.has(clave):
		return false
	dialogos_vistos[clave] = true
	return true


func iniciar_nivel() -> void:
	hp = maxf(hp, 40.0)  # nunca se empieza un nivel al borde de la muerte
	_instantanea = _capturar()
	var cfg := ConfigFile.new()
	cfg.set_value("partida", "datos", _instantanea)
	cfg.set_value("partida", "semilla", semilla)
	cfg.set_value("partida", "guardada", Time.get_datetime_string_from_system())
	cfg.save(PARTIDA)


func hay_partida() -> bool:
	return FileAccess.file_exists(PARTIDA)


func continuar_partida() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PARTIDA) != OK:
		nueva_partida()
	else:
		nueva_partida(cfg.get_value("partida", "semilla", 2026))
		var d = cfg.get_value("partida", "datos", null)
		if d is Dictionary and d.has("nivel"):
			_restaurar(d)
			_instantanea = d
	ir_a(ESCENA_BRIEFING)


## Reinicia el nivel actual: la epidemia vuelve al estado que tenía al empezar el nivel (GDD §9).
func reintentar_nivel() -> void:
	var causa_previa := causa
	_restaurar(_instantanea)
	if causa_previa == "ciudad":
		# La alcaldía reparte cubrebocas: evita que un reintento quede condenado desde el primer segundo.
		sir.f_cub = minf(1.0, sir.f_cub + 0.15)
		sir.i *= 0.8
	resultado = ""
	causa = ""
	ir_a(ESCENA_NIVEL)


func completar_nivel() -> void:
	nivel_actual = null
	if nivel >= NIVELES.size():
		resultado = "victoria"
		ir_a(ESCENA_FIN)
	else:
		nivel += 1
		ir_a(ESCENA_BRIEFING)


func derrota(causa_: String) -> void:
	if resultado != "":
		return
	resultado = "derrota"
	causa = causa_
	stats["muertes"] += 1
	nivel_actual = null
	ir_a(ESCENA_FIN)


func ir_a(escena: String) -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file.call_deferred(escena)


func cfg_nivel() -> Dictionary:
	return NIVELES[clampi(nivel, 1, NIVELES.size()) - 1]


# ========================================================================================================= mundo

func fraccion_infectados() -> float:
	return sir.i / sir.n


## Tasa de llegada espontánea al hospital (pacientes/min): crece con I/N (acople SIR → cola).
func lambda_actual() -> float:
	return (0.4 + 6.0 * minf(1.0, fraccion_infectados())) * lam_factor


## Avanza el SIR (RK4, Δt = 0,1 día) y la cola del hospital. Devuelve los eventos de la cola de este cuadro.
func avanzar_mundo(delta: float) -> Array:
	t_juego += delta
	t_mascara = maxf(0.0, t_mascara - delta)
	t_adrenalina = maxf(0.0, t_adrenalina - delta)
	_acum_sir += delta * DIAS_POR_SEGUNDO
	while _acum_sir >= 0.1:
		_acum_sir -= 0.1
		sir.paso(0.1)
		dia += 0.1
	if dia - _dia_hist >= 1.0:
		_dia_hist = dia
		historial.append([dia, sir.s, sir.i, sir.r])

	cola.lam = lambda_actual()
	var eventos: Array = cola.avanzar(cola.reloj + delta / SEG_POR_MINUTO)
	for ev in eventos:
		match ev[0]:
			"atendido":
				stats["atendidos"] += 1
				_t_atendidos.append(cola.reloj)
			"abandono":
				stats["abandonos"] += 1
				sumar_infectados()
				registrar("M2 Cola", "un paciente abandona la fila y vuelve a la calle (+I)")
	while not _t_atendidos.is_empty() and _t_atendidos[0] < cola.reloj - 10.0:
		_t_atendidos.pop_front()
	tasa_atencion = _t_atendidos.size() / minf(10.0, maxf(1.0, cola.reloj))
	# acople cola → SIR con la fórmula del modelo, γ_ef = γ + atendidos/(I + K): el hospital atiende una
	# fracción de los infectados proporcional a su ritmo, es decir γ_ef = γ + GAMMA_POR_PACIENTE · tasa
	sir.atendidos_dia = tasa_atencion * GAMMA_POR_PACIENTE * (sir.i + SIR.K_SATURACION)
	return eventos


## Abandono de la cola, contagio en la calle o irrupción en el hospital: sube I en el SIR.
func sumar_infectados() -> void:
	var k: float = minf(maxf(5.0, FRACCION_REBROTE * sir.i), sir.s)  # salen de S: la población se conserva
	sir.s -= k
	sir.abandono_cola(k)


## Paciente que trae Elena al hospital o a una ambulancia.
func entregar_paciente(tipo: String) -> void:
	cola.llegada_externa(tipo)
	if tipo == "infectado":
		stats["entregados"] += 1
		muestras += 1  # a cada paciente sedado se le toma una muestra
		registrar("M2 Cola", "infectado sedado entra a la fila (cola = %d)" % cola.en_cola())
	else:
		stats["rescatados"] += 1
		sir.rescate(ESCALA_PERSONAS)
		registrar("M5 SIR", "ciudadano a salvo: S → protegido")
	sonido("entrega")


func recoger(tipo: String) -> String:
	match tipo:
		"vendas", "cubrebocas", "adrenalina", "antiviral":
			inv[tipo] += 1
		"dardos":
			dardos += 3
		"muestra":
			muestras += 1
		"botiquin":
			hp = minf(100.0, hp + 50.0)
		"suministros":
			suministros += 15.0
	sonido("raro" if tipo in ["adrenalina", "muestra"] else "recoger")
	return OBJETOS[tipo]["nombre"]


## Usa el consumible seleccionado. Devuelve el texto para el HUD ("" si no había).
func usar_consumible() -> String:
	var tipo: String = CONSUMIBLES[consumible]
	if inv[tipo] <= 0:
		sonido("vacio")
		return ""
	inv[tipo] -= 1
	match tipo:
		"vendas":
			hp = minf(100.0, hp + 25.0)
			sonido("curar")
			return "Vendas: +25 HP"
		"cubrebocas":
			t_mascara = 90.0
			sir.f_cub = minf(1.0, sir.f_cub + F_CUB_POR_CUBREBOCAS)
			sonido("curar")
			registrar("M5 SIR", "cubrebocas repartidos: β_ef = %.3f" % sir.beta_ef())
			return "Cubrebocas: -50 % carga viral (90 s) y baja β"
		"adrenalina":
			t_adrenalina = 20.0
			sonido("raro")
			return "Adrenalina: +10 % crítico y +30 % velocidad (20 s)"
		"antiviral":
			viral = maxf(0.0, viral - 40.0)
			sonido("curar")
			return "Antiviral: -40 % carga viral"
	return ""


func siguiente_consumible() -> void:
	for k in CONSUMIBLES.size():
		consumible = (consumible + 1) % CONSUMIBLES.size()
		if inv[CONSUMIBLES[consumible]] > 0:
			return


func cambiar_arma(paso: int) -> void:
	var idx := ARMAS_ORDEN.find(arma)
	for k in ARMAS_ORDEN.size():
		idx = posmod(idx + paso, ARMAS_ORDEN.size())
		if tiene[ARMAS_ORDEN[idx]]:
			arma = ARMAS_ORDEN[idx]
			sonido("clic")
			return


func elegir_arma(idx: int) -> void:
	if idx >= 0 and idx < ARMAS_ORDEN.size() and tiene[ARMAS_ORDEN[idx]]:
		arma = ARMAS_ORDEN[idx]
		sonido("clic")


func municion(arma_: String) -> int:
	match arma_:
		"extintor":
			return cargas_extintor
		"dardos":
			return dardos
		"jeringa":
			return jeringas
	return -1


## Composición de enemigos que usa la radio: crece con I/N (acople SIR → Monte Carlo).
func encuentros_radio() -> Array:
	var lista := []
	var factor := 1.0 + 2.0 * fraccion_infectados()
	var base: Dictionary = cfg_nivel()["encuentros"]
	for tipo in base:
		for k in roundi(base[tipo] * factor):
			lista.append(tipo)
	return lista


## Evento de un modelo: alimenta el texto superpuesto del HUD.
func registrar(modelo: String, texto: String) -> void:
	feed.append([t_juego, modelo, texto])
	if feed.size() > 40:
		feed.pop_front()


# ========================================================================================================= audio

func sonido(nombre: String) -> void:
	if not SFX.has(nombre):
		return
	if not _sfx.has(nombre):
		var p: Array = SFX[nombre]
		_sfx[nombre] = _efecto(p[0], p[1], p[2], p[3], p[4], p[5])
	var voz := _voces[_voz]
	_voz = (_voz + 1) % _voces.size()
	voz.stream = _sfx[nombre]
	voz.pitch_scale = randf_range(0.94, 1.06)  # pequeña variación para que no suene repetido
	voz.play()


func musica(nombre: String) -> void:
	if nombre == _pista_actual:
		return
	_pista_actual = nombre
	if not PISTAS.has(nombre):
		_musica.stop()
		return
	if not _pistas.has(nombre):
		_pistas[nombre] = _pista(PISTAS[nombre])
	_musica.stream = _pistas[nombre]
	_musica.play()


func _wav(muestras_: PackedFloat32Array, tasa: int, bucle := false) -> AudioStreamWAV:
	var datos := PackedByteArray()
	datos.resize(muestras_.size() * 2)
	for k in muestras_.size():
		datos.encode_s16(k * 2, int(clampf(muestras_[k], -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = tasa
	w.stereo = false
	w.data = datos
	if bucle:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = muestras_.size()
	return w


func _efecto(f0: float, f1: float, dur: float, ruido: float, vol: float, cuadrada: bool) -> AudioStreamWAV:
	var tasa := 22050
	var n := int(dur * tasa)
	var m := PackedFloat32Array()
	m.resize(n)
	var fase := 0.0
	for k in n:
		var t := float(k) / float(n)
		fase += TAU * lerpf(f0, f1, t) / float(tasa)
		var v := sin(fase)
		if cuadrada:
			v = 1.0 if v > 0.0 else -1.0
		v = lerpf(v, randf() * 2.0 - 1.0, ruido)
		m[k] = v * (1.0 - t) * (1.0 - t) * minf(1.0, t * 40.0) * vol
	return _wav(m, tasa)


func _pista(def: Dictionary) -> AudioStreamWAV:
	var tasa := 11025
	var notas: Array = def["notas"]
	var paso: float = def["paso"]
	var dur := notas.size() * paso
	var n := int(dur * tasa)
	var bajo: float = roundf(float(def["bajo"]) * dur) / dur  # ciclos enteros: el bucle no hace clic
	var pulso: bool = def["pulso"]
	var m := PackedFloat32Array()
	m.resize(n)
	for k in n:
		var t := float(k) / float(tasa)
		var idx := mini(int(t / paso), notas.size() - 1)
		var tn := t - idx * paso   # tiempo dentro de la nota
		var f: float = notas[idx]
		var v := 0.10 * sin(TAU * bajo * t) * (0.8 + 0.2 * sin(TAU * t / dur))
		if f > 0.0:
			var env := exp(-3.0 * tn / paso) * minf(1.0, tn * 60.0)
			v += 0.22 * env * (sin(TAU * f * tn) + 0.3 * sin(TAU * 2.0 * f * tn))
		if pulso and tn < 0.09:
			v += 0.25 * sin(TAU * 60.0 * tn) * (1.0 - tn / 0.09)
		m[k] = v
	return _wav(m, tasa, true)


# ====================================================================================================== controles

func _crear_acciones() -> void:
	_accion("mover_izquierda", [KEY_A, KEY_LEFT])
	_accion("mover_derecha", [KEY_D, KEY_RIGHT])
	_accion("mover_arriba", [KEY_W, KEY_UP])
	_accion("mover_abajo", [KEY_S, KEY_DOWN])
	_accion("atacar", [KEY_SPACE], [MOUSE_BUTTON_LEFT])
	_accion("agacharse", [KEY_SHIFT])
	_accion("correr", [KEY_CTRL])
	_accion("interactuar", [KEY_E])
	_accion("cambiar_arma", [KEY_Q])
	_accion("arma_1", [KEY_1])
	_accion("arma_2", [KEY_2])
	_accion("arma_3", [KEY_3])
	_accion("arma_4", [KEY_4])
	_accion("usar", [KEY_F])
	_accion("siguiente_consumible", [KEY_R, KEY_TAB])
	_accion("camilla_mas", [KEY_KP_ADD, KEY_EQUAL, KEY_BRACKETRIGHT])
	_accion("camilla_menos", [KEY_KP_SUBTRACT, KEY_MINUS, KEY_SLASH])
	_accion("panel_simulacion", [KEY_F1])
	_accion("prueba_ataques", [KEY_F2])
	_accion("prueba_drops", [KEY_F3])


func _accion(nombre: String, teclas: Array, botones: Array = []) -> void:
	if InputMap.has_action(nombre):
		return
	InputMap.add_action(nombre)
	for tecla in teclas:
		var ev := InputEventKey.new()
		ev.physical_keycode = tecla
		InputMap.action_add_event(nombre, ev)
	for boton in botones:
		var em := InputEventMouseButton.new()
		em.button_index = boton
		InputMap.action_add_event(nombre, em)


# ==================================================================================================== sensaciones

## Hit-stop: congela un instante el juego para vender el impacto. El temporizador ignora time_scale.
func hit_stop(duracion := 0.06) -> void:
	if Engine.time_scale < 1.0:
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(duracion, true, false, true).timeout
	Engine.time_scale = 1.0


# ======================================================================================================= pruebas

## Caso de prueba 5 (GDD §17): 1 000 ataques por la espalda con el tubo. Esperado: tasa de críticos ≈ 0,35.
func prueba_ataques(n := 1000) -> String:
	var criticos := 0
	var suma := 0.0
	for k in n:
		var r: Array = mc.dano("tubo", true, false)
		suma += r[0]
		criticos += int(r[1])
	var txt := "PRUEBA F2: %d ataques por la espalda (tubo) -> críticos %.3f (esperado 0,350), daño medio %.2f (teórico 13,50)" % [
		n, float(criticos) / n, suma / n]
	stats["prueba"] = txt
	return txt


## Caso de prueba 6: 500 Errantes neutralizados. χ² con 5 g. l. frente a la tabla de drops (crítico 11,07).
func prueba_drops(n := 500) -> String:
	var tabla: Array = MonteCarlo.DROPS["Errante"]
	var cuenta := {}
	for fila in tabla:
		cuenta[fila[0]] = 0
	for k in n:
		cuenta[mc.drop("Errante")] += 1
	var chi2 := 0.0
	for fila in tabla:
		var esperado: float = fila[1] * n
		chi2 += pow(cuenta[fila[0]] - esperado, 2) / esperado
	var txt := "PRUEBA F3: %d drops de Errante -> chi2 = %.2f (%s; crítico 11,07)  %s" % [
		n, chi2, "no se rechaza H0" if chi2 < 11.07 else "se rechaza H0", str(cuenta)]
	stats["prueba"] = txt
	return txt
