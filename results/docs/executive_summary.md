# Student Success Prediction – Executive Summary

## 1. Project Overview

- **Objective**: Predict online middle school science students’ final course grades based on motivation, LMS engagement, and discussion forum behavior.
- **Business Context**: Enable early identification of at-risk students and support data-informed interventions in virtual science courses.

## 2. Data & Methods

- **Population**: 499 students from online middle school science courses (after cleaning and listwise deletion: 464 students).
- **Features used**:
  - Motivation: interest (int), utility value (uv), perceived competence (pc), composite motivation_score.
  - LMS engagement: time_spent, engagement_ratio, motivation_time.
  - Discussion behavior: cogproc, social, posemo, negemo, number of posts (n), emotion_balance.
  - Course context: subject, semester, enrollment_reason.
- **Model**: Random Forest (caret + ranger), evaluated on an 80/20 train–test split.

## 3. Model Performance (Test Set)

- **RMSE**: 13.01
- **R²**: 0.555
- **MAE**: 10.08

Interpretation:
- RMSE indicates the typical prediction error in points on the 0–100 grade scale.
- R² shows the proportion of variance in final grades explained by the model.

## 4. Key Drivers of Student Success (High-level)

- Feature importance from the Random Forest model suggests that:
  - **Discussion activity (n: number of posts)** is one of the strongest predictors of final grade.
  - **Subject (course type)** matters: some subjects consistently yield higher or lower grades.
  - **Time_spent** in the course has a strong association with achievement, but likely non-linear.
  - **Motivation_score** (combining int, uv, pc) and **emotion_balance** (positive vs negative emotion) contribute as secondary predictors.

## 5. Segment Insights

- **By Subject** (see results/tables/subject_performance.rds):
  - Subjects differ in average achievement and prediction error, indicating curriculum and assessment differences across courses.
- **By Enrollment Reason** (see results/tables/enrollment_reason_performance.rds):
  - Students enrolling for **Credit Recovery** or **Scheduling Conflict** may show different performance profiles and may require targeted support.
- **By Motivation & Engagement Segments** (see results/tables/segment_performance.rds):
  - Students in **high-motivation & high-engagement** bands tend to achieve the highest average final grades.
  - Segments with **low-motivation & low-engagement** show both lower average performance and higher prediction error, making them priority for proactive interventions.

## 6. At-risk Students View

- At-risk rule used in this analysis: **predicted final grade < 70**.
- A dedicated table of at-risk students is saved in `results/tables/at_risk_students.rds`.
- This table combines predicted grade, error, subject, semester, enrollment_reason, and motivation/engagement variables.

Potential use cases:
- Weekly risk monitoring dashboard for counselors and teachers.
- Prioritizing outreach to students with low predicted performance but high potential (e.g., moderate motivation but low engagement).

## 7. Recommendations for Educational Stakeholders

- **Early warning system**:
  - Integrate the model outputs into a dashboard (e.g., Power BI or Shiny) to flag students with low predicted grades.
  - Set tiered intervention thresholds (e.g., <60 = high risk, 60–70 = moderate risk).

- **Instructional design & subject review**:
  - Review subjects with consistently lower avg_actual or higher rmse_subject.
  - Align grading policies and support materials across subjects with high variability.

- **Motivation & engagement strategies**:
  - Design targeted nudges and scaffolding for segments with low motivation_band and low engagement_band.
  - Encourage structured use of discussion boards, since posting behavior (n) is strongly associated with success.

## 8. Next Steps for Extension

- Add additional models (e.g., Gradient Boosting, XGBoost) and compare performance with Random Forest.
- Deploy an interactive dashboard to allow advisors and teachers to filter by subject, semester, and risk level.
- Expand features with longitudinal data (e.g., prior GPA, attendance) for more robust early-warning systems.

----

This executive summary is auto-generated from the R analysis pipeline (scripts 03–05) and is intended to be refined into a final report or portfolio case study.
