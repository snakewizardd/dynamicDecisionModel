source("./scripts/functions.R")

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

firstRun <- function(original_goalInput, original_informationInput){

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



return(decision_log)

}

continue_run <- function(i){
  
  firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                     information_vector = list(decision_log[i,'information_vector']))
  
  constraint <- paste0("YOU MAY NOT SUGGEST ANY CHOICES THAT WERE ALREADY ENACTED BY THE USER. THOSE CHOICES ARE AS FOLLOWS - DO NOT
  SUGGEST THOSE OR OTHERS WHICH COULD BE CONSIDERED EQUIVALENT ", unique(decision_log$choice_chosen) %>% as.character())
  
  #paste0()
  
  choicesGenerated <- choiceGenerator(original_goal = decision_log[i,'original_goal'], original_information = decision_log[i,'information_vector'],
                                      constraints = constraint)
  
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
  
  
  constraint <- paste0("YOU MAY NOT SUGGEST ANY CHOICES THAT WERE ALREADY ENACTED BY THE USER. THOSE CHOICES ARE AS FOLLOWS - DO NOT
  SUGGEST THOSE OR OTHERS WHICH COULD BE CONSIDERED EQUIVALENT ", unique(decision_log$choice_chosen) %>% as.character())
  
  dataWithConstraint <- paste0(combinedData, constraint)
  
  chosenChoice <- choiceChooser(state=dataWithConstraint)
  
  combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                     information_vector = list(decision_log[i,'information_vector']),
                                     choice_vector = list(choicesGenerated),
                                     subjective_feedback = list(subjectiveAnalysis),
                                     objective_feedback = list(objectiveAnalysis),
                                     choice_chosen = list(chosenChoice))
  
  constraint <- paste0("AT THIS STEP YOU MAY HAVE A LOT OF CONTROL OVER HOW TO INTERNALIZE INFORMATION. DEPENDING ON YOUR INTERPRETATION, 
                       DOWNSTREAM THERE ARE EFFECTS, THUS CONSIDER IT WISELY")

  
  dataWithConstraint <- paste0(combinedData, constraint)
  
  
  newinformation <- newInformationVector(state=dataWithConstraint)
  
  
  
  combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                     information_vector = list(decision_log[i,'information_vector']),
                                     choice_vector = list(choicesGenerated),
                                     subjective_feedback = list(subjectiveAnalysis),
                                     objective_feedback = list(objectiveAnalysis),
                                     choice_chosen = list(chosenChoice),
                                     new_information = list(newinformation))
  
  constraint <- paste0("YOU MAY NOT DECLARE YOUR NEW GOAL TO BE ANYTHING IDENTICAL (AND I MEAN SEMANTICALLY IDENTICAL) TO PREVIOUS DECLARED GOALS
                       ", unique(decision_log$original_goal) %>% as.character())
  
  dataWithConstraint <- paste0(combinedData, constraint)
  
  
  constraint <- paste0("CONSTRAINT: YOU SHOULD KEEP IN MIND THAT THE RATE OF CHANGE IS ROUGHLY SPEAKING WITHIN THE CAPABILITY OF A HUMAN BEING WITHIN A CONSTRAINED PERIOD OF TIME
                       PLEASE DO NOT TRY TO OVEREXTEND AND SUGGEST DRASTICALLY UNACHEIVABLE GOALS WITHIN THE RATE OF CHANGE OF A REGULAR HUMAN BEING. ALSO KEEP IN MIND THE OVERARCHING
                       ORIGINAL GOAL OF", decision_log[1,'original_goal'], " AND ALWAYS FINETUNE YOUR GOALS, EVEN IF THEY ARE DIVERGENT, TOWARDS THE EVENTUAL END GOAL")
  
  
  newGoal <- goalReAnalyzer(state=dataWithConstraint)
  
  
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
  
  
  return(dataRow)
  #copy <- createNewRow(3)
  
  #decision_log <- rbind(decision_log,copy)
  
}

original_goalInput <- "become a crypto billionare"
original_informationInput <- "i have 35$ to my name and i live in sub saharan africa under a shed with no internet"
decision_log <- firstRun(original_goalInput = original_goalInput, original_informationInput = original_informationInput)


n = 5

for(i in 2:n){
  
copy <- createNewRow(i)
decision_log <- rbind(decision_log,copy)
#######################
newRow <- continue_run(i)
decision_log[i,] <- newRow

}

readr::write_csv(decision_log,'./newmod.csv')
