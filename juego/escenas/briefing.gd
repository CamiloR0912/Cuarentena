## Briefing del nivel (designs/ui_14_radio_briefing.md): tarjeta del nivel, historia y la radio de Don Álvaro.
## La radio ejecuta el Modelo 3: N réplicas Monte Carlo de la misión (intercambios de golpes contra los enemigos
## de la zona, cuya cantidad crece con I/N) y anuncia p̂ con su intervalo de confianza del 95 %.
## El jugador decide: aceptar la misión o esperar un día en el hospital (avanza el SIR y la cola, recupera HP).
extends Control

const Kit = preload("res://escenas/ui_kit.gd")
const REPLICAS := [1000, 5000, 10]   # 10 = parámetro extremo (caso de prueba 7): IC muy amplio
const AMBAR := Color("#E0A030")
const VERDE := Color("#B5C95A")
const ROJO := Color("#C0392B")
const AZUL := Color("#4FA3D1")

var cfg := {}
var indice_n := 0
var retrato: TextureRect
var txt_radio: Label
var txt_p: Label
var txt_ic: Label
var txt_detalle: Label
var txt_ciudad: Label
var pista: ColorRect
var rango: ColorRect
var punto: ColorRect
var boton_n: Button
var aceptar: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cfg = Juego.cfg_nivel()
	var fuente := Kit.fuente()
	var chica := Kit.fuente("PixelOperator8.ttf")
	var fondo := ColorRect.new()
	fondo.color = Kit.TINTA
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	add_child(Kit.texto(cfg["titulo"], Vector2(24, 12), fuente, 32, Kit.BLANCO))
	var tarjeta := TextureRect.new()
	tarjeta.texture = load(Kit.UI + "levels/%s.png" % cfg["tarjeta"])
	tarjeta.position = Vector2(24, 56)
	tarjeta.scale = Vector2(2, 2)   # 240×135 → 480×270
	add_child(tarjeta)
	add_child(Kit.texto("Modelos activos: %s" % cfg["modelos"], Vector2(24, 334), chica, 8, VERDE))
	add_child(Kit.parrafo(cfg["historia"], Rect2(24, 350, 480, 110), fuente, 16, Kit.BLANCO))
	add_child(Kit.parrafo("Objetivo: %s" % cfg["objetivo"], Rect2(24, 470, 480, 40), fuente, 16, AMBAR))
	txt_ciudad = Kit.texto("", Vector2(24, 520), chica, 8, Kit.NIEBLA)
	add_child(txt_ciudad)

	# radio de Don Álvaro
	var radio := Kit.panel("panel_radio", Rect2(528, 56, 408, 330), 10)
	add_child(radio)
	radio.add_child(Kit.texto("RADIO · DON ÁLVARO", Vector2(124, 14), fuente, 16, AMBAR))
	retrato = TextureRect.new()
	retrato.position = Vector2(16, 16)
	radio.add_child(retrato)
	txt_radio = Kit.parrafo("", Rect2(124, 36, 268, 84), fuente, 16, Kit.BLANCO)
	radio.add_child(txt_radio)
	radio.add_child(Kit.texto("Probabilidad estimada de volver (Monte Carlo)", Vector2(16, 128), chica, 8, Kit.NIEBLA))
	txt_p = Kit.texto("-- %", Vector2(16, 140), fuente, 48, Kit.BLANCO)
	radio.add_child(txt_p)
	txt_ic = Kit.texto("", Vector2(150, 150), fuente, 16, Kit.BLANCO)
	radio.add_child(txt_ic)
	# barra 0..1 con el intervalo de confianza
	pista = ColorRect.new()
	pista.color = Color("#2B2F33")
	pista.position = Vector2(16, 204)
	pista.size = Vector2(376, 12)
	radio.add_child(pista)
	rango = ColorRect.new()
	rango.color = Color(AZUL, 0.7)
	rango.position = Vector2(16, 206)
	rango.size = Vector2(0, 8)
	radio.add_child(rango)
	punto = ColorRect.new()
	punto.color = Kit.BLANCO
	punto.position = Vector2(16, 202)
	punto.size = Vector2(3, 16)
	radio.add_child(punto)
	radio.add_child(Kit.texto("0 %", Vector2(16, 220), chica, 8, Kit.NIEBLA))
	radio.add_child(Kit.texto("100 %", Vector2(360, 220), chica, 8, Kit.NIEBLA))
	txt_detalle = Kit.parrafo("", Rect2(16, 238, 376, 80), chica, 8, Kit.NIEBLA)
	radio.add_child(txt_detalle)

	var botones := VBoxContainer.new()
	botones.position = Vector2(632, 394)
	botones.add_theme_constant_override("separation", 6)
	add_child(botones)
	aceptar = Kit.boton("Aceptar la misión", fuente)
	aceptar.pressed.connect(_aceptar)
	var esperar := Kit.boton("Esperar un día", fuente)
	esperar.pressed.connect(_esperar)
	boton_n = Kit.boton("", fuente)
	boton_n.pressed.connect(_cambiar_n)
	var menu := Kit.boton("Menú principal", fuente, true)
	menu.pressed.connect(func(): Juego.ir_a(Juego.ESCENA_MENU))
	for b in [aceptar, esperar, boton_n, menu]:
		botones.add_child(b)
	aceptar.grab_focus()

	Juego.musica("menu")
	Juego.sonido("radio")
	_calcular.call_deferred()


