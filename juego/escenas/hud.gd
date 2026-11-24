## HUD del juego (designs/ui_00_hud_layout.md): barra superior con el pulso de la ciudad (SIR, Modelo 5) y barra inferior
## con vida, carga viral, ruido, inventario y arma. Encima del mundo: objetivo, avisos, panel del hospital (Modelo 2),
## barra del jefe y un registro de eventos de los modelos (texto superpuesto para el video).
## Coordenadas sobre el lienzo de 960×540. Lee el estado del autoload Juego.
extends CanvasLayer

const UI := "res://assets/ui/"
const BLANCO := Color("#EAF2F5")
const GRIS := Color("#B4BAC0")
const ROJO := Color("#C0392B")
const AMBAR := Color("#E0A030")
const VERDE := Color("#B5C95A")
const AZUL := Color("#4FA3D1")
const AZUL_S := Color("#3B5A75")
const BLANCO_R := Color("#9ACFEA")
const TINTA := Color("#121417")
const RANURAS := [["vendas", "bandage_icon"], ["cubrebocas", "facemask_icon"], ["adrenalina", "adrenaline_icon"],
	["antiviral", "antiviral_icon"], ["muestras", "sample_icon"], ["suministros", "supplies_icon"]]
const FASES_JEFE := ["Deambular", "Embestida", "Toser", "Llamar a la Masa"]

var fuente: FontFile
var fuente_grande: FontFile
var barra_i: TextureRect
var barra_s: ColorRect
var barra_r: ColorRect
var txt_r0: Label
var txt_in: Label
var txt_dia: Label
var relleno_hp: TextureRect
var relleno_viral: TextureRect
var medidor: TextureRect
var txt_estado: Label
var txt_objetivo: Label
var txt_aviso: Label
var txt_titulo: Label
var txt_subtitulo: Label
var txt_feed: Label
var txt_hospital: Label
var panel_hospital: NinePatchRect
var barra_colapso: ColorRect
var caja_jefe: Control
var barra_jefe: ColorRect
var txt_jefe: Label
var vineta_dano: TextureRect
var vineta_hp: TextureRect
var vineta_viral: TextureRect
var vineta_sigilo: TextureRect
var icono_arma: TextureRect
var txt_arma: Label
var txt_municion: Label

var _marcos := []
var _iconos := []
var _cuentas := []
var _puntos := []
var _tex_ranura := []
var _tex_ruido := []
var _tex_punto := []
var _tex_hp: Texture2D
var _tex_hp_bajo: Texture2D
var _tex_armas := {}
var _t_aviso := 0.0
var _t_titulo := 0.0
var _t_dano := 0.0


