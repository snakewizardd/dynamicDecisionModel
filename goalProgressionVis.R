library(dplyr)
library(ggplot2)
library(plotly)

# Example decision log (replace this with your actual data)
goal_progression <- decision_log %>%
  select(iteration, adjusted_goal) %>%
  mutate(iteration = as.factor(iteration))

# Create the ggplot chart
p <- ggplot(goal_progression, aes(x = iteration, y = iteration, text = adjusted_goal)) +  # Set y to iteration to avoid the long text on the y-axis
  geom_line(group = 1, color = "blue", size = 1) +   # Line showing progression
  geom_point(color = "red", size = 3) +              # Points for each iteration
  labs(title = "Goal Progression Over Iterations", 
       x = "Iteration", 
       y = "") +  # Hide y-axis label since we're using the x for iterations
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal() +
  theme(axis.text.y = element_blank(),   # Hide y-axis ticks since it's not necessary
        axis.ticks.y = element_blank())  # Remove ticks for y-axis

# Convert ggplot to plotly for interactive tooltips
p_interactive <- ggplotly(p, tooltip = "text")

# Customize layout
p_interactive <- p_interactive %>%
  layout(
    xaxis = list(tickangle = 45),  # Rotate x-axis labels for better readability
    yaxis = list(title = ""),       # Hide the y-axis title
    margin = list(l = 50, r = 50, t = 100, b = 50),  # Add margins to avoid text overlap
    title = list(text = "Goal Progression Over Iterations", x = 0.5, xanchor = "center")
  )

# Display the plot
p_interactive
