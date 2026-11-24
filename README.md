# Cuarentena

Roguelite de acción cenital con gestión de recursos para ExpoSimu 2026 (Simulación por Computador, UPTC).
Una médica recorre una Tunja en cuarentena, seda a los infectados y los lleva al hospital mientras una epidemia
simulada avanza en tiempo real. El diseño completo está en [GDD_Cuarentena.md](GDD_Cuarentena.md).

> Los nombres `apellido1_apellido2_...` son temporales: reemplácenlos por los apellidos del equipo antes de entregar
> (archivos de `juego/modelos/`, `juego/validacion/`, `modelos/` y la ruta de exportación en `juego/export_presets.cfg`).

## Cómo ejecutar

Se necesita **Godot 4.7** (versión estándar, no .NET): <https://godotengine.org/download>.

| Forma | Pasos |
|---|---|
| Desde el editor | Abrir Godot, *Importar*, elegir `juego/project.godot` y pulsar F5. |
| Desde la consola | `godot --path juego` |
| Ejecutable de Windows (opción A) | Ver "Exportar". Resultado: `build/windows/apellido1_apellido2_apellido3_ExpoSimu2026.exe` |
| Navegador (opción B) | Ver "Exportar". Resultado: `build/web/index.html` |

La primera vez que se abre el proyecto en un equipo, Godot importa los recursos (tarda cerca de un minuto).
Desde la consola se puede forzar con `godot --headless --path juego --import`.

## Exportar

1. En el editor: *Editor > Administrar plantillas de exportación > Descargar e instalar* (deben ser de la misma versión 4.7).
2. Los presets ya están en `juego/export_presets.cfg`. Desde la carpeta raíz:

```bash
mkdir -p build/windows build/web
godot --headless --path juego --export-release "Windows Desktop" ../build/windows/apellido1_apellido2_apellido3_ExpoSimu2026.exe
godot --headless --path juego --export-release "Web" ../build/web/index.html
```

El build web se exporta **sin hilos**, así que no necesita cabeceras COOP/COEP, pero sí un servidor HTTP
(no funciona abriendo el archivo con doble clic): `python -m http.server 8000 --directory build/web` y abrir
<http://localhost:8000>. Para publicarlo, subir la carpeta `build/web` comprimida a itch.io como proyecto HTML5.

## Controles

| Acción | Tecla / botón | Descripción |
|---|---|---|
| Movimiento | W A S D / flechas | Desplaza a Elena |
| Apuntar | Ratón | Orienta el ataque |
| Ataque | Clic izquierdo / Espacio | Ataca con el arma equipada |
| Agacharse (sigilo) | Shift | Menos ruido y menos velocidad |
| Correr | Ctrl | Más velocidad y más ruido |
| Interactuar / cargar | E | Cargar o soltar un sedado, usar farmacia, botiquín y estante |
| Cambiar arma | Q / rueda del ratón / 1-4 | Tubo, extintor, dardos, jeringa |
| Usar consumible | F | Usa el consumible seleccionado |
| Cambiar consumible | R / Tab | Vendas, cubrebocas, adrenalina, antiviral |
| Abrir / cerrar camilla | + / - | (Hospital) cambia c |
| Panel de simulación | F1 | Métricas en vivo de los cinco modelos |
| Casos de prueba | F2 / F3 | 1 000 ataques por la espalda / 500 drops de Errante |
| Pausa | Esc | Continuar, reiniciar nivel, controles, menú |

## Historia en el juego

- **Introducción** (`escenas/intro.tscn`): al pulsar *Jugar*, cuatro pantallas sobre la ciudad de noche presentan la Fiebre Gris, a Don Álvaro por radio y a Elena. Esc la salta; *Continuar* no la repite.
- **Diálogos con retratos** (`escenas/dialogo.gd`): un intercambio corto al empezar cada nivel y al despertar el Paciente Cero. Las líneas por radio llevan estática sobre el retrato. Mientras hay diálogo el juego queda en pausa (la epidemia y la cola no avanzan). E, Espacio o clic avanzan; Esc salta. Cada diálogo se ve una vez por partida: los reintentos no lo repiten.
- **Cierre**: al entregar las 10 muestras, el sintetizador se ilumina y la Dra. Mena, Elena y Don Álvaro cierran la historia antes de la pantalla de victoria.

Los textos están en `DIALOGOS`, dentro de `juego/nucleo/juego.gd`.

## Los cinco modelos dentro del juego

El juego usa **las mismas clases** de `juego/modelos/` que se validan por consola. Los generadores son los del
taller anterior (`juego/modelos/Ramirez_Camilo_prng.gd`, portados de `pseudo_gen/`).

