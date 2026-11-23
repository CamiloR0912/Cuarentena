"""
MODELO 1 — Caminata aleatoria 2D en retícula, con sesgo por ruido (Errantes y Tosedores; nube de contagio).

Ejecutar:  python modelos/apellido1_apellido2_modelo1_caminatas.py [--mostrar]

Tipología: simulación discreta estocástica.
PRNG: congruencial lineal del taller anterior (a=1664525, c=1013904223, m=2^32).

Modelo:
    En cada paso se elige una dirección con probabilidades (p_N, p_S, p_E, p_O) y se avanza ℓ.
        u < p_N                      -> y += ℓ
        u < p_N + p_S                -> y -= ℓ
        u < p_N + p_S + p_E          -> x += ℓ
        en otro caso                 -> x -= ℓ
    Sesgo por ruido (mecánica M1): la dirección más cercana a la fuente de ruido recibe p + b y las
    otras tres p - b/3, con b ∈ [0, 0.3] proporcional al ruido percibido dentro del radio de audición r_a.

Ecuaciones (validación):
    Sin sesgo (p = 1/4):  E[x_n] = E[y_n] = 0,   E[R²] = n·ℓ²
    Con sesgo:            E[x_n] = n·ℓ·(p_E − p_O),   E[y_n] = n·ℓ·(p_N − p_S)

Configuraciones (GDD §16.1), 10 000 réplicas cada una:
    1) n = 100, ℓ = 1, p = 1/4            -> E[R²] = 100
    2) n = 400, ℓ = 1, p = 1/4            -> E[R²] = 400
    3) n = 100, ℓ = 1, p_E = 0.4, resto 0.2 -> E[x_n] = 20
"""
import math

from Ramirez_Camilo_utilidades import (carpeta_resultados, encabezado, guardar, ic95_media, lcg,
                                            matplotlib_sin_ventana, tabla_validacion)

REPLICAS = 10_000
SEMILLA = 12345
DIRECCIONES = {"N": (0, 1), "S": (0, -1), "E": (1, 0), "O": (-1, 0)}


class CaminataAleatoria:
    """Caminata en retícula. probs = dict con claves N, S, E, O que suman 1."""

    def __init__(self, gen, paso=1, probs=None):
        self.gen = gen
        self.paso = paso
        self.probs = probs or {"N": 0.25, "S": 0.25, "E": 0.25, "O": 0.25}

    def direccion(self, probs=None):
        p = probs or self.probs
        u = self.gen.siguiente()
        if u < p["N"]:
            return "N"
        if u < p["N"] + p["S"]:
            return "S"
        if u < p["N"] + p["S"] + p["E"]:
            return "E"
        return "O"

    def caminar(self, n, x0=0, y0=0, es_obstaculo=None, probs_en=None):
        """
        Devuelve la trayectoria [(x0, y0), ..., (x_n, y_n)].
        es_obstaculo(x, y): si devuelve True, el paso se deshace (el agente se queda en su casilla).
        probs_en(x, y): probabilidades dependientes de la posición (p. ej. sesgo hacia el ruido).
        """
        x, y = x0, y0
        tray = [(x, y)]
        for _ in range(n):
            dx, dy = DIRECCIONES[self.direccion(probs_en(x, y) if probs_en else None)]
            nx, ny = x + dx * self.paso, y + dy * self.paso
            if not (es_obstaculo and es_obstaculo(nx, ny)):
                x, y = nx, ny
            tray.append((x, y))
        return tray


def probabilidades_con_sesgo(pos, fuente, b, base=0.25):
    """La dirección más alineada con la fuente recibe base + b; las demás base − b/3 (suman 1)."""
    dx, dy = fuente[0] - pos[0], fuente[1] - pos[1]
    if dx == 0 and dy == 0 or b <= 0:
        return {d: base for d in DIRECCIONES}
    mejor = ("E" if dx > 0 else "O") if abs(dx) >= abs(dy) else ("N" if dy > 0 else "S")
    return {d: base + b if d == mejor else base - b / 3 for d in DIRECCIONES}


def sesgo_por_ruido(ruido, distancia, radio_audicion, b_max=0.3):
    """b ∈ [0, b_max]: crece con el ruido (0-100) y decrece linealmente con la distancia dentro de r_a."""
    if distancia >= radio_audicion:
        return 0.0
    return b_max * (ruido / 100.0) * (1.0 - distancia / radio_audicion)


def experimento(gen, n, probs, replicas, guardar_r2_por_paso=False):
    """Réplicas independientes (el generador continúa su secuencia entre réplicas)."""
    cam = CaminataAleatoria(gen, 1, probs)
    xs, ys, r2 = [], [], []
    suma_r2_paso = [0.0] * (n + 1) if guardar_r2_por_paso else None
    for _ in range(replicas):
        tray = cam.caminar(n)
        x, y = tray[-1]
        xs.append(x), ys.append(y), r2.append(x * x + y * y)
        if suma_r2_paso is not None:
            for i, (tx, ty) in enumerate(tray):
                suma_r2_paso[i] += tx * tx + ty * ty
    curva = [s / replicas for s in suma_r2_paso] if suma_r2_paso else None
    return xs, ys, r2, curva


