"""
MODELO 3 — Simulación Monte Carlo: daño con críticos, drops y la radio de Don Álvaro.

Ejecutar:  python modelos/Sanchez_Diego_modelo3_montecarlo.py [--mostrar]

Tipología: simulación estocástica estática (réplicas independientes).
PRNG: congruencial aditivo (Fibonacci retrasado, j=24, k=55, m=2^32) del taller anterior, sembrado con el LCG;
      transformaciones de la librería: uniforme, normal (Box-Muller); y transformada inversa discreta (drops).

Modelo:
    Daño:   D = max(0, X) · (k si crit, 1 si no),  X ~ distribución del arma,  crit ~ Bernoulli(p_crit_ef)
            p_crit_ef = min(1, p_crit + 0.25·[espalda sin detección] + 0.10·[adrenalina]),  k = 2
            E[D] = μ_X · (1 + p_crit·(k − 1))
    Drops:  distribución categórica por tipo de enemigo (transformada inversa discreta), validada con χ².
    Radio:  p̂ = (1/N) Σ 1[misión_i exitosa],   IC95 = p̂ ± 1.96 √(p̂(1 − p̂)/N)
            Caso analítico: si cada encuentro se supera con probabilidad q, P(éxito) = q^m.

Configuraciones (GDD §16.3), N = 10 000 réplicas:
    1) Tubo: U(8, 12), p_crit = 0.10, k = 2            -> E[D] = 11.00
    2) Dardos: N(15, 3), p_crit = 0.15, k = 2          -> E[D] = 17.25
    3) Misión simplificada: q = 0.90, m = 5            -> P(éxito) = 0.9^5 = 0.59049
    Adicional: χ² de 10 000 drops por tipo de enemigo (5 g.l., valor crítico 11.07).
"""
import math

from scipy.stats import chi2 as chi2_dist  # solo para el valor crítico, como en la librería del taller anterior

from Ramirez_Camilo_utilidades import (Normal, aditivo, bernoulli, carpeta_resultados, categorica, encabezado,
                                            guardar, ic95_media, matplotlib_sin_ventana, tabla_validacion, uniforme)

N = 10_000
SEMILLA = 12345
K_CRIT = 2.0

ARMAS = {  # (distribución, parámetros, p_crit base)
    "tubo": ("uniforme", (8, 12), 0.10),
    "extintor": ("uniforme", (4, 6), 0.05),
    "dardos": ("normal", (15, 3), 0.15),
    "jeringa": ("fija", (30,), 0.35),
}

DROPS = {  # GDD §6.1: (objeto, probabilidad)
    "Errante": [("nada", .45), ("vendas", .25), ("dardos", .15), ("cubrebocas", .10), ("muestra", .04), ("adrenalina", .01)],
    "Tosedor": [("nada", .40), ("vendas", .20), ("dardos", .10), ("cubrebocas", .20), ("muestra", .08), ("adrenalina", .02)],
    "Corredor": [("nada", .30), ("vendas", .20), ("dardos", .25), ("cubrebocas", .10), ("muestra", .12), ("adrenalina", .03)],
    "Masa": [("nada", .10), ("vendas", .25), ("dardos", .25), ("cubrebocas", .15), ("muestra", .20), ("adrenalina", .05)],
}

ENEMIGOS = {  # agitación (HP), daño a Elena, probabilidad de golpear por intercambio
    "Errante": (30, 8, 0.30), "Tosedor": (20, 0, 0.0), "Corredor": (50, 15, 0.45), "Masa": (15, 5, 0.35),
}


