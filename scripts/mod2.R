#original_goalInput
#original_informationInput

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

original_goalInput <- "become a crypto billionare"

original_informationInput <- "i have 35$ to my name and i live in sub saharan africa under a shed with no internet"

firstQuery <- list(original_goal = list(original_goalInput),
     information_vector = list(original_informationInput))

choicesGenerated <- choiceGenerator(original_goal = original_goalInput, original_information = original_informationInput)

combinedData <- firstQuery <- list(original_goal = list(original_goalInput),
                                   information_vector = list(original_informationInput),
                                   choice_vector = list(choicesGenerated))

subjectiveAnalysis <- subjectiveAnalzyer(state = combinedData)
objectiveAnalysis <- objectiveAnalyzer(state = combinedData)

combinedData <- firstQuery <- list(original_goal = list(original_goalInput),
                                   information_vector = list(original_informationInput),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis))

chosenChoice <- choiceChooser(state=combinedData)

combinedData <- firstQuery <- list(original_goal = list(original_goalInput),
                                   information_vector = list(original_informationInput),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice))

newinformation <- newInformationVector(state=combinedData)


combinedData <- firstQuery <- list(original_goal = list(original_goalInput),
                                   information_vector = list(original_informationInput),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice),
                                   new_information = list(newinformation))

newGoal <- goalReAnalyzer(state=combinedData)


combinedData <- firstQuery <- list(original_goal = list(original_goalInput),
                                   information_vector = list(original_informationInput),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice),
                                   new_information = list(newinformation),
                                   new_goal = list(newGoal))

dataRow <- combinedData %>% as.data.frame()
colnames(dataRow) <- NULL

colnames(dataRow) <- c('original_goal','information_vector','choice_vector','subjective_feedback','objective_feedback','choice_chosen','new_information','new_goal')

decision_log <- dataRow

copy <- createNewRow(2)

decision_log <- rbind(decision_log,copy)
###############################
secondQuery <- list(original_goal = list(dataRow[1,'new_goal']),
                   information_vector = list(paste0(dataRow[1,'information_vector'],dataRow[1,'new_information'])))

choicesGenerated <- choiceGenerator(original_goal = secondQuery$original_goal[[1]], original_information = secondQuery$information_vector[[1]])


combinedData <- firstQuery <- list(current_goal = list(secondQuery$original_goal[[1]]),
                                   information_vector = list(secondQuery$information_vector[[1]]),
                                   choice_vector = list(choicesGenerated))

subjectiveAnalysis <- subjectiveAnalzyer(state = combinedData)
objectiveAnalysis <- objectiveAnalyzer(state = combinedData)

combinedData <- firstQuery <- list(current_goal = list(secondQuery$original_goal[[1]]),
                                   information_vector = list(secondQuery$information_vector[[1]]),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis))

chosenChoice <- choiceChooser(state=combinedData)

combinedData <- firstQuery <- list(current_goal = list(secondQuery$original_goal[[1]]),
                                   information_vector = list(secondQuery$information_vector[[1]]),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice))

newinformation <- newInformationVector(state=combinedData)


combinedData <- firstQuery <- list(current_goal = list(secondQuery$original_goal[[1]]),
                                   information_vector = list(secondQuery$information_vector[[1]]),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice),
                                   new_information = list(newinformation))

newGoal <- goalReAnalyzer(state=combinedData)


combinedData <- firstQuery <- list(current_goal = list(secondQuery$original_goal[[1]]),
                                   information_vector = list(secondQuery$information_vector[[1]]),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice),
                                   new_information = list(newinformation),
                                   new_goal = list(newGoal))
