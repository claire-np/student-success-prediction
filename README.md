# Student Success Prediction Using Behavioral, Linguistic, and Engagement Data — Insights for Educators

*Helping educators recognize which online science students may need support early on — ensuring no student is labeled, only supported.*

---

## 1. Project Overview

Drawing on my experience studying within LMS environments and working in EdTech, I became increasingly interested in how students’ digital behaviors can reveal early signs of academic difficulty. This project examines whether we can predict final grades early in fully online middle-school science courses using four major categories of signals:

- **Behavioral data from the LMS** (time on task, engagement ratio)  
- **Linguistic signals** from discussion posts (cognitive, social, emotional language)  
- **Self-reported motivation** (interest, utility value, perceived competence)  
- **Course context** (subject, semester, enrollment reason)

The purpose is not merely to minimize RMSE, but to generate actionable, early insights for educators—answering the key question:

> “Given what happens during the course, which students may need timely support—and what behaviors or language patterns signal that need?”

---

## 2. Data & Inspiration

This project draws inspiration from a real online middle-school science learning context and builds upon publicly available educational data.

### **Dataset Summary**

- Population: ~500 online middle-school science students
- Courses: Physical Science (PhysA), Earth Science (OcnA), Biology (BioA), Anatomy & Physiology (AnPhA), Forensic Science (FrScA)
- Variables include: LMS behavioral metrics; Discussion-forum linguistic features; Motivation survey data; Course-level contextual metadata.

The dataset has been used previously to illustrate an introductory random forest model. In this project, I extend that work in several ways:

- Build a reproducible pipeline** of scripts (00–09) for cleaning, modeling, and evaluation.  
- Compare multiple models (Random Forest, Gradient Boosting, XGBoost).  
- Add segment-level analysis (motivation × engagement, subject, enrollment reason).  
- Develop an interactive Shiny app for educators to explore predictions and at-risk students.

---

## 3. Key Questions for Educators

- **Early warning:**  
  Can we reliably flag students who are likely to fall below a passing threshold early enough for intervention, rather than after the final grade is determined?

- **Drivers of success:**  
  Which behaviors, motivation patterns, and language signals consistently differentiate high-performing students from those who struggle?

- **Instructional equity:**  
  Where do predictions vary across subjects, enrollment reasons, or motivation–engagement profiles, and what might this reveal about hidden barriers or unequal learning opportunities?

- **Actionable signals:**  
  Which simple, interpretable metrics (e.g., early engagement dips, negative sentiment, low motivation × time) can be surfaced in dashboards for weekly monitoring by teachers and advisors?

---

## 4. Methods

(Full technical detail is documented in the scripts and technical report.)

#### **Feature Engineering**

This project transforms LMS, motivation, and linguistic data into features that directly support instructional decisions:

- motivation_score = composite of interest, utility value, perceived competence  
- engagement_ratio = proportion of course modules accessed  
- emotion_balance = positive vs negative emotion in forum posts  
- motivation_time = motivation_score × time_spent  
- Encode categorical variables (subject, semester, enrollment_reason) as dummy variables.

#### **Modeling Approach**

- Random Forest  
- Gradient Boosting Machine  
- XGBoost (baseline and tuned)  

Each was trained on an 80/20 stratified split to ensure fair evaluation.

#### **Evaluation Metrics**: RMSE / R² / MAE

---

## 5. Overall Model Performance

| Model                | RMSE     | R²      | MAE      |
|---------------------|----------|---------|----------|
| Random Forest       | 13.0145  | 0.5548  | 10.0817  |
| Gradient Boosting   | 13.3212  | 0.5280  | 9.9126   |
| XGBoost – Standard  | 13.4739  | 0.5211  | 10.1495  |
| XGBoost – Tuned     | 13.8413  | 0.5078  | 10.3235  |

#### **Interpretation**

- All models explain ~50–55% of the variance in final course grades — a reasonable ceiling given behavioral, linguistic, and self-report features.  
- Random Forest delivers the best overall performance.  
- Gradient Boosting yields the lowest MAE.  
- XGBoost underperforms, likely due to small sample size and noisy features.  
- Prediction error (~10 points on a 0–100 scale) is acceptable for early-warning, but not high-stakes decisions.  
- Best practice: treat the model as **one supporting signal alongside teacher judgment.

---

## 6. Early Signals of Student Success & Risk

Across models, four behaviors consistently offer the strongest early indicators of risk:

- Discussion activity (n)— low posting is one of the simplest and strongest early warnings.  
- Engagement level (engagement_ratio) — both shallow engagement and inefficient over-engagement appear in struggling students.  
- Time on task (time_spent) — high time + low performance may indicate confusion.  
- Motivation patterns — very low or very high motivation creates volatile outcomes.

