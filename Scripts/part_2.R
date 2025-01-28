# Working libraries -------------------------------------------------------

library(blsAPI) # Official API
library(readxl)
library(dplyr)
library(tsibble) # time series
library(lubridate) # work with dates
library(tidyr)
library(imputeTS)
library(ggplot2)
library(ggthemes)
library(tseries) # ADF and KPSS tests
library(igraph)
library(corrr)
library(huge)


# Working directory -------------------------------------------------------

setwd('C:/Users/Julian/Desktop/Cursos/Fisica/Econofísica/WorkBench')
getwd()
list.files()

# Get data ----------------------------------------------------------------

r <- read.csv("Correlation_matrix.csv",row.names = 1)
ts <- read.csv('ts_df_wide.csv', row.names = 1)
df <- read.csv("ts_dataframe.csv")

dim(r) #(177,177)
dim(ts) # (143,177)

# Labels

group_df <- df %>%
  group_by(seriesID) %>%
  summarize(Name_group = unique(Name_group), .groups = 'drop')
dim(group_df)


# graph with threshold ----------------------------------------------------

# Create graph an adjacency matrix an set threshold

# ts_df_wide_corr <- read.csv('Correlation_matrix.csv', row.names = 1)

threshold1 <- 0.36  # set Threshold
threshold2 <- 0.5 
adj_matrix01 <- ifelse(abs(r) >= threshold1, 1, 0)
adj_matrix02 <- ifelse(abs(r) >= threshold2, 1, 0)


g01 <- graph_from_adjacency_matrix(adj_matrix01, mode = "undirected", diag = FALSE)
g02 <- graph_from_adjacency_matrix(adj_matrix02, mode = "undirected", diag = FALSE)


windows()

groups_l <- group_df$Name_group 

V(g01)$group <- groups_l
V(g02)$group <- groups_l

unique_groups <- unique(V(g01)$group)

library(viridis)
colors <- viridis(length(unique_groups)) 
vertex_colors <- colors[as.numeric(factor(V(g01)$group))]

windows()
set.seed(123)
# Configuración para reducir la distancia entre los gráficos
par(mfrow = c(1, 2), oma = c(0, 0, 0, 7), mar = c(5, 4, 4, 1))  # Ajusta los márgenes internos

# Gráfico 1
plot(g01, vertex.label = NA, vertex.size = 4, vertex.color = vertex_colors,
     main = 'Threshold = 0.36')

# Gráfico 2
par(mar = c(5, 1, 4, 2))  # Reduce el margen izquierdo del segundo gráfico
plot(g02, vertex.label = NA, vertex.size = 4, vertex.color = vertex_colors,
     main = 'Threshold = 0.5')

# Dibuja la leyenda en el margen derecho
par(fig = c(0, 1, 0, 1), new = TRUE, oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0))

legend("topright",                       # Posición en el margen derecho
       legend = unique_groups,        # Etiquetas de la leyenda
       fill = colors,                 # Colores de la leyenda
       title = "Groups",               # Título de la leyenda
       xpd = TRUE,                    # Permite que la leyenda se dibuje fuera del área de gráficos
       inset = c(-.05, 0),           # Ajusta la posición de la leyenda hacia adentro del margen
       bty = "n",                     # Elimina el borde de la leyenda para evitar recortes
       cex = 1)                     # Ajusta el tamaño de la leyenda

ecount(g01) # 388
vcount(g01) # 177


# Copulas gaussianas ------------------------------------------------------

# Trasnformación a una cópula gaussiana

# Aplicar la transformación de rangos a cada columna, así buscamos que esten
# uniformemente distribuidos en el intervalo [0,1]


ts_df_rank <- apply(ts, 2, rank) / (nrow(ts) + 1)

# Transformar los datos al espacio gaussiano utilizando la función inversa de la normal estándar
ts_df_gaussian <- qnorm(ts_df_rank)


# Inferencia del Grafo usando un Modelo Gráfico Gaussiano:

# Convertir los datos transformados a una matriz
ma_gaussian <- as.matrix(ts_df_gaussian)

# Inferir la red utilizando Lasso (glasso)
set.seed(123)
huge.out <- huge(ma_gaussian, method = "glasso")

# Seleccionar el modelo óptimo usando el criterio de estabilidad
huge.opt <- huge.select(huge.out, criterion= "stars", stars.thresh = .05)

# Crear el grafo a partir de la matriz de adyacencia resultante
g_copula_gaus <- graph_from_adjacency_matrix(huge.opt$refit, "undirected")

ecount(g_copula_gaus) # 384

# Visualización

V(g_copula_gaus)$group <- groups_l

vertex_colors <- colors[as.numeric(factor(V(g_copula_gaus)$group))]

windows()
set.seed(123)

plot(g_copula_gaus, 
     vertex.color = vertex_colors,  # Asignar colores a los nodos
     vertex.size = 5,               # Tamaño de los nodos
     vertex.label = NA,             # Sin etiquetas en los nodos
     edge.width = E(g_copula_gaus)$weight * 4,
     #edge.color = '#474747',layout = layout_fr,
     main = "Semiparametric Gaussian copula graphical models")  # Título del gráfico

legend("topright",                   # Posición de la leyenda
       legend = unique_groups,       # Etiquetas de la leyenda
       fill = colors,                # Colores de la leyenda
       title = "Group")              # Título de la leyenda

save(g_copula_gaus, file = "g_copula_gaus.RData")

# Para cargarlo
# load("g_copula_gaus.RData")


# Exploración de datos ----------------------------------------------------

ecount(g_copula_gaus) # 384
vcount(g_copula_gaus) # 177
