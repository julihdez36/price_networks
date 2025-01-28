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


# Working directory -------------------------------------------------------

setwd('C:/Users/Julian/Desktop/Cursos/Fisica/Econofísica/WorkBench')
getwd()
list.files()

# Get data ----------------------------------------------------------------

api_key <- readline(prompt = "API Key: ")


# Function to download data from API

item_list <- read_excel("item-list.xlsx")

get_bls_data <- function(series_ids, api_key, startyear = 2012, endyear = 2023) {
  payload <- list(
    'seriesid' = series_ids,
    'startyear' = startyear,
    'endyear' = endyear,
    'catalog' = FALSE,
    'calculations' = FALSE,
    'annualaverage' = FALSE,
    'registrationKey' = api_key
  )
  return(blsAPI(payload = payload, api_version = 2, return_data_frame = TRUE))
}

# Split the data into batches of 50 records. API rate limits.

batch_size <- 50
series_batches <- split(item_list$item_code, ceiling(seq_along(item_list$item_code) / batch_size))

# Query the API for each batch

dfs <- lapply(series_batches, get_bls_data, api_key = api_key)

# Merge all df into one
df <- bind_rows(dfs)

dim(df) # (26089,5)
length(table(df$seriesID))

# Data cleansing ----------------------------------------------------------

# Checking data consistency

sum(!levels(as.factor(df$seriesID)) %in% item_list$item_code) # 0

table(df$year) # different records by years, why?

# Missing values

sum(is.na(df)) # 0 NA

freq_table <- table(df$seriesID)
filtered_values <- freq_table[freq_table < 144]

sum(-filtered_values +144) #119 records doesn't appear
length(filtered_values) # 9 items have less records

# Let's remove the items with incomplete information 

items_toremove <- names(freq_table[freq_table < 138]) #removing 5 items
df <- df[!(df$seriesID %in% items_toremove),] 
dim(df) # from 26089 to 25484 records

# Change data type: convert it into time series

df$date <-parse_date_time(paste(df$year, df$periodName, "01"), 
                          orders = "ymd")

df$date <- as.Date(df$date)
df$seriesID <- as.factor(df$seriesID)
df$value <- as.numeric(df$value)

# Remove useless columns
df <- df %>%  select(-year,-period,-periodName)

# Creating a tsibble

ts_df <- as_tsibble(df, index = date, key = seriesID)
length(levels(ts_df$seriesID)) # 177 items

ts_df

# Completing tstibble (interpolation imputation)

ts_df <- ts_df %>%
  complete(seriesID, date = seq(min(date), max(date), by = "month"))

sum(!complete.cases(ts_df)) # 4 NA

ts_df$value <- na_interpolation(ts_df$value)

# add columns

colnames(item_list)
ts_df <- ts_df %>% 
  left_join(item_list %>% select(item_code, Group, Name_group), by = c("seriesID" = "item_code"))

ts_df <- ts_df %>%
  mutate(across(c(Group, Name_group), as.factor))

levels(ts_df$Name_group) # 8 groups

# data loading ------------------------------------------------------------

write.csv(df,file = 'df_base.csv')
write.csv(ts_df,file = 'ts_dataframe.csv') # complete

# stationarity condition --------------------------------------------------
# This avoids spurious correlations

# logarithmic difference

ts_df_diff <- ts_df %>%
  group_by(seriesID) %>%
  mutate(diff_log_value = log(value) - lag(log(value))) %>%
  filter(!is.na(diff_log_value)) %>%
  ungroup()

# Let's summarize the results for the ADF and KPSS tests

stationary_counts <- adf_kpss_test_results %>%
  summarise(
    ADF_Estacionaria = sum(adf_stationary == "Estacionaria (ADF)"),
    ADF_No_Estacionaria = sum(adf_stationary == "No Estacionaria (ADF)"),
    KPSS_Estacionaria = sum(kpss_stationary == "Estacionaria (KPSS)"),
    KPSS_No_Estacionaria = sum(kpss_stationary == "No Estacionaria (KPSS)")
  ) %>%
  pivot_longer(cols = everything(), names_to = "Prueba", values_to = "count") %>%
  separate(Prueba, into = c("Test", "Estacionariedad"), sep = "_")

stationary_counts

# ADF and KPSS tests results 

windows()
ggplot(stationary_counts, aes(x = Test, y = count, fill = Estacionariedad)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Resultados de pruebas ADF y KPSS de raíz unitaria",
       x = "Tipo de Prueba",
       y = "Número de Series",
       fill = "Estacionariedad",  # Cambia el título de la leyenda de 'fill'
       subtitle = 'Ajuste Benjamini-Hochberg para control de FDR') +
  theme_light()+scale_fill_grey()

# Correlation graph -------------------------------------------------------

# Basic correlation

# Change format

ts_df_wide <- ts_df_diff %>%
  select(date, seriesID, diff_log_value) %>%
  pivot_wider(names_from = seriesID, values_from = diff_log_value)

# Correlation matrix

r <- cor(ts_df_wide[,2:178])
windows()
heatmap(r, main = 'Matriz de correlación') 

# Load r ----------------------------------------------------------------

# write.csv(r,file = 'Correlation_matrix.csv')
# write.csv(ts_df_wide,file = 'ts_df_wide.csv', row.names = FALSE)

