## Prueba de humo del juego (sin abrir el editor). Carga cada pantalla y cada nivel, los deja correr unos
## cuadros y comprueba que los cinco modelos estén activos. Sale con código 1 si algo falla.
##   godot --headless --path juego -s res://validacion/prueba_juego.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const Cola = preload("res://modelos/Cabra_Coy_modelo2_colas.gd")

var aprobadas := 0
var falladas := 0
var juego: Node


func _initialize() -> void:
	await _pruebas()
	print("\nResultado: %d comprobaciones correctas, %d fallidas" % [aprobadas, falladas])
	quit(1 if falladas > 0 else 0)


func comprobar(condicion: bool, etiqueta: String) -> void:
	if condicion:
		aprobadas += 1
		print("  ok    %s" % etiqueta)
	else:
		falladas += 1
		print("  FALLA %s" % etiqueta)
		push_error("FALLA %s" % etiqueta)


func _cuadros(n: int) -> void:
	for k in n:
		await physics_frame


func _caja_dialogo(padre: Node):
	for hijo in padre.get_children():
		if hijo.has_signal("terminado") and hijo.has_method("avanzar"):
			return hijo
	return null


func _abrir(ruta: String) -> Node:
	var escena: PackedScene = load(ruta)
	if escena == null:
		return null
	var nodo := escena.instantiate()
	root.add_child(nodo)
	return nodo