class MonteCarlo:
    def __init__(self, gen):
        self.gen = gen
        self.normal = Normal(gen)

    def p_crit_efectiva(self, arma, espalda_sin_deteccion=False, adrenalina=False):
        return min(1.0, ARMAS[arma][2] + 0.25 * espalda_sin_deteccion + 0.10 * adrenalina)

    def dano(self, arma, espalda_sin_deteccion=False, adrenalina=False):
        """Devuelve (daño, fue_critico)."""
        dist, par, _ = ARMAS[arma]
        if dist == "uniforme":
            x = uniforme(self.gen, *par)
        elif dist == "normal":
            x = self.normal.muestra(*par)
        else:
            x = par[0]
        crit = bernoulli(self.gen, self.p_crit_efectiva(arma, espalda_sin_deteccion, adrenalina))
        return max(0.0, x) * (K_CRIT if crit else 1.0), bool(crit)

    def drop(self, enemigo):
        return categorica(self.gen, DROPS[enemigo])

    def mision_simplificada(self, q, m):
        """Éxito si se superan los m encuentros, cada uno con probabilidad q."""
        return all(bernoulli(self.gen, q) for _ in range(m))

    def mision(self, encuentros, hp, arma="tubo"):
        """
        Misión del juego: Elena enfrenta los encuentros en orden. En cada intercambio ataca (daño Monte Carlo)
        y el enemigo la golpea con su probabilidad. Éxito si termina con HP > 0.
        """
        for enemigo in encuentros:
            agitacion, dano_enemigo, p_golpe = ENEMIGOS[enemigo]
            while agitacion > 0 and hp > 0:
                agitacion -= self.dano(arma)[0]
                if agitacion > 0 and bernoulli(self.gen, p_golpe):
                    hp -= dano_enemigo
            if hp <= 0:
                return False
        return True

    def radio(self, encuentros, hp, arma="tubo", replicas=5_000):
        """Estimación de la radio de Don Álvaro: p̂ e IC 95 % de volver con vida."""
        exitos = sum(self.mision(encuentros, hp, arma) for _ in range(replicas))
        p = exitos / replicas
        h = 1.96 * math.sqrt(p * (1 - p) / replicas)
        return p, p - h, p + h


def chi2_drops(mc, enemigo, n):
    tabla = DROPS[enemigo]
    obs = {v: 0 for v, _ in tabla}
    for _ in range(n):
        obs[mc.drop(enemigo)] += 1
    estad = sum((obs[v] - n * p) ** 2 / (n * p) for v, p in tabla)
    critico = chi2_dist.ppf(0.95, len(tabla) - 1)
    return obs, estad, critico


