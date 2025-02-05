library(dplyr)
library(reactable)
library(htmltools)

# Extract the original goal (assuming it's the same for all iterations)
original_goal_text <- unique(decision_log$original_goal)[1]

# Select relevant columns (keeping all columns in the table)
decision_log_filtered <- decision_log

# Create the UI with a header and reactable table
ui <- tagList(
  h3("Goal Progression Overview"),
  p(strong("Original Goal: "), original_goal_text),  # Display the original goal above the table
  reactable(
    decision_log_filtered,
    columns = list(
      iteration = colDef(name = "Iteration", width = 100),
      original_goal = colDef(name = "Original Goal", minWidth = 300, style = list(whiteSpace = "pre-line")),
      adjusted_goal = colDef(name = "Adjusted Goal", minWidth = 300, style = list(whiteSpace = "pre-line")),
      information_vector = colDef(name = "Information Vector", minWidth = 300, style = list(whiteSpace = "pre-line")),
      choices_for_step = colDef(name = "Choices for Step", minWidth = 300, style = list(whiteSpace = "pre-line")),
      subjective_feedback = colDef(name = "Subjective Feedback", minWidth = 300, style = list(whiteSpace = "pre-line")),
      objective_feedback = colDef(name = "Objective Feedback", minWidth = 300, style = list(whiteSpace = "pre-line")),
      choice_chosen = colDef(name = "Choice Chosen", minWidth = 250, style = list(whiteSpace = "pre-line")),
      new_information_vector = colDef(name = "New Information", minWidth = 300, style = list(whiteSpace = "pre-line")),
      new_goal = colDef(name = "New Goal", minWidth = 300, style = list(whiteSpace = "pre-line"))
    ),
    searchable = TRUE,
    striped = TRUE,
    highlight = TRUE,
    bordered = TRUE,
    pagination = FALSE,  # Show all rows by default
    defaultPageSize = nrow(decision_log_filtered)  # Ensure all rows render
  )
)

# Render the UI
ui

server <- function(input, output, session) {}

#shinyApp(ui, server)

save_html(ui, "./sampleOutputs/goal_progression-crypto-full2.html")
