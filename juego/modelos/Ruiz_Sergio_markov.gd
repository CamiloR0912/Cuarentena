## MODELO COMPLEMENTARIO — Cadenas de Markov (port de modelos/..._markov.py):
## progresión del infectado {Errante, Tosedor, Corredor} por minuto y fases del Paciente Cero.
##   Tiempo esperado Errante -> Corredor = 1/0.10 + 1/0.15 = 16.67 min;  π_n = π_0 P^n;  πP = π
extends RefCounted

const ESTADOS := ["Errante", "Tosedor", "Corredor"]
const P := [[0.90, 0.10, 0.00], [0.00, 0.85, 0.15], [0.00, 0.00, 1.00]]
const FASES := ["Deambular", "Embestida", "Toser", "Llamar a la Masa"]
const P_JEFE := [[0.50, 0.25, 0.15, 0.10],
	[0.60, 0.10, 0.20, 0.10],
	[0.55, 0.20, 0.10, 0.15],
	[0.70, 0.15, 0.15, 0.00]]


## Siguiente estado (índice) desde `estado` con la matriz p (transformada inversa discreta).
static func paso(gen, p: Array, estado: int) -> int:
	var fila := []
	for j in p[estado].size():
		fila.append([j, p[estado][j]])
	return gen.categorica(fila)


## π_0 · P^n
static func distribucion(pi0: Array, p: Array, n: int) -> Array:
	var pi := pi0.duplicate()
	for k in n:
		var nueva := []
		for j in p.size():
			var acc := 0.0
			for i in p.size():
				acc += pi[i] * p[i][j]
			nueva.append(acc)
		pi = nueva
	return pi


static func estacionaria(p: Array, iteraciones := 2000) -> Array:
	var pi := []
	for i in p.size():
		pi.append(1.0 / p.size())
	return distribucion(pi, p, iteraciones)


static func tiempo_hasta_corredor(gen) -> int:
	var estado := 0
	var t := 0
	while estado != 2:
		estado = paso(gen, P, estado)
		t += 1
	return t
