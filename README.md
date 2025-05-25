# Semiparametric approache to infer topological properties in complex price networks

## Abstract
 
The problem of estimating the structure of the price system in an economy using complex networks is considered. To this end, the set of prices is represented as a vector $p \in \mathbb{R}^{l}$ defined over a finite Euclidean space of $l$ available commodities, on which a graph $G = (V, E)$ is induced. Here, the set of edges $E$ describes the *conditional dependence* relationships between pairs of vertices $(p_{i}, p_{j}) \in V^{2}$. Since the joint distribution of the data does not exhibit normality, a semiparametric extension of Gaussian Graphical Models (GGMs) is employed, based on Gaussian copulas and known as the *nonparanormal SKEPTIC*. To address high dimensionality and obtain *sparse* inference, the Graphical Lasso (GLasso) estimator is used. The methodology is applied to U.S. Consumer Price Index (CPI) data, covering the time window from 2012 to 2023. The implementation is carried out in R software, using the `igraph` and `huge` packages.  

## Keywords:

Complex networks, Price system, Gaussian Graphical Models (GGMs), Nonparanormal SKEPTIC, Graphical Lasso (GLasso), Consumer Price Index (CPI)

--- 

## Resumen 

Se considera el problema de estimación de la estructura del sistema de precios en una economía mediante el uso de redes complejas. Para ello, se representa el conjunto de precios como un vector $p \in \mathbb{R}^{l}$ definido sobre un espacio euclídeo finito de $l$ mercancias disponibles, sobre el que se induce un grafo $G = (V, E)$ donde el conjunto de aristas $E$ describe las relaciones de *dependencia condicional* entre pares de vértices $(p_{i}, p_{j}) \in V^{2}$. Dado que la distribución conjunta de los datos no exhibe normalidad, se emplea una extensión semiparamétrica de los Modelos Gráficos Gaussianos (GGMs), basada en cópulas gaussianas y conocida como *nonparanormal SKEPTIC*. Para enfrentar la alta dimensionalidad y obtener una inferencia *sparse*, se utiliza el estimador Graphical Lasso (GLasso). La metodología se aplica a datos del Índice de Precios al Consumo (IPC) de Estados Unidos, en una ventana temporal que abarca el período 2012–2023. La implementación se realiza en el software R, utilizando los paquetes `igraph` y `huge`.

## Palabras claves: 

Redes complejas, Sistema de precios, Modelos Gráficos Gaussianos (GGMs), Nonparanormal SKEPTIC, Graphical Lasso (GLasso), Índice de Precios al Consumo (IPC).

--- 

* Presentación de la investigación en la !(https://www.youtube.com/watch?v=AszdiR5j0jI&list=PL9-E3cL2KgKlW9D-7mOGoVZ0W7Kv6CeLC&index=3&ab_channel=LatinR)[**Conferencia Latinoamericana sobre Uso de R en Investigación + Desarrollo [esp.]**]