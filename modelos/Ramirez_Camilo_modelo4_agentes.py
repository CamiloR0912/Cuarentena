"""
MODELO 4 — Simulación basada en agentes: Masas (boids), contagio en la calle, Corredores (FSM) y ciudadanos (pánico).

Ejecutar:  python modelos/apellido1_apellido2_modelo4_agentes.py [--mostrar]

Tipología: simulación basada en agentes, tiempo discreto.
PRNG: congruencial lineal del taller anterior (a=1664525, c=1013904223, m=2^32), semilla distinta a la del modelo 1.

Boids (cada individuo i con vecinos V_i dentro del radio de visión r_v, mundo toroidal):
    separación  s_i = −Σ (x_j − x_i) / |x_j − x_i|²
    alineación  a_i = (1/|V_i|) Σ v_j − v_i
    cohesión    c_i = (1/|V_i|) Σ x_j − x_i
    v_i ← normalizar(v_i + w_s s_i + w_a a_i + w_c c_i + η ξ_i) · v_max   (ξ_i: dirección aleatoria; rapidez constante)
    Parámetro de orden  φ = |Σ v_i| / (N v_max)
    Sin alineación las direcciones son independientes: E[φ²] = 1/N  ->  φ_rms = 1/√N.

Contagio entre agentes (población bien mezclada, paso diario):
    P(S→I) = 1 − exp(−β I/N),   P(I→R) = 1 − exp(−γ)
    Debe reproducir el SIR: tamaño final r∞ = 1 − e^{−ℛ0 r∞},  ℛ0 = β/γ.

Configuraciones (GDD §16.4):
    1) Boids N=50, w_a = 0 (sin alineación)        -> φ_rms = 1/√50 = 0.1414
    2) Boids N=50, w_a alto, ruido bajo            -> φ → 1
    3) Contagio β=0.3, γ=0.1 (ℛ0 = 3), N = 2000     -> r∞ = 0.9405
"""
import math

from apellido1_apellido2_utilidades import (bernoulli, carpeta_resultados, encabezado, guardar, ic95_media, lcg,
                                            matplotlib_sin_ventana, tabla_validacion, uniforme)

SEMILLA = 777


# ── Boids (Masas) ──────────────────────────────────────────────────────────────────────────────

class Boids:
    def __init__(self, gen, n=50, lado=50.0, r_vision=6.0, v_max=1.0, w_s=0.6, w_a=0.0, w_c=0.02, ruido=0.6):
        self.gen, self.n, self.lado, self.rv, self.vmax = gen, n, lado, r_vision, v_max
        self.w_s, self.w_a, self.w_c, self.ruido = w_s, w_a, w_c, ruido
        self.pos = [[uniforme(gen, 0, lado), uniforme(gen, 0, lado)] for _ in range(n)]
        self.vel = [self._dir_aleatoria(v_max) for _ in range(n)]

    def _dir_aleatoria(self, r):
        ang = uniforme(self.gen, 0, 2 * math.pi)
        return [r * math.cos(ang), r * math.sin(ang)]

    def _delta(self, a, b):
        """Diferencia b − a en el toro (distancia mínima)."""
        d = [b[0] - a[0], b[1] - a[1]]
        for k in (0, 1):
            if d[k] > self.lado / 2:
                d[k] -= self.lado
            elif d[k] < -self.lado / 2:
                d[k] += self.lado
        return d

    def paso(self):
        nuevas = []
        for i in range(self.n):
            sep, ali, coh, cnt = [0.0, 0.0], [0.0, 0.0], [0.0, 0.0], 0
            for j in range(self.n):
                if i == j:
                    continue
                d = self._delta(self.pos[i], self.pos[j])
                dist2 = d[0] ** 2 + d[1] ** 2
                if 0 < dist2 < self.rv ** 2:
                    cnt += 1
                    sep[0] -= d[0] / dist2
                    sep[1] -= d[1] / dist2
                    ali[0] += self.vel[j][0]
                    ali[1] += self.vel[j][1]
                    coh[0] += d[0]
                    coh[1] += d[1]
            v = list(self.vel[i])
            if cnt:
                for k in (0, 1):
                    v[k] += (self.w_s * sep[k] + self.w_a * (ali[k] / cnt - self.vel[i][k]) + self.w_c * coh[k] / cnt)
            xi = self._dir_aleatoria(self.ruido)
            v = [v[0] + xi[0], v[1] + xi[1]]
            norma = math.sqrt(v[0] * v[0] + v[1] * v[1]) or 1.0  # sqrt (no hypot): misma operación que el port a GDScript
            nuevas.append([v[0] / norma * self.vmax, v[1] / norma * self.vmax])
        self.vel = nuevas
        for p, v in zip(self.pos, self.vel):
            p[0] = (p[0] + v[0]) % self.lado
            p[1] = (p[1] + v[1]) % self.lado

    def phi(self):
        sx = sum(v[0] for v in self.vel)
        sy = sum(v[1] for v in self.vel)
        return math.sqrt(sx * sx + sy * sy) / (self.n * self.vmax)


