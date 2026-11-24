## Encabezado de ejecución y tabla de validación (igual que en los prototipos de Python).
extends RefCounted


static func encabezado(modelo: String, generador: String, extra := "") -> void:
	var linea := "=".repeat(92)
	print(linea)
	print(" %s" % modelo)
	print(" Fecha y hora : %s" % Time.get_datetime_string_from_system(false, true))
	print(" Usuario      : %s   Equipo: %s   Godot %s" % [OS.get_environment("USERNAME"), OS.get_environment("COMPUTERNAME"),
		Engine.get_version_info().string])
	print(" PRNG         : %s" % generador)
	if extra != "":
		print(" %s" % extra)
	print(linea)


static func dif_pct(teorico: float, obtenido: float) -> float:
	return absf(obtenido) * 100.0 if teorico == 0.0 else absf(obtenido - teorico) / absf(teorico) * 100.0


## filas: Array de {config, parametros, medida, teorico, obtenido}; imprime y guarda CSV en validacion/resultados/<carpeta>/
static func tabla(filas: Array, carpeta: String) -> void:
	print("\n%-7s%-42s%-14s%12s%12s%9s" % ["Config", "Parámetros", "Medida", "Teórico", "Obtenido", "Dif. %"])
	print("-".repeat(96))
	var dir := "res://validacion/resultados/%s" % carpeta
	DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(dir + "/validacion.csv", FileAccess.WRITE)
	f.store_line("config,parametros,medida,teorico,obtenido,dif_pct")
	for fila in filas:
		var d := dif_pct(fila.teorico, fila.obtenido)
		print("%-7s%-42s%-14s%12.4f%12.4f%8.2f%%" % [str(fila.config), fila.parametros, fila.medida, fila.teorico, fila.obtenido, d])
		f.store_line('%s,"%s",%s,%.10f,%.10f,%.6f' % [str(fila.config), fila.parametros, fila.medida, fila.teorico, fila.obtenido, d])
	print("\nTabla guardada en %s" % ProjectSettings.globalize_path(dir + "/validacion.csv"))


## Media e IC 95 % (aprox. normal, desviación muestral)
static func ic95(xs: Array) -> Array:
	var n := xs.size()
	var s := 0.0
	for v in xs:
		s += v
	var med := s / n
	var acc := 0.0
	for v in xs:
		acc += (v - med) * (v - med)
	var h := 1.96 * sqrt(acc / (n - 1)) / sqrt(n) if n > 1 else 0.0
	return [med, med - h, med + h]
