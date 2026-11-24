## MODELO 3 — Monte Carlo: daño con críticos, drops y radio de Don Álvaro (port de modelos/..._modelo3_montecarlo.py).
##   D = max(0, X) · (k si crit),  crit ~ Bernoulli(min(1, p_crit + 0.25·espalda + 0.10·adrenalina)),  k = 2
##   Drops: categórica por enemigo.  Radio: p̂ ± 1.96 √(p̂(1−p̂)/N)
extends RefCounted

const K_CRIT := 2.0
const ARMAS := {  # [distribución, parámetros, p_crit base]
	"tubo": ["uniforme", [8.0, 12.0], 0.10],
	"extintor": ["uniforme", [4.0, 6.0], 0.05],
	"dardos": ["normal", [15.0, 3.0], 0.15],
	"jeringa": ["fija", [30.0], 0.35],
}
const DROPS := {  # GDD §6.1
	"Errante": [["nada", .45], ["vendas", .25], ["dardos", .15], ["cubrebocas", .10], ["muestra", .04], ["adrenalina", .01]],
	"Tosedor": [["nada", .40], ["vendas", .20], ["dardos", .10], ["cubrebocas", .20], ["muestra", .08], ["adrenalina", .02]],
	"Corredor": [["nada", .30], ["vendas", .20], ["dardos", .25], ["cubrebocas", .10], ["muestra", .12], ["adrenalina", .03]],
	"Masa": [["nada", .10], ["vendas", .25], ["dardos", .25], ["cubrebocas", .15], ["muestra", .20], ["adrenalina", .05]],
}
const ENEMIGOS := {  # [agitación, daño a Elena, probabilidad de golpear por intercambio]
	"Errante": [30.0, 8.0, 0.30], "Tosedor": [20.0, 0.0, 0.0], "Corredor": [50.0, 15.0, 0.45], "Masa": [15.0, 5.0, 0.35],
}

var gen


func _init(generador) -> void:
	gen = generador


func p_crit_efectiva(arma: String, espalda_sin_deteccion := false, adrenalina := false) -> float:
	return minf(1.0, ARMAS[arma][2] + 0.25 * int(espalda_sin_deteccion) + 0.10 * int(adrenalina))


## Devuelve [daño, fue_critico]
func dano(arma: String, espalda_sin_deteccion := false, adrenalina := false) -> Array:
	var def: Array = ARMAS[arma]
	var x: float
	match def[0]:
		"uniforme":
			x = gen.uniforme(def[1][0], def[1][1])
		"normal":
			x = gen.normal(def[1][0], def[1][1])
		_:
			x = def[1][0]
	var crit: int = gen.bernoulli(p_crit_efectiva(arma, espalda_sin_deteccion, adrenalina))
	return [maxf(0.0, x) * (K_CRIT if crit else 1.0), crit == 1]


func drop(enemigo: String) -> String:
	return gen.categorica(DROPS[enemigo])


## Éxito si se superan los m encuentros, cada uno con probabilidad q (se detiene en el primer fracaso).
func mision_simplificada(q: float, m: int) -> bool:
	for i in m:
		if not gen.bernoulli(q):
			return false
	return true


## Misión del juego: intercambios de golpes hasta sedar a cada enemigo; éxito si Elena termina con HP > 0.
func mision(encuentros: Array, hp: float, arma := "tubo") -> bool:
	for enemigo in encuentros:
		var e: Array = ENEMIGOS[enemigo]
		var agitacion: float = e[0]
		while agitacion > 0.0 and hp > 0.0:
			agitacion -= dano(arma)[0]
			if agitacion > 0.0 and gen.bernoulli(e[2]):
				hp -= e[1]
		if hp <= 0.0:
			return false
	return true


## Radio de Don Álvaro: [p̂, límite inferior, límite superior] del IC 95 %.
func radio(encuentros: Array, hp: float, arma := "tubo", replicas := 5000) -> Array:
	var exitos := 0
	for i in replicas:
		exitos += int(mision(encuentros, hp, arma))
	var p := float(exitos) / replicas
	var h := 1.96 * sqrt(p * (1.0 - p) / replicas)
	return [p, p - h, p + h]