def main():
    encabezado("MODELO 3 — Monte Carlo: daño, críticos, drops y radio", "Aditivo x_n=(x_n-24 + x_n-55) mod 2^32 "
               "(sembrado con LCG)", f"N = {N} réplicas, semilla = {SEMILLA}, k = {K_CRIT}")
    carpeta = carpeta_resultados("modelo3_montecarlo")
    mc = MonteCarlo(aditivo(SEMILLA))

    tubo = [mc.dano("tubo") for _ in range(N)]
    dardos = [mc.dano("dardos") for _ in range(N)]
    exitos = [mc.mision_simplificada(0.9, 5) for _ in range(N)]
    e_tubo, a1, b1 = ic95_media([d for d, _ in tubo])
    e_dardo, a2, b2 = ic95_media([d for d, _ in dardos])
    p_hat = sum(exitos) / N
    h = 1.96 * math.sqrt(p_hat * (1 - p_hat) / N)
    print(f"\nConfig 1 (tubo):   E[D] = {e_tubo:.4f}  IC95 [{a1:.4f}, {b1:.4f}]   tasa de críticos "
          f"{sum(c for _, c in tubo) / N:.4f} (p_crit = 0.10)")
    print(f"Config 2 (dardos): E[D] = {e_dardo:.4f}  IC95 [{a2:.4f}, {b2:.4f}]   tasa de críticos "
          f"{sum(c for _, c in dardos) / N:.4f} (p_crit = 0.15)")
    print(f"Config 3 (misión): p̂ = {p_hat:.4f}  IC95 [{p_hat - h:.4f}, {p_hat + h:.4f}]")
    espalda = sum(mc.dano("tubo", espalda_sin_deteccion=True)[1] for _ in range(1000)) / 1000
    print(f"Caso de prueba 5: 1000 ataques por la espalda con tubo -> tasa de críticos {espalda:.3f} (esperado 0.35)")
    tabla_validacion([
        {"config": 1, "parametros": "Tubo U(8,12), p_crit=0.10, k=2", "medida": "E[D]", "teorico": 11.0, "obtenido": e_tubo},
        {"config": 2, "parametros": "Dardos N(15,3), p_crit=0.15, k=2", "medida": "E[D]", "teorico": 17.25, "obtenido": e_dardo},
        {"config": 3, "parametros": "Mision q=0.90, m=5", "medida": "P(exito)", "teorico": 0.9 ** 5, "obtenido": p_hat},
    ], carpeta)

    print("\nPrueba χ² de los drops (10 000 por enemigo, α = 0.05):")
    drops = {}
    for enemigo in DROPS:
        obs, est, crit = chi2_drops(mc, enemigo, N)
        drops[enemigo] = obs
        print(f"   {enemigo:<9} χ² = {est:7.3f}   crítico = {crit:.2f}   {'NO se rechaza H0' if est < crit else 'se rechaza H0'}")

    zona = ["Errante", "Errante", "Corredor", "Errante", "Masa", "Masa", "Corredor"]
    p, lo, hi = mc.radio(zona, hp=100)
    print(f"\nRadio de Don Álvaro (farmacia del centro: {len(zona)} encuentros, HP = 100, tubo):")
    print(f'   "Doctora, en la farmacia hay antivirales, pero la zona está caliente. Calculo un {p * 100:.0f} % de '
          f'probabilidad de volver." (IC95 {lo * 100:.1f} %–{hi * 100:.1f} %)')

    plt = matplotlib_sin_ventana()
    fig, axs = plt.subplots(1, 2, figsize=(11, 4.2))
    for ax, datos, nombre, esperado in ((axs[0], tubo, "Tubo U(8,12)", 11.0), (axs[1], dardos, "Dardos N(15,3)", 17.25)):
        normales = [d for d, c in datos if not c]
        criticos = [d for d, c in datos if c]
        ax.hist([normales, criticos], bins=40, stacked=True, label=["Normal", "Crítico (×2)"], color=["#4FA3D1", "#C0392B"])
        ax.axvline(esperado, color="k", ls="--", label=f"E[D] teórico = {esperado}")
        ax.set(xlabel="Daño", ylabel="Frecuencia", title=f"Modelo 3: daño con {nombre}")
        ax.legend(fontsize=8)
    guardar(plt, fig, carpeta, "histograma_dano")

    fig, ax = plt.subplots(figsize=(7.5, 4.5))
    ns, ps, los, his = [], [], [], []
    acc = 0
    for i, e in enumerate(exitos, start=1):
        acc += e
        if i % 50 == 0:
            ph = acc / i
            hh = 1.96 * math.sqrt(ph * (1 - ph) / i)
            ns.append(i), ps.append(ph), los.append(ph - hh), his.append(ph + hh)
    ax.plot(ns, ps, label="p̂ (estimación Monte Carlo)")
    ax.fill_between(ns, los, his, alpha=0.25, label="IC 95 %")
    ax.axhline(0.9 ** 5, color="r", ls="--", label="Teórico 0.9⁵ = 0.5905")
    ax.set(xlabel="N (réplicas)", ylabel="P(éxito)", title="Modelo 3: convergencia de p̂ (misión q = 0.9, m = 5)", xscale="log")
    ax.legend()
    guardar(plt, fig, carpeta, "convergencia_p")

    fig, axs = plt.subplots(1, 4, figsize=(15, 3.8), sharey=True)
    for ax, (enemigo, obs) in zip(axs, drops.items()):
        nombres = [v for v, _ in DROPS[enemigo]]
        ax.bar(nombres, [obs[v] for v in nombres], alpha=0.75, label="Observado")
        ax.plot(nombres, [N * p for _, p in DROPS[enemigo]], "r_", ms=22, mew=2.5, label="Esperado")
        ax.set_title(f"Drops: {enemigo}")
        ax.tick_params(axis="x", rotation=60)
    axs[0].set_ylabel("Frecuencia (10 000 drops)")
    axs[0].legend(fontsize=8)
    guardar(plt, fig, carpeta, "drops_chi2")

    fig, ax = plt.subplots(figsize=(7.5, 4.5))
    ms = list(range(1, 13))
    for arma in ("tubo", "dardos", "jeringa"):
        ax.plot(ms, [mc.radio(["Errante"] * m, 100, arma, replicas=1500)[0] for m in ms], "o-", label=arma.capitalize())
    ax.set(xlabel="Encuentros con Errantes en la misión", ylabel="p̂ de volver",
           title="Modelo 3: probabilidad estimada por la radio según el arma")
    ax.legend()
    guardar(plt, fig, carpeta, "radio_por_arma")


if __name__ == "__main__":
    main()
