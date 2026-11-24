## Dardo sedante: proyectil recto que se detiene en muros y golpea al primer infectado que toca.
extends Node2D

const VELOCIDAD := 460.0
const ALCANCE := 520.0

var nivel
var dir := Vector2.RIGHT
var origen := Vector2.ZERO
var _recorrido := 0.0


func _ready() -> void:
	rotation = dir.angle()
	z_index = 2


func _draw() -> void:
	draw_line(Vector2(-7, 0), Vector2(4, 0), Color("#EAF2F5"), 2.0)
	draw_line(Vector2(4, 0), Vector2(8, 0), Color("#E0A030"), 2.0)
	draw_line(Vector2(-7, -2), Vector2(-7, 2), Color("#C0392B"), 1.0)


func _physics_process(delta: float) -> void:
	var paso := dir * VELOCIDAD * delta
	# el dardo vuela a la altura del pecho; el muro se comprueba a la altura de los pies
	var pies := position + Vector2(0, 16)
	if not nivel.linea_de_vista(pies, pies + paso):
		queue_free()
		return
	position += paso
	_recorrido += paso.length()
	for e in nivel.enemigos_activos():
		var centro: Vector2 = e.position + Vector2(0, -16)
		if centro.distance_to(position) < 16.0:
			nivel.golpear(e, "dardos", origen)
			queue_free()
			return
	if _recorrido > ALCANCE:
		queue_free()
