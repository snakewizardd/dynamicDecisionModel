library(dplyr)
library(reactable)
library(htmltools)

# Extract the original goal (assuming it's the same for all iterations)
original_goal_text <- unique(decision_log$original_goal)[1]

# Select relevant columns (removing original_goal from the table)
decision_log_filtered <- decision_log %>%
  select(iteration, choices_for_step, choice_chosen, new_goal, new_information_vector)

# Create the UI with a header and reactable table
ui <- tagList(
  h3("Goal Progression Overview"),
  p(strong("Original Goal: "), original_goal_text),  # Display the original goal above the table
  reactable(
    decision_log_filtered,
    columns = list(
      iteration = colDef(name = "Iteration", width = 100),
      choices_for_step = colDef(name = "Choices for Step", minWidth = 300, style = list(whiteSpace = "pre-line")),
      choice_chosen = colDef(name = "Choice Chosen", minWidth = 250, style = list(whiteSpace = "pre-line")),
      new_goal = colDef(name = "New Goal", minWidth = 300, style = list(whiteSpace = "pre-line")),
      new_information_vector = colDef(name = "New Information", minWidth = 300, style = list(whiteSpace = "pre-line"))
    ),
    searchable = TRUE,
    striped = TRUE,
    highlight = TRUE,
    bordered = TRUE,
    pagination = FALSE,  # Show all rows by default
    defaultPageSize = nrow(decision_log_filtered)  # Ensure all 20 steps render
  )
)

# Render the UI
ui


server <- function(input,output,session){}

shinyApp(ui,server)
