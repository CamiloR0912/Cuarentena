## Pantalla de inicio (designs/ui_17_main_menu.md): fondo en 3 capas, logo y botones
## Jugar / Continuar / Controles / Créditos / Salir. "Continuar" solo se habilita si hay una partida guardada.
extends Control

const Kit = preload("res://escenas/ui_kit.gd")

var ciudad: TextureRect
var frente: TextureRect


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fuente := Kit.fuente()
	var chica := Kit.fuente("PixelOperator8.ttf")
	add_child(Kit.hoja("menu/menu_bg_sky.png", 1))
	ciudad = Kit.hoja("menu/menu_bg_city.png", 2)
	frente = Kit.hoja("menu/menu_bg_front.png", 2)
	add_child(ciudad)
	add_child(frente)
	var logo := TextureRect.new()
	logo.texture = load(Kit.UI + "logo/logo.png")
	logo.position = Vector2(280, 40)
	add_child(logo)

	var botones := VBoxContainer.new()
	botones.position = Vector2(80, 250)
	botones.add_theme_constant_override("separation", 10)
	add_child(botones)
	var hay_partida: bool = Juego.hay_partida()
	var jugar := Kit.boton("Jugar", fuente)
	jugar.pressed.connect(_jugar)
	var continuar := Kit.boton("Continuar", fuente)
	continuar.disabled = not hay_partida
	continuar.focus_mode = Control.FOCUS_ALL if hay_partida else Control.FOCUS_NONE
	continuar.pressed.connect(_continuar)
	var controles := Kit.boton("Controles", fuente)
	controles.pressed.connect(_info.bind("controles"))
	var creditos := Kit.boton("Créditos", fuente)
	creditos.pressed.connect(_info.bind("creditos"))
	var salir := Kit.boton("Salir", fuente, true)
	salir.pressed.connect(get_tree().quit)
	for b in [jugar, continuar, controles, creditos, salir]:
		botones.add_child(b)
	(continuar if hay_partida else jugar).grab_focus()

	add_child(Kit.texto("Cuarentena v1.0", Vector2(8, 522), chica, 8, Kit.NIEBLA))
	var expo := Kit.texto("ExpoSimu 2026 · UPTC", Vector2(652, 522), chica, 8, Kit.NIEBLA)
	expo.size.x = 300
	expo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(expo)
	Juego.musica("menu")


func _process(_delta: float) -> void:
	Kit.animar(ciudad, 1)  # ventanas encendidas
	Kit.animar(frente, 3)  # luces de la ambulancia, cinta


func _jugar() -> void:
	Juego.sonido("clic")
	Juego.nueva_partida()
	Juego.ir_a(Juego.ESCENA_INTRO)


func _continuar() -> void:
	Juego.sonido("clic")
	Juego.continuar_partida()


func _info(modo: String) -> void:
	Juego.sonido("clic")
	Juego.info_modo = modo
	Juego.ir_a(Juego.ESCENA_INFO)