def correr_boids(gen, pasos=400, descarte=100, **kw):
    b = Boids(gen, **kw)
    serie = []
    for _ in range(pasos):
        b.paso()
        serie.append(b.phi())
    estable = serie[descarte:]
    return b, serie, math.sqrt(sum(f * f for f in estable) / len(estable)), sum(estable) / len(estable)


# ── Contagio entre agentes (calle) ─────────────────────────────────────────────────────────────

def contagio_abm(gen, n=2000, i0=20, beta=0.3, gamma=0.1, dias=200):
    """Cada agente: 0 = S, 1 = I, 2 = R. Devuelve las series S, I, R por día."""
    estado = [1] * i0 + [0] * (n - i0)
    p_rec = 1 - math.exp(-gamma)
    serie = []
    for _ in range(dias):
        infectados = estado.count(1)
        serie.append((estado.count(0), infectados, estado.count(2)))
        if infectados == 0:
            continue
        p_inf = 1 - math.exp(-beta * infectados / n)
        for k in range(n):
            if estado[k] == 0 and bernoulli(gen, p_inf):
                estado[k] = 1
            elif estado[k] == 1 and bernoulli(gen, p_rec):
                estado[k] = 2
    return serie


def sir_rk4(n, i0, beta, gamma, dias, dt=0.1):
    s, i, r = n - i0, float(i0), 0.0
    f = lambda s_, i_: (-beta * s_ * i_ / n, beta * s_ * i_ / n - gamma * i_, gamma * i_)
    serie = []
    pasos_dia = round(1 / dt)
    for d in range(dias):
        serie.append((s, i, r))
        for _ in range(pasos_dia):
            k1 = f(s, i)
            k2 = f(s + dt / 2 * k1[0], i + dt / 2 * k1[1])
            k3 = f(s + dt / 2 * k2[0], i + dt / 2 * k2[1])
            k4 = f(s + dt * k3[0], i + dt * k3[1])
            s += dt / 6 * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0])
            i += dt / 6 * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1])
            r += dt / 6 * (k1[2] + 2 * k2[2] + 2 * k3[2] + k4[2])
    return serie


def tamano_final(r0):
    """Raíz de r = 1 − exp(−ℛ0 r) por punto fijo."""
    r = 0.5
    for _ in range(200):
        r = 1 - math.exp(-r0 * r)
    return r


# ── Corredor: máquina de estados finitos ───────────────────────────────────────────────────────

