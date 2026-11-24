## Validación de las cadenas de Markov (GDD §16.6). Ejecutar:
##   godot --headless --path juego -s res://validacion/Ruiz_Sergio_validar_markov.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const Markov = preload("res://modelos/Ruiz_Sergio_markov.gd")
const Reporte = preload("res://validacion/Ramirez_Camilo_reporte.gd")
const SEMILLA := 4242
const REPLICAS := 10000


func _init() -> void:
	var gen = Prng.lcg(SEMILLA)
	Reporte.encabezado("MODELO COMPLEMENTARIO — Cadenas de Markov (GDScript)", gen.nombre, "semilla = %d" % SEMILLA)
	var tiempos := []
	for k in REPLICAS:
		tiempos.append(float(Markov.tiempo_hasta_corredor(gen)))
	var t := Reporte.ic95(tiempos)
	print("\nTiempo Errante -> Corredor: %.3f min IC95 [%.3f, %.3f]  (teórico 16.667)" % t)
	var pi10 := Markov.distribucion([1.0, 0.0, 0.0], Markov.P, 10)
	var finales := [0, 0, 0]
	for k in REPLICAS:
		var e := 0
		for paso in 10:
			e = Markov.paso(gen, Markov.P, e)
		finales[e] += 1
	var pi_jefe := Markov.estacionaria(Markov.P_JEFE)
	var visitas := [0, 0, 0, 0]
	var e := 0
	for k in 50000:
		e = Markov.paso(gen, Markov.P_JEFE, e)
		visitas[e] += 1
	for f in 4:
		print("Jefe %-17s π teórica %.4f / simulada %.4f" % [Markov.FASES[f], pi_jefe[f], visitas[f] / 50000.0])
	Reporte.tabla([
		{"config": 1, "parametros": "P infectado, inicio Errante", "medida": "E[T] (min)", "teorico": 1 / 0.10 + 1 / 0.15, "obtenido": t[0]},
		{"config": 2, "parametros": "pi_10, estado Corredor", "medida": "P(Corredor)", "teorico": pi10[2], "obtenido": finales[2] / float(REPLICAS)},
		{"config": 3, "parametros": "P jefe, 50 000 pasos", "medida": "pi(Deambular)", "teorico": pi_jefe[0], "obtenido": visitas[0] / 50000.0},
	], "markov")
	quit()