func _calcular() -> void:
	var n: int = REPLICAS[indice_n]
	boton_n.text = "Réplicas N = %d" % n
	var encuentros: Array = Juego.encuentros_radio()
	var hp: float = maxf(Juego.hp, 40.0)
	var r: Array = Juego.mc.radio(encuentros, hp, "tubo", n)
	var p: float = r[0]
	var inferior: float = clampf(r[1], 0.0, 1.0)
	var superior: float = clampf(r[2], 0.0, 1.0)
	Juego.stats["radio"] = [p, inferior, superior, n]
	Juego.registrar("M3 Monte Carlo", "radio: p = %.3f, IC 95 %% [%.3f, %.3f], N = %d" % [p, inferior, superior, n])

	var animo := "neutral"
	var color := Kit.BLANCO
	if p >= 0.75:
		animo = "confident"
		color = VERDE
	elif p < 0.45:
		animo = "worried"
		color = ROJO
	var hoja: Texture2D = load("res://assets/portraits/alvaro_%s.png" % animo)
	var cuadro := AtlasTexture.new()
	cuadro.atlas = hoja
	cuadro.region = Rect2(0, 0, 96, 96)
	retrato.texture = cuadro
	txt_radio.text = "%s Calculo un %d %% de probabilidad de volver." % [cfg["radio"], roundi(p * 100.0)]
	txt_p.text = "%d %%" % roundi(p * 100.0)
	txt_p.add_theme_color_override("font_color", color)
	txt_ic.text = "IC 95 %%: [%s ; %s]" % [_c(inferior * 100.0), _c(superior * 100.0)]
	rango.position.x = 16.0 + 376.0 * inferior
	rango.size.x = maxf(2.0, 376.0 * (superior - inferior))
	punto.position.x = 16.0 + 376.0 * p - 1.0

	var cuenta := {}
	for tipo in encuentros:
		cuenta[tipo] = cuenta.get(tipo, 0) + 1
	var partes := []
	for tipo in cuenta:
		partes.append("%d %s" % [cuenta[tipo], tipo])
	var error: float = sqrt(p * (1.0 - p) / n)
	txt_detalle.text = "Encuentros simulados: %s (crecen con I/N).\nHP %d, arma: tubo. N = %d réplicas, error estándar %s.\nGenerador: congruencial aditivo (Fibonacci retrasado) del taller anterior." % [
		", ".join(partes), int(hp), n, _c(error * 100.0) + " %"]
	var sir = Juego.sir
	txt_ciudad.text = "Día %d · I/N = %s %% · R0 efectivo = %s · HP %d · muestras %d" % [int(Juego.dia),
		_c(100.0 * sir.i / sir.n), _c(sir.beta_ef() / sir.gamma_ef()), int(Juego.hp), Juego.muestras]


func _c(v: float) -> String:
	return String.num(v, 1).replace(".", ",")


func _cambiar_n() -> void:
	indice_n = (indice_n + 1) % REPLICAS.size()
	Juego.sonido("clic")
	_calcular()


func _aceptar() -> void:
	Juego.sonido("clic")
	Juego.ir_a(Juego.ESCENA_NIVEL)


## Rama "No" del diagrama: el jugador se queda en el hospital. Pasa un día de epidemia y de cola.
func _esperar() -> void:
	var segundos: float = 1.0 / Juego.DIAS_POR_SEGUNDO
	for k in 100:
		Juego.avanzar_mundo(segundos / 100.0)
	Juego.hp = minf(100.0, Juego.hp + 15.0)
	Juego.sonido("curar")
	if Juego.fraccion_infectados() > Juego.UMBRAL_COLAPSO:
		Juego.derrota("ciudad")
		return
	_calcular()