#### **Data-driven thresholds**

- `n < 5` → common among students scoring < 65  
- `motivation_score < 3.2` or `> 4.7` → highest variability  
- `engagement_ratio < 20` or `> 150` → shallow vs inefficient  
- `predicted_grade < 70` → reliable early risk indicator

> **Figure 1. Random Forest Feature Importance**  
> This plot highlights the strongest early indicators of student performance — with discussion activity (`n`) standing out as the dominant predictor.

<img width="2380" height="1180" alt="Feature Importance" src="https://github.com/user-attachments/assets/b1334689-adb9-41ae-8356-f3f9d5885928" />

---

## 7. Where the Model Struggles — and Why That Matters

Even though the models perform reasonably well, they struggle with certain student groups and subjects.

#### **1. Subjects where predictions are less reliable**

- Physics (PhysA) has the highest prediction error.  
- Engagement metrics don’t reflect actual conceptual learning.

➡️ Metrics like “time spent” or “engagement ratio” may not reflect actual learning in Physics. Early, concept-focused check-ins are more trustworthy than LMS signals here.

#### **2. Enrollment groups that are harder to predict**

- Students who take the course due to a Scheduling Conflict show highly irregular engagement patterns.

➡️ A low engagement score might not mean low effort. These students often need pacing support or scheduling flexibility, not generic reminders.

#### **3. The “quietly at risk” students**

- Middle motivation × middle engagement students do “just enough” to stay unnoticed.

➡️ They rarely get help but contribute heavily to underperformance.

> **Figure 2. Time Spent vs Final Grade (with Prediction Error Highlighted)**  
> This visualization reveals where the model struggles most. Students who spend a large amount of time but earn low final grades (red points) represent “struggling hard-workers”—high-effort learners who need targeted instructional support, not more reminders to engage. These high-error cases illustrate why human judgment remains essential.

<img width="2100" height="1200" alt="time_vs_grade_error" src="https://github.com/user-attachments/assets/3ac7786b-390c-4491-acf6-cf94ac5a4d04" />


---

## 8. Practical Use for Teachers

The workflow stays human-centered. Data informs early action; teachers make the final decisions.

#### **1. Core signals → weekly scan**

- `predicted_grade < 70`  
- Very low posting activity (`< 3–5 posts early`)  
- `motivation_score < 3.2` or `> 4.7`

➡️ Students showing 1+ of these patterns likely need early support.

#### **2. Human judgment → next steps**

After a student is flagged, teachers examine things the model cannot see:

- Pacing: Are they skipping modules?  
- Post quality: Signs of confusion, frustration, or minimal effort?  
- Time pattern: Too little (avoidance) or too much (inefficient struggle)?  
- Communication: Have they reached out or gone silent?  

➡️ This converts a flag into real understanding.

#### **3. Low-cost interventions**

- Low posting → small structured questions
- Low motivation → personal relevance connection 
- High time + low output → study-strategy checkpoint
- Silent students → supportive check-in message

➡️ These actions address universal learning patterns.

---

## 9. Future Extensions

This project is a first version, but there are several clear ways I would push it further in the future:

- Adding assessment-level data, weekly pacing logs, or clickstream sequences would help capture how students learn, not just how often they interact.  
- Week-by-week engagement and motivation trends would make early detection more realistic.  
- Mixed-effects models or simple sequence models could reduce error in subjects like Physics.  
- Evaluating whether errors differ across groups would make the system more trustworthy.  
- Packaging the early-warning rules into a lightweight dashboard or weekly automated report would make the work directly usable.

➡️ In short, my goal is to evolve this work from a static prediction model into a dynamic, week-by-week early-warning system.

---

## 10. Source Acknowledgment

This project draws on the dataset from **Data Science in Education Using R** (by Ryan Estrellado, Emily A. Freer, Isabella C. Velásquez, Joshua M. Rosenberg, Jesse Mostipak), specifically the R package: `dataedu::sci_mo_with_text`

While the book provides an introductory Random Forest example, this repository represents a substantial technical and interpretive expansion.

#### **Major contributions include:**

- Building a reproducible end-to-end pipeline (scripts 00–10).  
- Creating new domain-driven features such as motivation_time, engagement_ratio, and emotion_balance.  
- Benchmarking multiple models (Random Forest, GBM, XGBoost baseline + tuned) with RMSE, MAE, R².  
- Conducting deeper educational analysis: subject-level variability, enrollment-reason patterns, motivation × engagement segmentation.  
- Translating model findings into practical early-warning guidance for teachers.

>_This repository is an independent, technically upgraded, and educator-aligned extension of the original example, maintained solely for educational and portfolio demonstration purposes._


