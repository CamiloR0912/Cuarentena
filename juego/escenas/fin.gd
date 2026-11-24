## Pantalla final (designs/ui_21_game_over.md y ui_22_victory.md): según Juego.resultado muestra la derrota
## (causa, estadísticas y curva SIR) o la victoria (escena de la cura, curva SIR final y puntuación).
extends Control

const Kit = preload("res://escenas/ui_kit.gd")
const AMBAR := Color("#E0A030")
const ROJO := Color("#C0392B")
const VERDE := Color("#B5C95A")
const CAUSAS := {
	"hp": ["cause_hp", "Elena cayó", "Los infectados la superaron. Sin la doctora, la fila del hospital no avanza."],
	"viral": ["cause_viral", "Carga viral al 100 %", "Elena se contagió sin tratamiento: las nubes y los golpes suman carga viral."],
	"ciudad": ["cause_city", "La ciudad colapsó", "Los infectados superaron el límite de I/N: el modelo SIR cruzó el punto de no retorno."],
	"hospital": ["cause_hospital", "El hospital colapsó", "La sala de espera estuvo llena demasiado tiempo: faltaron camillas abiertas (cola M/M/c)."],
}

var animadas := []   # [TextureRect, fps]
var primer_boton: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var victoria: bool = Juego.resultado == "victoria"
	var fuente := Kit.fuente()
	var chica := Kit.fuente("PixelOperator8.ttf")
	var fondo := ColorRect.new()
	fondo.color = Kit.TINTA
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	if victoria:
		var escena := Kit.hoja("victory/victory_scene.png", 2)
		add_child(escena)
		animadas.append([escena, 2.0])
		var brillo := TextureRect.new()
		brillo.texture = load(Kit.UI + "victory/victory_glow_overlay.png")
		brillo.modulate.a = 0.6
		add_child(brillo)
		var velo := ColorRect.new()
		velo.color = Color(Kit.TINTA, 0.55)
		velo.position = Vector2(40, 40)
		velo.size = Vector2(880, 460)
		add_child(velo)
		add_child(Kit.texto("LA CURA", Vector2(64, 52), fuente, 48, Kit.BLANCO))
		add_child(Kit.parrafo("La doctora Mena sintetiza la cura con las muestras de Elena. La barra de la ciudad vuelve al azul: cada infectado neutralizado fue una persona que pudo volver a casa.",
			Rect2(64, 108, 420, 80), fuente, 16, Kit.BLANCO))
		Juego.musica("victoria")
	else:
		var causa: Array = CAUSAS.get(Juego.causa, CAUSAS["hp"])
		var hoja: Texture2D = load(Kit.UI + "gameover/%s.png" % causa[0])
		var icono := Kit.hoja("gameover/%s.png" % causa[0], maxi(1, hoja.get_width() / 64))
		icono.position = Vector2(64, 52)
		add_child(icono)
		animadas.append([icono, 4.0])
		add_child(Kit.texto("DERROTA", Vector2(144, 48), fuente, 48, ROJO))
		add_child(Kit.texto(causa[1], Vector2(146, 96), fuente, 16, AMBAR))
		add_child(Kit.parrafo(causa[2], Rect2(64, 128, 420, 60), fuente, 16, Kit.BLANCO))
		Juego.musica("derrota")

	# estadísticas
	var s: Dictionary = Juego.stats
	var sir = Juego.sir
	var acumulados: float = (sir.i + sir.r) / sir.n
	var lineas := [
		"%s" % Juego.cfg_nivel()["titulo"],
		"Día %d de la epidemia · %d min de juego" % [int(Juego.dia), int(Juego.t_juego / 60.0)],
		"Infectados sedados: %d   entregados: %d" % [s["sedados"], s["entregados"]],
		"Ciudadanos rescatados: %d" % s["rescatados"],
		"Hospital: %d atendidos, %d abandonos" % [s["atendidos"], s["abandonos"]],
		"Ataques: %d   críticos: %d" % [s["ataques"], s["criticos"]],
		"Contagios en la calle: %d   mutaciones: %d" % [s["contagios_calle"], s["transiciones_markov"]],
		"I/N final: %s %%   afectados (I+R)/N: %s %%" % [_c(100.0 * sir.i / sir.n), _c(100.0 * acumulados)],
	]
	if victoria:
		var puntos: int = 50 * s["sedados"] + 100 * s["entregados"] + 150 * s["rescatados"] + 20 * s["atendidos"] \
			- 30 * s["abandonos"] - 200 * s["muertes"] + int((1.0 - acumulados) * 5000.0)
		lineas.append("PUNTUACIÓN: %d" % maxi(0, puntos))
	for k in lineas.size():
		add_child(Kit.texto(lineas[k], Vector2(64, 204 + k * 22), fuente, 16, VERDE if k == lineas.size() - 1 and victoria else Kit.BLANCO))

	# curva SIR de la partida
	var marco := TextureRect.new()
	marco.texture = load(Kit.UI + "gameover/chart_bg.png")
	marco.position = Vector2(520, 96)
	marco.scale = Vector2(1.3, 1.3)   # 280×140 → 364×182
	add_child(marco)
	add_child(Kit.texto("CURVA SIR DE LA PARTIDA", Vector2(520, 76), chica, 8, Kit.NIEBLA))
	add_child(Kit.curva_sir(Rect2(532, 106, 340, 162), Juego.historial, sir.n, Juego.UMBRAL_COLAPSO))
	add_child(Kit.texto("S azul · I rojo · R blanco · ámbar: límite de colapso (%d %%)" % roundi(Juego.UMBRAL_COLAPSO * 100.0),
		Vector2(520, 286), chica, 8, Kit.NIEBLA))

	var botones := VBoxContainer.new()
	botones.position = Vector2(596, 330)
	botones.add_theme_constant_override("separation", 8)
	add_child(botones)
	if victoria:
		var creditos := Kit.boton("Créditos", fuente)
		creditos.pressed.connect(_creditos)
		botones.add_child(creditos)
		primer_boton = creditos
	else:
		var reintentar := Kit.boton("Reintentar nivel", fuente)
		reintentar.pressed.connect(Juego.reintentar_nivel)
		botones.add_child(reintentar)
		primer_boton = reintentar
	var menu := Kit.boton("Menú principal", fuente)
	menu.pressed.connect(_menu)
	botones.add_child(menu)
	var salir := Kit.boton("Salir", fuente, true)
	salir.pressed.connect(get_tree().quit)
	botones.add_child(salir)
	primer_boton.grab_focus()


func _process(_delta: float) -> void:
	for par in animadas:
		Kit.animar(par[0], par[1])


func _c(v: float) -> String:
	return String.num(v, 1).replace(".", ",")


func _menu() -> void:
	Juego.resultado = ""
	Juego.ir_a(Juego.ESCENA_MENU)


func _creditos() -> void:
	Juego.resultado = ""
	Juego.info_modo = "creditos"
	Juego.ir_a(Juego.ESCENA_INFO)
