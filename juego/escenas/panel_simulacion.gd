## Panel de simulación (F1): parámetros y métricas en vivo de los cinco modelos y de la cadena de Markov,
## con el valor teórico al lado cuando existe. Sirve para el video, las capturas y la tabla de verificación (4.2).
## F2 y F3 ejecutan los casos de prueba 5 y 6 del GDD (1 000 ataques por la espalda, 500 drops de Errante).
extends CanvasLayer

const Kit = preload("res://escenas/ui_kit.gd")
const Cola = preload("res://modelos/Cabra_Coy_modelo2_colas.gd")
const MonteCarlo = preload("res://modelos/Sanchez_Diego_modelo3_montecarlo.gd")
const Markov = preload("res://modelos/Ruiz_Sergio_markov.gd")
const ANCHO := 604.0
const ALTO := 432.0
const GRAFICA := Rect2(388, 344, 200, 72)

var raiz: Control
var texto: Label
var linea_s: Line2D
var linea_i: Line2D
var linea_r: Line2D
var _t := 0.0
var _pi_jefe := []


func _ready() -> void:
	layer = 5
	raiz = Control.new()
	raiz.position = Vector2(348, 38)
	raiz.visible = false
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	var fondo := ColorRect.new()
	fondo.color = Color(Kit.TINTA, 0.9)
	fondo.size = Vector2(ANCHO, ALTO)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(fondo)
	texto = Kit.texto("", Vector2(8, 6), Kit.fuente("PixelOperator8.ttf"), 8, Kit.BLANCO)
	texto.size = Vector2(ANCHO - 16.0, ALTO - 12.0)
	texto.clip_text = true
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(texto)
	var marco := ColorRect.new()
	marco.color = Color(0.17, 0.18, 0.2, 1.0)
	marco.position = GRAFICA.position
	marco.size = GRAFICA.size
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(marco)
	linea_s = _linea(Color("#4FA3D1"))
	linea_i = _linea(Color("#C0392B"))
	linea_r = _linea(Color("#EAF2F5"))
	var umbral := _linea(Color("#E0A030"))
	var y_umbral: float = GRAFICA.end.y - GRAFICA.size.y * Juego.UMBRAL_COLAPSO
	umbral.points = PackedVector2Array([Vector2(GRAFICA.position.x, y_umbral), Vector2(GRAFICA.end.x, y_umbral)])
	_pi_jefe = Markov.estacionaria(Markov.P_JEFE)


func _linea(color: Color) -> Line2D:
	var l := Line2D.new()
	l.width = 1.0
	l.default_color = color
	raiz.add_child(l)
	return l


func alternar() -> void:
	raiz.visible = not raiz.visible
	_t = 0.0


func mostrar() -> void:
	raiz.visible = true
	_t = 0.0


func _process(delta: float) -> void:
	if not raiz.visible:
		return
	_t -= delta
	if _t > 0.0:
		return
	_t = 0.25
	texto.text = _componer()
	_graficar()


func _c(v: float, decimales := 2) -> String:
	return String.num(v, decimales).replace(".", ",")


