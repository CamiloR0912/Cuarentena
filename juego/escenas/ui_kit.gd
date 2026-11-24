## Piezas de UI compartidas por el menú principal y la pausa (designs/ui_01_ui_kit.md): fuente pixel y botones 9-slice.
extends RefCounted

const UI := "res://assets/ui/"
const BLANCO := Color("#EAF2F5")  # N8
const NIEBLA := Color("#8A9199")  # N6
const TINTA := Color("#121417")   # N0


## Fuente pixel sin suavizado (PixelOperator a 16 px para títulos y botones, PixelOperator8 a 8 px para textos pequeños).
static func fuente(archivo := "PixelOperator.ttf") -> FontFile:
	var f: FontFile = load("res://assets/fonts/" + archivo).duplicate()
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	return f


## Botón 200×28 del kit: la hoja trae 4 estados de 24×24 (normal, hover, pressed, disabled) con esquinas de 8 px.
static func boton(texto: String, fuente: FontFile, peligro := false) -> Button:
	var hoja: Texture2D = load(UI + ("kit/button_danger.png" if peligro else "kit/button.png"))
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(200, 28)
	var estados := ["normal", "hover", "pressed", "disabled"]
	for i in estados.size():
		b.add_theme_stylebox_override(estados[i], _estado(hoja, i))
	b.add_theme_stylebox_override("focus", _estado(hoja, 1))  # teclado: mismo aspecto que hover (el texto se dibuja encima)
	b.add_theme_font_override("font", fuente)
	b.add_theme_font_size_override("font_size", 16)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(c, BLANCO)
	b.add_theme_color_override("font_disabled_color", NIEBLA)
	b.mouse_entered.connect(func(): if not b.disabled: b.grab_focus())  # ratón y teclado comparten el resaltado
	return b


static func _estado(hoja: Texture2D, i: int) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = hoja
	s.region_rect = Rect2(i * 24, 0, 24, 24)
	s.set_texture_margin_all(8)
	s.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE  # el kit pide bordes repetidos, no estirados
	s.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	return s


static func texto(t: String, pos: Vector2, fuente: FontFile, tam: int, color: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.position = pos
	l.add_theme_font_override("font", fuente)
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	return l


## Imagen que muestra un cuadro de una hoja horizontal de n cuadros; animar() la avanza a fps cuadros por segundo.
static func hoja(ruta: String, n: int) -> TextureRect:
	var t: Texture2D = load(UI + ruta)
	var a := AtlasTexture.new()
	a.atlas = t
	a.region = Rect2(0, 0, t.get_width() / n, t.get_height())
	var r := TextureRect.new()
	r.texture = a
	r.set_meta("cuadros", n)
	return r


static func animar(r: TextureRect, fps: float) -> void:
	var a: AtlasTexture = r.texture
	a.region.position.x = (int(Time.get_ticks_msec() / 1000.0 * fps) % int(r.get_meta("cuadros"))) * a.region.size.x


## Panel 9-slice del kit (panel_dark, panel_solid, panel_radio, panel_danger, panel_warning).
static func panel(nombre: String, r: Rect2, margen := 8) -> NinePatchRect:
	var p := NinePatchRect.new()
	p.texture = load(UI + "kit/%s.png" % nombre)
	p.position = r.position
	p.size = r.size
	for lado in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		p.set_patch_margin(lado, margen)
	return p


## Texto con ajuste de línea dentro de un ancho.
static func parrafo(t: String, r: Rect2, fuente_: FontFile, tam: int, color: Color) -> Label:
	# la etiqueta se crea vacía: con el texto puesto y sin ajuste de línea, su ancho mínimo sería todo el texto
	var l := texto("", r.position, fuente_, tam, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size = r.size
	l.text = t
	return l


## Curvas S, I, R del historial [[día, S, I, R], ...] dentro del rectángulo r, con la línea del umbral de colapso.
static func curva_sir(r: Rect2, historial: Array, poblacion: float, umbral: float) -> Node2D:
	var nodo := Node2D.new()
	var colores := [Color("#4FA3D1"), Color("#C0392B"), Color("#EAF2F5")]
	var t_max := 1.0
	if not historial.is_empty():
		t_max = maxf(1.0, historial[-1][0])
	var salto := maxi(1, historial.size() / 240)
	for serie in 3:
		var linea := Line2D.new()
		linea.width = 2.0
		linea.default_color = colores[serie]
		var pts := PackedVector2Array()
		for k in range(0, historial.size(), salto):
			var fila: Array = historial[k]
			var x: float = r.position.x + r.size.x * fila[0] / t_max
			var y: float = r.end.y - r.size.y * fila[serie + 1] / poblacion
			pts.append(Vector2(x, y))
		linea.points = pts
		nodo.add_child(linea)
	var limite := Line2D.new()
	limite.width = 1.0
	limite.default_color = Color("#E0A030")
	var y_lim := r.end.y - r.size.y * umbral
	limite.points = PackedVector2Array([Vector2(r.position.x, y_lim), Vector2(r.end.x, y_lim)])
	nodo.add_child(limite)
	return nodo
