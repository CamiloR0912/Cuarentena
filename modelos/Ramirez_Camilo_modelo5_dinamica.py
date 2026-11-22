"""
MODELO 5 — Dinámica de sistemas: modelo SIR del pulso epidémico de Tunja (N = 180 000).

Ejecutar:  python modelos/apellido1_apellido2_modelo5_dinamica.py [--mostrar]

Tipología: simulación continua (ecuaciones diferenciales), integración Runge-Kutta de orden 4.
PRNG: congruencial lineal del taller anterior (a=1664525, c=1013904223, m=2^32) para el análisis de
      sensibilidad estocástico (β ~ U(0.25, 0.35) por réplica); el núcleo SIR es determinista.

Ecuaciones:
    dS/dt = −β S I / N,   dI/dt = β S I / N − γ I,   dR/dt = γ I
    ℛ0 = β/γ;  el pico ocurre cuando S = N/ℛ0;  I_max/N = 1 − (1 + ln ℛ0)/ℛ0  (S0 ≈ N)
    Tamaño final:  r∞ = 1 − exp(−ℛ0 r∞)
Acoplamiento con el jugador (GDD §7.5):
    β_ef = β (1 − 0.4 f_cub)          (f_cub = fracción con cubrebocas)
    γ_ef = γ + atendidos_por_día / (I + K)   (hospital; K = 2000 evita que la tasa se dispare cuando I -> 0,
                                              ajuste respecto al GDD, que usaba atendidos/I y es inestable)
    cada abandono de la cola: I += 1;  cada ciudadano rescatado: S −= 1 (queda protegido)
    Punto de no retorno: I/N > umbral de colapso.

Configuraciones (GDD §16.5), γ = 0.1, N = 180 000, I0 = 10:
    1) β = 0.30 (ℛ0 = 3.0) -> I_max/N = 0.3005, r∞ = 0.9405
    2) β = 0.20 (ℛ0 = 2.0) -> I_max/N = 0.1534, r∞ = 0.7968
    3) β = 0.15 (ℛ0 = 1.5) -> I_max/N = 0.0630, r∞ = 0.5828
"""
import math

from apellido1_apellido2_utilidades import (carpeta_resultados, encabezado, guardar, ic95_media, lcg,
                                            matplotlib_sin_ventana, tabla_validacion, uniforme)

N = 180_000
I0 = 10
GAMMA = 0.1
SEMILLA = 2026


def i_max_teorico(r0):
    return 1 - (1 + math.log(r0)) / r0


def r_inf_teorico(r0):
    r = 0.5
    for _ in range(500):
        r = 1 - math.exp(-r0 * r)
    return r


class SIR:
    """Stocks S, I, R; flujos contagio y recuperación. Integrador RK4 o Euler con paso dt (días)."""

    def __init__(self, n=N, i0=I0, beta=0.3, gamma=GAMMA):
        self.n, self.beta, self.gamma = n, beta, gamma
        self.s, self.i, self.r = n - i0, float(i0), 0.0
        self.f_cub = 0.0          # fracción de la población con cubrebocas
        self.atendidos_dia = 0.0  # pacientes atendidos por el hospital (por día)

    def beta_ef(self):
        return self.beta * (1 - 0.4 * self.f_cub)

    K_SATURACION = 2000.0

    def gamma_ef(self):
        return self.gamma + self.atendidos_dia / (self.i + self.K_SATURACION)

    def derivadas(self, s, i):
        b, g = self.beta_ef(), self.gamma_ef()
        contagio = b * s * i / self.n
        return -contagio, contagio - g * i, g * i

    def paso(self, dt, metodo="rk4"):
        s, i = self.s, self.i
        if metodo == "euler":
            k = self.derivadas(s, i)
            ds, di, dr = (dt * x for x in k)
        else:
            k1 = self.derivadas(s, i)
            k2 = self.derivadas(s + dt / 2 * k1[0], i + dt / 2 * k1[1])
            k3 = self.derivadas(s + dt / 2 * k2[0], i + dt / 2 * k2[1])
            k4 = self.derivadas(s + dt * k3[0], i + dt * k3[1])
            ds, di, dr = (dt / 6 * (a + 2 * b + 2 * c + d) for a, b, c, d in zip(k1, k2, k3, k4))
        self.s, self.i, self.r = max(0.0, s + ds), max(0.0, i + di), self.r + dr

    # eventos del juego
    def abandono_cola(self, k=1):
        self.i += k

    def rescate(self, k=1):
        k = min(k, self.s)
        self.s -= k
        self.r += k  # protegido: sale de los susceptibles

    def simular(self, dias, dt=0.1, metodo="rk4", eventos=None):
        """eventos(dia, modelo) se llama una vez por día (intervenciones del jugador). Devuelve (t, S, I, R)."""
        serie = [(0.0, self.s, self.i, self.r)]
        pasos = round(1 / dt)
        for d in range(dias):
            if eventos:
                eventos(d, self)
            for _ in range(pasos):
                self.paso(dt, metodo)
            serie.append((d + 1.0, self.s, self.i, self.r))
        return serie


