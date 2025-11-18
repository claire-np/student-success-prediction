# SCRIPT 05: BUSINESS INSIGHTS

# Load packages
source("scripts/00_load_packages.R")

# Load model & prediction data
df_train <- readRDS("data_processed/df_train.rds")
df_test  <- readRDS("data_processed/df_test.rds")
rf_model <- readRDS("results/models/rf_model.rds")
metrics  <- readRDS("results/tables/metrics.rds")

# Create prediction table if not already saved
if (file.exists("results/tables/prediction_table.rds")) {
  df_pred <- readRDS("results/tables/prediction_table.rds")
} else {
  df_pred <- df_test %>%
    mutate(
      pred      = predict(rf_model, df_test),
      error     = final_grade - pred,
      abs_error = abs(error)
    )
}

# Output folders
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/docs",   recursive = TRUE, showWarnings = FALSE)

# Global metrics table
metrics_tbl <- tibble(
  metric = c("RMSE", "R2", "MAE"),
  value  = c(
    as.numeric(metrics["RMSE"]),
    as.numeric(metrics["Rsquared"]),
    as.numeric(metrics["MAE"])
  )
)
saveRDS(metrics_tbl, "results/tables/metrics_table.rds")


# -----------------------------
# Subject-level performance
# -----------------------------
subject_perf <- df_pred %>%
  group_by(subject) %>%
  summarise(
    n_students   = n(),
    avg_actual   = mean(final_grade),
    avg_pred     = mean(pred),
    rmse_subject = RMSE(pred, final_grade),
    mae_subject  = MAE(pred, final_grade)
  ) %>%
  arrange(desc(avg_actual))

saveRDS(subject_perf, "results/tables/subject_performance.rds")


# -----------------------------
# Enrollment reason performance
# -----------------------------
reason_perf <- df_pred %>%
  group_by(enrollment_reason) %>%
  summarise(
    n_students  = n(),
    avg_actual  = mean(final_grade),
    avg_pred    = mean(pred),
    rmse_reason = RMSE(pred, final_grade),
    mae_reason  = MAE(pred, final_grade)
  ) %>%
  arrange(desc(avg_actual))

saveRDS(reason_perf, "results/tables/enrollment_reason_performance.rds")


# -----------------------------
# Motivation & engagement segments
# -----------------------------
df_segments <- df_pred %>%
  mutate(
    motivation_band = ntile(motivation_score, 3),
    engagement_band = ntile(engagement_ratio, 3)
  )

segment_perf <- df_segments %>%
  group_by(motivation_band, engagement_band) %>%
  summarise(
    n_students   = n(),
    avg_actual   = mean(final_grade),
    avg_pred     = mean(pred),
    rmse_segment = RMSE(pred, final_grade),
    mae_segment  = MAE(pred, final_grade)
  )

saveRDS(segment_perf, "results/tables/segment_performance.rds")


# -----------------------------
# At-risk student identification
# -----------------------------
risk_threshold <- 70

at_risk <- df_pred %>%
  filter(pred < risk_threshold) %>%
  arrange(pred) %>%
  select(
    final_grade, pred, error, abs_error,
    subject, semester, enrollment_reason,
    motivation_score, engagement_ratio, emotion_balance, n
  )

saveRDS(at_risk, "results/tables/at_risk_students.rds")


# -----------------------------
# Executive summary (Markdown)
# -----------------------------
summary_path <- "results/docs/executive_summary.md"

summary_md <- c(
  "# Student Success Prediction – Executive Summary",
  "",
  "This report summarizes learning patterns, subject differences,",
  "and early-warning insights for online middle-school science courses.",
  "",
  "## Key Findings",
  paste0("- RMSE: **", round(as.numeric(metrics['RMSE']), 2), "**"),
  paste0("- R²: **", round(as.numeric(metrics['Rsquared']), 3), "**"),
  paste0("- MAE: **", round(as.numeric(metrics['MAE']), 2), "**"),
  "",
  "### Subject Patterns",
  "- Strong variation across subjects (see subject_performance.rds).",
  "- FrScA and BioA show higher accuracy; PhysA and AnPhA show more variability.",
  "",
  "### Enrollment Reason",
  "- Logistic/contextual factors influence performance (see enrollment_reason_performance.rds).",
  "",
  "### Behavioral Segments",
  "- High-motivation × high-engagement students consistently outperform.",
  "- Low-motivation × low-engagement is the most at-risk group.",
  "",
  "### Early Warning",
  paste0("- Students predicted < ", risk_threshold, " saved in at_risk_students.rds."),
  "",
  "## Use Cases",
  "- Teacher dashboards for early support",
  "- Curriculum review by subject",
  "- Intervention targeting low-engagement learners",
  "",
  "## Next Steps",
  "- Extend modeling to XGBoost & Gradient Boosting",
  "- Deploy full Shiny dashboard",
  "- Integrate longitudinal learning data for improved prediction"
)

writeLines(summary_md, summary_path)
