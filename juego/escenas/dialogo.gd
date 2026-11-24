## Caja de diálogo reutilizable con retrato (designs/ui_14_radio_briefing.md, portraits/).
## Recibe una lista lineal de líneas {quien, animo, texto, radio} (los datos viven en Juego.DIALOGOS) y las muestra
## con efecto de máquina de escribir. Mientras está abierta pausa el árbol: la epidemia y la cola no avanzan.
##   E / Espacio / Enter / clic: completa la línea o pasa a la siguiente.   Esc: salta todo el diálogo.
## Uso:  var d := Dialogo.abrir(self, Juego.DIALOGOS["nivel1"]);  await d.terminado
extends CanvasLayer

signal terminado
signal linea(indice: int, datos: Dictionary)   # al empezar cada línea (la intro cambia el retrato grande)

const Kit = preload("res://escenas/ui_kit.gd")
const AMBAR := Color("#E0A030")
const AZUL := Color("#4FA3D1")
const NOMBRES := {"alvaro": "DON ÁLVARO", "elena": "DRA. ELENA RUIZ", "mena": "DRA. MENA"}
const VELOCIDAD := 48.0          # caracteres por segundo
const ANCHO := 760.0
const ALTO := 128.0

var lineas: Array = []
var indice := -1
var y_caja := 340.0              # la intro la baja; en los niveles queda sobre la barra inferior del HUD
var mostrar_retrato := true
var pausar := true

var caja: NinePatchRect
var retrato: TextureRect
var estatica: TextureRect
var nombre: Label
var texto: Label
var ayuda: Label
var _visible := 0.0
var _t_parpadeo := 2.0
var _t_estatica := 0.0
var _cuadro_retrato: AtlasTexture
var _cuadro_estatica: AtlasTexture
var _texturas := {}
var _cerrando := false


static func abrir(padre: Node, lineas_: Array, opciones := {}):
	var d = load("res://escenas/dialogo.gd").new()
	d.lineas = lineas_
	d.y_caja = opciones.get("y", 340.0)
	d.mostrar_retrato = opciones.get("retrato", true)
	d.pausar = opciones.get("pausar", true)
	padre.add_child(d)
	return d


