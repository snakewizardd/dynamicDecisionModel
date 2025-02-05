library(httr)
library(jsonlite)
#library(dotenv)
library(dplyr)


choiceGenerator <- function(original_goal,original_information, constraints = NULL){
  
  url <- "http://host.docker.internal:3000/api/v1/prediction/095ead8d-54fa-4b43-bd42-da04f06ad25a"
  
  
  payload <- list(
    question = paste0("Original Goal- ",original_goal, "+ ", "Original Information- ", original_information) , " ", constraints)
  
  response <- POST(
    url,
    add_headers(
      "Content-Type" = "application/json"
    ),
    body = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  return(content(response)$text)
}

subjectiveAnalzyer <- function(state){
  
  
  
  url <- "http://host.docker.internal:3000/api/v1/prediction/4077eab3-fbad-462d-aaa8-063ce634e074"
  
  payload <- list(
    question = state)
  
  response <- POST(
    url,
    add_headers(
      "Content-Type" = "application/json"
    ),
    body = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  return(content(response)$text)
}

objectiveAnalyzer <- function(state){
  
  url <- "http://host.docker.internal:3000/api/v1/prediction/671d04e2-0e79-44c5-99f4-be0eaaf383b4"
  
  payload <- list(
    question = state)
  
  response <- POST(
    url,
    add_headers(
      "Content-Type" = "application/json"
    ),
    body = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  return(content(response)$text)
}

choiceChooser <- function(state, constraints = NULL){
  
  url <- "http://host.docker.internal:3000/api/v1/prediction/c556616f-35f7-47cd-acc8-825cbc8307dc"
  
  payload <- list(
    question = state)
  
  response <- POST(
    url,
    add_headers(
      "Content-Type" = "application/json"
    ),
    body = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  return(content(response)$text)
  
}

newInformationVector <- function(state){
  
  
  url <- "http://host.docker.internal:3000/api/v1/prediction/db4d1260-2b53-43c4-a343-11ffa0475900"
  
  payload <- list(
    question = state)
  
  response <- POST(
    url,
    add_headers(
      "Content-Type" = "application/json"
    ),
    body = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  return(content(response)$text)
}

goalReAnalyzer <- function(state){
  
  
  url <- "http://host.docker.internal:3000/api/v1/prediction/8b10f724-a9fe-434d-a429-d93b4518c761"
  
  payload <- list(
    question = state)
  
  response <- POST(
    url,
    add_headers(
      "Content-Type" = "application/json"
    ),
    body = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  return(content(response)$text)
  
  
}

createNewRow <- function(i){
  
  copy <- decision_log[1,]
  copy[0,]
  copy[1,'iteration'] <- i
  copy[1,'original_goal'] <- decision_log[1,'original_goal']
  copy[1,"adjusted_goal"] <- decision_log[i - 1,'new_goal']
  copy[1,'information_vector'] <- paste0(decision_log[i - 1,'information_vector'], decision_log[i - 1,'new_information_vector'])
  copy[1,'choices_for_step'] <- NA
  copy[1,'subjective_feedback'] <- NA
  copy[1,'objective_feedback'] <- NA
  copy[1,'choice_chosen'] <- NA
  copy[1,'new_information_vector'] <- NA
  copy[1,'new_goal'] <- NA
  
  return(copy)
  
}

firstRunInit <- function(original_goal, original_information){
  
  choicesGenerated <- choiceGenerator(original_goal = original_goalInput,
                                      original_information = original_informationInput)
  
  decision_log <- data.frame(
    iteration = integer(),
    original_goal = character(),
    adjusted_goal = character(),
    information_vector = list(),
    choices_for_step = list(),
    subjective_feedback = list(),
    objective_feedback = list(),
    choice_chosen = character(),
    new_information_vector = list(),
    new_goal = character(),
    stringsAsFactors = FALSE
  )
  
  decision_log[1,'iteration'] <- 1
  decision_log[1,'original_goal'] <- original_goalInput
  decision_log[1,'adjusted_goal'] <- "N/A yet"
  decision_log[1,'information_vector'] <- original_informationInput
  decision_log[1,'choices_for_step'] <- choicesGenerated
  
  
  state <- paste0("Original Goal- ",
                  decision_log[1,'original_goal'],
                  "Information Vector - ",
                  decision_log[1,'information_vector'],
                  "Choice Vector -",
                  decision_log[1,'choices_for_step'])
  
  
  subjectiveFeedback <- subjectiveAnalzyer(state)
  
  decision_log[1,'subjective_feedback'] <- subjectiveFeedback
  
  
  objectiveFeedback <- objectiveAnalyzer(state)
  
  
  decision_log[1,'objective_feedback'] <- objectiveFeedback
  
  state <- paste0("Original Goal- ",
                  decision_log[1,'original_goal'],
                  "Information Vector - ",
                  decision_log[1,'information_vector'],
                  "Choice Vector -",
                  decision_log[1,'choices_for_step'],
                  "Subjective Analysis - ",
                  decision_log[1,'subjective_feedback'],
                  
                  "Objective Analysis -",
                  decision_log[1,'objective_feedback']
                  
  )
  
  
  choiceChosen <- choiceChooser(state)
  
  
  decision_log[1,'choice_chosen'] <- choiceChosen
  
  
  state <- paste0("Original Goal- ",
                  decision_log[1,'original_goal'],
                  "Information Vector - ",
                  decision_log[1,'information_vector'],
                  "Choice Vector -",
                  decision_log[1,'choices_for_step'],
                  "Subjective Analysis - ",
                  decision_log[1,'subjective_feedback'],
                  
                  "Objective Analysis -",
                  decision_log[1,'objective_feedback'],
                  "Choice Taken - ",
                  decision_log[1,'choice_chosen']
                  
                  
  )
  
  
  
  newInformation <- newInformationVector(state)
  
  decision_log[1,'new_information_vector'] <- newInformation
  
  state <- paste0("Original Goal- ",
                  decision_log[1,'original_goal'],
                  "Information Vector - ",
                  decision_log[1,'information_vector'],
                  "Choice Vector -",
                  decision_log[1,'choices_for_step'],
                  "Subjective Analysis - ",
                  decision_log[1,'subjective_feedback'],
                  
                  "Objective Analysis -",
                  decision_log[1,'objective_feedback'],
                  "Choice Taken - ",
                  decision_log[1,'choice_chosen'],
                  'New Information Acquired - ',
                  decision_log[1,'new_information_vector']
  )
  
  
  
  newlyDeclaredGoal <- goalReAnalyzer(state)
  
  
  decision_log[1,'new_goal'] <- newlyDeclaredGoal
  
  return(decision_log)
  
}

continueIteration <- function(i){
  
  original_goal <- decision_log[i - 1,'original_goal']
  new_goal <- decision_log[i,'adjusted_goal']
  information_vector <- paste0(decision_log[i - 1,'information_vector'],decision_log[i-1,'new_information_vector'])
  
  decision_log[i,'information_vector'] <- information_vector
  
  fullChoiceList <- decision_log[,'choice_chosen'] %>% unique() %>% as.character() %>% paste()
  
  payload <- list(
    question = paste0("Goal- ",new_goal, "+ ", " Information- ", information_vector,
                      'Contraint - choices suggested must not include previously made choices in any way. Only new options',
                      fullChoiceList))
  
  choiceVector <- choiceGenerator(original_goal = original_goal, original_information = information_vector)
  
  
  decision_logRow <- data.frame(
    iteration = integer(),
    original_goal = character(),
    adjusted_goal = character(),
    information_vector = list(),
    choices_for_step = list(),
    subjective_feedback = list(),
    objective_feedback = list(),
    choice_chosen = character(),
    new_information_vector = list(),
    new_goal = character(),
    stringsAsFactors = FALSE
  )
  
  decision_logRow[1,'iteration'] <- i
  decision_logRow[1,'original_goal'] <- decision_log[i - 1,'original_goal']
  decision_logRow[1,'adjusted_goal'] <- decision_log[i - 1,'new_goal']
  decision_logRow[1,'information_vector'] <- information_vector
  
  decision_logRow[1,'choices_for_step'] <- choiceVector
  
  
  state <- paste0("Current Goal- ",
                  decision_logRow[1,'adjusted_goal'],
                  "Information Vector - ",
                  decision_logRow[1,'information_vector'],
                  "Choice Vector -",
                  decision_logRow[1,'choices_for_step'])
  
  
  payload <- list(
    question = state)
  
  subjectiveFeedback <- subjectiveAnalzyer(state = payload)
  decision_logRow[1,'subjective_feedback'] <- subjectiveFeedback
  
  objectiveFeedback <- objectiveAnalyzer(state = payload)
  decision_logRow[1,'objective_feedback'] <- objectiveFeedback
  
  state <- paste0("Current Goal- ",
                  decision_logRow[1,'adjusted_goal'],
                  "Information Vector - ",
                  decision_logRow[1,'information_vector'],
                  "Choice Vector -",
                  decision_logRow[1,'choices_for_step'],
                  "Subjective Analysis - ",
                  decision_logRow[1,'subjective_feedback'],
                  
                  "Objective Analysis -",
                  decision_logRow[1,'objective_feedback'],
                  'Contraint - choices suggested must not include previously made choices in any way. Only new options',
                  fullChoiceList
                  
  )
  
  chosenChoice <- choiceChooser(state)
  
  
  
  decision_logRow[1,'choice_chosen'] <- chosenChoice
  
  state <- paste0("Current Goal- ",
                  decision_logRow[1,'adjusted_goal'],
                  "Information Vector - ",
                  decision_logRow[1,'information_vector'],
                  "Choice Vector -",
                  decision_logRow[1,'choices_for_step'],
                  "Subjective Analysis - ",
                  decision_logRow[1,'subjective_feedback'],
                  
                  "Objective Analysis -",
                  decision_logRow[1,'objective_feedback'],
                  "Choice Taken - ",
                  decision_logRow[1,'choice_chosen']
                  
                  
  )
  
  
  newInformation <- newInformationVector(state)
  
  
  
  decision_logRow[1,'new_information_vector'] <- newInformation
  
  
  
  
  
  state <- paste0("Current Goal- ",
                  decision_logRow[1,'adjusted_goal'],
                  "Information Vector - ",
                  decision_logRow[1,'information_vector'],
                  "Choice Vector -",
                  decision_logRow[1,'choices_for_step'],
                  "Subjective Analysis - ",
                  decision_logRow[1,'subjective_feedback'],
                  
                  "Objective Analysis -",
                  decision_logRow[1,'objective_feedback'],
                  "Choice Taken - ",
                  decision_logRow[1,'choice_chosen'],
                  'New Information Acquired - ',
                  decision_logRow[1,'new_information_vector']
                  
                  
                  
  )
  
  
  
  fullGoalList <- decision_log[,'adjusted_goal'] %>% unique() %>% as.character() %>% paste()
  
  
  payload <- list(
    question = paste0(state, "Constraint - you must always pick a new goal different than previously chosen goals ", fullGoalList)
  )
  
  
  newlyDeclaredGoal <- goalReAnalyzer(state)
  
  
  decision_logRow[1,'new_goal'] <- newlyDeclaredGoal
  
  
  decision_logRow <- decision_logRow %>% select(colnames(decision_log))
  
  return(decision_logRow)
  
}