func _ready() -> void:
	layer = 2
	fuente = _fuente("PixelOperator8.ttf")
	fuente_grande = _fuente("PixelOperator.ttf")

	# viñetas a pantalla completa, debajo de las barras
	vineta_sigilo = _vineta("vfx/screen/vignette_stealth.png")
	vineta_viral = _vineta("vfx/screen/vignette_viral.png")
	vineta_hp = _vineta("vfx/screen/vignette_lowhp.png")
	vineta_dano = _vineta("vfx/screen/vignette_damage.png")

	# barra superior: pulso de la ciudad
	_panel("kit/panel_solid.png", Rect2(0, 0, 960, 32), 8)
	_texto("PULSO DE LA CIUDAD", Vector2(8, 2), BLANCO)
	txt_dia = _texto("", Vector2(170, 2), GRIS)
	_imagen(load(UI + "hud/sir_bar_frame.png"), Vector2(6, 15))
	barra_i = _imagen(load(UI + "hud/sir_infected_texture.png"), Vector2(8, 17))
	barra_i.stretch_mode = TextureRect.STRETCH_TILE
	barra_s = _rect(Vector2(8, 17), AZUL_S)
	barra_r = _rect(Vector2(8, 17), BLANCO_R)
	_imagen(_cuadro("hud/sir_threshold_marker.png", 7, 0), Vector2(8 + 760 * Juego.UMBRAL_COLAPSO - 3, 13))
	txt_r0 = _texto("", Vector2(788, 2), BLANCO)
	txt_in = _texto("", Vector2(788, 16), BLANCO)

	# barra inferior
	_panel("kit/panel_solid.png", Rect2(0, 476, 960, 64), 8)
	_imagen(_cuadro("hud/icon_hp.png", 12, 0), Vector2(8, 484))
	_panel("kit/bar_frame.png", Rect2(24, 485, 160, 10), 3)
	_tex_hp = load(UI + "hud/bar_fill_hp.png")
	_tex_hp_bajo = load(UI + "hud/bar_fill_low.png")
	relleno_hp = _imagen(_tex_hp, Vector2(26, 487))
	_imagen(_cuadro("hud/icon_viral.png", 12, 0), Vector2(8, 502))
	_panel("kit/bar_frame.png", Rect2(24, 503, 160, 10), 3)
	relleno_viral = _imagen(load(UI + "hud/bar_fill_viral.png"), Vector2(26, 505))
	for r in [relleno_hp, relleno_viral]:
		r.stretch_mode = TextureRect.STRETCH_TILE
	for i in 6:
		_tex_ruido.append(_cuadro("hud/noise_meter.png", 40, i))
	medidor = _imagen(_tex_ruido[0], Vector2(200, 484))
	_texto("RUIDO", Vector2(203, 502), GRIS)
	txt_estado = _texto("", Vector2(8, 520), VERDE)

	for i in 3:
		_tex_ranura.append(_cuadro("kit/slot.png", 40, i))
		_tex_punto.append(_cuadro("hud/weapon_slot_dots.png", 8, i))
	for i in RANURAS.size():
		var x := 350 + i * 44
		_marcos.append(_imagen(_tex_ranura[0], Vector2(x, 484)))
		var icono := _imagen(load("res://assets/sprites/items/%s.png" % RANURAS[i][1]), Vector2(x + 4, 488))
		if icono.texture.get_width() < 32:  # el icono de suministros es de 16×16
			icono.position = Vector2(x + 12, 496)
		_iconos.append(icono)
		_cuentas.append(_texto("", Vector2(x + 22, 512), BLANCO))
	_texto("F: usar   R: cambiar", Vector2(350, 526), GRIS)

	_panel("kit/panel_dark.png", Rect2(760, 480, 192, 56), 8)
	_imagen(_cuadro("hud/weapon_icon_frame.png", 52, 0), Vector2(768, 488))
	for arma in Juego.ARMAS_ORDEN:
		_tex_armas[arma] = load("res://assets/sprites/weapons/%s.png" % Juego.ARMAS_INFO[arma]["icono"])
	icono_arma = _imagen(_tex_armas["tubo"], Vector2(770, 490))
	txt_arma = _texto("TUBO", Vector2(826, 486), BLANCO)
	txt_municion = _texto("", Vector2(826, 500), GRIS)
	for i in 4:
		_puntos.append(_imagen(_tex_punto[2], Vector2(826 + i * 10, 520)))

	# sobre el mundo
	txt_objetivo = _texto("", Vector2(8, 36), AMBAR)
	_contorno(txt_objetivo)
	txt_aviso = _texto("", Vector2(180, 440), BLANCO, fuente_grande, 16)
	txt_aviso.size = Vector2(600, 32)
	txt_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	txt_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_contorno(txt_aviso)
	txt_titulo = _texto("", Vector2(0, 96), BLANCO, fuente_grande, 32)
	txt_titulo.size = Vector2(960, 40)
	txt_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contorno(txt_titulo)
	txt_subtitulo = _texto("", Vector2(0, 136), AMBAR, fuente_grande, 16)
	txt_subtitulo.size = Vector2(960, 20)
	txt_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contorno(txt_subtitulo)
	txt_feed = _texto("", Vector2(500, 36), VERDE)
	txt_feed.size = Vector2(452, 60)
	txt_feed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_contorno(txt_feed)

	panel_hospital = _panel("kit/panel_dark.png", Rect2(8, 52, 236, 146), 8)
	panel_hospital.visible = false
	txt_hospital = _texto("", Vector2(10, 8), BLANCO)
	remove_child(txt_hospital)
	panel_hospital.add_child(txt_hospital)
	barra_colapso = ColorRect.new()
	barra_colapso.color = ROJO
	barra_colapso.position = Vector2(10, 134)
	barra_colapso.size = Vector2(0, 4)
	barra_colapso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_hospital.add_child(barra_colapso)

	caja_jefe = Control.new()
	caja_jefe.position = Vector2(330, 52)
	caja_jefe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja_jefe.visible = false
	add_child(caja_jefe)
	var fondo := ColorRect.new()
	fondo.color = TINTA
	fondo.size = Vector2(304, 10)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja_jefe.add_child(fondo)
	barra_jefe = ColorRect.new()
	barra_jefe.color = VERDE
	barra_jefe.position = Vector2(2, 2)
	barra_jefe.size = Vector2(300, 6)
	barra_jefe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja_jefe.add_child(barra_jefe)
	txt_jefe = _texto("", Vector2(0, 12), BLANCO)
	remove_child(txt_jefe)
	caja_jefe.add_child(txt_jefe)
	txt_jefe.size = Vector2(304, 10)
	txt_jefe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contorno(txt_jefe)


