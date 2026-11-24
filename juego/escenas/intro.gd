## Introducción (antes del briefing del nivel 1): cuatro pantallas sobre la ciudad de noche con niebla.
## La narración muestra un título grande; las líneas de Don Álvaro y Elena, su retrato a doble tamaño con
## estática de radio. Usa la misma caja de diálogo de los niveles (escenas/dialogo.gd). Esc salta la intro.
extends Control

const Kit = preload("res://escenas/ui_kit.gd")
const Dialogo = preload("res://escenas/dialogo.gd")
const AMBAR := Color("#E0A030")

var ciudad: TextureRect
var niebla: TextureRect
var titulo: Label
var subtitulo: Label
var retrato: TextureRect
var estatica: TextureRect
var _cuadro: AtlasTexture
var _cuadro_estatica: AtlasTexture
var _t_estatica := 0.0
var _t_parpadeo := 2.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fuente := Kit.fuente()
	add_child(Kit.hoja("menu/menu_bg_sky.png", 1))
	ciudad = Kit.hoja("menu/menu_bg_city.png", 2)
	add_child(ciudad)
	var velo := ColorRect.new()
	velo.color = Color(Kit.TINTA, 0.6)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(velo)
	niebla = TextureRect.new()
	niebla.texture = load("res://assets/vfx/fog_layer_a.png")
	niebla.stretch_mode = TextureRect.STRETCH_TILE
	niebla.size = Vector2(1440, 540)
	niebla.modulate.a = 0.5
	add_child(niebla)

	titulo = Kit.texto("", Vector2(0, 110), fuente, 48, Kit.BLANCO)
	titulo.size.x = 960
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(titulo)
	subtitulo = Kit.texto("", Vector2(0, 176), fuente, 16, AMBAR)
	subtitulo.size.x = 960
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitulo)

	var marco := ColorRect.new()
	marco.color = Kit.TINTA
	marco.position = Vector2(380, 60)
	marco.size = Vector2(200, 200)
	add_child(marco)
	retrato = TextureRect.new()
	_cuadro = AtlasTexture.new()
	retrato.texture = _cuadro
	retrato.position = Vector2(384, 64)
	retrato.scale = Vector2(2, 2)   # 96 → 192 px, píxeles nítidos (filtro Nearest del proyecto)
	add_child(retrato)
	estatica = TextureRect.new()
	_cuadro_estatica = AtlasTexture.new()
	_cuadro_estatica.atlas = load("res://assets/portraits/radio_static.png")
	_cuadro_estatica.region = Rect2(0, 0, 96, 96)
	estatica.texture = _cuadro_estatica
	estatica.position = retrato.position
	estatica.scale = Vector2(2, 2)
	add_child(estatica)
	for nodo in [marco, retrato, estatica]:
		nodo.modulate.a = 0.0
	retrato.set_meta("marco", marco)

	Juego.musica("menu")
	var d = Dialogo.abrir(self, Juego.DIALOGOS["intro"], {"y": 372.0, "retrato": false, "pausar": false})
	d.linea.connect(_al_cambiar_linea)
	await d.terminado
	Juego.ir_a(Juego.ESCENA_BRIEFING)


func _al_cambiar_linea(_indice: int, l: Dictionary) -> void:
	var quien: String = l.get("quien", "")
	var marco: ColorRect = retrato.get_meta("marco")
	var tw := create_tween()
	tw.set_parallel(true)
	if quien == "":
		titulo.text = l.get("titulo", "")
		subtitulo.text = l.get("subtitulo", "")
		for nodo in [marco, retrato, estatica]:
			tw.tween_property(nodo, "modulate:a", 0.0, 0.3)
		tw.tween_property(titulo, "modulate:a", 1.0, 0.4)
		tw.tween_property(subtitulo, "modulate:a", 1.0, 0.4)
		return
	tw.tween_property(titulo, "modulate:a", 0.0, 0.3)
	tw.tween_property(subtitulo, "modulate:a", 0.0, 0.3)
	tw.tween_property(marco, "modulate:a", 1.0, 0.3)
	tw.tween_property(retrato, "modulate:a", 1.0, 0.3)
	var archivo := "elena_portrait_%s" % l.get("animo", "neutral") if quien == "elena" \
		else "%s_%s" % [quien, l.get("animo", "neutral")]
	_cuadro.atlas = load("res://assets/portraits/%s.png" % archivo)
	_cuadro.region = Rect2(0, 0, 96, 96)
	_t_estatica = 0.6 if l.get("radio", false) else 0.0


func _process(delta: float) -> void:
	Kit.animar(ciudad, 1)
	niebla.position.x -= 12.0 * delta
	if niebla.position.x <= -480.0:
		niebla.position.x += 480.0
	_t_parpadeo -= delta
	if _cuadro.atlas != null and _cuadro.atlas.get_width() >= 192:
		_cuadro.region.position.x = 96.0 if _t_parpadeo < 0.12 else 0.0
	if _t_parpadeo <= 0.0:
		_t_parpadeo = randf_range(2.0, 4.0)
	if _t_estatica > 0.0:
		_t_estatica -= delta
		_cuadro_estatica.region.position.x = float(int(Time.get_ticks_msec() / 60) % 4) * 96.0
		estatica.modulate.a = clampf(_t_estatica / 0.6, 0.0, 1.0) * 0.9
	elif retrato.modulate.a > 0.0:
		estatica.modulate.a = 0.0
