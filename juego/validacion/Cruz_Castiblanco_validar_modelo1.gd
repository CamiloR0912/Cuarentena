## Validación del Modelo 1 (GDD §16.1). Ejecutar:
##   godot --headless --path juego -s res://validacion/Cruz_Castiblanco_validar_modelo1.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const Caminata = preload("res://modelos/Cruz_Castiblanco_modelo1_caminatas.gd")
const Reporte = preload("res://validacion/Ramirez_Camilo_reporte.gd")
const REPLICAS := 10000
const SEMILLA := 12345


func _init() -> void:
	var gen = Prng.lcg(SEMILLA)
	Reporte.encabezado("MODELO 1 — Caminata aleatoria 2D con sesgo por ruido (GDScript)", gen.nombre,
		"Réplicas por configuración = %d, semilla = %d, ℓ = 1" % [REPLICAS, SEMILLA])
	var sesgo := {"N": 0.2, "S": 0.2, "E": 0.4, "O": 0.2}
	var r2_1 := _finales(gen, 100, Caminata.UNIFORME, "r2")
	var r2_2 := _finales(gen, 400, Caminata.UNIFORME, "r2")
	var xs3 := _finales(gen, 100, sesgo, "x")
	var c1 := Reporte.ic95(r2_1)
	var c2 := Reporte.ic95(r2_2)
	var c3 := Reporte.ic95(xs3)
	print("\nConfig 1: E[R²] = %.3f  IC95 [%.3f, %.3f]" % c1)
	print("Config 2: E[R²] = %.3f  IC95 [%.3f, %.3f]" % c2)
	print("Config 3: E[x_n] = %.3f  IC95 [%.3f, %.3f]" % c3)
	Reporte.tabla([
		{"config": 1, "parametros": "n=100, l=1, p=1/4", "medida": "E[R^2]", "teorico": 100.0, "obtenido": c1[0]},
		{"config": 2, "parametros": "n=400, l=1, p=1/4", "medida": "E[R^2]", "teorico": 400.0, "obtenido": c2[0]},
		{"config": 3, "parametros": "n=100, l=1, pE=0.4, pN=pS=pO=0.2", "medida": "E[x_n]", "teorico": 20.0, "obtenido": c3[0]},
	], "modelo1_caminatas")

	# Mecánica del juego: sesgo hacia el ruido de combate (90) con radio de audición 60
	var fuente := Vector2i(30, 20)
	var probs_ruido := func(p: Vector2i) -> Dictionary:
		var dist := Vector2(fuente - p).length()
		return Caminata.probabilidades_con_sesgo(p, fuente, Caminata.sesgo_por_ruido(90, dist, 60))
	var cam = Caminata.new(gen)
	var con_ruido := cam.caminar(300, Vector2i.ZERO, Callable(), probs_ruido)
	var sin_ruido := cam.caminar(300)
	print("\nDemostración de sesgo: con ruido termina a %.1f casillas de la fuente; sin ruido a %.1f." % [
		Vector2(fuente - con_ruido[-1]).length(), Vector2(fuente - sin_ruido[-1]).length()])
	quit()


## Réplicas independientes; devuelve R² o x final de cada una (el generador continúa su secuencia).
func _finales(gen, n: int, probs: Dictionary, medida: String) -> Array:
	var cam = Caminata.new(gen, 1, probs)
	var out := []
	for i in REPLICAS:
		var fin: Vector2i = cam.caminar(n)[-1]
		out.append(float(fin.x * fin.x + fin.y * fin.y) if medida == "r2" else float(fin.x))
	return out