func _componer() -> String:
	var s: Dictionary = Juego.stats
	var l := []
	l.append("PANEL DE SIMULACIÓN (F1) · semilla %d · t = %d s · F2/F3: casos de prueba" % [Juego.semilla,
		int(Juego.t_juego)])

	# --- Modelo 1
	var pasos: Dictionary = s["pasos"]
	var total: int = pasos["N"] + pasos["S"] + pasos["E"] + pasos["O"]
	var div := maxf(1.0, float(total))
	l.append("")
	l.append("M1 CAMINATA ALEATORIA 2D · PRNG congruencial lineal")
	l.append("  pasos %d  N %s  S %s  E %s  O %s  (0,25 sin sesgo)" % [total, _c(pasos["N"] / div),
		_c(pasos["S"] / div), _c(pasos["E"] / div), _c(pasos["O"] / div)])
	var sesgados: int = s["pasos_sesgados"]
	l.append("  sesgo b último %s · con sesgo %d, hacia la fuente %s (esperado 0,25 + b)" % [_c(s["sesgo_ultimo"]),
		sesgados, _c(s["pasos_hacia_fuente"] / maxf(1.0, float(sesgados)))])

	# --- Modelo 2
	var cola = Juego.cola
	var teo: Dictionary = Cola.teoria(cola.lam, cola.mu, cola.c)
	var estable: bool = teo["rho"] < 1.0
	l.append("")
	l.append("M2 COLA M/M/c DEL HOSPITAL · PRNG multiplicativo (MINSTD) · 1 min = %d s" % int(Juego.SEG_POR_MINUTO))
	l.append("  lambda %s  mu %s  c %d  rho %s  paciencia %d min  en cola %d" % [_c(cola.lam), _c(cola.mu), cola.c,
		_c(teo["rho"]), int(Juego.PACIENCIA), cola.en_cola()])
	l.append("  Wq medido %s / teórico %s min · Lq medido %s / teórico %s" % [_c(cola.wq_medido()),
		_c(teo["Wq"]) if estable else "inf", _c(cola.lq_medido()), _c(teo["Lq"]) if estable else "inf"])
	l.append("  llegadas %d · atendidos %d · abandonos %d · tasa %s pac/min" % [cola.llegadas, cola.atendidos,
		cola.abandonos, _c(Juego.tasa_atencion)])

	# --- Modelo 3
	var ataques: int = s["ataques"]
	var espalda: int = s["ataques_espalda"]
	l.append("")
	l.append("M3 MONTE CARLO · PRNG aditivo (Fibonacci retrasado)")
	l.append("  ataques %d · críticos %s · por la espalda %d con críticos %s (tubo: 0,35)" % [ataques,
		_c(s["criticos"] / maxf(1.0, float(ataques))), espalda, _c(s["criticos_espalda"] / maxf(1.0, float(espalda)))])
	var medias := []
	for arma in ["tubo", "dardos", "jeringa", "extintor"]:
		var d: Array = s["dano"][arma]
		var n: int = d[0]
		medias.append("%s %s (E %s)" % [arma, _c(d[1] / n) if n > 0 else "-", _c(_dano_esperado(arma))])
	l.append("  daño medio: " + "  ".join(medias))
	var drops: Dictionary = s["drops"]
	for enemigo in drops:
		var partes := []
		var fila: Dictionary = drops[enemigo]
		for objeto in fila:
			partes.append("%s %d" % [objeto, fila[objeto]])
		l.append("  drops %s: %s" % [enemigo, ", ".join(partes)])
	var radio: Array = s["radio"]
	if radio[3] > 0:
		l.append("  radio: p = %s  IC 95 %% [%s, %s]  N = %d" % [_c(radio[0], 3), _c(radio[1], 3), _c(radio[2], 3),
			radio[3]])

	# --- Modelo 4
	var estados := {"PATRULLA": 0, "ALERTA": 0, "PERSECUCION": 0, "BUSQUEDA": 0}
	var caminantes := 0
	var masa := 0
	for e in get_tree().get_nodes_in_group("enemigos"):
		if e.vida != "activo":
			continue
		if e.tipo == "Corredor" and e.fsm != null:
			estados[e.fsm.estado] += 1
		elif e.tipo == "Masa":
			masa += 1
		elif e.tipo == "Errante" or e.tipo == "Tosedor":
			caminantes += 1
	var ciudadanos := get_tree().get_nodes_in_group("ciudadanos")
	var panico := 0.0
	for c in ciudadanos:
		panico += c.panico()
	l.append("")
	l.append("M4 AGENTES · PRNG congruencial lineal")
	l.append("  corredores: patrulla %d  alerta %d  persecución %d  búsqueda %d · caminantes %d" % [
		estados["PATRULLA"], estados["ALERTA"], estados["PERSECUCION"], estados["BUSQUEDA"], caminantes])
	l.append("  masa: %d individuos, phi = %s (1 = coordinado) · ciudadanos %d, pánico medio %s" % [masa,
		_c(s["phi"]), ciudadanos.size(), _c(panico / maxf(1.0, float(ciudadanos.size())))])
	l.append("  contagios en la calle %d · rescatados %d · sedados %d · entregados %d" % [s["contagios_calle"],
		s["rescatados"], s["sedados"], s["entregados"]])

	# --- Modelo 5
	var sir = Juego.sir
	l.append("")
	l.append("M5 DINÁMICA DE SISTEMAS: SIR · RK4, dt = 0,1 día · %s días/s" % _c(Juego.DIAS_POR_SEGUNDO))
	l.append("  día %s   S %d   I %d   R %d   I/N %s %% (límite %d %%)" % [_c(Juego.dia, 1), int(sir.s), int(sir.i),
		int(sir.r), _c(100.0 * sir.i / sir.n), roundi(Juego.UMBRAL_COLAPSO * 100.0)])
	l.append("  beta_ef %s (f_cub %s)   gamma_ef %s (atendidos/día %d)   R0_ef %s" % [_c(sir.beta_ef(), 3),
		_c(sir.f_cub), _c(sir.gamma_ef(), 3), int(sir.atendidos_dia), _c(sir.beta_ef() / sir.gamma_ef())])

	# --- Markov
	var fases: Array = s["fases_jefe"]
	var visitas: int = fases[0] + fases[1] + fases[2] + fases[3]
	l.append("")
	l.append("CADENA DE MARKOV · Errante -> Tosedor -> Corredor: %d transiciones (1 min = %d s)" % [
		s["transiciones_markov"], 20])
	if visitas > 0:
		var partes_jefe := []
		for k in 4:
			partes_jefe.append("%s %s (pi %s)" % [Markov.FASES[k].left(9), _c(fases[k] / float(visitas)),
				_c(_pi_jefe[k])])
		l.append("  jefe: " + "  ".join(partes_jefe))
	var prueba: String = s["prueba"]
	if prueba != "":
		l.append("")
		l.append(prueba)
	l.append("")
	l.append("SIR en vivo: S azul, I rojo, R blanco; línea ámbar = límite de colapso")
	return "\n".join(l)


