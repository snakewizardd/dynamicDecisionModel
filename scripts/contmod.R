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

#original_goalInput <- "become a crypto billionare"

#original_informationInput <- "i have 35$ to my name and i live in sub saharan africa under a shed with no internet"

firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                   information_vector = list(decision_log[i,'information_vector']))

choicesGenerated <- choiceGenerator(original_goal = decision_log[i,'original_goal'], original_information = decision_log[i,'information_vector'])

combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                   information_vector = list(decision_log[i,'information_vector']),
                                   choice_vector = list(choicesGenerated))

subjectiveAnalysis <- subjectiveAnalzyer(state = combinedData)
objectiveAnalysis <- objectiveAnalyzer(state = combinedData)

combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                   information_vector = list(decision_log[i,'information_vector']),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis))

chosenChoice <- choiceChooser(state=combinedData)

combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                   information_vector = list(decision_log[i,'information_vector']),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice))

newinformation <- newInformationVector(state=combinedData)


combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                   information_vector = list(decision_log[i,'information_vector']),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice),
                                   new_information = list(newinformation))

newGoal <- goalReAnalyzer(state=combinedData)


combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                   information_vector = list(decision_log[i,'information_vector']),
                                   choice_vector = list(choicesGenerated),
                                   subjective_feedback = list(subjectiveAnalysis),
                                   objective_feedback = list(objectiveAnalysis),
                                   choice_chosen = list(chosenChoice),
                                   new_information = list(newinformation),
                                   new_goal = list(newGoal))

dataRow <- combinedData %>% as.data.frame()
colnames(dataRow) <- NULL

colnames(dataRow) <- c('original_goal','information_vector','choice_vector','subjective_feedback','objective_feedback','choice_chosen','new_information','new_goal')

decision_log[i,] <- dataRow

#copy <- createNewRow(3)

#decision_log <- rbind(decision_log,copy)