func _ready() -> void:
	layer = 8                                  # sobre el HUD, bajo la pausa
	process_mode = Node.PROCESS_MODE_ALWAYS    # sigue funcionando con el árbol pausado
	var fuente := Kit.fuente()
	var chica := Kit.fuente("PixelOperator8.ttf")
	var velo := ColorRect.new()
	velo.color = Color(Kit.TINTA, 0.35)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(velo)

	caja = Kit.panel("panel_dark", Rect2((960.0 - ANCHO) / 2.0, y_caja, ANCHO, ALTO), 8)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caja)
	var x_texto := 16.0
	if mostrar_retrato:
		var marco := ColorRect.new()
		marco.color = Kit.TINTA
		marco.position = Vector2(14, 14)
		marco.size = Vector2(100, 100)
		caja.add_child(marco)
		retrato = TextureRect.new()
		retrato.position = Vector2(16, 16)
		_cuadro_retrato = AtlasTexture.new()
		retrato.texture = _cuadro_retrato
		caja.add_child(retrato)
		estatica = TextureRect.new()
		estatica.position = Vector2(16, 16)
		_cuadro_estatica = AtlasTexture.new()
		_cuadro_estatica.atlas = load("res://assets/portraits/radio_static.png")
		_cuadro_estatica.region = Rect2(0, 0, 96, 96)
		estatica.texture = _cuadro_estatica
		estatica.modulate.a = 0.0
		caja.add_child(estatica)
		x_texto = 128.0
	nombre = Kit.texto("", Vector2(x_texto, 12), fuente, 16, AMBAR)
	caja.add_child(nombre)
	texto = Kit.parrafo("", Rect2(x_texto, 34, ANCHO - x_texto - 18.0, 72), fuente, 16, Kit.BLANCO)
	texto.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING  # el ajuste de línea no salta al escribir
	caja.add_child(texto)
	ayuda = Kit.texto("E / Espacio: continuar   ·   Esc: saltar", Vector2(0, ALTO - 16.0), chica, 8, Kit.NIEBLA)
	ayuda.size.x = ANCHO - 14.0
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	caja.add_child(ayuda)

	if pausar:
		get_tree().paused = true
	# entra deslizándose desde abajo
	caja.position.y = y_caja + 24.0
	caja.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(caja, "position:y", y_caja, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(caja, "modulate:a", 1.0, 0.2)
	_siguiente.call_deferred()   # diferido: quien abre el diálogo alcanza a conectar la señal "linea"


func _input(event: InputEvent) -> void:
	if _cerrando:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cerrar()
	elif event.is_action_pressed("interactuar") or event.is_action_pressed("atacar") \
			or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		avanzar()


## Completa la línea si aún se está escribiendo; si ya terminó, pasa a la siguiente.
func avanzar() -> void:
	if _visible < texto.get_total_character_count():
		_visible = float(texto.get_total_character_count())
		texto.visible_characters = -1
	else:
		_siguiente()


func saltar() -> void:
	_cerrar()


func _siguiente() -> void:
	indice += 1
	if indice >= lineas.size():
		_cerrar()
		return
	var l: Dictionary = lineas[indice]
	var quien: String = l.get("quien", "")
	var radio: bool = l.get("radio", false)
	nombre.text = NOMBRES.get(quien, "") + ("  ·  RADIO" if radio and quien != "" else "")
	caja.texture = load(Kit.UI + ("kit/panel_radio.png" if radio else "kit/panel_dark.png"))
	texto.text = l.get("texto", "")
	texto.visible_characters = 0
	_visible = 0.0
	if mostrar_retrato:
		retrato.visible = quien != ""
		if quien != "":
			_cuadro_retrato.atlas = _textura_retrato(quien, l.get("animo", "neutral"))
			_cuadro_retrato.region = Rect2(0, 0, 96, 96)
		_t_estatica = 0.45 if radio else 0.0
	if radio:
		Juego.sonido("radio")
	linea.emit(indice, l)


func _textura_retrato(quien: String, animo: String) -> Texture2D:
	var archivo := "elena_portrait_%s" % animo if quien == "elena" else "%s_%s" % [quien, animo]
	if not _texturas.has(archivo):
		var ruta := "res://assets/portraits/%s.png" % archivo
		if not ResourceLoader.exists(ruta):
			ruta = "res://assets/portraits/%s.png" % ("elena_portrait_neutral" if quien == "elena" else quien + "_neutral")
		_texturas[archivo] = load(ruta)
	return _texturas[archivo]


func _process(delta: float) -> void:
	if indice < 0 or indice >= lineas.size():
		return
	var total := texto.get_total_character_count()
	if _visible < total:
		var antes := int(_visible)
		_visible = minf(float(total), _visible + VELOCIDAD * delta)
		texto.visible_characters = int(_visible)
		if int(_visible) / 3 != antes / 3:   # un "bip" de voz cada 3 letras
			Juego.sonido("voz")
	ayuda.modulate.a = 1.0 if _visible >= total else 0.4
	if not mostrar_retrato or not retrato.visible:
		return
	# parpadeo: la hoja del retrato trae el cuadro 2 con los ojos cerrados
	_t_parpadeo -= delta
	if _cuadro_retrato.atlas != null and _cuadro_retrato.atlas.get_width() >= 192:
		_cuadro_retrato.region.position.x = 96.0 if _t_parpadeo < 0.12 else 0.0
	if _t_parpadeo <= 0.0:
		_t_parpadeo = randf_range(2.0, 4.0)
	# estática de radio al empezar la línea
	if _t_estatica > 0.0:
		_t_estatica -= delta
		_cuadro_estatica.region.position.x = float(int(Time.get_ticks_msec() / 60) % 4) * 96.0
		estatica.modulate.a = clampf(_t_estatica / 0.45, 0.0, 1.0) * 0.9
	else:
		estatica.modulate.a = 0.0


func _cerrar() -> void:
	if _cerrando:
		return
	_cerrando = true
	var tw := create_tween()
	tw.tween_property(caja, "modulate:a", 0.0, 0.15)
	await tw.finished
	# se espera un cuadro antes de reanudar: la tecla que cerró el diálogo no debe disparar E ni ataque en el juego
	await get_tree().process_frame
	if pausar:
		get_tree().paused = false
	terminado.emit()
	queue_free()
