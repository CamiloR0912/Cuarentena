## Validación del Modelo 4 (GDD §16.4). Ejecutar:
##   godot --headless --path juego -s res://validacion/Ramirez_Camilo_validar_modelo4.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const Agentes = preload("res://modelos/Ramirez_Camilo_modelo4_agentes.gd")
const Reporte = preload("res://validacion/Ramirez_Camilo_reporte.gd")
const SEMILLA := 777


func _init() -> void:
	var gen = Prng.lcg(SEMILLA)
	Reporte.encabezado("MODELO 4 — Agentes: boids, contagio, FSM del Corredor, pánico (GDScript)", gen.nombre,
		"semilla = %d" % SEMILLA)
	var rms1 := 0.0
	for i in 5:
		rms1 += pow(_boids(gen, 0.0, 0.6)[0], 2) / 5.0
	rms1 = sqrt(rms1)
	var medias2 := []
	for i in 5:
		medias2.append(_boids(gen, 0.9, 0.08)[1])
	var phi2 := Reporte.ic95(medias2)
	var finales := []
	for i in 10:
		finales.append(Agentes.contagio(gen)[-1][2] / 2000.0)
	var r_inf := Reporte.ic95(finales)
	print("\nConfig 1: φ_rms = %.4f (teórico 1/√50 = %.4f)" % [rms1, 1.0 / sqrt(50.0)])
	print("Config 2: φ medio = %.4f  IC95 [%.4f, %.4f]" % phi2)
	print("Config 3: r∞ = %.4f  IC95 [%.4f, %.4f]" % r_inf)
	Reporte.tabla([
		{"config": 1, "parametros": "Boids N=50, w_a=0, eta=0.6", "medida": "phi_rms", "teorico": 1.0 / sqrt(50.0), "obtenido": rms1},
		{"config": 2, "parametros": "Boids N=50, w_a=0.9, eta=0.08", "medida": "phi", "teorico": 1.0, "obtenido": phi2[0]},
		{"config": 3, "parametros": "ABM beta=0.3, gamma=0.1, N=2000", "medida": "r_inf", "teorico": Agentes.tamano_final(3.0),
			"obtenido": r_inf[0]},
	], "modelo4_agentes")

	var guion := []
	for x in 5: guion.append([10.0, false])
	for x in 2: guion.append([70.0, false])
	for x in 6: guion.append([30.0, true])
	for x in 15: guion.append([10.0, false])
	for x in 6: guion.append([5.0, false])
	var cor = Agentes.Corredor.new()
	print("\nFSM del Corredor (un paso por segundo):")
	for t in guion.size():
		if cor.actualizar(1.0, guion[t][0], guion[t][1]):
			print("   t = %2d s: ruido %2d, ve a Elena %-5s -> %s" % [t, guion[t][0], str(guion[t][1]), cor.estado])
	quit()


## Corre 400 pasos y descarta los primeros 100; devuelve [φ_rms, φ medio] de la parte estable.
func _boids(gen, w_a: float, ruido: float) -> Array:
	var b = Agentes.Boids.new(gen, 50, 50.0, 6.0, 1.0, 0.6, w_a, 0.02, ruido)
	var s2 := 0.0
	var s := 0.0
	for k in 400:
		b.paso()
		if k >= 100:
			var f: float = b.phi()
			s2 += f * f
			s += f
	return [sqrt(s2 / 300.0), s / 300.0]
