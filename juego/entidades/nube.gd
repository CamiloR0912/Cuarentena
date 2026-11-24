## Nube de contagio del Tosedor: cada partícula hace una caminata aleatoria (difusión, Modelo 1) y la
## concentración se desvanece con el tiempo. El nivel pregunta cuántas partículas rodean a Elena.
extends Node2D

const Caminata = preload("res://modelos/Cruz_Castiblanco_modelo1_caminatas.gd")
const VIDA := 9.0
const PASO := 3.0          # px por paso de difusión
const PARTICULAS := 16

var particulas := PackedVector2Array()
var vida := VIDA
var _t := 0.0


func _ready() -> void:
	z_index = 1
	for k in PARTICULAS:
		particulas.append(Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0)))
	add_to_group("nubes")


func _physics_process(delta: float) -> void:
	vida -= delta
	if vida <= 0.0:
		queue_free()
		return
	_t -= delta
	if _t <= 0.0:
		_t = 0.1
		for k in particulas.size():
			var d: String = Juego.caminata.direccion()
			var paso: Vector2 = Vector2(Caminata.DIRECCIONES[d]) * PASO
			particulas[k] = particulas[k] + paso
		queue_redraw()


func _draw() -> void:
	var alfa := clampf(vida / VIDA, 0.0, 1.0) * 0.32
	for p in particulas:
		draw_circle(p, 9.0, Color(0.48, 0.56, 0.31, alfa))
		draw_circle(p, 4.0, Color(0.71, 0.79, 0.35, alfa))


## Número de partículas a menos de `radio` px del punto (coordenadas del mundo).
func concentracion(punto: Vector2, radio := 22.0) -> int:
	var n := 0
	for p in particulas:
		if (position + p).distance_to(punto) < radio:
			n += 1
	return n
