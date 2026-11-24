## MODELO 2 — Cola M/M/c del hospital, eventos discretos (port de modelos/..._modelo2_colas.py).
## Llegadas Exp(λ), servicios Exp(μ), c camillas, FIFO. Extensión del juego: abandono si la espera supera la paciencia.
## Teoría (Erlang C, a = λ/μ, ρ = a/c < 1): P0, Lq = P0 a^c ρ / (c!(1−ρ)^2), Wq = Lq/λ, W = Wq + 1/μ, L = λW
extends RefCounted

var gen
var lam: float
var mu: float
var c: int
var paciencia = null  # null = M/M/c puro


func _init(generador, tasa_llegada: float, tasa_servicio: float, camillas: int, paciencia_max = null) -> void:
	gen = generador
	lam = tasa_llegada
	mu = tasa_servicio
	c = camillas
	paciencia = paciencia_max


static func teoria(lam_: float, mu_: float, c_: int) -> Dictionary:
	var a := lam_ / mu_
	var rho := a / c_
	if rho >= 1.0:
		return {"rho": rho, "P0": 0.0, "Pw": 1.0, "Lq": INF, "Wq": INF, "W": INF, "L": INF}
	var suma := 0.0
	for n in c_:
		suma += pow(a, n) / _fact(n)
	var cola := pow(a, c_) / (_fact(c_) * (1.0 - rho))
	var p0 := 1.0 / (suma + cola)
	var lq := p0 * pow(a, c_) * rho / (_fact(c_) * pow(1.0 - rho, 2))
	var wq := lq / lam_
	return {"rho": rho, "P0": p0, "Pw": cola * p0, "Lq": lq, "Wq": wq, "W": wq + 1.0 / mu_, "L": lam_ * (wq + 1.0 / mu_)}


static func _fact(n: int) -> float:
	var f := 1.0
	for i in range(2, n + 1):
		f *= i
	return f


## Devuelve Lq y ocupación promediados en el tiempo, Wq, W, abandonos y atendidos.
func simular(t_fin: float) -> Dictionary:
	var eventos := []  # montículo binario de [t, orden, tipo, id]
	var orden := 0
	var reloj := 0.0
	var ocupados := 0
	var cola: Array[int] = []
	var en_cola := {}
	var siguiente_id := 0
	var area_lq := 0.0
	var area_ocup := 0.0
	var t_ultimo := 0.0
	var esperas := []
	var sistema := []
	var abandonos := 0
	var atendidos := 0
	var llegada_de := {}
	_push(eventos, [gen.exponencial(lam), orden, "llegada", -1])
	orden += 1
	while not eventos.is_empty():
		var ev: Array = _pop(eventos)
		var t: float = ev[0]
		if t > t_fin:
			break
		area_lq += en_cola.size() * (t - t_ultimo)
		area_ocup += ocupados * (t - t_ultimo)
		t_ultimo = t
		reloj = t
		match ev[2]:
			"llegada":
				_push(eventos, [reloj + gen.exponencial(lam), orden, "llegada", -1])
				orden += 1
				var pid := siguiente_id
				siguiente_id += 1
				llegada_de[pid] = reloj
				if ocupados < c:
					ocupados += 1
					esperas.append(0.0)
					_push(eventos, [reloj + gen.exponencial(mu), orden, "salida", pid])
					orden += 1
				else:
					cola.append(pid)
					en_cola[pid] = true
					if paciencia != null:
						_push(eventos, [reloj + paciencia, orden, "abandono", pid])
						orden += 1
			"salida":
				atendidos += 1
				sistema.append(reloj - llegada_de[ev[3]])
				llegada_de.erase(ev[3])
				while not cola.is_empty() and not en_cola.has(cola[0]):
					cola.pop_front()
				if not cola.is_empty():
					var nxt: int = cola.pop_front()
					en_cola.erase(nxt)
					esperas.append(reloj - llegada_de[nxt])
					_push(eventos, [reloj + gen.exponencial(mu), orden, "salida", nxt])
					orden += 1
				else:
					ocupados -= 1
			"abandono":
				if en_cola.has(ev[3]):
					en_cola.erase(ev[3])
					cola.erase(ev[3])
					llegada_de.erase(ev[3])
					abandonos += 1
	area_lq += en_cola.size() * (t_fin - t_ultimo)
	area_ocup += ocupados * (t_fin - t_ultimo)
	return {"Lq": area_lq / t_fin, "rho": area_ocup / (t_fin * c), "Wq": _media(esperas), "W": _media(sistema),
		"abandonos": abandonos, "atendidos": atendidos}


static func _media(xs: Array) -> float:
	var s := 0.0
	for v in xs:
		s += v
	return s / xs.size()


# Montículo binario ordenado por (tiempo, orden de creación), como heapq en Python.
static func _menor(a: Array, b: Array) -> bool:
	return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1])


static func _push(h: Array, e: Array) -> void:
	h.append(e)
	var i := h.size() - 1
	while i > 0:
		var p := (i - 1) / 2
		if not _menor(h[i], h[p]):
			break
		var tmp = h[i]
		h[i] = h[p]
		h[p] = tmp
		i = p