| Modelo | Dónde se ve | Cómo entra al juego | PRNG |
|---|---|---|---|
| 1. Caminata aleatoria 2D | Errantes y Tosedores (niveles 1, 3, 4), oleadas del nivel 2, partículas de la nube del Tosedor | Cada paso de casilla sale de `direccion()`; el ruido de Elena da el sesgo `b` (`sesgo_por_ruido`, `probabilidades_con_sesgo`). `entidades/enemigo.gd`, `entidades/nube.gd` | Congruencial lineal |
| 2. Cola M/M/c | Hospital (nivel 2, panel lateral) y en segundo plano en todos los niveles | Llegadas Exp(λ) con λ = (0,4 + 6·I/N)·factor, servicio Exp(μ = 1), c lo fija el jugador, abandono a los 6 min. El panel compara W_q medido con Erlang C. `modelos/..._modelo2_colas.gd` (sección de tiempo real), `nucleo/juego.gd` | Multiplicativo (MINSTD) |
| 3. Monte Carlo | Cada ataque (número flotante, rojo si es crítico), cada drop y la radio de Don Álvaro en el briefing | `dano()`, `drop()` y `radio()` de la clase del modelo. `escenas/nivel.gd` (`golpear`, `soltar_drop`), `escenas/briefing.gd` | Aditivo (Fibonacci retrasado) |
| 4. Agentes | Corredores (FSM, marcador sobre la cabeza), Masas (boids), ciudadanos (pánico y contagio) en niveles 3 y 4 | Clases `Corredor`, `Boids` y `Ciudadano` del modelo. `entidades/enemigo.gd`, `entidades/masa.gd`, `entidades/ciudadano.gd` | Congruencial lineal |
| 5. Dinámica de sistemas (SIR) | Barra superior del HUD, ritmo de aparición de infectados, derrota por colapso | RK4 con Δt = 0,1 día. Cubrebocas → β; pacientes atendidos → γ; abandonos y contagios → I; rescates → S. `nucleo/juego.gd` (`avanzar_mundo`) | Determinista (el lineal se usa en la sensibilidad) |
| Markov (complementario) | Errante → Tosedor → Corredor con el tiempo; fases del Paciente Cero | `Markov.paso()` cada "minuto" de la cadena. `entidades/enemigo.gd` | Congruencial lineal |

**Para el video:** F1 abre el panel con los parámetros y las métricas de cada modelo junto a su valor teórico, y
arriba a la derecha aparece siempre un registro de eventos etiquetado por modelo ("M3 Monte Carlo · CRÍTICO x2...").

### Ajustes respecto al GDD (para la sección 4.2 del informe)

| Parámetro | GDD | Juego | Motivo |
|---|---|---|---|
| Umbral de colapso I/N | 0,60 | 0,20 | Con ℛ0 = 3 el pico teórico es 0,30: 0,60 nunca se alcanza. |
| γ efectiva | γ + atendidos/I | γ + atendidos/(I + 2000) | La forma original es inestable cuando I → 0. |
| Hospital → SIR | atendidos por unidad de tiempo | γ sube 0,015 por cada paciente/min atendido | 180 000 habitantes frente a una cola de decenas de pacientes: se usa la fórmula del modelo con atendidos = 0,015 · tasa · (I + K). |
| Rescate | 1 persona | 400 personas pasan de S a protegidas | Misma razón. |
| Abandono de la cola / contagio en la calle | +1 a I | el 1 % de I (mínimo 5) pasa de S a I | Un efecto fijo sería enorme al inicio e invisible al final. |
| Ritmo del SIR | no definido | 0,05 días por segundo | Sin intervención, la ciudad colapsa hacia los 14 minutos de juego. |
| Minuto de la cola | 60 s | 4 s | Para que W_q se pueda observar durante un nivel de 5 minutos. |
| Minuto de la cadena de Markov | 60 s | 20 s | 16,67 min esperados hasta Corredor no caben en un nivel. |
| Colapso del hospital | cola > 20 durante 60 s | sala llena (10) durante 20 s | El mapa tiene 10 sillas y la paciencia limita la cola. |
| Rescates del nivel 3 | 10 | 8 | El mapa tiene 6 puntos de aparición de ciudadanos (2 por punto). |
| Muestras virales | solo drops | drops + 1 por infectado entregado + 5 del jefe | Con la tabla de drops (4-20 %) la cuota de 10 no era alcanzable. |
| Victoria del nivel 1 | entrar al hospital | entregar 3 sedados en la ambulancia y recoger el antiviral de la farmacia; entonces abre la salida | Entrar caminando no mostraba ningún modelo ni enseñaba el ciclo sedar → cargar → entregar. |
| Correr | sin tecla | Ctrl | El GDD define el ruido de correr pero no la tecla; Shift queda para agacharse. |
| Reintento tras colapso de la ciudad | estado al inicio del nivel | igual, más +0,15 de cubrebocas y −20 % de I | Evita un reintento perdido desde el primer segundo. |

No implementado: barricadas del nivel 2 (los marcadores existen en el mapa), priorización manual de pacientes y
búsqueda de rutas (los infectados van en línea recta y rodean obstáculos con un desvío lateral).

## Validación y pruebas por consola

```bash
# Modelos independientes (tres configuraciones cada uno, tabla teórico vs obtenido y CSV)
godot --headless --path juego -s res://validacion/Ramirez_Camilo_validar_prng.gd
godot --headless --path juego -s res://validacion/Cruz_Castiblanco_validar_modelo1.gd   # ... modelo2 a modelo5, markov

# Prueba de humo del juego: carga cada pantalla y cada nivel y comprueba que los modelos estén activos
godot --headless --path juego -s res://validacion/prueba_juego.gd
```

Los prototipos en Python con los gráficos del informe están en [modelos/](modelos/README.md).

## Estructura

```
juego/                 proyecto Godot (res://)
  nucleo/juego.gd      autoload: estado de la partida, SIR y cola persistentes, audio por código, controles
  modelos/             los cinco modelos, Markov y los PRNG (clases RefCounted, sin nodos)
  validacion/          un runner por modelo + prueba_juego.gd
  entidades/           Elena, infectados, masa, ciudadanos, nube, dardo
  escenas/             menú, intro, briefing, nivel, diálogos, HUD, panel F1, pausa, fin, controles y créditos
  assets/              sprites, mapas de Tiled, interfaz, efectos, fuentes
modelos/               prototipos en Python y gráficos de validación
designs/               especificaciones de arte y evidencias
pseudo_gen/            generadores del taller anterior
```

El audio (música y efectos) se sintetiza por código al arrancar, así que no hay archivos de sonido ni
atribuciones de audio de terceros.
