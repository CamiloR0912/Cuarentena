## Utilidades de sprites: arma SpriteFrames a partir de las hojas LPC (celdas de 64×64, filas abajo/arriba/derecha)
## y tiras horizontales de efectos (cuadros cuadrados de lado = alto de la imagen).
extends RefCounted

const FILAS := ["down", "up", "right"]  # izquierda = derecha volteada
const SIN_BUCLE := ["fall", "death", "attack", "attack_pipe", "attack_syringe", "attack_dart", "attack_extinguisher",
	"hurt", "cheer", "summon", "cough", "interact", "use_item", "stun"]
const RAPIDAS := ["attack", "attack_pipe", "attack_syringe", "attack_dart", "attack_extinguisher"]


## Animaciones "<anim>_<fila>" para cada hoja res://assets/sprites/characters/<carpeta>/<carpeta>_<anim>.png.
## Las hojas de una sola fila (fall, death, cheer...) se registran igual para las tres direcciones.
static func cuadros(carpeta: String, anims: Array) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	for anim in anims:
		var ruta := "res://assets/sprites/characters/%s/%s_%s.png" % [carpeta, carpeta, anim]
		if not ResourceLoader.exists(ruta):
			continue
		var hoja: Texture2D = load(ruta)
		var celda := 96 if anim == "attack_pipe" else 64
		var filas: int = maxi(1, hoja.get_height() / celda)
		var columnas: int = maxi(1, hoja.get_width() / celda)
		var fps := 4.0 if anim == "idle" else (16.0 if anim in RAPIDAS else 10.0)
		for f in FILAS.size():
			var clave := "%s_%s" % [anim, FILAS[f]]
			frames.add_animation(clave)
			frames.set_animation_speed(clave, fps)
			frames.set_animation_loop(clave, not (anim in SIN_BUCLE))
			var fila: int = mini(f, filas - 1)
			for col in columnas:
				var cuadro := AtlasTexture.new()
				cuadro.atlas = hoja
				cuadro.region = Rect2(col * celda, fila * celda, celda, celda)
				frames.add_frame(clave, cuadro)
	return frames


## Sprite de personaje con el pivote en los pies.
static func personaje(carpeta: String, anims: Array) -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	s.name = "sprite"
	s.sprite_frames = cuadros(carpeta, anims)
	s.offset = Vector2(0, -30)
	return s


## Reproduce "<anim>_<dirección>" según el vector dir. Con reiniciar = true vuelve a empezar aunque ya esté activa.
static func animar(s: AnimatedSprite2D, anim: String, dir: Vector2, reiniciar := false) -> void:
	var hacia := "down"
	var voltear := false
	if absf(dir.x) > absf(dir.y):
		hacia = "right"
		voltear = dir.x < 0.0
	elif dir.y < 0.0:
		hacia = "up"
	var clave := "%s_%s" % [anim, hacia]
	if not s.sprite_frames.has_animation(clave):
		return
	s.flip_h = voltear
	if reiniciar:
		s.stop()
		s.play(clave)
	elif s.animation != clave:
		s.play(clave)


## Tira horizontal de cuadros cuadrados como animación. Si no hace bucle, se libera sola al terminar.
static func tira(ruta: String, fps := 12.0, bucle := false) -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("a")
	frames.set_animation_speed("a", fps)
	frames.set_animation_loop("a", bucle)
	if ResourceLoader.exists(ruta):
		var hoja: Texture2D = load(ruta)
		var lado: int = hoja.get_height()
		for col in maxi(1, hoja.get_width() / lado):
			var cuadro := AtlasTexture.new()
			cuadro.atlas = hoja
			cuadro.region = Rect2(col * lado, 0, lado, lado)
			frames.add_frame("a", cuadro)
	s.sprite_frames = frames
	if frames.get_frame_count("a") > 0:
		s.play("a")
	if not bucle:
		s.animation_finished.connect(s.queue_free)
	return s
