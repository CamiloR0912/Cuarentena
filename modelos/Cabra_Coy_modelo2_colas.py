"""
MODELO 2 — Sistema de colas M/M/c del Hospital San Rafael (triaje).

Ejecutar:  python modelos/apellido1_apellido2_modelo2_colas.py [--mostrar]

Tipología: simulación de eventos discretos.
PRNG: congruencial multiplicativo MINSTD del taller anterior (a=16807, m=2^31-1),
      con la transformación exponencial de la librería (transformada inversa).

Modelo:
    Llegadas Poisson de tasa λ (tiempos entre llegadas ~ Exp(λ)), c camillas (servidores) en paralelo,
    tiempos de servicio ~ Exp(μ), disciplina FIFO, capacidad infinita.
    Extensión del juego (no se usa en la validación): si un paciente espera más de T_pac abandona la cola
    y regresa a la calle como infectado (+1 a I en el modelo SIR).

Ecuaciones (a = λ/μ, ρ = a/c < 1):
    P0 = [ Σ_{n=0}^{c-1} a^n/n!  +  a^c / (c!(1-ρ)) ]^{-1}
    P_espera (Erlang C) = a^c P0 / (c!(1-ρ))
    Lq = P0 a^c ρ / (c!(1-ρ)^2),   Wq = Lq/λ,   W = Wq + 1/μ,   L = λW

Configuraciones (GDD §16.2), 30 réplicas de 10 000 minutos cada una:
    1) λ=0.8, μ=1, c=1  -> Wq = 4.000, Lq = 3.200
    2) λ=1.5, μ=1, c=2  -> Wq = 1.286, Lq = 1.929
    3) λ=2.0, μ=1, c=3  -> Wq = 0.444, Lq = 0.889
"""
import heapq
import math

from apellido1_apellido2_utilidades import (carpeta_resultados, encabezado, exponencial, guardar, ic95_media,
                                            matplotlib_sin_ventana, minstd, tabla_validacion)

T_FIN = 10_000.0
REPLICAS = 30
SEMILLA = 12345


def teoria_mmc(lam, mu, c):
    """Medidas analíticas del M/M/c (Erlang C). Requiere ρ < 1."""
    a = lam / mu
    rho = a / c
    if rho >= 1:
        return {"rho": rho, "P0": 0.0, "Pw": 1.0, "Lq": math.inf, "Wq": math.inf, "W": math.inf, "L": math.inf}
    suma = sum(a ** n / math.factorial(n) for n in range(c))
    cola = a ** c / (math.factorial(c) * (1 - rho))
    p0 = 1.0 / (suma + cola)
    lq = p0 * a ** c * rho / (math.factorial(c) * (1 - rho) ** 2)
    wq = lq / lam
    w = wq + 1 / mu
    return {"rho": rho, "P0": p0, "Pw": cola * p0, "Lq": lq, "Wq": wq, "W": w, "L": lam * w}


class ColaMMc:
    """
    Simulación de eventos discretos del M/M/c.
    paciencia: tiempo máximo de espera (None = sin abandonos, M/M/c puro).
    Registra Lq y ocupación promediados en el tiempo, esperas y tiempos en el sistema.
    """

    def __init__(self, gen, lam, mu, c, paciencia=None):
        self.gen, self.lam, self.mu, self.c, self.paciencia = gen, lam, mu, c, paciencia

    def simular(self, t_fin, traza_hasta=0.0):
        eventos = []  # (tiempo, orden, tipo, id_paciente)
        orden = 0

        def programar(t, tipo, pid=None):
            nonlocal orden
            heapq.heappush(eventos, (t, orden, tipo, pid))
            orden += 1

        reloj, ocupados = 0.0, 0
        cola = []  # (id, t_llegada)
        en_cola = set()
        siguiente_id = 0
        area_lq = area_ocup = 0.0
        t_ultimo = 0.0
        esperas, sistema, abandonos, atendidos = [], [], 0, 0
        llegada_de = {}
        traza = [(0.0, 0)]
        programar(exponencial(self.gen, self.lam), "llegada")
        while eventos:
            t, _, tipo, pid = heapq.heappop(eventos)
            if t > t_fin:
                break
            area_lq += len(cola) * (t - t_ultimo)
            area_ocup += ocupados * (t - t_ultimo)
            t_ultimo = reloj = t
            if tipo == "llegada":
                programar(reloj + exponencial(self.gen, self.lam), "llegada")
                pid = siguiente_id
                siguiente_id += 1
                llegada_de[pid] = reloj
                if ocupados < self.c:
                    ocupados += 1
                    esperas.append(0.0)
                    programar(reloj + exponencial(self.gen, self.mu), "salida", pid)
                else:
                    cola.append(pid)
                    en_cola.add(pid)
                    if self.paciencia is not None:
                        programar(reloj + self.paciencia, "abandono", pid)
            elif tipo == "salida":
                atendidos += 1
                sistema.append(reloj - llegada_de.pop(pid))
                while cola and cola[0] not in en_cola:  # descarta los que ya abandonaron
                    cola.pop(0)
                if cola:
                    nxt = cola.pop(0)
                    en_cola.discard(nxt)
                    esperas.append(reloj - llegada_de[nxt])
                    programar(reloj + exponencial(self.gen, self.mu), "salida", nxt)
                else:
                    ocupados -= 1
            elif tipo == "abandono" and pid in en_cola:
                en_cola.discard(pid)
                cola.remove(pid)
                llegada_de.pop(pid)
                abandonos += 1
            if reloj <= traza_hasta:
                traza.append((reloj, len(en_cola)))
        area_lq += len(en_cola) * (t_fin - t_ultimo)
        area_ocup += ocupados * (t_fin - t_ultimo)
        return {"Lq": area_lq / t_fin, "rho": area_ocup / (t_fin * self.c), "Wq": sum(esperas) / len(esperas),
                "W": sum(sistema) / len(sistema), "abandonos": abandonos, "atendidos": atendidos,
                "esperas": esperas, "traza": traza}


