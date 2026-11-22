"""
Validación de los generadores del taller anterior (pseudo_gen) con los parámetros usados en Cuarentena.

Ejecutar:  python modelos/apellido1_apellido2_validar_prng.py [--mostrar]

Para cada generador se generan N = 10 000 números y se aplican las 5 pruebas de la librería
(medias, varianza, chi-cuadrado, Kolmogorov-Smirnov, póker) con α = 0.05.

Asignación de generadores a modelos:
    Congruencial lineal (2^32)  -> Modelo 1 (caminatas) y Modelo 4 (agentes) y Modelo 5 (sensibilidad SIR)
    Multiplicativo MINSTD       -> Modelo 2 (cola M/M/c)
    Aditivo (Fibonacci 24/55)   -> Modelo 3 (Monte Carlo)
"""
from apellido1_apellido2_utilidades import (aditivo, carpeta_resultados, encabezado, gnp, lcg,
                                            matplotlib_sin_ventana, minstd)

N = 10_000
SEMILLA = 12345


def main():
    encabezado("Validación de generadores pseudoaleatorios (taller anterior)", "LCG, MINSTD, Aditivo",
               f"N = {N} números por generador, semilla = {SEMILLA}, α = 0.05")
    carpeta = carpeta_resultados("prng")
    from pseudo_gen.utilidades import Visualizacion
    matplotlib_sin_ventana()
    generadores = [("Congruencial lineal a=1664525 c=1013904223 m=2^32", "lcg", lcg(SEMILLA)),
                   ("Multiplicativo MINSTD a=16807 m=2^31-1", "minstd", minstd(SEMILLA)),
                   ("Aditivo x_n=(x_n-24 + x_n-55) mod 2^32", "aditivo", aditivo(SEMILLA))]
    todas = True
    for nombre, clave, gen in generadores:
        _, ri = gen.generar(N)
        pruebas = [gnp.PruebaMedias(ri).ejecutar(), gnp.PruebaVarianza(ri).ejecutar(),
                   gnp.PruebaChi2(ri, k_intervalos=10).ejecutar(), gnp.PruebaKS(ri).ejecutar(),
                   gnp.PruebaPoker(ri).ejecutar()]
        print(f"\n{nombre}")
        print(f"  {'Prueba':<34}{'Estadístico':>14}{'Referencia':>14}  Resultado")
        for p in pruebas:
            ref = p.valor_critico if p.valor_critico is not None else float("nan")
            print(f"  {p.nombre:<34}{p.estadistico:>14.5f}{ref:>14.5f}  {'APROBADA' if p.aprobada else 'RECHAZADA'}")
            todas = todas and p.aprobada
        Visualizacion.histograma_generacion(ri, titulo=nombre, guardar_en=str(carpeta / f"{clave}_histograma.png"),
                                            mostrar=False)
        Visualizacion.prueba_chi2(pruebas[2], guardar_en=str(carpeta / f"{clave}_chi2.png"), mostrar=False)
        Visualizacion.prueba_ks(pruebas[3], guardar_en=str(carpeta / f"{clave}_ks.png"), mostrar=False)
        Visualizacion.prueba_poker(pruebas[4], guardar_en=str(carpeta / f"{clave}_poker.png"), mostrar=False)
    print(f"\nConclusión: {'los 3 generadores aprueban las 5 pruebas' if todas else 'algún generador NO aprueba'}"
          f" (gráficos en {carpeta}).")


if __name__ == "__main__":
    main()
