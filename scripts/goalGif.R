library(dplyr)
library(ggplot2)
library(gganimate)
library(stringr)

plotData <- decision_log

plotData <- decision_log %>% mutate(iteration = 1:nrow(decision_log)) %>%
  select(iteration, everything())

# Wrapping text for better visibility
plotData <- plotData %>%
  mutate(adjusted_goal_wrapped = str_wrap(choice_chosen, width = 40)) 

# Base plot
p <- ggplot(plotData, aes(x = iteration, y = iteration)) +
  geom_point(color = "red", size = 4) +
  geom_text(aes(label = adjusted_goal_wrapped), vjust = -0.5, hjust = 0.5, size = 4) +
  labs(title = "Goal Progression Over Iterations",
       subtitle = "Tracking how the goal evolves over time",
       x = "Iteration",
       y = "Progression") +
  theme_minimal() +
  annotate("text", x = 1, y = max(plotData$iteration) + 1, 
           label = paste("Original Goal:\n", str_wrap(unique(plotData$original_goal[1]), 50)), 
           hjust = 0, color = "darkgreen", size = 5)

# Add animation
animated_plot <- p + transition_reveal(iteration)

# Save animation
#anim_save("autoBiz.gif", animated_plot)

# Show animation
animated_plot
