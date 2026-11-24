## MODELO 4 — Agentes (port de modelos/..._modelo4_agentes.py): Masas (boids), contagio en la calle,
## Corredor (máquina de estados) y ciudadanos (pánico). Clases internas para usarlas por separado en el juego.
##   Boids: v ← normalizar(v + w_s·sep + w_a·ali + w_c·coh + η·ξ)·v_max,  φ = |Σv| / (N v_max)
##   Contagio: P(S→I) = 1 − exp(−β I/N),  P(I→R) = 1 − exp(−γ)
extends RefCounted


class Boids:
	# Floats de 64 bits (Vector2 es de 32 bits y el enjambre es caótico: se perdería la paridad con Python).
	var gen
	var n: int
	var lado: float
	var rv: float
	var vmax: float
	var w_s: float
	var w_a: float
	var w_c: float
	var ruido: float
	var px := PackedFloat64Array()
	var py := PackedFloat64Array()
	var vx := PackedFloat64Array()
	var vy := PackedFloat64Array()

	func _init(generador, cantidad := 50, lado_ := 50.0, r_vision := 6.0, v_max := 1.0, ws := 0.6, wa := 0.0, wc := 0.02,
			eta := 0.6) -> void:
		gen = generador
		n = cantidad
		lado = lado_
		rv = r_vision
		vmax = v_max
		w_s = ws
		w_a = wa
		w_c = wc
		ruido = eta
		for i in n:
			px.append(gen.uniforme(0.0, lado))
			py.append(gen.uniforme(0.0, lado))
		for i in n:
			var d := _dir_aleatoria(vmax)
			vx.append(d[0])
			vy.append(d[1])

	func _dir_aleatoria(r: float) -> Array:
		var ang: float = gen.uniforme(0.0, 2.0 * PI)
		return [r * cos(ang), r * sin(ang)]

	## componente de b − a en el toro (distancia mínima)
	func _delta(d: float) -> float:
		if d > lado / 2.0:
			return d - lado
		if d < -lado / 2.0:
			return d + lado
		return d

	func paso() -> void:
		var nx := PackedFloat64Array()
		var ny := PackedFloat64Array()
		for i in n:
			var sep_x := 0.0
			var sep_y := 0.0
			var ali_x := 0.0
			var ali_y := 0.0
			var coh_x := 0.0
			var coh_y := 0.0
			var cnt := 0
			for j in n:
				if i == j:
					continue
				var dx := _delta(px[j] - px[i])
				var dy := _delta(py[j] - py[i])
				var dist2 := dx * dx + dy * dy
				if dist2 > 0.0 and dist2 < rv * rv:
					cnt += 1
					sep_x -= dx / dist2
					sep_y -= dy / dist2
					ali_x += vx[j]
					ali_y += vy[j]
					coh_x += dx
					coh_y += dy
			var v0 := vx[i]
			var v1 := vy[i]
			if cnt:
				v0 += (w_s * sep_x + w_a * (ali_x / cnt - vx[i]) + w_c * coh_x / cnt)
				v1 += (w_s * sep_y + w_a * (ali_y / cnt - vy[i]) + w_c * coh_y / cnt)
			var xi := _dir_aleatoria(ruido)
			v0 = v0 + xi[0]
			v1 = v1 + xi[1]
			var norma := sqrt(v0 * v0 + v1 * v1)
			if norma == 0.0:
				norma = 1.0
			nx.append(v0 / norma * vmax)
			ny.append(v1 / norma * vmax)
		vx = nx
		vy = ny
		for i in n:
			px[i] = fposmod(px[i] + vx[i], lado)
			py[i] = fposmod(py[i] + vy[i], lado)

	func phi() -> float:
		var sx := 0.0
		var sy := 0.0
		for i in n:
			sx += vx[i]
			sy += vy[i]
		return sqrt(sx * sx + sy * sy) / (n * vmax)


## Contagio en población bien mezclada (0 = S, 1 = I, 2 = R). Devuelve [S, I, R] por día.
static func contagio(gen, n := 2000, i0 := 20, beta := 0.3, gamma := 0.1, dias := 200) -> Array:
	var estado := PackedByteArray()
	estado.resize(n)
	for k in i0:
		estado[k] = 1
	var p_rec := 1.0 - exp(-gamma)
	var serie := []
	for d in dias:
		var cuenta := [estado.count(0), estado.count(1), estado.count(2)]
		serie.append(cuenta)
		if cuenta[1] == 0:
			continue
		var p_inf := 1.0 - exp(-beta * cuenta[1] / n)
		for k in n:
			if estado[k] == 0:
				if gen.bernoulli(p_inf):
					estado[k] = 1
			elif estado[k] == 1 and gen.bernoulli(p_rec):
				estado[k] = 2
	return serie


## Raíz de r = 1 − exp(−ℛ0 r)
static func tamano_final(r0: float) -> float:
	var r := 0.5
	for i in 200:
		r = 1.0 - exp(-r0 * r)
	return r


## PATRULLA -(ruido > umbral)-> ALERTA -(ve a Elena)-> PERSECUCION -(la pierde)-> BUSQUEDA -(10 s)-> PATRULLA
class Corredor:
	const UMBRAL_RUIDO := 40.0
	var estado := "PATRULLA"
	var t_sin_estimulo := 0.0

	## Devuelve true si cambió de estado.
	func actualizar(dt: float, ruido_percibido: float, ve_a_elena: bool) -> bool:
		var anterior := estado
		if estado == "PATRULLA" and ruido_percibido > UMBRAL_RUIDO:
			estado = "ALERTA"
		elif estado in ["ALERTA", "BUSQUEDA"] and ve_a_elena:
			estado = "PERSECUCION"
		elif estado == "PERSECUCION" and not ve_a_elena:
			estado = "BUSQUEDA"
		if estado in ["ALERTA", "BUSQUEDA"]:
			var estimulo := ruido_percibido > UMBRAL_RUIDO or ve_a_elena
			t_sin_estimulo = 0.0 if estimulo else t_sin_estimulo + dt
			if t_sin_estimulo >= 10.0:
				estado = "PATRULLA"
				t_sin_estimulo = 0.0
		return anterior != estado


## Pánico P ∈ [0,1]: sube cerca de infectados, baja cerca de Elena. P < 0.5 sigue a Elena; P ≥ 0.5 huye.
class Ciudadano:
	var p := 0.3

	func _init(panico := 0.3) -> void:
		p = panico

	func actualizar(dt: float, infectados_cerca: int, elena_cerca: bool) -> String:
		p = clampf(p + dt * (0.08 * infectados_cerca - (0.12 if elena_cerca else 0.02)), 0.0, 1.0)
		return "sigue a Elena" if p < 0.5 else "huye"
