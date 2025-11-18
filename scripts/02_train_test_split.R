source("scripts/00_load_packages.R")
library(caret)

df <- readRDS("data_processed/df_clean.rds")

set.seed(2020)

train_index <- createDataPartition(df$final_grade, p = 0.8, list = FALSE)

df_train <- df[train_index, ]
df_test  <- df[-train_index, ]

attr(df_train, "na.action")
attr(df_test,  "na.action")

saveRDS(df_train, "data_processed/df_train.rds")
saveRDS(df_test,  "data_processed/df_test.rds")
