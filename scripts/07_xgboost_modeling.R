# 07_xgboost_modeling.R
# XGBoost baseline & tuned models for student grade prediction

source("scripts/00_load_packages.R")

df_train <- readRDS("data_processed/df_train.rds")
df_test  <- readRDS("data_processed/df_test.rds")

train_matrix <- model.matrix(final_grade ~ . - 1, df_train)
test_matrix  <- model.matrix(final_grade ~ . - 1, df_test)

dtrain <- xgb.DMatrix(data = train_matrix, label = df_train$final_grade)
dtest  <- xgb.DMatrix(data = test_matrix)

params_std <- list(
  objective = "reg:squarederror",
  eval_metric = "rmse",
  eta = 0.1,
  max_depth = 6,
  subsample = 0.8,
  colsample_bytree = 0.8
)

xgb_std <- xgb.train(
  params = params_std,
  data = dtrain,
  nrounds = 300,
  verbose = 0
)

params_tuned <- list(
  objective = "reg:squarederror",
  eval_metric = "rmse",
  eta = 0.05,
  max_depth = 4,
  min_child_weight = 3,
  subsample = 0.9,
  colsample_bytree = 0.7
)

xgb_tuned <- xgb.train(
  params = params_tuned,
  data = dtrain,
  nrounds = 600,
  verbose = 0
)

df_test$pred_xgb_std   <- predict(xgb_std,   dtest)
df_test$pred_xgb_tuned <- predict(xgb_tuned, dtest)

xgb_std_metrics <- caret::defaultSummary(data.frame(
  obs  = df_test$final_grade,
  pred = df_test$pred_xgb_std
))

xgb_tuned_metrics <- caret::defaultSummary(data.frame(
  obs  = df_test$final_grade,
  pred = df_test$pred_xgb_tuned
))

dir.create("results/models", recursive = TRUE, showWarnings = FALSE)
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)

saveRDS(xgb_std,          "results/models/xgb_std_model.rds")
saveRDS(xgb_tuned,        "results/models/xgb_tuned_model.rds")
saveRDS(xgb_std_metrics,  "results/tables/xgb_std_metrics.rds")
saveRDS(xgb_tuned_metrics,"results/tables/xgb_tuned_metrics.rds")
