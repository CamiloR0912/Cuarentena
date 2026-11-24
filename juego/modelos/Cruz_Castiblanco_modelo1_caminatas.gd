## MODELO 1 — Caminata aleatoria 2D en retícula con sesgo por ruido (port de modelos/..._modelo1_caminatas.py).
##   u < pN -> y+ℓ;  u < pN+pS -> y−ℓ;  u < pN+pS+pE -> x+ℓ;  si no -> x−ℓ
##   Sesgo: la dirección hacia la fuente de ruido recibe p + b, las otras p − b/3, b ∈ [0, 0.3].
extends RefCounted

const DIRECCIONES := {"N": Vector2i(0, 1), "S": Vector2i(0, -1), "E": Vector2i(1, 0), "O": Vector2i(-1, 0)}
const UNIFORME := {"N": 0.25, "S": 0.25, "E": 0.25, "O": 0.25}

var gen
var paso := 1
var probs := UNIFORME


func _init(generador, longitud_paso := 1, probabilidades := UNIFORME) -> void:
	gen = generador
	paso = longitud_paso
	probs = probabilidades


func direccion(p: Dictionary = {}) -> String:
	if p.is_empty():
		p = probs
	var u: float = gen.siguiente()
	if u < p["N"]:
		return "N"
	if u < p["N"] + p["S"]:
		return "S"
	if u < p["N"] + p["S"] + p["E"]:
		return "E"
	return "O"


## Trayectoria [(x0, y0) … (xn, yn)]. es_obstaculo(Vector2i) -> bool deshace el paso; probs_en(Vector2i) -> Dictionary.
func caminar(n: int, inicio := Vector2i.ZERO, es_obstaculo := Callable(), probs_en := Callable()) -> Array[Vector2i]:
	var pos := inicio
	var tray: Array[Vector2i] = [pos]
	for i in n:
		var d: Vector2i = DIRECCIONES[direccion(probs_en.call(pos) if probs_en.is_valid() else {})]
		var nueva := pos + d * paso
		if not (es_obstaculo.is_valid() and es_obstaculo.call(nueva)):
			pos = nueva
		tray.append(pos)
	return tray


static func probabilidades_con_sesgo(pos: Vector2i, fuente: Vector2i, b: float, base := 0.25) -> Dictionary:
	var dx := fuente.x - pos.x
	var dy := fuente.y - pos.y
	if (dx == 0 and dy == 0) or b <= 0.0:
		return {"N": base, "S": base, "E": base, "O": base}
	var mejor := ("E" if dx > 0 else "O") if absi(dx) >= absi(dy) else ("N" if dy > 0 else "S")
	var p := {}
	for d in DIRECCIONES:
		p[d] = base + b if d == mejor else base - b / 3.0
	return p


## b ∈ [0, b_max]: crece con el ruido (0-100) y decrece linealmente con la distancia dentro del radio de audición.
static func sesgo_por_ruido(ruido: float, distancia: float, radio_audicion: float, b_max := 0.3) -> float:
	if distancia >= radio_audicion:
		return 0.0
	return b_max * (ruido / 100.0) * (1.0 - distancia / radio_audicion)
