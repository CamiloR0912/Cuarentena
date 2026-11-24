## Comprueba que el port de los generadores reproduce la secuencia de Python (pseudo_gen) bit a bit.
## Ejecutar: godot --headless --path juego -s res://validacion/Ramirez_Camilo_validar_prng.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const Reporte = preload("res://validacion/Ramirez_Camilo_reporte.gd")

# Primeros valores producidos por Python (modelos/Ramirez_Camilo_utilidades.py)
const REFERENCIA := {
	"lcg": [0.02040268573909998, 0.01654784823767841, 0.5431557944975793],
	"minstd": [0.09661652850760917, 0.8339946273872604, 0.9477024976851895],
	"aditivo": [0.027473307447507977, 0.47921500890515745, 0.8348338028881699],
	"normal": [-1.1568343534449788, 1.2432717176057304, -0.32730309479384645],
}


func _init() -> void:
	Reporte.encabezado("Paridad de generadores Python -> GDScript", "LCG, MINSTD, Aditivo, Normal (Box-Muller)")
	var gens := {"lcg": Prng.lcg(12345), "minstd": Prng.minstd(12345), "aditivo": Prng.aditivo(12345)}
	var todo_ok := true
	for clave in gens:
		var obtenidos := []
		for i in 3:
			obtenidos.append(gens[clave].siguiente())
		todo_ok = _comparar(clave, obtenidos) and todo_ok
	var g = Prng.lcg(1)
	var normales := []
	for i in 3:
		normales.append(g.normal(0.0, 1.0))
	todo_ok = _comparar("normal", normales) and todo_ok
	print("\nResultado: %s" % ("IDÉNTICOS a Python" if todo_ok else "DIFERENTES de Python"))
	quit(0 if todo_ok else 1)


func _comparar(clave: String, obtenidos: Array) -> bool:
	var ok := true
	for i in obtenidos.size():
		ok = ok and is_equal_approx(obtenidos[i], REFERENCIA[clave][i]) and absf(obtenidos[i] - REFERENCIA[clave][i]) < 1e-15
	print("%-8s %s  %s" % [clave, str(obtenidos), "OK" if ok else "DIFERENTE"])
	return ok
