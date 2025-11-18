# SCRIPT 03: MODELING

# Load packages
source("scripts/00_load_packages.R")

# Load train/test data
df_train <- readRDS("data_processed/df_train.rds")
df_test  <- readRDS("data_processed/df_test.rds")

set.seed(2020)

# Train Random Forest model
rf_model <- train(
  final_grade ~ .,
  data       = df_train,
  method     = "ranger",
  importance = "permutation",
  trControl  = trainControl(method = "cv", number = 5)
)

# Predictions
df_test$pred <- predict(rf_model, df_test)

# Compute metrics
metrics <- defaultSummary(data.frame(
  obs  = df_test$final_grade,
  pred = df_test$pred
))

# Save results
dir.create("results/models", recursive = TRUE, showWarnings = FALSE)
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)

saveRDS(rf_model, "results/models/rf_model.rds")
saveRDS(metrics,  "results/tables/metrics.rds")
