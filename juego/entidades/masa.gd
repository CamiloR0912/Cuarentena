## Masa: enjambre de 8-15 infectados regido por la clase Boids del Modelo 4 (la misma que se valida por consola).
## Cada 0,1 s se copian las posiciones reales a la simulación (en casillas), se da un paso de boids
## (separación, alineación, cohesión y ruido) y el rumbo resultante se entrega a cada individuo.
## Se dispersa cuando pierde la mitad de sus miembros y entonces suelta su drop (tabla "Masa").
extends Node

const Agentes = preload("res://modelos/Ramirez_Camilo_modelo4_agentes.gd")
const CELDA := 32.0
# pesos de boids (w_s, w_a, w_c), radio de visión en casillas y ruido angular
const W_SEPARACION := 0.6
const W_ALINEACION := 0.9
const W_COHESION := 0.03
const RADIO_VISION := 6.0
const RUIDO := 0.1

var nivel
var miembros := []
var inicial := 0
var boids
var origen := Vector2.ZERO
var dispersada := false
var persigue := false
var _t := 0.0


func crear(nivel_, centro: Vector2, cantidad: int) -> void:
	nivel = nivel_
	origen = centro
	inicial = cantidad
	# lado enorme: el mundo toroidal del modelo nunca "da la vuelta" dentro del mapa
	boids = Agentes.Boids.new(Juego.gen_lineal, cantidad, 100000.0, RADIO_VISION, 1.0, W_SEPARACION, W_ALINEACION,
		W_COHESION, RUIDO)
	for k in cantidad:
		var ang := TAU * k / cantidad
		var e = nivel.crear_enemigo("Masa", centro + Vector2(cos(ang), sin(ang)) * (18.0 + 7.0 * (k % 3)))
		e.masa = self
		miembros.append(e)


func _physics_process(delta: float) -> void:
	if dispersada or nivel == null:
		return
	var vivos := []
	for e in miembros:
		if is_instance_valid(e) and e.vida == "activo":
			vivos.append(e)
	if vivos.size() * 2 <= inicial:
		_dispersar(vivos)
		return
	_t -= delta
	if _t > 0.0:
		return
	_t = 0.1
	var n := vivos.size()
	boids.n = n
	var centro := Vector2.ZERO
	for k in n:
		var p: Vector2 = vivos[k].position
		boids.px[k] = p.x / CELDA
		boids.py[k] = p.y / CELDA
		centro += p
	centro /= float(n)
	boids.paso()
	Juego.stats["phi"] = boids.phi()  # parámetro de orden: 1 = movimiento coordinado

	var a_elena: Vector2 = nivel.elena.position - centro
	var d := a_elena.length()
	var ruido_elena: float = nivel.elena.ruido
	persigue = d < 160.0 or (d < 330.0 and ruido_elena >= 30.0)
	var tiron := Vector2.ZERO
	if persigue:
		tiron = a_elena.normalized() * 1.2
	elif centro.distance_to(origen) > 170.0:
		tiron = (origen - centro).normalized() * 0.8  # sin estímulo vuelve a su zona
	var rapidez := 120.0 if persigue else 45.0
	for k in n:
		var vx: float = boids.vx[k]
		var vy: float = boids.vy[k]
		var v := Vector2(vx, vy) + tiron
		vivos[k].rumbo = v.normalized() * rapidez


func _dispersar(vivos: Array) -> void:
	dispersada = true
	var centro := origen
	if not vivos.is_empty():
		centro = Vector2.ZERO
		for e in vivos:
			centro += e.position
		centro /= float(vivos.size())
	for e in vivos:
		e.huir()
	Juego.registrar("M4 Agentes", "la Masa pierde la mitad de sus miembros y se dispersa")
	nivel.soltar_drop("Masa", centro)
	queue_free()