class Corredor:
    """PATRULLA -(oye ruido > umbral)-> ALERTA -(ve a Elena)-> PERSECUCION -(la pierde)-> BUSQUEDA -(10 s)-> PATRULLA"""
    UMBRAL_RUIDO = 40

    def __init__(self):
        self.estado = "PATRULLA"
        self.t_sin_estimulo = 0.0

    def actualizar(self, dt, ruido_percibido, ve_a_elena):
        anterior = self.estado
        if self.estado == "PATRULLA" and ruido_percibido > self.UMBRAL_RUIDO:
            self.estado = "ALERTA"
        elif self.estado in ("ALERTA", "BUSQUEDA") and ve_a_elena:
            self.estado = "PERSECUCION"
        elif self.estado == "PERSECUCION" and not ve_a_elena:
            self.estado = "BUSQUEDA"
        if self.estado in ("ALERTA", "BUSQUEDA"):
            estimulo = ruido_percibido > self.UMBRAL_RUIDO or ve_a_elena
            self.t_sin_estimulo = 0.0 if estimulo else self.t_sin_estimulo + dt
            if self.t_sin_estimulo >= 10.0:
                self.estado, self.t_sin_estimulo = "PATRULLA", 0.0
        return anterior != self.estado


# ── Ciudadano: pánico ──────────────────────────────────────────────────────────────────────────

class Ciudadano:
    """Pánico P ∈ [0,1]: sube cerca de infectados, baja cerca de Elena. P < 0.5 sigue a Elena; P ≥ 0.5 huye."""

    def __init__(self, panico=0.3):
        self.p = panico

    def actualizar(self, dt, infectados_cerca, elena_cerca):
        self.p += dt * (0.08 * infectados_cerca - (0.12 if elena_cerca else 0.02))
        self.p = min(1.0, max(0.0, self.p))
        return "sigue a Elena" if self.p < 0.5 else "huye"


