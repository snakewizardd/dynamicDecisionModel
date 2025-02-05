library(dplyr)
library(ggplot2)

# Ensure adjusted_goal is properly ordered
decision_log <- decision_log %>%
  mutate(adjusted_goal = as.character(adjusted_goal)) %>%  # Convert factor to character
  mutate(adjusted_goal = factor(adjusted_goal, levels = unique(adjusted_goal[order(iteration)])))

# Extract the first unique original goal
original_goal_text <- unique(decision_log$original_goal)[1]

# Plot the goal progression
ggplot(decision_log, aes(x = iteration, y = adjusted_goal, group = 1)) +
  geom_line(color = "blue", size = 1) +   # Line showing progression
  geom_point(color = "red", size = 3) +   # Points for each iteration
  labs(title = "Goal Progression Over Iterations", 
       x = "Iteration", 
       y = "Adjusted Goal") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal() +
  annotate("text", x = min(decision_log$iteration), y = min(as.numeric(decision_log$adjusted_goal)), 
           label = paste("Original Goal:\n", original_goal_text), 
           hjust = 0, vjust = 1, color = "darkgreen", size = 4)