def pico(serie):
    t, _, i, _ = max(serie, key=lambda p: p[2])
    return t, i


def main():
    encabezado("MODELO 5 — Dinámica de sistemas: SIR (RK4)", "Congruencial lineal a=1664525 c=1013904223 m=2^32 "
               "(sensibilidad de β)", f"N = {N}, I0 = {I0}, γ = {GAMMA}, Δt = 0.1 día, semilla = {SEMILLA}")
    carpeta = carpeta_resultados("modelo5_dinamica")
    filas, series = [], {}
    for k, beta in ((1, 0.30), (2, 0.20), (3, 0.15)):
        r0 = beta / GAMMA
        serie = SIR(beta=beta).simular(400)
        series[beta] = serie
        t_p, i_p = pico(serie)
        r_fin = serie[-1][3] / N
        print(f"Config {k}: β = {beta}, ℛ0 = {r0:.1f} -> pico I/N = {i_p / N:.4f} el día {t_p:.0f}, r∞ = {r_fin:.4f}")
        par = f"beta={beta}, gamma={GAMMA}, R0={r0:.1f}"
        filas += [{"config": k, "parametros": par, "medida": "I_max/N", "teorico": i_max_teorico(r0), "obtenido": i_p / N},
                  {"config": k, "parametros": par, "medida": "r_inf", "teorico": r_inf_teorico(r0), "obtenido": r_fin}]
    tabla_validacion(filas, carpeta)

    # Error RK4 vs Euler frente al paso (referencia: RK4 con Δt = 0.001), I(día 60) con β = 0.3
    ref = SIR(beta=0.3).simular(60, dt=0.001)[-1][2]
    dts = [1.0, 0.5, 0.25, 0.1, 0.05]
    err = {m: [abs(SIR(beta=0.3).simular(60, dt=dt, metodo=m)[-1][2] - ref) / ref for dt in dts] for m in ("euler", "rk4")}
    print("\nError relativo de I(60) frente a la referencia:")
    for dt, e1, e4 in zip(dts, err["euler"], err["rk4"]):
        print(f"   Δt = {dt:<5} Euler = {e1:.2e}   RK4 = {e4:.2e}")

    # Sensibilidad estocástica: β ~ U(0.25, 0.35) con el PRNG, 500 réplicas
    gen = lcg(SEMILLA)
    picos, dias_pico = [], []
    for _ in range(500):
        s = SIR(beta=uniforme(gen, 0.25, 0.35)).simular(250, dt=0.25)
        t_p, i_p = pico(s)
        picos.append(i_p / N), dias_pico.append(t_p)
    m, lo, hi = ic95_media(picos)
    print(f"\nSensibilidad: β ~ U(0.25, 0.35), 500 réplicas -> I_max/N medio = {m:.4f} IC95 [{lo:.4f}, {hi:.4f}], "
          f"rango [{min(picos):.3f}, {max(picos):.3f}]; día del pico entre {min(dias_pico):.0f} y {max(dias_pico):.0f}")

    # Intervenciones del jugador (escenario del juego, ℛ0 = 3)
    def jugador(dia, sir):
        if dia == 30:
            sir.f_cub = 0.3            # reparte cubrebocas
        if 35 <= dia < 90:
            sir.atendidos_dia = 900.0  # el hospital funciona (camillas abiertas)
            sir.rescate(40)            # ciudadanos rescatados
        if 55 <= dia < 60:
            sir.abandono_cola(300)     # colapso temporal de la cola
    base = SIR(beta=0.3).simular(200)
    interv = SIR(beta=0.3).simular(200, eventos=jugador)
    print(f"Escenario de juego: pico sin intervención {pico(base)[1] / N:.3f}, con intervención {pico(interv)[1] / N:.3f}")
    print(f"Nota de diseño: con ℛ0 = 3 el pico teórico es {i_max_teorico(3):.2f}; un umbral de colapso I/N > 0.60 nunca "
          f"se alcanza (requeriría ℛ0 ≈ {next(r for r in [x / 10 for x in range(11, 400)] if i_max_teorico(r) > 0.6):.1f}).")

    plt = matplotlib_sin_ventana()
    fig, axs = plt.subplots(1, 3, figsize=(15, 4.2), sharey=True)
    for ax, beta in zip(axs, (0.30, 0.20, 0.15)):
        sr = series[beta]
        for idx, nombre, color in ((1, "S", "#4FA3D1"), (2, "I", "#7A8F4E"), (3, "R", "#8A9199")):
            ax.plot([p[0] for p in sr], [p[idx] / N for p in sr], color=color, label=nombre)
        ax.axhline(i_max_teorico(beta / GAMMA), ls=":", color="#7A8F4E")
        ax.set(title=f"β = {beta} (ℛ0 = {beta / GAMMA:.1f})", xlabel="Día")
        ax.legend()
    axs[0].set_ylabel("Fracción de la población")
    guardar(plt, fig, carpeta, "curvas_sir")

    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.loglog(dts, err["euler"], "o-", label="Euler (orden 1)")
    ax.loglog(dts, err["rk4"], "s-", label="RK4 (orden 4)")
    ax.set(xlabel="Δt (días)", ylabel="Error relativo de I(60)", title="Modelo 5: convergencia de los integradores")
    ax.legend()
    guardar(plt, fig, carpeta, "error_rk4_euler")

    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.hist(picos, bins=30, alpha=0.75, color="#7A8F4E")
    ax.axvline(i_max_teorico(3.0), color="r", ls="--", label="Pico con β = 0.30")
    ax.set(xlabel="I_max / N", ylabel="Frecuencia", title="Modelo 5: sensibilidad del pico a β ~ U(0.25, 0.35)")
    ax.legend()
    guardar(plt, fig, carpeta, "sensibilidad_beta")

    fig, ax = plt.subplots(figsize=(8, 4.5))
    ax.plot([p[0] for p in base], [p[2] / N for p in base], "k--", label="I sin intervención")
    ax.plot([p[0] for p in interv], [p[2] / N for p in interv], color="#C0392B", label="I con intervenciones del jugador")
    ax.axvline(30, color="#4FA3D1", alpha=0.5), ax.text(31, 0.27, "cubrebocas", fontsize=8)
    ax.axvspan(35, 90, alpha=0.08, color="#4FA3D1", label="hospital + rescates")
    ax.axvspan(55, 60, alpha=0.25, color="#E0A030", label="abandonos de la cola")
    ax.set(xlabel="Día", ylabel="I/N", title="Modelo 5: acoplamiento con las decisiones del jugador")
    ax.legend(fontsize=8)
    guardar(plt, fig, carpeta, "intervenciones")


if __name__ == "__main__":
    main()
