## Validación del Modelo 2 (GDD §16.2). Ejecutar:
##   godot --headless --path juego -s res://validacion/Cabra_Coy_validar_modelo2.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const Cola = preload("res://modelos/Cabra_Coy_modelo2_colas.gd")
const Reporte = preload("res://validacion/Ramirez_Camilo_reporte.gd")
const T_FIN := 10000.0
const REPLICAS := 30
const SEMILLA := 12345


func _init() -> void:
	var gen = Prng.minstd(SEMILLA)
	Reporte.encabezado("MODELO 2 — Cola M/M/c del hospital (GDScript)", gen.nombre + " + Exp(λ) por transformada inversa",
		"%d réplicas × %d min, semilla = %d" % [REPLICAS, T_FIN, SEMILLA])
	var filas := []
	for cfg in [[1, 0.8, 1.0, 1], [2, 1.5, 1.0, 2], [3, 2.0, 1.0, 3]]:
		var teo := Cola.teoria(cfg[1], cfg[2], cfg[3])
		var wq := []
		var lq := 0.0
		var rho := 0.0
		for i in REPLICAS:
			var r := Cola.new(gen, cfg[1], cfg[2], cfg[3]).simular(T_FIN)
			wq.append(r.Wq)
			lq += r.Lq / REPLICAS
			rho += r.rho / REPLICAS
		var w := Reporte.ic95(wq)
		print("\nConfig %d: λ=%s, μ=%s, c=%d   Wq teo %.3f sim %.3f IC95 [%.3f, %.3f]" % [cfg[0], cfg[1], cfg[2], cfg[3],
			teo.Wq, w[0], w[1], w[2]])
		var par := "lambda=%s, mu=%s, c=%d" % [cfg[1], cfg[2], cfg[3]]
		filas.append({"config": cfg[0], "parametros": par, "medida": "Wq (min)", "teorico": teo.Wq, "obtenido": w[0]})
		filas.append({"config": cfg[0], "parametros": par, "medida": "Lq", "teorico": teo.Lq, "obtenido": lq})
		filas.append({"config": cfg[0], "parametros": par, "medida": "rho", "teorico": teo.rho, "obtenido": rho})
	Reporte.tabla(filas, "modelo2_colas")
	var ext := Cola.new(gen, 0.8, 1.0, 1, 5.0).simular(T_FIN)
	var total: int = ext.atendidos + ext.abandonos
	print("\nExtensión (juego): T_pac = 5 min -> abandonan %d de %d pacientes (%.1f %%), Wq = %.3f min." % [ext.abandonos,
		total, 100.0 * ext.abandonos / total, ext.Wq])
	quit()
