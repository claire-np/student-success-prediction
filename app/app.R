# ------------------------------------------------------------
# Student Success Prediction Dashboard (Shiny App)
# Project: student-success-prediction-r
# ------------------------------------------------------------

library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(caret)

# ------------------------------------------------------------
# 1. Load data & model (run once when app starts)
# ------------------------------------------------------------

# Vì app.R nằm trong thư mục /app, ta dùng đường dẫn "../"
df_test_raw <- readRDS("../data_processed/df_test.rds")
rf_model    <- readRDS("../results/models/rf_model.rds")

# Tạo dataframe đã có prediction + risk band
df_scored <- df_test_raw %>%
  mutate(
    pred_rf   = predict(rf_model, newdata = df_test_raw),
    error     = final_grade - pred_rf,
    abs_error = abs(error),
    risk_band = case_when(
      pred_rf < 60              ~ "High risk (<60)",
      pred_rf >= 60 & pred_rf < 70 ~ "Moderate risk (60–69)",
      pred_rf >= 70 & pred_rf < 85 ~ "On-track (70–84)",
      pred_rf >= 85             ~ "High-performing (85+)",
      TRUE                      ~ "Unknown"
    )
  )

# Các giá trị dùng cho filter
subject_choices <- sort(unique(df_scored$subject))
semester_choices <- sort(unique(df_scored$semester))
enroll_choices <- sort(unique(df_scored$enrollment_reason))
risk_choices <- c("High risk (<60)",
                  "Moderate risk (60–69)",
                  "On-track (70–84)",
                  "High-performing (85+)")

# Tính KPI tổng thể
overall_rmse <- caret::defaultSummary(
  data.frame(
    obs  = df_scored$final_grade,
    pred = df_scored$pred_rf
  )
)["RMSE"]

overall_r2 <- caret::defaultSummary(
  data.frame(
    obs  = df_scored$final_grade,
    pred = df_scored$pred_rf
  )
)["Rsquared"]

# ------------------------------------------------------------
# 2. UI
# ------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Student Success Prediction – Online Science Courses"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Filters"),
      selectInput(
        "subject",
        "Subject:",
        choices = c("All", as.character(subject_choices)),
        selected = "All"
      ),
      selectInput(
        "semester",
        "Semester:",
        choices = c("All", as.character(semester_choices)),
        selected = "All"
      ),
      selectInput(
        "enroll_reason",
        "Enrollment reason:",
        choices = c("All", as.character(enroll_choices)),
        selected = "All"
      ),
      selectInput(
        "risk",
        "Risk band (by predicted grade):",
        choices = c("All", risk_choices),
        selected = "All"
      ),
      hr(),
      helpText("Data source: dataedu::sci_mo_with_text (processed).
Model: Random Forest (caret + ranger).")
    ),
    
    mainPanel(
      tabsetPanel(
        id = "tabs",
        
        # ---------------- Overview tab ----------------
        tabPanel(
          title = "Overview",
          br(),
          fluidRow(
            column(
              width = 4,
              wellPanel(
                h5("Average actual grade"),
                textOutput("avg_actual")
              )
            ),
            column(
              width = 4,
              wellPanel(
                h5("Average predicted grade"),
                textOutput("avg_pred")
              )
            ),
            column(
              width = 4,
              wellPanel(
                h5("RMSE (overall)"),
                textOutput("rmse_overall")
              )
            )
          ),
          br(),
          plotOutput("dist_plot", height = "300px"),
          br(),
          plotOutput("error_by_subject", height = "300px")
        ),
        
        # ---------------- At-risk students tab ----------------
        tabPanel(
          title = "At-risk Students",
          br(),
          h4("Student list (filtered)"),
          DTOutput("at_risk_table")
        ),
        
        # ---------------- Feature importance tab ----------------
        tabPanel(
          title = "Feature Importance",
          br(),
          h4("Random Forest Variable Importance"),
          plotOutput("varimp_plot", height = "400px"),
          br(),
          helpText("Higher importance = stronger contribution to predicting final grade.")
        )
      )
    )
  )
)

# ------------------------------------------------------------
# 3. SERVER
# ------------------------------------------------------------

server <- function(input, output, session) {
  
  # Reactive filtered data
  filtered_data <- reactive({
    df <- df_scored
    
    if (input$subject != "All") {
      df <- df %>% filter(subject == input$subject)
    }
    if (input$semester != "All") {
      df <- df %>% filter(semester == input$semester)
    }
    if (input$enroll_reason != "All") {
      df <- df %>% filter(enrollment_reason == input$enroll_reason)
    }
    if (input$risk != "All") {
      df <- df %>% filter(risk_band == input$risk)
    }
    
    df
  })
  
  # ----- KPI text outputs -----
  output$avg_actual <- renderText({
    df <- filtered_data()
    if (nrow(df) == 0) return("No data")
    sprintf("%.1f", mean(df$final_grade, na.rm = TRUE))
  })
  
  output$avg_pred <- renderText({
    df <- filtered_data()
    if (nrow(df) == 0) return("No data")
    sprintf("%.1f", mean(df$pred_rf, na.rm = TRUE))
  })
  
  output$rmse_overall <- renderText({
    sprintf("%.2f", as.numeric(overall_rmse))
  })
  
  # ----- Distribution plot -----
  output$dist_plot <- renderPlot({
    df <- filtered_data()
    if (nrow(df) == 0) return(NULL)
    
    ggplot(df, aes(x = final_grade)) +
      geom_histogram(bins = 20, alpha = 0.5) +
      geom_vline(aes(xintercept = mean(final_grade, na.rm = TRUE)),
                 linetype = "dashed") +
      labs(
        title = "Distribution of Actual Grades (Filtered)",
        x = "Final Grade",
        y = "Count"
      )
  })
  
  # ----- Error by subject -----
  output$error_by_subject <- renderPlot({
    df <- filtered_data()
    if (nrow(df) == 0) return(NULL)
    
    df %>%
      group_by(subject) %>%
      summarise(
        rmse = sqrt(mean((final_grade - pred_rf)^2, na.rm = TRUE)),
        n = n()
      ) %>%
      ggplot(aes(x = subject, y = rmse)) +
      geom_col() +
      labs(
        title = "RMSE by Subject (Filtered)",
        x = "Subject",
        y = "RMSE"
      )
  })
  
  # ----- At-risk students table -----
  output$at_risk_table <- renderDT({
    df <- filtered_data()
    if (nrow(df) == 0) return(NULL)
    
    df %>%
      arrange(pred_rf) %>%
      select(
        subject,
        semester,
        enrollment_reason,
        final_grade,
        pred_rf,
        risk_band,
        motivation_score,
        engagement_ratio,
        emotion_balance,
        n
      ) %>%
      datatable(
        options = list(pageLength = 20),
        rownames = FALSE
      )
  })
  
  # ----- Variable importance plot -----
  output$varimp_plot <- renderPlot({
    imp <- varImp(rf_model)
    
    imp_df <- imp$importance %>%
      tibble::rownames_to_column("variable") %>%
      arrange(desc(Overall)) %>%
      slice(1:15)  # lấy top 15 biến quan trọng nhất
    
    ggplot(imp_df, aes(x = reorder(variable, Overall), y = Overall)) +
      geom_col() +
      coord_flip() +
      labs(
        title = "Top 15 Important Variables (Random Forest)",
        x = "Variable",
        y = "Importance"
      )
  })
}

# ------------------------------------------------------------
# 4. Run the app
# ------------------------------------------------------------

shinyApp(ui = ui, server = server)
