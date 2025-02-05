createNewRow <- function(i){
  
  copy <- decision_log[1,]
  copy[0,]
  #copy[1,'iteration'] <- i
  copy[1,'original_goal'] <- decision_log[i -1,'new_goal']
  #copy[1,"adjusted_goal"] <- decision_log[i - 1,'new_goal']
  copy[1,'information_vector'] <- paste0(decision_log[i - 1,'information_vector'], decision_log[i - 1,'new_information'])
  copy[1,'choice_vector'] <- NA
  copy[1,'subjective_feedback'] <- NA
  copy[1,'objective_feedback'] <- NA
  copy[1,'choice_chosen'] <- NA
  copy[1,'new_information'] <- NA
  copy[1,'new_goal'] <- NA
  
  return(copy)
  
}
