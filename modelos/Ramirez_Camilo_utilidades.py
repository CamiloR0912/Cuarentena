"""
Utilidades compartidas por los modelos de simulación de Cuarentena.

- Importa la librería propia de números pseudoaleatorios (pseudo_gen, taller anterior).
- Variables aleatorias que los modelos necesitan y la librería no trae:
  Bernoulli, categórica (transformada inversa discreta) y una normal de un solo valor.
- Encabezado de ejecución (fecha, hora, usuario) y tabla de validación para las capturas del informe.

Ningún módulo usa `random` ni `numpy.random`: toda la aleatoriedad sale de pseudo_gen.
"""
import csv
import datetime
import getpass
import math
import os
import platform
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
if str(RAIZ) not in sys.path:
    sys.path.insert(0, str(RAIZ))

import pseudo_gen as gnp  # noqa: E402  (librería del taller anterior)

RESULTADOS = Path(__file__).resolve().parent / "resultados"


# ── Generadores usados por cada modelo (parámetros con período completo, validados con las 5 pruebas) ──

def lcg(semilla=12345):
    """Congruencial lineal mixto, Numerical Recipes: a=1664525, c=1013904223, m=2^32 (período 2^32)."""
    return gnp.CongruencialLineal(x0=semilla, a=1664525, c=1013904223, m=2**32)


def minstd(semilla=12345):
    """Congruencial multiplicativo MINSTD (Park & Miller): a=16807, m=2^31-1 (período m-1)."""
    return gnp.CongruencialMultiplicativo(x0=semilla, a=16807, m=2**31 - 1)


def aditivo(semilla=12345):
    """Congruencial aditivo (Fibonacci retrasado) x_n = (x_{n-24} + x_{n-55}) mod 2^32, sembrado con el LCG."""
    return gnp.CongruencialAditivo.desde_lcg(x0=semilla, a=1664525, c=1013904223, m_lcg=2**32, j=24, k=55, m=2**32)


# ── Variables aleatorias a partir de R ~ U(0,1) ────────────────────────────────────────────────

def uniforme(gen, a, b):
    """U(a, b) con la transformación de la librería."""
    return gnp.uniforme([gen.siguiente()], a, b)[0]


def exponencial(gen, tasa):
    """Exp(λ) por transformada inversa (librería)."""
    return gnp.exponencial([gen.siguiente()], tasa)[0]


class Normal:
    """N(μ, σ²) por Box-Muller (librería). Box-Muller produce pares: se guarda el segundo valor."""

    def __init__(self, gen):
        self.gen = gen
        self._guardado = None

    def muestra(self, mu, sigma):
        if self._guardado is None:
            z1, z2 = gnp.normal_box_muller([self.gen.siguiente(), self.gen.siguiente()], 0.0, 1.0)
            self._guardado = z2
            return mu + sigma * z1
        z, self._guardado = self._guardado, None
        return mu + sigma * z


def bernoulli(gen, p):
    """Bernoulli(p): 1 si R < p."""
    return 1 if gen.siguiente() < p else 0


def categorica(gen, tabla):
    """
    Transformada inversa discreta.
    tabla: lista de (valor, probabilidad) que suma 1. Devuelve el valor cuyo intervalo acumulado contiene a R.
    """
    u = gen.siguiente()
    acumulada = 0.0
    for valor, p in tabla:
        acumulada += p
        if u < acumulada:
            return valor
    return tabla[-1][0]  # protección por redondeo de la suma


# ── Reporte: encabezado, tabla de validación y archivos ─────────────────────────────────────────

def encabezado(modelo, generador, extra=""):
    """Datos que piden las capturas del taller: fecha, hora, usuario, equipo, modelo y generador."""
    ahora = datetime.datetime.now()
    linea = "=" * 92
    print(linea)
    print(f" {modelo}")
    print(f" Fecha y hora : {ahora:%Y-%m-%d %H:%M:%S}")
    print(f" Usuario      : {getpass.getuser()}   Equipo: {platform.node()}   Python {platform.python_version()}")
    print(f" PRNG         : {generador}")
    if extra:
        print(f" {extra}")
    print(linea)


def diferencia_pct(teorico, obtenido):
    if teorico == 0:
        return abs(obtenido) * 100
    return abs(obtenido - teorico) / abs(teorico) * 100


def tabla_validacion(filas, carpeta, nombre="validacion"):
    """
    filas: lista de dicts con claves config, parametros, medida, teorico, obtenido.
    Imprime la tabla del taller (teórico vs obtenido y diferencia %) y la guarda en CSV.
    """
    print(f"\n{'Config':<7}{'Parámetros':<42}{'Medida':<14}{'Teórico':>12}{'Obtenido':>12}{'Dif. %':>9}")
    print("-" * 96)
    for f in filas:
        f["dif_pct"] = diferencia_pct(f["teorico"], f["obtenido"])
        print(f"{f['config']:<7}{f['parametros']:<42}{f['medida']:<14}{f['teorico']:>12.4f}{f['obtenido']:>12.4f}"
              f"{f['dif_pct']:>8.2f}%")
    carpeta.mkdir(parents=True, exist_ok=True)
    with open(carpeta / f"{nombre}.csv", "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=["config", "parametros", "medida", "teorico", "obtenido", "dif_pct"])
        w.writeheader()
        w.writerows(filas)
    print(f"\nTabla guardada en {carpeta / (nombre + '.csv')}")


def carpeta_resultados(nombre):
    c = RESULTADOS / nombre
    c.mkdir(parents=True, exist_ok=True)
    return c


def matplotlib_sin_ventana():
    """Backend sin ventanas para guardar PNG; si se pasa --mostrar se abren las ventanas."""
    import matplotlib
    if "--mostrar" not in sys.argv:
        matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    plt.rcParams.update({"figure.dpi": 110, "savefig.dpi": 150, "axes.grid": True, "grid.alpha": 0.3})
    return plt


def guardar(plt, fig, carpeta, nombre):
    fig.tight_layout()
    ruta = carpeta / f"{nombre}.png"
    fig.savefig(ruta)
    print(f"Gráfico: {ruta}")
    if "--mostrar" not in sys.argv:
        plt.close(fig)


def media(xs):
    return sum(xs) / len(xs)


def ic95_media(xs):
    """Media e intervalo de confianza del 95 % (aprox. normal)."""
    n = len(xs)
    m = media(xs)
    s = math.sqrt(sum((x - m) ** 2 for x in xs) / (n - 1)) if n > 1 else 0.0
    h = 1.96 * s / math.sqrt(n)
    return m, m - h, m + h
