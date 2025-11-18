cat("---- SCRIPT 04 START ----\n")

# 1. Set working directory
proj_path <- rstudioapi::getActiveProject()
setwd(proj_path)
cat("Working directory:", getwd(), "\n\n")

# 2. Load packages
cat("Loading packages...\n")
library(tidyverse)
library(caret)
library(vip)            # Variable importance plots
library(ggplot2)

# 3. Load model + data
cat("Loading data and model...\n")
df_test  <- readRDS("data_processed/df_test.rds")
rf_model <- readRDS("results/models/rf_model.rds")
metrics  <- readRDS("results/tables/metrics.rds")

cat("Data & model loaded.\n\n")

# Create output directories
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)

# ============================================================
# 4. Feature Importance Plot
# ============================================================

cat("Computing feature importance...\n")

imp <- vip::vi(rf_model$finalModel)  # extract importance

p_imp <- vip::vip(rf_model, geom = "col") +
  ggtitle("Feature Importance (Random Forest)") +
  theme_minimal()

ggsave("results/figures/feature_importance.png", p_imp, width = 8, height = 5)

cat("Feature importance saved.\n")

# ============================================================
# 5. Predictions table + error calculation
# ============================================================

cat("Generating predictions & error table...\n")

df_pred <- df_test %>%
  mutate(
    pred = predict(rf_model, df_test),
    error = final_grade - pred,
    abs_error = abs(error)
  )

saveRDS(df_pred, "results/tables/prediction_table.rds")

cat("Prediction table saved.\n")

# ============================================================
# 6. Plot: Predictions vs Actual
# ============================================================

p_pred <- ggplot(df_pred, aes(x = final_grade, y = pred)) +
  geom_point(alpha = 0.6, color = "#0072B2") +
  geom_abline(color = "red", linetype = "dashed") +
  theme_minimal() +
  labs(
    title = "Predicted vs Actual Final Grades",
    x = "Actual Grade",
    y = "Predicted Grade"
  )

ggsave("results/figures/pred_vs_actual.png", p_pred, width = 7, height = 5)

cat("Pred vs Actual plot saved.\n")

# ============================================================
# 7. Error Distribution
# ============================================================

p_err <- ggplot(df_pred, aes(x = error)) +
  geom_histogram(fill = "#E69F00", bins = 20, alpha = 0.8) +
  theme_minimal() +
  labs(
    title = "Error Distribution (Actual - Predicted)",
    x = "Prediction Error",
    y = "Count"
  )

ggsave("results/figures/error_distribution.png", p_err, width = 7, height = 5)

cat("Error distribution saved.\n")

# ============================================================
# 8. Save error table separately
# ============================================================

top_errors <- df_pred %>%
  arrange(desc(abs_error))

saveRDS(top_errors, "results/tables/error_table.rds")

cat("Error table saved.\n")

cat("---- SCRIPT 04 COMPLETE ----\n")
