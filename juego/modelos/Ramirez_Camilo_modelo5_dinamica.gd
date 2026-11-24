## MODELO 5 — SIR del pulso epidémico de Tunja, integración RK4 (port de modelos/..._modelo5_dinamica.py).
##   dS/dt = −β S I/N,  dI/dt = β S I/N − γ I,  dR/dt = γ I
##   Jugador: β_ef = β (1 − 0.4 f_cub);  γ_ef = γ + atendidos_dia / (I + K);  abandono: I += 1;  rescate: S −= 1
extends RefCounted

const K_SATURACION := 2000.0

var n: float
var beta: float
var gamma: float
var s: float
var i: float
var r := 0.0
var f_cub := 0.0         # fracción de la población con cubrebocas
var atendidos_dia := 0.0 # pacientes atendidos por el hospital (por día)


func _init(poblacion := 180000.0, i0 := 10.0, beta_ := 0.3, gamma_ := 0.1) -> void:
	n = poblacion
	beta = beta_
	gamma = gamma_
	s = poblacion - i0
	i = i0


static func i_max_teorico(r0: float) -> float:
	return 1.0 - (1.0 + log(r0)) / r0


static func r_inf_teorico(r0: float) -> float:
	var x := 0.5
	for k in 500:
		x = 1.0 - exp(-r0 * x)
	return x


func beta_ef() -> float:
	return beta * (1.0 - 0.4 * f_cub)


func gamma_ef() -> float:
	return gamma + atendidos_dia / (i + K_SATURACION)


func derivadas(s_: float, i_: float) -> Array:
	var contagio := beta_ef() * s_ * i_ / n
	var g := gamma_ef()
	return [-contagio, contagio - g * i_, g * i_]


func paso(dt: float, metodo := "rk4") -> void:
	var d := []
	if metodo == "euler":
		var k: Array = derivadas(s, i)
		d = [dt * k[0], dt * k[1], dt * k[2]]
	else:
		var k1: Array = derivadas(s, i)
		var k2: Array = derivadas(s + dt / 2 * k1[0], i + dt / 2 * k1[1])
		var k3: Array = derivadas(s + dt / 2 * k2[0], i + dt / 2 * k2[1])
		var k4: Array = derivadas(s + dt * k3[0], i + dt * k3[1])
		for c in 3:
			d.append(dt / 6 * (k1[c] + 2 * k2[c] + 2 * k3[c] + k4[c]))
	var s0 := s
	var i0 := i
	s = maxf(0.0, s0 + d[0])
	i = maxf(0.0, i0 + d[1])
	r += d[2]


func abandono_cola(k := 1.0) -> void:
	i += k


func rescate(k := 1.0) -> void:
	k = minf(k, s)
	s -= k
	r += k  # protegido: sale de los susceptibles


## eventos(dia, modelo) se llama una vez por día (intervenciones del jugador). Devuelve [[t, S, I, R], ...].
func simular(dias: int, dt := 0.1, metodo := "rk4", eventos := Callable()) -> Array:
	var serie := [[0.0, s, i, r]]
	var pasos := roundi(1.0 / dt)
	for d in dias:
		if eventos.is_valid():
			eventos.call(d, self)
		for k in pasos:
			paso(dt, metodo)
		serie.append([d + 1.0, s, i, r])
	return serie


## [t, I] del pico (el primero si hay empate)
static func pico(serie: Array) -> Array:
	var mejor: Array = serie[0]
	for p in serie:
		if p[2] > mejor[2]:
			mejor = p
	return [mejor[0], mejor[2]]
