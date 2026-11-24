## Validación del Modelo 3 (GDD §16.3). Ejecutar:
##   godot --headless --path juego -s res://validacion/Sanchez_Diego_validar_modelo3.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const MonteCarlo = preload("res://modelos/Sanchez_Diego_modelo3_montecarlo.gd")
const Reporte = preload("res://validacion/Ramirez_Camilo_reporte.gd")
const N := 10000
const SEMILLA := 12345
const CHI2_CRITICO_5GL := 11.070497693516351  # χ²(0.95; 5), valor de scipy.stats.chi2.ppf


func _init() -> void:
	var gen = Prng.aditivo(SEMILLA)
	Reporte.encabezado("MODELO 3 — Monte Carlo: daño, críticos, drops y radio (GDScript)", gen.nombre + " (sembrado con LCG)",
		"N = %d réplicas, semilla = %d, k = 2" % [N, SEMILLA])
	var mc = MonteCarlo.new(gen)
	var tubo := []
	var dardos := []
	var exitos := 0
	for i in N:
		tubo.append(mc.dano("tubo")[0])
	for i in N:
		dardos.append(mc.dano("dardos")[0])
	for i in N:
		exitos += int(mc.mision_simplificada(0.9, 5))
	var t := Reporte.ic95(tubo)
	var d := Reporte.ic95(dardos)
	var p_hat := float(exitos) / N
	var criticos_espalda := 0
	for i in 1000:
		criticos_espalda += int(mc.dano("tubo", true)[1])
	print("\nConfig 1 (tubo):   E[D] = %.4f  IC95 [%.4f, %.4f]" % t)
	print("Config 2 (dardos): E[D] = %.4f  IC95 [%.4f, %.4f]" % d)
	print("Config 3 (misión): p̂ = %.4f" % p_hat)
	print("Caso de prueba 5: 1000 ataques por la espalda -> tasa de críticos %.3f (esperado 0.35)" % (criticos_espalda / 1000.0))
	Reporte.tabla([
		{"config": 1, "parametros": "Tubo U(8,12), p_crit=0.10, k=2", "medida": "E[D]", "teorico": 11.0, "obtenido": t[0]},
		{"config": 2, "parametros": "Dardos N(15,3), p_crit=0.15, k=2", "medida": "E[D]", "teorico": 17.25, "obtenido": d[0]},
		{"config": 3, "parametros": "Mision q=0.90, m=5", "medida": "P(exito)", "teorico": pow(0.9, 5), "obtenido": p_hat},
	], "modelo3_montecarlo")

	print("\nPrueba χ² de los drops (10 000 por enemigo, α = 0.05):")
	for enemigo in MonteCarlo.DROPS:
		var obs := {}
		for fila in MonteCarlo.DROPS[enemigo]:
			obs[fila[0]] = 0
		for i in N:
			obs[mc.drop(enemigo)] += 1
		var est := 0.0
		for fila in MonteCarlo.DROPS[enemigo]:
			var esperado: float = N * fila[1]
			est += pow(obs[fila[0]] - esperado, 2) / esperado
		print("   %-9s χ² = %7.3f   crítico = %.2f   %s" % [enemigo, est, CHI2_CRITICO_5GL,
			"NO se rechaza H0" if est < CHI2_CRITICO_5GL else "se rechaza H0"])

	var zona := ["Errante", "Errante", "Corredor", "Errante", "Masa", "Masa", "Corredor"]
	var r: Array = mc.radio(zona, 100.0)
	print('\nRadio: "Doctora, en la farmacia hay antivirales, pero la zona está caliente. Calculo un %d %% de probabilidad de volver." (IC95 %.1f %%–%.1f %%)' % [roundi(r[0] * 100), r[1] * 100, r[2] * 100])
	quit()
