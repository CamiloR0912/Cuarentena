## Menú de pausa (designs/ui_20_pause_menu.md): Esc congela todo el árbol (personajes, SIR, cola, HUD) y muestra
## Continuar / Reiniciar nivel / Controles / Menú principal / Salir. Esc otra vez reanuda.
extends CanvasLayer

const Kit = preload("res://escenas/ui_kit.gd")

var raiz: Control
var panel: NinePatchRect
var ayuda: NinePatchRect
var icono: TextureRect
var continuar: Button
var volver: Button


func _ready() -> void:
	layer = 10  # encima del HUD
	process_mode = Node.PROCESS_MODE_ALWAYS  # sigue escuchando Esc con el árbol pausado
	var fuente := Kit.fuente()
	var chica := Kit.fuente("PixelOperator8.ttf")
	raiz = Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.visible = false
	add_child(raiz)
	var velo := ColorRect.new()
	velo.color = Color(Kit.TINTA, 0.6)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(velo)

	panel = _marco(Rect2(340, 132, 280, 276))
	var titulo := Kit.texto("PAUSA", Vector2(0, 10), fuente, 32, Kit.BLANCO)
	titulo.size.x = 280
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(titulo)
	icono = Kit.hoja("pause/pause_icon.png", 2)
	icono.position = Vector2(140 - fuente.get_string_size("PAUSA", HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x / 2 - 32, 18)
	panel.add_child(icono)
	var info := Kit.texto("Simulación en pausa", Vector2(0, 50), chica, 8, Kit.NIEBLA)
	info.size.x = 280
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)

	var botones := VBoxContainer.new()
	botones.position = Vector2(40, 84)
	botones.add_theme_constant_override("separation", 8)  # 36 px entre botones (spec)
	panel.add_child(botones)
	continuar = Kit.boton("Continuar", fuente)
	continuar.pressed.connect(_pausar.bind(false))
	var reiniciar := Kit.boton("Reiniciar nivel", fuente)
	reiniciar.pressed.connect(_reiniciar)
	var controles := Kit.boton("Controles", fuente)
	controles.pressed.connect(_ver_controles.bind(true))
	var menu := Kit.boton("Menú principal", fuente)
	menu.pressed.connect(_menu_principal)
	var salir := Kit.boton("Salir al escritorio", fuente, true)
	salir.pressed.connect(get_tree().quit)
	for b in [continuar, reiniciar, controles, menu, salir]:
		botones.add_child(b)

	# tabla de controles
	ayuda = _marco(Rect2(180, 60, 600, 420))
	ayuda.visible = false
	var cabecera := Kit.texto("CONTROLES", Vector2(0, 10), fuente, 32, Kit.BLANCO)
	cabecera.size.x = 600
	cabecera.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_child(cabecera)
	for k in Juego.CONTROLES.size():
		var fila: Array = Juego.CONTROLES[k]
		var y := 58 + k * 20
		ayuda.add_child(Kit.texto(fila[0], Vector2(24, y), chica, 8, Kit.BLANCO))
		ayuda.add_child(Kit.texto(fila[1], Vector2(190, y), chica, 8, Color("#E0A030")))
		ayuda.add_child(Kit.texto(fila[2], Vector2(350, y), chica, 8, Kit.NIEBLA))
	volver = Kit.boton("Volver", fuente)
	volver.position = Vector2(200, 376)
	volver.pressed.connect(_ver_controles.bind(false))
	ayuda.add_child(volver)


func _marco(r: Rect2) -> NinePatchRect:
	var p := NinePatchRect.new()
	p.texture = load(Kit.UI + "kit/panel_dark.png")
	p.position = r.position
	p.size = r.size
	for lado in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		p.set_patch_margin(lado, 8)
	raiz.add_child(p)
	return p


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # Esc
		if ayuda.visible:
			_ver_controles(false)
		else:
			_pausar(not raiz.visible)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if raiz.visible:
		Kit.animar(icono, 2)


func _pausar(pausar: bool) -> void:
	raiz.visible = pausar
	panel.visible = true
	ayuda.visible = false
	get_tree().paused = pausar
	if pausar:
		continuar.grab_focus()


func _ver_controles(ver: bool) -> void:
	ayuda.visible = ver
	panel.visible = not ver
	if ver:
		volver.grab_focus()
	else:
		continuar.grab_focus()


func _reiniciar() -> void:
	Juego.reintentar_nivel()


func _menu_principal() -> void:
	Juego.ir_a(Juego.ESCENA_MENU)
