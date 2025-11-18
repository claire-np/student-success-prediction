# 10_shiny_dashboard.R

library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(DT)

pred_table     <- readRDS("results/tables/prediction_table.rds")
error_table    <- readRDS("results/tables/error_table.rds")
subject_perf   <- readRDS("results/tables/subject_performance.rds")
segment_perf   <- readRDS("results/tables/segment_performance.rds")
reason_perf    <- readRDS("results/tables/enrollment_reason_performance.rds")
model_compare  <- readRDS("results/tables/model_comparison.rds")
rf_model       <- readRDS("results/models/rf_model.rds")

ui <- fluidPage(
  
  titlePanel("Student Success Prediction Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Filters"),
      
      selectInput("subject", "Subject:",
                  choices = c("All", unique(pred_table$subject)),
                  selected = "All"),
      
      selectInput("reason", "Enrollment Reason:",
                  choices = c("All", unique(pred_table$enrollment_reason)),
                  selected = "All"),
      
      sliderInput("gradeRange", "Final Grade Range:",
                  min = 0, max = 100, value = c(0, 100)),
      
      hr(),
      downloadButton("downloadData", "Download Filtered Data")
    ),
    
    mainPanel(
      tabsetPanel(
        
        tabPanel("Model Performance",
                 h3("Model Comparison Summary"),
                 DTOutput("modelComparison")
        ),
        
        tabPanel("Feature Importance",
                 h3("Top Predictors (Random Forest)"),
                 plotOutput("varImpPlot", height = "500px")
        ),
        
        tabPanel("Subject Difficulty",
                 h3("Prediction Error by Subject"),
                 plotOutput("subjectPlot", height = "500px"),
                 tableOutput("subjectTable")
        ),
        
        tabPanel("Enrollment Reason",
                 h3("Error by Enrollment Reason"),
                 plotOutput("reasonPlot", height = "500px"),
                 tableOutput("reasonTable")
        ),
        
        tabPanel("Motivation × Engagement",
                 h3("Segment Heatmap"),
                 plotOutput("segmentHeatmap", height = "500px"),
                 tableOutput("segmentTable")
        ),
        
        tabPanel("Error Explorer",
                 h3("Prediction Error Distribution"),
                 plotOutput("errorDist", height = "500px"),
                 DTOutput("worstCases")
        ),
        
        tabPanel("Student Drill-Down",
                 h3("Filtered Student Records"),
                 DTOutput("studentTable")
        )
      )
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    df <- pred_table
    if (input$subject != "All") df <- df %>% filter(subject == input$subject)
    if (input$reason  != "All") df <- df %>% filter(enrollment_reason == input$reason)
    df %>% filter(final_grade >= input$gradeRange[1],
                  final_grade <= input$gradeRange[2])
  })
  
  output$downloadData <- downloadHandler(
    filename = function() "filtered_students.csv",
    content = function(file) write_csv(filtered_data(), file)
  )
  
  output$modelComparison <- renderDT({
    model_compare
  })
  
  output$varImpPlot <- renderPlot({
    imp <- rf_model$finalModel$variable.importance
    imp_df <- data.frame(Feature = names(imp), Importance = imp) %>%
      arrange(desc(Importance)) %>% head(15)
    
    ggplot(imp_df, aes(reorder(Feature, Importance), Importance)) +
      geom_col(fill = "#4682B4") +
      coord_flip() +
      labs(x = "Feature", y = "Importance")
  })
  
  output$subjectPlot <- renderPlot({
    ggplot(subject_perf, aes(subject, rmse_subject, fill = subject)) +
      geom_col() +
      labs(y = "RMSE", x = "Subject")
  })
  
  output$subjectTable <- renderTable(subject_perf)
  
  output$reasonPlot <- renderPlot({
    ggplot(reason_perf, aes(enrollment_reason, rmse_reason, fill = enrollment_reason)) +
      geom_col() +
      labs(y = "RMSE", x = "Enrollment Reason")
  })
  
  output$reasonTable <- renderTable(reason_perf)
  
  output$segmentHeatmap <- renderPlot({
    ggplot(segment_perf, aes(engagement_band, motivation_band, fill = rmse_segment)) +
      geom_tile() +
      scale_fill_gradient(low = "#D0E1F2", high = "#1C4E80") +
      labs(x = "Engagement Band", y = "Motivation Band", fill = "RMSE")
  })
  
  output$segmentTable <- renderTable(segment_perf)
  
  output$errorDist <- renderPlot({
    ggplot(error_table, aes(abs_error)) +
      geom_histogram(binwidth = 5, fill = "#6495ED", color = "white") +
      labs(x = "Absolute Error", y = "Count")
  })
  
  output$worstCases <- renderDT({
    error_table %>% arrange(desc(abs_error)) %>% head(20)
  })
  
  output$studentTable <- renderDT({
    filtered_data()
  })
}

shinyApp(ui = ui, server = server)