# =================================================================================================== mensajes

func aviso(texto: String) -> void:
	txt_aviso.text = texto
	_t_aviso = 4.5


func objetivo(texto: String) -> void:
	if txt_objetivo.text != texto:
		txt_objetivo.text = texto


func titulo(texto: String, subtitulo: String) -> void:
	txt_titulo.text = texto
	txt_subtitulo.text = "Modelos activos: " + subtitulo
	_t_titulo = 4.0


func destello_dano() -> void:
	_t_dano = 0.4


## Panel lateral del hospital: cola, camillas, W_q medido frente al teórico (Erlang C) y aviso de colapso.
func hospital(fase: String, colapso: float) -> void:
	panel_hospital.visible = true
	var cola = Juego.cola
	var teo: Dictionary = Juego.Cola.teoria(cola.lam, cola.mu, cola.c)
	var rho: float = teo["rho"]
	var wq_teorico := "inestable (rho >= 1)" if rho >= 1.0 else "%s min" % _coma(teo["Wq"], 2)
	txt_hospital.text = "HOSPITAL SAN RAFAEL · %s\n" % ("DÍA" if fase == "dia" else "NOCHE") \
		+ "Cola M/M/c (Modelo 2)\n" \
		+ "En espera: %d / 10\n" % cola.en_cola() \
		+ "Camillas c: %d  (ocupadas %d)\n" % [cola.c, mini(cola.ocupados, cola.c)] \
		+ "lambda %s  mu %s  rho %s\n" % [_coma(cola.lam, 2), _coma(cola.mu, 1), _coma(rho, 2)] \
		+ "Wq medido:  %s min\n" % _coma(cola.wq_medido(), 2) \
		+ "Wq teórico: %s\n" % wq_teorico \
		+ "Atendidos %d · Abandonos %d\n" % [cola.atendidos, cola.abandonos] \
		+ "Suministros: %d\n" % int(Juego.suministros) \
		+ "[+] abrir camilla   [-] cerrar"
	barra_colapso.size.x = 216.0 * clampf(colapso, 0.0, 1.0)


func jefe(fraccion: float, fase: int) -> void:
	caja_jefe.visible = fraccion >= 0.0
	if fraccion >= 0.0:
		barra_jefe.size.x = 300.0 * clampf(fraccion, 0.0, 1.0)
		txt_jefe.text = "PACIENTE CERO · fase: %s (Markov)" % FASES_JEFE[clampi(fase, 0, 3)]


# ================================================================================================ actualización