def main():
    encabezado("MODELO 1 — Caminata aleatoria 2D con sesgo por ruido", "Congruencial lineal a=1664525 c=1013904223 "
               "m=2^32", f"Réplicas por configuración = {REPLICAS}, semilla = {SEMILLA}, ℓ = 1")
    carpeta = carpeta_resultados("modelo1_caminatas")
    gen = lcg(SEMILLA)
    uni = {"N": 0.25, "S": 0.25, "E": 0.25, "O": 0.25}
    ses = {"N": 0.2, "S": 0.2, "E": 0.4, "O": 0.2}

    _, _, r2_1, _ = experimento(gen, 100, uni, REPLICAS)
    _, _, r2_2, curva = experimento(gen, 400, uni, REPLICAS, guardar_r2_por_paso=True)
    xs3, ys3, _, _ = experimento(gen, 100, ses, REPLICAS)

    m1, a1, b1 = ic95_media(r2_1)
    m2, a2, b2 = ic95_media(r2_2)
    m3, a3, b3 = ic95_media(xs3)
    print(f"\nConfig 1: E[R²] = {m1:.3f}  IC95 [{a1:.3f}, {b1:.3f}]")
    print(f"Config 2: E[R²] = {m2:.3f}  IC95 [{a2:.3f}, {b2:.3f}]")
    print(f"Config 3: E[x_n] = {m3:.3f}  IC95 [{a3:.3f}, {b3:.3f}]   E[y_n] = {sum(ys3) / len(ys3):.3f} (teórico 0)")
    tabla_validacion([
        {"config": 1, "parametros": "n=100, l=1, p=1/4", "medida": "E[R^2]", "teorico": 100.0, "obtenido": m1},
        {"config": 2, "parametros": "n=400, l=1, p=1/4", "medida": "E[R^2]", "teorico": 400.0, "obtenido": m2},
        {"config": 3, "parametros": "n=100, l=1, pE=0.4, pN=pS=pO=0.2", "medida": "E[x_n]", "teorico": 20.0,
         "obtenido": m3},
    ], carpeta)

    # Mecánica del juego: un Errante que oye ruido se sesga hacia la fuente
    fuente = (30, 20)
    def probs_ruido(x, y):
        dist = math.hypot(fuente[0] - x, fuente[1] - y)
        return probabilidades_con_sesgo((x, y), fuente, sesgo_por_ruido(90, dist, 60))
    cam = CaminataAleatoria(gen)
    con_ruido = cam.caminar(300, probs_en=probs_ruido)
    sin_ruido = cam.caminar(300)
    print(f"\nDemostración de sesgo: con ruido (combate = 90, r_a = 60) termina a "
          f"{math.hypot(fuente[0] - con_ruido[-1][0], fuente[1] - con_ruido[-1][1]):.1f} casillas de la fuente; "
          f"sin ruido a {math.hypot(fuente[0] - sin_ruido[-1][0], fuente[1] - sin_ruido[-1][1]):.1f}.")

    plt = matplotlib_sin_ventana()
    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.plot(range(len(curva)), curva, label="E[R²] simulado (10 000 réplicas)")
    ax.plot([0, 400], [0, 400], "--", label="Teórico E[R²] = n·ℓ²")
    ax.set(xlabel="n (pasos)", ylabel="E[R²]", title="Modelo 1: desplazamiento cuadrático medio vs n")
    ax.legend()
    guardar(plt, fig, carpeta, "r2_vs_n")

    fig, ax = plt.subplots(figsize=(6.5, 6.5))
    tray_gen = CaminataAleatoria(gen)
    for k in range(5):
        t = tray_gen.caminar(400)
        ax.plot([p[0] for p in t], [p[1] for p in t], lw=0.8, label=f"Réplica {k + 1}")
    ax.plot(0, 0, "ko")
    ax.set(xlabel="x", ylabel="y", title="Modelo 1: trayectorias de ejemplo (n = 400, p = 1/4)")
    ax.set_aspect("equal")
    ax.legend(fontsize=8)
    guardar(plt, fig, carpeta, "trayectorias")

    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.hist(xs3, bins=range(min(xs3), max(xs3) + 2, 2), density=True, alpha=0.7, label="x_n simulado")
    ax.axvline(20, color="r", ls="--", label="E[x_n] teórico = 20")
    ax.axvline(m3, color="k", ls=":", label=f"Media simulada = {m3:.2f}")
    ax.set(xlabel="x_n", ylabel="Densidad", title="Modelo 1: distribución de x_n con sesgo p_E = 0.4 (n = 100)")
    ax.legend()
    guardar(plt, fig, carpeta, "histograma_sesgo")

    fig, ax = plt.subplots(figsize=(6.5, 6.5))
    ax.plot([p[0] for p in sin_ruido], [p[1] for p in sin_ruido], lw=0.9, label="Sin ruido (p = 1/4)")
    ax.plot([p[0] for p in con_ruido], [p[1] for p in con_ruido], lw=0.9, label="Con ruido de combate")
    ax.plot(*fuente, "r*", ms=14, label="Fuente de ruido (Elena)")
    ax.add_patch(plt.Circle(fuente, 60, fill=False, ls="--", color="r", alpha=0.4))
    ax.set(xlabel="x", ylabel="y", title="Modelo 1: sesgo de la caminata hacia el ruido (mecánica M1)")
    ax.set_aspect("equal")
    ax.legend(fontsize=8)
    guardar(plt, fig, carpeta, "sesgo_ruido")


if __name__ == "__main__":
    main()
