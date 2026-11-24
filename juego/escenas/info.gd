## Pantallas de Controles (designs/ui_18_controls_screen.md) y Créditos (ui_19_credits_screen.md).
## Juego.info_modo decide cuál se muestra. Los créditos resumen designs/evidence/attributions.md.
extends Control

const Kit = preload("res://escenas/ui_kit.gd")
const AMBAR := Color("#E0A030")
const CREDITOS := [
	["CUARENTENA", "ExpoSimu 2026 · Simulación por Computador · UPTC"],
	["Equipo", "apellido1 · apellido2 · apellido3 (reemplazar por los integrantes)"],
	["Docente", "Alex Puertas González"],
	["Motor", "Godot Engine 4.7 (licencia MIT)"],
	["Mapas", "Tiled + importador YATI de Roland Helmerichs (MIT)"],
	["Personajes", "Universal LPC Spritesheet Character Generator. Autores por capa en designs/evidence/lpc_credits.md. Licencias CC-BY-SA 3.0 / GPL 3.0 / OGA-BY 3.0. Recoloreados a la paleta Cuarentena-36 y editados."],
	["Tilesets base", "LPC Modern Streets, LPC City Outside, LPC Base Assets, LPC Modern Car Additions, LPC Revised: The Office, Futuristic Doctor's Office, Beds (CC-BY-SA 3.0 / GPL 3.0), modificados."],
	["Fuente", "Pixel Operator, de Jayvee Enaguas (HarvettFox96), CC0 1.0"],
	["Arte propio", "Objetos, iconos, interfaz, efectos, logo, tarjetas de nivel y escena de victoria: creación del equipo."],
	["Audio", "Música y efectos generados por código en el propio juego (síntesis de ondas, nucleo/juego.gd): creación original, sin archivos de terceros."],
	["Simulación", "Generadores congruenciales (lineal, multiplicativo y aditivo) del taller anterior; modelos: caminata aleatoria, cola M/M/c, Monte Carlo, agentes y SIR."],
	["IA", "El uso de asistentes de IA se declara en el informe (sección de declaración de uso de IA)."],
]


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fuente := Kit.fuente()
	var chica := Kit.fuente("PixelOperator8.ttf")
	add_child(Kit.hoja("menu/menu_bg_sky.png", 1))
	var velo := ColorRect.new()
	velo.color = Color(Kit.TINTA, 0.8)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(velo)

	if Juego.info_modo == "creditos":
		add_child(Kit.texto("CRÉDITOS", Vector2(48, 20), fuente, 32, Kit.BLANCO))
		var y := 66.0
		for fila in CREDITOS:
			add_child(Kit.texto(fila[0], Vector2(48, y), chica, 8, AMBAR))
			var parrafo := Kit.parrafo(fila[1], Rect2(190, y, 720, 30), chica, 8, Kit.BLANCO)
			add_child(parrafo)
			y += 22.0 + 11.0 * floorf(String(fila[1]).length() / 88.0)
	else:
		add_child(Kit.texto("CONTROLES", Vector2(48, 20), fuente, 32, Kit.BLANCO))
		add_child(Kit.texto("ACCIÓN", Vector2(64, 70), chica, 8, Kit.NIEBLA))
		add_child(Kit.texto("TECLA / BOTÓN", Vector2(300, 70), chica, 8, Kit.NIEBLA))
		add_child(Kit.texto("DESCRIPCIÓN", Vector2(540, 70), chica, 8, Kit.NIEBLA))
		for k in Juego.CONTROLES.size():
			var fila: Array = Juego.CONTROLES[k]
			var y := 92 + k * 24
			add_child(Kit.texto(fila[0], Vector2(64, y), fuente, 16, Kit.BLANCO))
			add_child(Kit.texto(fila[1], Vector2(300, y), fuente, 16, AMBAR))
			add_child(Kit.texto(fila[2], Vector2(540, y), fuente, 16, Kit.NIEBLA))

	var volver := Kit.boton("Volver", fuente)
	volver.position = Vector2(380, 496)
	volver.pressed.connect(_volver)
	add_child(volver)
	volver.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_volver()


func _volver() -> void:
	Juego.ir_a(Juego.ESCENA_MENU)