func refrescar(ruido: float, agachada: bool) -> void:
	var delta := get_process_delta_time()
	var sir = Juego.sir
	var fi: float = sir.i / sir.n
	var fs: float = sir.s / sir.n
	var wi := roundi(760 * fi)
	var ws := roundi(760 * fs)
	barra_i.size = Vector2(wi, 10)
	barra_s.position.x = 8 + wi
	barra_s.size = Vector2(ws, 10)
	barra_r.position.x = 8 + wi + ws
	barra_r.size = Vector2(maxi(0, 760 - wi - ws), 10)
	txt_r0.text = "R0 = %s" % _coma(sir.beta_ef() / sir.gamma_ef(), 2)
	txt_in.text = "I/N = %s %%" % _coma(fi * 100.0, 1)
	txt_in.modulate = ROJO if fi > Juego.UMBRAL_COLAPSO * 0.8 else BLANCO
	txt_dia.text = "Día %d · límite I/N = %d %%" % [int(Juego.dia), roundi(Juego.UMBRAL_COLAPSO * 100.0)]

	var hp: float = clampf(Juego.hp, 0.0, 100.0)
	relleno_hp.texture = _tex_hp_bajo if hp < 25.0 else _tex_hp
	relleno_hp.size = Vector2(roundi(156 * hp / 100.0), 6)
	relleno_viral.size = Vector2(roundi(156 * clampf(Juego.viral, 0.0, 100.0) / 100.0), 6)
	medidor.texture = _tex_ruido[clampi(ceili(ruido / 20.0), 0, 5)]

	var estado := ""
	if Juego.t_mascara > 0.0:
		estado += "CUBREBOCAS %d s   " % ceili(Juego.t_mascara)
	if Juego.t_adrenalina > 0.0:
		estado += "ADRENALINA %d s" % ceili(Juego.t_adrenalina)
	txt_estado.text = estado

	var cantidades := [Juego.inv["vendas"], Juego.inv["cubrebocas"], Juego.inv["adrenalina"], Juego.inv["antiviral"],
		Juego.muestras, int(Juego.suministros)]
	for i in RANURAS.size():
		var n: int = cantidades[i]
		var marco: TextureRect = _marcos[i]
		marco.texture = _tex_ranura[2 if i == Juego.consumible else (1 if n > 0 else 0)]
		var icono: TextureRect = _iconos[i]
		icono.modulate.a = 1.0 if n > 0 else 0.25
		var cuenta: Label = _cuentas[i]
		cuenta.text = "x%d" % n if n > 0 else ""

	var arma: String = Juego.arma
	icono_arma.texture = _tex_armas[arma]
	txt_arma.text = Juego.ARMAS_INFO[arma]["nombre"]
	var municion: int = Juego.municion(arma)
	txt_municion.text = "Sin munición" if municion < 0 else ("Carga: %d" % municion)
	txt_municion.modulate = ROJO if municion == 0 else BLANCO
	for i in 4:
		var punto: TextureRect = _puntos[i]
		var nombre: String = Juego.ARMAS_ORDEN[i]
		punto.texture = _tex_punto[0 if nombre == arma else (1 if Juego.tiene[nombre] else 2)]

	# avisos y título que se desvanecen
	_t_aviso = maxf(0.0, _t_aviso - delta)
	txt_aviso.modulate.a = clampf(_t_aviso, 0.0, 1.0)
	_t_titulo = maxf(0.0, _t_titulo - delta)
	txt_titulo.modulate.a = clampf(_t_titulo, 0.0, 1.0)
	txt_subtitulo.modulate.a = clampf(_t_titulo, 0.0, 1.0)

	# registro de los modelos: las últimas líneas de los últimos 9 s
	var lineas := []
	for k in range(Juego.feed.size() - 1, -1, -1):
		var ev: Array = Juego.feed[k]
		if Juego.t_juego - ev[0] > 9.0 or lineas.size() >= 4:
			break
		lineas.push_front("%s · %s" % [ev[1], ev[2]])
	txt_feed.text = "\n".join(lineas)

	# viñetas
	_t_dano = maxf(0.0, _t_dano - delta)
	vineta_dano.modulate.a = _t_dano / 0.4
	vineta_hp.modulate.a = 0.8 if hp < 25.0 else 0.0
	vineta_viral.modulate.a = clampf((Juego.viral - 50.0) / 50.0, 0.0, 1.0)
	vineta_sigilo.modulate.a = 0.6 if agachada else 0.0


# ==================================================================================================== piezas

func _coma(v: float, decimales: int) -> String:
	return String.num(v, decimales).replace(".", ",")  # decimales en español


func _fuente(archivo: String) -> FontFile:
	var f: FontFile = load("res://assets/fonts/" + archivo).duplicate()
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	return f


func _contorno(l: Label) -> void:
	l.add_theme_color_override("font_outline_color", TINTA)
	l.add_theme_constant_override("outline_size", 4)


func _vineta(ruta: String) -> TextureRect:
	var r := TextureRect.new()
	r.texture = load("res://assets/" + ruta)
	r.position = Vector2.ZERO
	r.modulate.a = 0.0
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _panel(ruta: String, r: Rect2, margen: int) -> NinePatchRect:
	var p := NinePatchRect.new()
	p.texture = load(UI + ruta)
	p.position = r.position
	p.size = r.size
	p.patch_margin_left = margen
	p.patch_margin_right = margen
	p.patch_margin_top = margen
	p.patch_margin_bottom = margen
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(p)
	return p


func _imagen(t: Texture2D, pos: Vector2) -> TextureRect:
	var r := TextureRect.new()
	r.texture = t
	r.position = pos
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE  # el HUD no debe tragarse la rueda ni los clics
	add_child(r)
	return r


func _rect(pos: Vector2, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.position = pos
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


## Cuadro i (de ancho w) de una hoja horizontal
func _cuadro(ruta: String, w: int, i: int) -> AtlasTexture:
	var hoja: Texture2D = load(UI + ruta)
	var a := AtlasTexture.new()
	a.atlas = hoja
	a.region = Rect2(i * w, 0, w, hoja.get_height())
	return a


func _texto(t: String, pos: Vector2, color: Color, f: FontFile = null, tam := 8) -> Label:
	var l := Label.new()
	l.text = t
	l.position = pos
	l.add_theme_font_override("font", fuente if f == null else f)
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l
