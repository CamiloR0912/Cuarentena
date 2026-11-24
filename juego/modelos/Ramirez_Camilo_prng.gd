## Port a GDScript de los generadores del taller anterior (pseudo_gen) y de las variables aleatorias
## de modelos/Ramirez_Camilo_utilidades.py. Misma semilla => misma secuencia que en Python.
##   Congruencial lineal      x_{i+1} = (a x_i + c) mod m,  R = x/m
##   Multiplicativo (MINSTD)  x_{i+1} = (a x_i) mod m,      R = x/m
##   Aditivo (Fibonacci)      x_n = (x_{n-j} + x_{n-k}) mod m, sembrado con el lineal
## Los enteros de GDScript son de 64 bits: a·x < 2^53, así que no hay desbordamiento.
extends RefCounted

enum Tipo { LINEAL, MULTIPLICATIVO, ADITIVO }

var tipo: Tipo
var nombre := ""
var a := 0
var c := 0
var m := 1
var x := 0
var _buf: Array[int] = []   # aditivo: últimos k valores (anillo)
var _pos := 0               # aditivo: índice del valor más antiguo (x_{n-k})
var _j := 0
var _normal_guardada = null # Box-Muller produce pares: se guarda el segundo valor


static func lcg(semilla := 12345):
	var g = new()
	g.tipo = Tipo.LINEAL
	g.nombre = "Congruencial lineal a=1664525 c=1013904223 m=2^32"
	g.a = 1664525
	g.c = 1013904223
	g.m = 1 << 32
	g.x = semilla
	return g


static func minstd(semilla := 12345):
	var g = new()
	g.tipo = Tipo.MULTIPLICATIVO
	g.nombre = "Multiplicativo MINSTD a=16807 m=2^31-1"
	g.a = 16807
	g.m = (1 << 31) - 1
	g.x = semilla
	return g


static func aditivo(semilla := 12345, j := 24, k := 55):
	var g = new()
	g.tipo = Tipo.ADITIVO
	g.nombre = "Aditivo x_n=(x_n-24 + x_n-55) mod 2^32"
	g.m = 1 << 32
	g._j = j
	var semillas = lcg(semilla)  # semillas = x_1..x_k del lineal (sin x0), como desde_lcg()
	for i in k:
		semillas.siguiente()
		g._buf.append(semillas.x % g.m)
	return g


## R_i ∈ [0, 1)
func siguiente() -> float:
	match tipo:
		Tipo.LINEAL:
			x = (a * x + c) % m
		Tipo.MULTIPLICATIVO:
			x = (a * x) % m
		Tipo.ADITIVO:
			var k := _buf.size()
			x = (_buf[(_pos + k - _j) % k] + _buf[_pos]) % m
			_buf[_pos] = x
			_pos = (_pos + 1) % k
	return float(x) / float(m)


func uniforme(lo: float, hi: float) -> float:
	return lo + (hi - lo) * siguiente()


func exponencial(tasa: float) -> float:
	var r := siguiente()
	if r <= 0.0:
		r = 1e-10
	return -(1.0 / tasa) * log(r)


func normal(mu: float, sigma: float) -> float:
	if _normal_guardada == null:
		var r1 := siguiente()
		var r2 := siguiente()
		if r1 <= 0.0:
			r1 = 1e-10
		var factor := sqrt(-2.0 * log(r1))
		var ang := 2.0 * PI * r2
		_normal_guardada = factor * sin(ang)
		return mu + sigma * (factor * cos(ang))
	var z: float = _normal_guardada
	_normal_guardada = null
	return mu + sigma * z


func bernoulli(p: float) -> int:
	return 1 if siguiente() < p else 0


## tabla: Array de [valor, probabilidad] que suma 1 (transformada inversa discreta)
func categorica(tabla: Array):
	var u := siguiente()
	var acumulada := 0.0
	for fila in tabla:
		acumulada += fila[1]
		if u < acumulada:
			return fila[0]
	return tabla[-1][0]
