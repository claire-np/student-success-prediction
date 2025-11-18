# 09_insight_engine.R
# Generate insights and visualizations from performance tables

library(tidyverse)
library(ggplot2)

dir.create("results/insights", recursive = TRUE, showWarnings = FALSE)

pred   <- readRDS("results/tables/prediction_table.rds")
subj   <- readRDS("results/tables/subject_performance.rds")
seg    <- readRDS("results/tables/segment_performance.rds")
reason <- readRDS("results/tables/enrollment_reason_performance.rds")

# Subject-level difficulty
p_subject <- subj %>%
  ggplot(aes(subject, rmse_subject, fill = rmse_subject)) +
  geom_col() +
  scale_fill_gradient(low = "#c7e9b4", high = "#084081") +
  labs(title = "Subject-Level Prediction Difficulty (RMSE)",
       x = "Subject", y = "RMSE") +
  theme_minimal()

ggsave("results/insights/subject_rmse.png", p_subject, width = 7, height = 4)

# Enrollment reason variability
p_reason <- reason %>%
  ggplot(aes(reorder(enrollment_reason, rmse_reason), rmse_reason, fill = rmse_reason)) +
  geom_col() +
  coord_flip() +
  scale_fill_gradient(low = "#fdd0a2", high = "#990000") +
  labs(title = "Prediction Error by Enrollment Reason",
       x = "Enrollment Reason", y = "RMSE") +
  theme_minimal()

ggsave("results/insights/reason_rmse.png", p_reason, width = 7, height = 4)

# Motivation × Engagement heatmap
p_segment <- seg %>%
  ggplot(aes(motivation_band, engagement_band, fill = rmse_segment)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#edf8fb", high = "#006d2c") +
  labs(title = "RMSE Heatmap: Motivation × Engagement Segments",
       x = "Motivation Band", y = "Engagement Band") +
  theme_minimal()

ggsave("results/insights/segment_rmse_heatmap.png", p_segment, width = 6, height = 5)

# Top 10 highest-error students
top10 <- pred %>% arrange(desc(abs_error)) %>% slice(1:10)
saveRDS(top10, "results/insights/top10_worst_predictions.rds")

# Error distribution
p_error <- pred %>%
  ggplot(aes(abs_error)) +
  geom_histogram(bins = 30, fill = "#3182bd", color = "white", alpha = 0.8) +
  labs(title = "Distribution of Absolute Prediction Errors",
       x = "Absolute Error", y = "Count") +
  theme_minimal()

ggsave("results/insights/error_distribution.png", p_error, width = 7, height = 4)

# Motivation vs error
p_mot <- pred %>%
  ggplot(aes(motivation_score, abs_error)) +
  geom_point(alpha = 0.4, color = "#2b8cbe") +
  geom_smooth(method = "loess", color = "red") +
  labs(title = "Motivation vs Prediction Error",
       x = "Motivation Score", y = "Absolute Error") +
  theme_minimal()

ggsave("results/insights/motivation_vs_error.png", p_mot, width = 7, height = 4)

# Time spent vs grade vs error
p_spend <- pred %>%
  ggplot(aes(time_spent, final_grade, color = abs_error)) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(low = "green", high = "red") +
  labs(title = "Time Spent vs Final Grade (Error Highlighted)",
       x = "Time Spent", y = "Final Grade", color = "Abs Error") +
  theme_minimal()

ggsave("results/insights/time_vs_grade_error.png", p_spend, width = 7, height = 4)