## E[D] = μ_X · (1 + p_crit · (k − 1)) con la p_crit base del arma (sin bonificaciones).
func _dano_esperado(arma: String) -> float:
	var def: Array = MonteCarlo.ARMAS[arma]
	var media := 0.0
	match def[0]:
		"uniforme":
			media = (def[1][0] + def[1][1]) / 2.0
		_:
			media = def[1][0]
	return media * (1.0 + def[2] * (MonteCarlo.K_CRIT - 1.0))


func _graficar() -> void:
	var h: Array = Juego.historial
	if h.size() < 2:
		return
	var n: float = Juego.sir.n
	var t_max: float = maxf(1.0, h[-1][0])
	var ps := PackedVector2Array()
	var pi := PackedVector2Array()
	var pr := PackedVector2Array()
	var salto := maxi(1, h.size() / 200)
	for k in range(0, h.size(), salto):
		var fila: Array = h[k]
		var x: float = GRAFICA.position.x + GRAFICA.size.x * fila[0] / t_max
		ps.append(Vector2(x, GRAFICA.end.y - GRAFICA.size.y * fila[1] / n))
		pi.append(Vector2(x, GRAFICA.end.y - GRAFICA.size.y * fila[2] / n))
		pr.append(Vector2(x, GRAFICA.end.y - GRAFICA.size.y * fila[3] / n))
	linea_s.points = ps
	linea_i.points = pi
	linea_r.points = pr