func _pruebas() -> void:
	await process_frame
	juego = root.get_node_or_null("Juego")
	comprobar(juego != null, "autoload Juego registrado")
	if juego == null:
		return

	print("\n[Diálogos]")
	var intro := _abrir("res://escenas/intro.tscn")
	await _cuadros(5)
	var caja = _caja_dialogo(intro)
	comprobar(caja != null and caja.indice == 0, "la intro abre la caja de diálogo")
	if caja != null:
		caja.avanzar()   # completa la línea que se está escribiendo
		caja.avanzar()   # pasa a la siguiente
		comprobar(caja.indice == 1, "avanzar pasa a la siguiente línea")
		caja.saltar()
		await _cuadros(15)
		comprobar(not is_instance_valid(caja), "Esc cierra el diálogo")
	if is_instance_valid(intro):
		intro.queue_free()
	if current_scene != null:
		current_scene.queue_free()   # la intro terminada abre el briefing
	await _cuadros(3)
	juego.nueva_partida()
	juego.nivel = 1
	var con_dialogo := _abrir("res://escenas/nivel.tscn")
	await _cuadros(5)
	var caja_nivel = _caja_dialogo(con_dialogo)
	comprobar(caja_nivel != null and paused, "al empezar un nivel aparece su diálogo y pausa el juego")
	if caja_nivel != null:
		caja_nivel.saltar()
		await _cuadros(15)
	comprobar(not paused, "al cerrar el diálogo el juego se reanuda")
	comprobar(not juego.marcar_dialogo("nivel1"), "el diálogo del nivel no se repite en la misma partida")
	con_dialogo.queue_free()
	await _cuadros(3)
	juego.dialogos_activos = false   # el resto de pruebas corre sin diálogos

	print("\n[Modelo 2] cola en tiempo real frente a Erlang C (lambda 1,5; mu 1; c 2; 6 000 min)")
	var cola = Cola.new(Prng.minstd(12345), 1.5, 1.0, 2)
	cola.iniciar()
	var t := 0.0
	while t < 6000.0:
		t += 0.05
		cola.avanzar(t)
	var teo: Dictionary = Cola.teoria(1.5, 1.0, 2)
	var wq: float = cola.wq_medido(1000000)
	print("  Wq medido %.3f, teórico %.3f; Lq medido %.3f, teórico %.3f" % [wq, teo["Wq"], cola.lq_medido(), teo["Lq"]])
	comprobar(absf(wq - teo["Wq"]) / teo["Wq"] < 0.15, "Wq en tiempo real a menos del 15 % del teórico")

	print("\n[Pantallas]")
	for ruta in ["res://escenas/menu_principal.tscn", "res://escenas/briefing.tscn", "res://escenas/info.tscn"]:
		var pantalla := _abrir(ruta)
		await _cuadros(5)
		comprobar(pantalla != null and is_instance_valid(pantalla) and pantalla.get_child_count() > 0, ruta)
		if pantalla != null:
			pantalla.queue_free()
		await _cuadros(2)
	comprobar(juego.stats["radio"][3] > 0, "la radio ejecutó Monte Carlo (N = %d, p = %.3f)" % [juego.stats["radio"][3],
		juego.stats["radio"][0]])

	for n in [1, 2, 3, 4]:
		print("\n[Nivel %d]" % n)
		juego.nueva_partida()
		juego.nivel = n
		var nivel := _abrir("res://escenas/nivel.tscn")
		await _cuadros(240)   # 4 s de simulación
		var vivo: bool = nivel != null and is_instance_valid(nivel)
		comprobar(vivo, "el nivel carga y corre 240 cuadros")
		if not vivo:
			continue
		comprobar(nivel.get("elena") != null, "Elena creada")
		var enemigos := get_nodes_in_group("enemigos")
		print("  infectados: %d, ciudadanos: %d, zonas: %s" % [enemigos.size(), get_nodes_in_group("ciudadanos").size(),
			str(nivel.zonas.keys())])
		if n != 2:
			comprobar(enemigos.size() > 0, "hay infectados en el mapa")
			var antes: int = juego.stats["ataques"]
			var objetivo = enemigos[0]
			for k in 60:
				if objetivo.vida != "activo":
					break
				nivel.golpear(objetivo, "tubo", objetivo.position + Vector2(0, 20))
			comprobar(juego.stats["ataques"] > antes, "Monte Carlo decide el daño (%d ataques)" % (juego.stats["ataques"] - antes))
			if objetivo.tipo != "Paciente Cero":
				comprobar(objetivo.vida == "sedado", "el infectado queda sedado al agotar su agitación")
		if n == 1:
			var pasos: Dictionary = juego.stats["pasos"]
			comprobar(pasos["N"] + pasos["S"] + pasos["E"] + pasos["O"] > 0, "los errantes dan pasos de caminata aleatoria")
			# triaje de calle: la salida está cerrada hasta entregar 3 sedados y recoger el antiviral
			var salida: Vector2 = nivel.zonas["level_exit"][0].get_center()
			var ambulancia: Vector2 = nivel.zonas["dropoff_zone"][0].get_center()
			nivel.elena.position = salida
			await _cuadros(10)
			comprobar(not nivel.terminado, "retén cerrado: llegar a la salida no completa el nivel")
			for k in juego.META_ENTREGAS_N1:
				var paciente = null
				for e in get_nodes_in_group("enemigos"):
					if not e.is_queued_for_deletion() and e.vida != "cargado":
						paciente = e
						break
				for j in 60:
					if paciente.vida != "activo":
						break
					nivel.golpear(paciente, "tubo", paciente.position + Vector2(0, 20))
				nivel.elena.position = paciente.position + Vector2(8, 0)
				await _cuadros(3)
				nivel.interactuar()
				nivel.elena.position = ambulancia
				await _cuadros(5)
			comprobar(nivel.entregas_triaje == juego.META_ENTREGAS_N1 and not nivel.salida_abierta,
				"3 sedados entregados (%d); falta el antiviral y el retén sigue cerrado" % nivel.entregas_triaje)
			nivel.elena.position = nivel.puntos["pharmacy"][0] + Vector2(0, 24)
			await _cuadros(3)
			nivel.interactuar()
			comprobar(nivel.salida_abierta, "antiviral recogido: el retén se abre")
			nivel.elena.position = salida
			await _cuadros(10)
			comprobar(nivel.terminado, "con el triaje completo, la salida termina el nivel")
			juego.hp = 100.0
		if n == 2:
			comprobar(nivel._camillas.size() > 0, "camillas del mapa enlazadas con la cola (%d)" % nivel._camillas.size())
			comprobar(juego.cola.reloj > 0.0, "la cola M/M/c avanza")
		if n == 3:
			comprobar(get_nodes_in_group("ciudadanos").size() > 0, "hay ciudadanos (agentes con pánico)")
		if n == 4:
			comprobar(nivel.jefe != null, "Paciente Cero creado")
		comprobar(juego.dia > 0.0 and juego.sir.i > 0.0, "el SIR avanza (día %.2f, I = %.1f)" % [juego.dia, juego.sir.i])
		nivel.queue_free()
		await _cuadros(3)

	print("\n[Fin de partida]")
	for resultado in ["derrota", "victoria"]:
		juego.resultado = resultado
		juego.causa = "ciudad"
		var fin := _abrir("res://escenas/fin.tscn")
		await _cuadros(5)
		comprobar(fin != null and is_instance_valid(fin) and fin.get_child_count() > 0, "pantalla de %s" % resultado)
		if fin != null:
			fin.queue_free()
		await _cuadros(2)

	print("\n[Casos de prueba 5 y 6]")
	print("  " + juego.prueba_ataques())
	print("  " + juego.prueba_drops())