static func _pop(h: Array) -> Array:
	var top: Array = h[0]
	var last: Array = h.pop_back()
	if not h.is_empty():
		h[0] = last
		var i := 0
		while true:
			var l := 2 * i + 1
			var r := l + 1
			var m := i
			if l < h.size() and _menor(h[l], h[m]):
				m = l
			if r < h.size() and _menor(h[r], h[m]):
				m = r
			if m == i:
				break
			var tmp = h[i]
			h[i] = h[m]
			h[m] = tmp
			i = m
	return top


# ------------------------------------------------------------------------------------------------------------------
# Uso en tiempo real (juego): la misma cola avanzada por tramos. No altera simular(), que es lo que se valida.
# El juego llama iniciar() una vez y avanzar(reloj + Δt) en cada cuadro; puede cambiar lam y c sobre la marcha.
# ------------------------------------------------------------------------------------------------------------------
var reloj := 0.0
var ocupados := 0
var atendidos := 0
var abandonos := 0
var llegadas := 0
var esperas := []         # espera en cola de cada paciente que llegó a una camilla (min)
var _eventos := []
var _orden := 0
var _fila: Array[int] = []
var _llegada_de := {}
var _tipo_de := {}
var _sig_id := 0
var _area_lq := 0.0


func iniciar() -> void:
	reloj = 0.0
	ocupados = 0
	atendidos = 0
	abandonos = 0
	llegadas = 0
	esperas = []
	_eventos = []
	_orden = 0
	_fila = []
	_llegada_de = {}
	_tipo_de = {}
	_sig_id = 0
	_area_lq = 0.0
	_programar(gen.exponencial(lam), "llegada", -1)


func en_cola() -> int:
	return _fila.size()


## Tipos ("ciudadano" o "infectado") de los pacientes que esperan, en orden de llegada.
func tipos_en_cola() -> Array:
	var tipos := []
	for pid in _fila:
		tipos.append(_tipo_de.get(pid, "ciudadano"))
	return tipos


## Paciente que trae el jugador (infectado sedado o ciudadano rescatado): llegada fuera del proceso de Poisson.
func llegada_externa(tipo := "infectado") -> void:
	_admitir(tipo)


func fijar_camillas(n: int) -> void:
	c = maxi(1, n)
	_llenar()


## Procesa los eventos hasta el instante `hasta` (min). Devuelve [[evento, tipo de paciente], ...] con
## evento ∈ {"llegada", "atendido", "abandono"}.
func avanzar(hasta: float) -> Array:
	var ocurridos := []
	while not _eventos.is_empty() and _eventos[0][0] <= hasta:
		var ev: Array = _pop(_eventos)
		var t: float = ev[0]
		_area_lq += _fila.size() * (t - reloj)
		reloj = t
		var pid: int = ev[3]
		match ev[2]:
			"llegada":
				_programar(reloj + gen.exponencial(lam), "llegada", -1)
				_admitir("ciudadano")
				ocurridos.append(["llegada", "ciudadano"])
			"salida":
				atendidos += 1
				ocurridos.append(["atendido", _tipo_de.get(pid, "ciudadano")])
				_llegada_de.erase(pid)
				_tipo_de.erase(pid)
				ocupados -= 1
				_llenar()
			"abandono":
				if _fila.has(pid):
					_fila.erase(pid)
					ocurridos.append(["abandono", _tipo_de.get(pid, "ciudadano")])
					_llegada_de.erase(pid)
					_tipo_de.erase(pid)
					abandonos += 1
	_area_lq += _fila.size() * (hasta - reloj)
	reloj = hasta
	return ocurridos


## Wq medido: media de las últimas `ultimos` esperas (min).
func wq_medido(ultimos := 60) -> float:
	if esperas.is_empty():
		return 0.0
	var desde := maxi(0, esperas.size() - ultimos)
	var s := 0.0
	for k in range(desde, esperas.size()):
		s += esperas[k]
	return s / (esperas.size() - desde)


## Lq medido: longitud media de la cola promediada en el tiempo.
func lq_medido() -> float:
	return _area_lq / reloj if reloj > 0.0 else 0.0


func _programar(t: float, tipo: String, pid: int) -> void:
	_push(_eventos, [t, _orden, tipo, pid])
	_orden += 1


func _admitir(tipo: String) -> void:
	var pid := _sig_id
	_sig_id += 1
	llegadas += 1
	_llegada_de[pid] = reloj
	_tipo_de[pid] = tipo
	if ocupados < c:
		ocupados += 1
		esperas.append(0.0)
		_programar(reloj + gen.exponencial(mu), "salida", pid)
	else:
		_fila.append(pid)
		if paciencia != null:
			_programar(reloj + paciencia, "abandono", pid)


func _llenar() -> void:
	while ocupados < c and not _fila.is_empty():
		var pid: int = _fila.pop_front()
		esperas.append(reloj - _llegada_de[pid])
		ocupados += 1
		_programar(reloj + gen.exponencial(mu), "salida", pid)
