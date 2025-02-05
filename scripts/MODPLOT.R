library(dplyr)
library(ggplot2)

plotData <- decision_log

plotData <- decision_log %>% mutate(iteration = 1:nrow(decision_log)) %>%
  select(iteration, everything())

# Ensure adjusted_goal is properly ordered
plotData <- plotData %>%
  mutate(adjusted_goal = as.character(original_goal)) %>%  # Convert factor to character
  mutate(adjusted_goal = factor(adjusted_goal, levels = unique(adjusted_goal[order(iteration)])))

# Extract the first unique original goal
original_goal_text <- unique(plotData$original_goal)[1]

# Plot the goal progression
ggplot(plotData, aes(x = iteration, y = original_goal, group = 1)) +
  geom_line(color = "blue", size = 1) +   # Line showing progression
  geom_point(color = "red", size = 3) +   # Points for each iteration
  labs(title = "Goal Progression Over Iterations", 
       x = "Iteration", 
       y = "Adjusted Goal") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal() +
  annotate("text", x = min(plotData$iteration), y = min(as.numeric(plotData$original_goal)), 
           label = paste("Original Goal:\n", unique(plotData$original_goal)),
           hjust = 0, vjust = 1, color = "darkgreen", size = 25)