def main():
    encabezado("MODELO 4 — Agentes: boids, contagio, FSM del Corredor, pánico", "Congruencial lineal a=1664525 "
               "c=1013904223 m=2^32", f"semilla = {SEMILLA}")
    carpeta = carpeta_resultados("modelo4_agentes")
    gen = lcg(SEMILLA)

    reps = 5
    c1 = [correr_boids(gen, w_a=0.0, ruido=0.6) for _ in range(reps)]
    c2 = [correr_boids(gen, w_a=0.9, ruido=0.08) for _ in range(reps)]
    phi_rms1 = math.sqrt(sum(r[2] ** 2 for r in c1) / reps)
    phi2, a2, b2 = ic95_media([r[3] for r in c2])
    print(f"\nConfig 1: boids sin alineación -> φ_rms = {phi_rms1:.4f} (teórico 1/√50 = {1 / math.sqrt(50):.4f}), "
          f"φ medio = {sum(r[3] for r in c1) / reps:.4f} (teórico √(π/4N) = {math.sqrt(math.pi / 200):.4f})")
    print(f"Config 2: boids con alineación  -> φ medio = {phi2:.4f}  IC95 [{a2:.4f}, {b2:.4f}]")
    abm = [contagio_abm(gen) for _ in range(10)]
    finales = [s[-1][2] / 2000 for s in abm]
    r_inf, a3, b3 = ic95_media(finales)
    print(f"Config 3: contagio ABM (ℛ0 = 3) -> tamaño final r∞ = {r_inf:.4f}  IC95 [{a3:.4f}, {b3:.4f}]")
    tabla_validacion([
        {"config": 1, "parametros": "Boids N=50, w_a=0, eta=0.6", "medida": "phi_rms", "teorico": 1 / math.sqrt(50),
         "obtenido": phi_rms1},
        {"config": 2, "parametros": "Boids N=50, w_a=0.9, eta=0.08", "medida": "phi", "teorico": 1.0, "obtenido": phi2},
        {"config": 3, "parametros": "ABM beta=0.3, gamma=0.1, N=2000", "medida": "r_inf", "teorico": tamano_final(3.0),
         "obtenido": r_inf},
    ], carpeta)

    # FSM del Corredor: guion de estímulos (ruido percibido, ¿ve a Elena?) cada segundo
    guion = [(10, False)] * 5 + [(70, False)] * 2 + [(30, True)] * 6 + [(10, False)] * 15 + [(5, False)] * 6
    cor, estados = Corredor(), []
    print("\nFSM del Corredor (un paso por segundo):")
    for t, (ruido, ve) in enumerate(guion):
        if cor.actualizar(1.0, ruido, ve):
            print(f"   t = {t:>2} s: ruido {ruido:>2}, ve a Elena {str(ve):<5} -> {cor.estado}")
        estados.append(cor.estado)

    ciud, panico = Ciudadano(0.3), []
    for t in range(60):
        ciud.actualizar(1.0, infectados_cerca=2 if 10 <= t < 25 else 0, elena_cerca=t >= 30)
        panico.append(ciud.p)

    plt = matplotlib_sin_ventana()
    fig, ax = plt.subplots(figsize=(8, 4.3))
    ax.plot(c1[0][1], lw=0.8, label="Config 1: sin alineación (w_a = 0)")
    ax.plot(c2[0][1], lw=0.8, label="Config 2: con alineación (w_a = 0.9)")
    ax.axhline(1 / math.sqrt(50), color="C0", ls="--", label="1/√N")
    ax.axhline(1.0, color="C1", ls="--", label="Orden total φ = 1")
    ax.set(xlabel="Paso", ylabel="φ", title="Modelo 4: parámetro de orden de la Masa (N = 50)", ylim=(0, 1.05))
    ax.legend(fontsize=8)
    guardar(plt, fig, carpeta, "phi_vs_tiempo")

    fig, axs = plt.subplots(1, 2, figsize=(11, 5.2))
    for ax, (b, _, _, _), titulo in ((axs[0], c1[0], "Sin alineación: desorden"), (axs[1], c2[0], "Con alineación: enjambre")):
        ax.quiver([p[0] for p in b.pos], [p[1] for p in b.pos], [v[0] for v in b.vel], [v[1] for v in b.vel],
                  color="#7A8F4E", scale=25)
        ax.set(xlim=(0, b.lado), ylim=(0, b.lado), title=f"{titulo} (φ = {b.phi():.2f})")
        ax.set_aspect("equal")
    guardar(plt, fig, carpeta, "boids_posiciones")

    fig, ax = plt.subplots(figsize=(8, 4.5))
    for k, serie in enumerate(abm[:5]):
        ax.plot([s[1] / 2000 for s in serie], color="C3", alpha=0.35, lw=0.9, label="ABM (5 réplicas)" if k == 0 else None)
    sir = sir_rk4(2000, 20, 0.3, 0.1, 200)
    ax.plot([s[1] / 2000 for s in sir], "k--", lw=1.8, label="SIR (RK4)")
    ax.set(xlabel="Día", ylabel="Fracción infectada I/N", title="Modelo 4: contagio entre agentes vs modelo SIR (ℛ0 = 3)")
    ax.legend()
    guardar(plt, fig, carpeta, "abm_vs_sir")

    fig, axs = plt.subplots(2, 1, figsize=(8, 5.5))
    orden = ["PATRULLA", "ALERTA", "PERSECUCION", "BUSQUEDA"]
    axs[0].step(range(len(estados)), [orden.index(e) for e in estados], where="post", color="#C0392B")
    axs[0].set(yticks=range(4), yticklabels=orden, xlabel="Tiempo (s)", title="Modelo 4: estados del Corredor (FSM)")
    axs[1].plot(panico, color="#E0A030")
    axs[1].axhline(0.5, ls="--", color="k", label="Umbral: ≥ 0.5 huye")
    axs[1].axvspan(10, 25, alpha=0.15, color="#7A8F4E", label="Infectados cerca")
    axs[1].axvspan(30, 60, alpha=0.15, color="#4FA3D1", label="Elena cerca")
    axs[1].set(xlabel="Tiempo (s)", ylabel="Pánico P", title="Pánico de un ciudadano")
    axs[1].legend(fontsize=8)
    guardar(plt, fig, carpeta, "fsm_y_panico")


if __name__ == "__main__":
    main()
