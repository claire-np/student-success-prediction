# 08_model_comparison.R
# Combine metrics from all models for comparison

source("scripts/00_load_packages.R")

rf_metrics        <- readRDS("results/tables/metrics.rds")
gbm_metrics       <- readRDS("results/tables/gbm_metrics.rds")
xgb_std_metrics   <- readRDS("results/tables/xgb_std_metrics.rds")
xgb_tuned_metrics <- readRDS("results/tables/xgb_tuned_metrics.rds")

model_comparison <- tibble(
  model = c(
    "Random Forest",
    "Gradient Boosting (GBM)",
    "XGBoost - Standard",
    "XGBoost - Tuned"
  ),
  
  RMSE = c(
    rf_metrics["RMSE"],
    gbm_metrics["RMSE"],
    xgb_std_metrics["RMSE"],
    xgb_tuned_metrics["RMSE"]
  ),
  
  R2 = c(
    rf_metrics["Rsquared"],
    gbm_metrics["Rsquared"],
    xgb_std_metrics["Rsquared"],
    xgb_tuned_metrics["Rsquared"]
  ),
  
  MAE = c(
    rf_metrics["MAE"],
    gbm_metrics["MAE"],
    xgb_std_metrics["MAE"],
    xgb_tuned_metrics["MAE"]
  )
) %>% 
  arrange(RMSE)

dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
saveRDS(model_comparison, "results/tables/model_comparison.rds")
