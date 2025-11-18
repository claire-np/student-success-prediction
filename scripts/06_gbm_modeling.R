cat("---- SCRIPT 06: GBM MODELING START ----\n")

# Load packages
source("scripts/00_load_packages.R")

# Load training/testing data
df_train <- readRDS("data_processed/df_train.rds")
df_test  <- readRDS("data_processed/df_test.rds")

cat("Train size:", nrow(df_train), "| Test size:", nrow(df_test), "\n")

# Set seed for reproducibility
set.seed(2025)

cat("Training Gradient Boosting (GBM) model...\n")

gbm_model <- caret::train(
  final_grade ~ .,
  data = df_train,
  method = "gbm",
  trControl = caret::trainControl(
    method = "repeatedcv",
    number = 10,
    repeats = 5,
    verboseIter = FALSE
  ),
  verbose = FALSE
)

cat("GBM training complete.\n")
print(gbm_model)

# Make predictions on test set
cat("Generating predictions...\n")
df_test$pred_gbm <- predict(gbm_model, df_test)

# Compute metrics
cat("Computing metrics...\n")

gbm_metrics <- caret::defaultSummary(data.frame(
  obs  = df_test$final_grade,
  pred = df_test$pred_gbm
))

cat("GBM Metrics:",
    "RMSE =", gbm_metrics["RMSE"],
    "| R² =", gbm_metrics["Rsquared"],
    "| MAE =", gbm_metrics["MAE"], "\n")

# Ensure directories exist
if (!dir.exists("results/models")) { dir.create("results/models", recursive = TRUE) }
if (!dir.exists("results/tables")) { dir.create("results/tables", recursive = TRUE) }

# Save model & metrics
cat("Saving model and metrics...\n")
saveRDS(gbm_model,   "results/models/06_gbm_modeling.rds")
saveRDS(gbm_metrics, "results/tables/06_gbm_modeling.rds")

cat("---- SCRIPT 06: GBM MODELING COMPLETE ----\n")
