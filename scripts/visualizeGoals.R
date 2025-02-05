# Load necessary libraries
library(dplyr)
library(ggplot2)

# Example decision log (replace this with your actual data)
# decision_log <- data.frame(
#   iteration = 1:8,
#   original_goal = rep("I want to transition from finance to data science.", 8),
#   adjusted_goal = c("N/A yet", 
#                     "start working on practical projects using financial datasets while continuing self-study in data science", 
#                     "Start a project analyzing historical stock prices using machine learning techniques", 
#                     "Start working on a specific financial dataset project to apply your skills and build your portfolio", 
#                     "Continue self-studying Python and machine learning", 
#                     "Identify specific financial datasets to work on for your projects", 
#                     "Continue self-studying Python and machine learning", 
#                     "Continue self-studying Python and machine learning")
# )

# Transform the data into a tidy format (iteration, goal text)
goal_progression <- decision_log %>%
  select(iteration, adjusted_goal) %>%
  mutate(iteration = as.factor(iteration))

# Plot the goal progression with the original goal as a global label
ggplot(goal_progression, aes(x = iteration, y = adjusted_goal)) +
  geom_line(group = 1, color = "blue", size = 1) +   # Line showing progression
  geom_point(color = "red", size = 3) +              # Points for each iteration
  labs(title = "Goal Progression Over Iterations", 
       x = "Iteration", 
       y = "Adjusted Goal") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal() +
  annotate("text", x = 0, y = max(goal_progression$adjusted_goal), 
           label = paste("Original Goal:\n", unique(decision_log$original_goal)), 
           hjust = 0, vjust = 1, color = "darkgreen", size = 4)
