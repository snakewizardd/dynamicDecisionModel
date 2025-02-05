# Load necessary libraries
library(dplyr)
library(plotly)

# Sample decision log (use your actual data here)
decision_log <- data.frame(
  iteration = 1:8,
  original_goal = rep("I want to transition from finance to data science.", 8),
  adjusted_goal = c("N/A yet", 
                    "start working on practical projects using financial datasets while continuing self-study in data science", 
                    "Start a project analyzing historical stock prices using machine learning techniques", 
                    "Start working on a specific financial dataset project to apply your skills and build your portfolio", 
                    "Continue self-studying Python and machine learning", 
                    "Identify specific financial datasets to work on for your projects", 
                    "Continue self-studying Python and machine learning", 
                    "Continue self-studying Python and machine learning")
)

# Create a plotly plot
p <- ggplot(decision_log, aes(x = iteration, y = adjusted_goal, text = paste("Iteration:", iteration, "<br>Goal:", adjusted_goal))) +
  geom_line(group = 1, color = "blue", size = 1) +  # Line showing progression
  geom_point(color = "red", size = 3) +  # Points for each iteration
  labs(title = "Goal Progression Over Iterations", 
       x = "Iteration", 
       y = "Adjusted Goal") +
  theme_minimal()

# Convert ggplot to plotly for interactivity
p <- ggplotly(p, tooltip = "text")

# Add animation and hover effects
p <- p %>% layout(
  title = "Goal Progression Over Iterations",
  xaxis = list(title = "Iteration", range = c(1, 8)),
  yaxis = list(title = "Adjusted Goal"),
  showlegend = FALSE
) %>% 
  animation_opts(frame = 1000, redraw = TRUE) %>%
  animation_slider(currentvalue = list(prefix = "Iteration: ", font = list(size = 20)))

# Show the plot
p
