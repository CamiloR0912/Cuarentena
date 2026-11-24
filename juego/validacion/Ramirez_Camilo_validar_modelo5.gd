## Validación del Modelo 5 (GDD §16.5). Ejecutar:
##   godot --headless --path juego -s res://validacion/Ramirez_Camilo_validar_modelo5.gd
extends SceneTree

const Prng = preload("res://modelos/Ramirez_Camilo_prng.gd")
const SIR = preload("res://modelos/Ramirez_Camilo_modelo5_dinamica.gd")
const Reporte = preload("res://validacion/Ramirez_Camilo_reporte.gd")
const N := 180000.0
const SEMILLA := 2026


func _init() -> void:
	var gen = Prng.lcg(SEMILLA)
	Reporte.encabezado("MODELO 5 — Dinámica de sistemas: SIR (RK4) (GDScript)", gen.nombre + " (sensibilidad de β)",
		"N = 180000, I0 = 10, γ = 0.1, Δt = 0.1 día, semilla = %d" % SEMILLA)
	var filas := []
	var k := 1
	for beta in [0.30, 0.20, 0.15]:
		var r0: float = beta / 0.1
		var serie: Array = SIR.new(N, 10.0, beta).simular(400)
		var p: Array = SIR.pico(serie)
		var r_fin: float = serie[-1][3] / N
		print("Config %d: β = %s, ℛ0 = %.1f -> pico I/N = %.4f el día %d, r∞ = %.4f" % [k, beta, r0, p[1] / N, p[0], r_fin])
		var par := "beta=%s, gamma=0.1, R0=%.1f" % [beta, r0]
		filas.append({"config": k, "parametros": par, "medida": "I_max/N", "teorico": SIR.i_max_teorico(r0), "obtenido": p[1] / N})
		filas.append({"config": k, "parametros": par, "medida": "r_inf", "teorico": SIR.r_inf_teorico(r0), "obtenido": r_fin})
		k += 1
	Reporte.tabla(filas, "modelo5_dinamica")

	var ref: float = SIR.new(N, 10.0, 0.3).simular(60, 0.001)[-1][2]
	print("\nError relativo de I(60) frente a RK4 con Δt = 0.001:")
	for dt in [1.0, 0.5, 0.25, 0.1, 0.05]:
		var e1 := absf(SIR.new(N, 10.0, 0.3).simular(60, dt, "euler")[-1][2] - ref) / ref
		var e4 := absf(SIR.new(N, 10.0, 0.3).simular(60, dt, "rk4")[-1][2] - ref) / ref
		print("   Δt = %-5s Euler = %s   RK4 = %s" % [dt, String.num_scientific(e1), String.num_scientific(e4)])

	var picos := []
	for rep in 500:
		var s: Array = SIR.new(N, 10.0, gen.uniforme(0.25, 0.35)).simular(250, 0.25)
		picos.append(SIR.pico(s)[1] / N)
	var m := Reporte.ic95(picos)
	print("\nSensibilidad: β ~ U(0.25, 0.35), 500 réplicas -> I_max/N medio = %.4f IC95 [%.4f, %.4f]" % m)

	var jugador := func(dia: int, sir) -> void:
		if dia == 30:
			sir.f_cub = 0.3
		if dia >= 35 and dia < 90:
			sir.atendidos_dia = 900.0
			sir.rescate(40.0)
		if dia >= 55 and dia < 60:
			sir.abandono_cola(300.0)
	var base: Array = SIR.new(N, 10.0, 0.3).simular(200)
	var interv: Array = SIR.new(N, 10.0, 0.3).simular(200, 0.1, "rk4", jugador)
	print("Escenario de juego: pico sin intervención %.3f, con intervención %.3f" % [SIR.pico(base)[1] / N, SIR.pico(interv)[1] / N])
	quit()
