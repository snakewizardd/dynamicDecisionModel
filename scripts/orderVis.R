# Load necessary libraries
library(dplyr)
library(ggplot2)

# Example decision log (replace this with your actual data)
# decision_log <- data.frame(
#   iteration = 1:8,
#   original_goal = rep("I want to transition from finance to data science.", 8),
#   adjusted_goal = c("N/A yet", 
#                     "Start working on practical projects using financial datasets while continuing self-study in data science", 
#                     "Start a project analyzing historical stock prices using machine learning techniques", 
#                     "Start working on a specific financial dataset project to apply your skills and build your portfolio", 
#                     "Identify specific financial datasets to work on for your projects", 
#                     "Continue self-studying Python and machine learning", 
#                     "Continue self-studying Python and machine learning", 
#                     "Continue self-studying Python and machine learning")
# )

# Ensure adjusted_goal is ordered by iteration manually using unique sequence
decision_log <- decision_log %>%
  mutate(adjusted_goal = factor(adjusted_goal, levels = unique(adjusted_goal[order(iteration)])))

# Plot the goal progression with the original goal as a global label
ggplot(decision_log, aes(x = iteration, y = adjusted_goal, group = 1)) +
  geom_line(color = "blue", size = 1) +   # Line showing progression
  geom_point(color = "red", size = 3) +   # Points for each iteration
  labs(title = "Goal Progression Over Iterations", 
       x = "Iteration", 
       y = "Adjusted Goal") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal() +
  annotate("text", x = 1, y = 1, 
           label = paste("Original Goal:\n", unique(decision_log$original_goal)[1]), 
           hjust = 0, vjust = 1, color = "darkgreen", size = 4)
