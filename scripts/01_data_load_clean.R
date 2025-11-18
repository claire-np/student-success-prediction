source("scripts/00_load_packages.R")

df <- dataedu::sci_mo_with_text

df <- df %>%
  select(
    int, uv, pc,              # motivation
    time_spent,               # engagement time
    final_grade,              # target
    subject,                  # course subject
    enrollment_reason,        # why enrolled
    semester,                 # term
    enrollment_status,        # status
    cogproc, social,          # discussion content
    posemo, negemo,           # emotion tone
    n                         # number of discussion posts
  )

df <- na.omit(df)

df <- df %>% select(-enrollment_status)

df <- df %>% mutate_if(is.character, as.factor)

df <- df %>%
  mutate(
    motivation_score   = (int + uv + pc) / 3,
    engagement_ratio   = time_spent / n,            # time per post
    emotion_balance    = posemo - negemo,           # net positivity
    motivation_time    = motivation_score * time_spent
  )

if (!dir.exists("data_processed")) {
  dir.create("data_processed")
}

saveRDS(df, "data_processed/df_clean.rds")
