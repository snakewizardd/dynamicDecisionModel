library(dplyr)
library(ggplot2)
library(gganimate)
library(stringr)

# Assuming decision_log is already defined as your dataframe
# Example decision_log creation (replace with your actual data)
set.seed(123)
# decision_log <- data.frame(
#   original_goal = rep("Become a successful entrepreneur with a sustainable and impactful business that helps people.", 20),
#   choice_chosen = paste("Iteration", 1:20, ": New strategy based on feedback. Trying a new marketing channel focusing on social media. Revised product demo based on user testing. Implementing new customer service protocol. Exploring partnerships. Analyzing competitor actions.  Refining the business model.  Adjusting pricing.  Exploring alternative funding options. Pivoting towards B2B model.  Adding a new feature.  Focusing on a specific niche.  Improving user onboarding.  Conducting market research. Addressing scalability issues. Focusing on revenue generation. Launching a loyalty program. Expanding geographically.",sep = " - ")
# )


plotData <- decision_log

plotData <- decision_log %>% mutate(iteration = 1:nrow(decision_log)) %>%
  select(iteration, everything())

# Wrapping text for better visibility
plotData <- plotData %>%
  mutate(adjusted_goal_wrapped = str_wrap(choice_chosen, width = 80)) # Increased width

# Base plot
p <- ggplot(plotData, aes(x = iteration, y = iteration)) +
  geom_point(color = "red", size = 4) +
  geom_text(aes(label = adjusted_goal_wrapped), vjust = -0.5, hjust = 0.5, size = 5, family = "serif") + # Increased size and added family
  labs(title = "Goal Progression Over Iterations",
       subtitle = "Tracking how the goal evolves over time",
       x = "Iteration",
       y = "Progression") +
  theme_minimal() +
  annotate("text", x = 1, y = max(plotData$iteration) + 2,  # Adjusted Y position
           label = paste("Original Goal:\n", str_wrap(unique(plotData$original_goal[1]), 100)), # Increased width
           hjust = 0, color = "darkgreen", size = 6, family = "serif") + # Increased size and added family
  theme(plot.title = element_text(size = 16, hjust = 0.5, family = "serif"), # Title customization
        plot.subtitle = element_text(size = 14, hjust = 0.5, family = "serif"), # Subtitle customization
        axis.title.x = element_text(size = 12, family = "serif"), # X-axis title customization
        axis.title.y = element_text(size = 12, family = "serif"), # Y-axis title customization
        axis.text = element_text(size = 10, family = "serif"), #Axis label customization
        panel.background = element_rect(fill = "aliceblue"), #Background color
        plot.background = element_rect(fill = "white")) #Plot Area Background

# Add animation
animated_plot <- p + transition_reveal(iteration) +
  view_follow(fixed_y = TRUE) #Keeps the Y axis in view

# Save animation
animation <- animate(animated_plot, height = 800, width = 1200, units = "px", res = 100, duration = 10, fps = 20)  # Increased height and width
anim_save("cryptoTest.gif", animation)

# Show animation
#animation