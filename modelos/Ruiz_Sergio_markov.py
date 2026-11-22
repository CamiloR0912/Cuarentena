"""
MODELO COMPLEMENTARIO — Cadenas de Markov: progresión del infectado y fases del Paciente Cero.

Ejecutar:  python modelos/Ruiz_Sergio_markov.py [--mostrar]

PRNG: congruencial lineal del taller anterior (a=1664525, c=1013904223, m=2^32), semilla propia.

Progresión del infectado (por minuto de juego), estados {Errante, Tosedor, Corredor}:
        | 0.90  0.10  0    |
    P = | 0     0.85  0.15 |        Corredor es absorbente.
        | 0     0     1    |
    Tiempo esperado Errante -> Corredor = 1/0.10 + 1/0.15 = 16.67 min
    Distribución tras n minutos: π_n = π_0 · P^n

Fases del Paciente Cero {Deambular, Embestida, Toser, Llamar}: cadena ergódica; π estacionaria con πP = π.
"""
from Ramirez_Camilo_utilidades import (carpeta_resultados, categorica, encabezado, guardar, ic95_media, lcg,
                                            matplotlib_sin_ventana, tabla_validacion)

SEMILLA = 4242
ESTADOS = ["Errante", "Tosedor", "Corredor"]
P = [[0.90, 0.10, 0.00], [0.00, 0.85, 0.15], [0.00, 0.00, 1.00]]
FASES = ["Deambular", "Embestida", "Toser", "Llamar a la Masa"]
P_JEFE = [[0.50, 0.25, 0.15, 0.10],
          [0.60, 0.10, 0.20, 0.10],
          [0.55, 0.20, 0.10, 0.15],
          [0.70, 0.15, 0.15, 0.00]]


def mat_mult(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(len(b))) for j in range(len(b[0]))] for i in range(len(a))]


def distribucion(pi0, p, n):
    pi = [pi0]
    for _ in range(n):
        pi = mat_mult(pi, p)
    return pi[0]


def estacionaria(p, iteraciones=2000):
    pi = [1.0 / len(p)] * len(p)
    for _ in range(iteraciones):
        pi = distribucion(pi, p, 1)
    return pi


def paso(gen, p, estado):
    return categorica(gen, list(enumerate(p[estado])))


def tiempo_hasta_corredor(gen):
    estado, t = 0, 0
    while estado != 2:
        estado = paso(gen, P, estado)
        t += 1
    return t


def main():
    encabezado("MODELO COMPLEMENTARIO — Cadenas de Markov", "Congruencial lineal a=1664525 c=1013904223 m=2^32",
               f"semilla = {SEMILLA}")
    carpeta = carpeta_resultados("markov")
    gen = lcg(SEMILLA)
    replicas = 10_000

    tiempos = [tiempo_hasta_corredor(gen) for _ in range(replicas)]
    t_med, lo, hi = ic95_media(tiempos)
    print(f"\nTiempo Errante -> Corredor: simulado {t_med:.3f} min IC95 [{lo:.3f}, {hi:.3f}]  (teórico 16.667)")
    pi10 = distribucion([1, 0, 0], P, 10)
    finales = [0, 0, 0]
    for _ in range(replicas):
        e = 0
        for _ in range(10):
            e = paso(gen, P, e)
        finales[e] += 1
    sim10 = [f / replicas for f in finales]
    print("Distribución tras 10 min:  " + "   ".join(f"{s}: teo {t:.4f} / sim {m:.4f}" for s, t, m in zip(ESTADOS, pi10, sim10)))
    pi_jefe = estacionaria(P_JEFE)
    visitas = [0] * 4
    e = 0
    for _ in range(50_000):
        e = paso(gen, P_JEFE, e)
        visitas[e] += 1
    sim_jefe = [v / 50_000 for v in visitas]
    print("Jefe, distribución estacionaria:  " + "   ".join(f"{f}: {t:.4f} / {m:.4f}" for f, t, m in zip(FASES, pi_jefe, sim_jefe)))
    tabla_validacion([
        {"config": 1, "parametros": "P infectado, inicio Errante", "medida": "E[T] (min)", "teorico": 1 / 0.10 + 1 / 0.15, "obtenido": t_med},
        {"config": 2, "parametros": "pi_10, estado Corredor", "medida": "P(Corredor)", "teorico": pi10[2], "obtenido": sim10[2]},
        {"config": 3, "parametros": "P jefe, 50 000 pasos", "medida": "pi(Deambular)", "teorico": pi_jefe[0], "obtenido": sim_jefe[0]},
    ], carpeta)

    plt = matplotlib_sin_ventana()
    fig, ax = plt.subplots(figsize=(7.5, 4.5))
    evol = [distribucion([1, 0, 0], P, n) for n in range(61)]
    for k, (nombre, color) in enumerate(zip(ESTADOS, ("#7A8F4E", "#B5C95A", "#C0392B"))):
        ax.plot(range(61), [d[k] for d in evol], color=color, label=nombre)
    ax.set(xlabel="Minutos de juego", ylabel="Probabilidad", title="Markov: evolución de un infectado que empieza como Errante")
    ax.legend()
    guardar(plt, fig, carpeta, "evolucion_distribucion")

    fig, ax = plt.subplots(figsize=(7.5, 4.2))
    ax.hist(tiempos, bins=range(0, 80, 2), alpha=0.75, color="#C0392B")
    ax.axvline(16.667, color="k", ls="--", label="E[T] teórico = 16.67 min")
    ax.set(xlabel="Minutos hasta volverse Corredor", ylabel="Frecuencia", title="Markov: tiempo de absorción (10 000 réplicas)")
    ax.legend()
    guardar(plt, fig, carpeta, "tiempo_absorcion")

    fig, ax = plt.subplots(figsize=(7, 4.2))
    x = range(4)
    ax.bar([i - 0.2 for i in x], pi_jefe, 0.4, label="π teórica (πP = π)")
    ax.bar([i + 0.2 for i in x], sim_jefe, 0.4, label="Frecuencia simulada")
    ax.set_xticks(list(x), FASES)
    ax.set(ylabel="Proporción del tiempo", title="Markov: fases del Paciente Cero")
    ax.legend()
    guardar(plt, fig, carpeta, "fases_jefe")


if __name__ == "__main__":
    main()