def replicar(gen, lam, mu, c, replicas=REPLICAS, paciencia=None):
    res = [ColaMMc(gen, lam, mu, c, paciencia).simular(T_FIN, traza_hasta=200.0) for _ in range(replicas)]
    return res


def main():
    encabezado("MODELO 2 — Cola M/M/c del hospital (eventos discretos)", "Multiplicativo MINSTD a=16807 m=2^31-1 "
               "+ Exp(λ) por transformada inversa", f"{REPLICAS} réplicas × {T_FIN:.0f} min, semilla = {SEMILLA}")
    carpeta = carpeta_resultados("modelo2_colas")
    gen = minstd(SEMILLA)
    configs = [(1, 0.8, 1.0, 1), (2, 1.5, 1.0, 2), (3, 2.0, 1.0, 3)]
    filas, resultados = [], {}
    for k, lam, mu, c in configs:
        teo = teoria_mmc(lam, mu, c)
        res = replicar(gen, lam, mu, c)
        resultados[k] = res
        wq, wq_a, wq_b = ic95_media([r["Wq"] for r in res])
        lq = sum(r["Lq"] for r in res) / len(res)
        rho = sum(r["rho"] for r in res) / len(res)
        w = sum(r["W"] for r in res) / len(res)
        print(f"\nConfig {k}: λ={lam}, μ={mu}, c={c}")
        print(f"   {'':<6}{'ρ':>9}{'Lq':>9}{'Wq':>9}{'W':>9}")
        print(f"   {'Teo.':<6}{teo['rho']:>9.3f}{teo['Lq']:>9.3f}{teo['Wq']:>9.3f}{teo['W']:>9.3f}")
        print(f"   {'Sim.':<6}{rho:>9.3f}{lq:>9.3f}{wq:>9.3f}{w:>9.3f}   IC95 Wq [{wq_a:.3f}, {wq_b:.3f}]")
        par = f"lambda={lam}, mu={mu}, c={c}"
        filas += [{"config": k, "parametros": par, "medida": "Wq (min)", "teorico": teo["Wq"], "obtenido": wq},
                  {"config": k, "parametros": par, "medida": "Lq", "teorico": teo["Lq"], "obtenido": lq},
                  {"config": k, "parametros": par, "medida": "rho", "teorico": teo["rho"], "obtenido": rho}]
    tabla_validacion(filas, carpeta)

    # Extensión del juego: abandonos por paciencia (T_pac = 5 min) con 1 sola camilla y λ = 0.8
    ext = ColaMMc(gen, 0.8, 1.0, 1, paciencia=5.0).simular(T_FIN)
    total = ext["atendidos"] + ext["abandonos"]
    print(f"\nExtensión (juego): λ=0.8, μ=1, c=1, T_pac=5 min -> abandonan {ext['abandonos']} de {total} pacientes "
          f"({100 * ext['abandonos'] / total:.1f} %), cada abandono suma +1 a I en el SIR. Wq = {ext['Wq']:.3f} min.")

    plt = matplotlib_sin_ventana()
    lam, mu = 2.0, 1.0
    cs = list(range(3, 8))
    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.plot(cs, [teoria_mmc(lam, mu, c)["Wq"] for c in cs], "o-", label="Wq teórico (Erlang C)")
    sims = [ic95_media([r["Wq"] for r in replicar(gen, lam, mu, c, replicas=5)]) for c in cs]
    ax.errorbar(cs, [s[0] for s in sims], yerr=[[s[0] - s[1] for s in sims], [s[2] - s[0] for s in sims]],
                fmt="s", capsize=4, label="Wq simulado (IC 95 %)")
    ax.set(xlabel="c (camillas abiertas)", ylabel="Wq (min)", title="Modelo 2: espera en cola vs camillas (λ = 2, μ = 1)")
    ax.set_xticks(cs)
    ax.legend()
    guardar(plt, fig, carpeta, "wq_vs_c")

    fig, ax = plt.subplots(figsize=(8, 4.2))
    for k in (1, 2, 3):
        tr = resultados[k][0]["traza"]
        ax.step([p[0] for p in tr], [p[1] for p in tr], where="post", lw=0.9, label=f"Config {k}")
    ax.set(xlabel="Tiempo (min)", ylabel="Pacientes en cola", title="Modelo 2: longitud de la cola en el tiempo (primeros 200 min)")
    ax.legend()
    guardar(plt, fig, carpeta, "cola_en_el_tiempo")

    fig, ax = plt.subplots(figsize=(7, 4.5))
    esperas = [e for e in resultados[1][0]["esperas"] if e > 0]
    ax.hist(esperas, bins=60, density=True, alpha=0.7, label="Esperas > 0 simuladas (config 1)")
    teo = teoria_mmc(0.8, 1.0, 1)
    tasa = 1.0 * 1 - 0.8  # en M/M/1 la espera condicionada a esperar es Exp(cμ − λ)
    xs = [i * 0.25 for i in range(int(max(esperas) / 0.25))]
    ax.plot(xs, [tasa * math.exp(-tasa * x) for x in xs], "r--", label="Teórico Exp(cμ − λ)")
    ax.set(xlabel="Tiempo de espera (min)", ylabel="Densidad",
           title=f"Modelo 2: distribución de la espera (P_espera teórica = {teo['Pw']:.2f})")
    ax.legend()
    guardar(plt, fig, carpeta, "distribucion_espera")


if __name__ == "__main__":
    main()
