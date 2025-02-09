library(dplyr)
library(httr)
library(jsonlite)


remove_parentheses <- function(text) {
  gsub("[()]", "", text)
}

remove_quotes <- function(text) {
  gsub("['\"]", "", text)
}


firstIteration <- function(i = 1, P, I){
  
  sink("output.txt")
  cat(paste0("P_1: ", P, "\n\n"))
  cat(paste0("I_1: ", I, "\n\n"))
  sink()
  
  
  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # Suggest choices
  command <- "aichat --model openai:gpt-4o-mini --rag ddm --role choiceGenerator 'Suggest the possible choices to consider given P_1 and I_1. Return only the choices in plaintext'"
  outputChoices <- system(command, intern = TRUE)
  cat(paste0("\nD_", i, ":"), file="output.txt", append=TRUE)
  cat(outputChoices, file="output.txt", append=TRUE)


  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

# Subjective analysis
command3 <- "aichat --model openai:gpt-4o-mini --rag ddm 'Perform a subjective analysis. Suggest one of the choices in the first person. Return only a plaintext paragraph.'"
outputSubjective <- system(command3, intern = TRUE)
cat(paste0("\n\nSubjective Analysis_", i, ": \n", outputSubjective, "\n"), file="output.txt", append=TRUE)

# Objective analysis
command4 <- "aichat --model openai:gpt-4o-mini --rag ddm 'Perform an objective analysis. Suggest one of the choices in the first person. Return only a plaintext paragraph.'"
outputObjective <- system(command4, intern = TRUE)
cat(paste0("\nObjective Analysis_", i, ": \n", outputObjective, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # Choose choice
  command5 <- "aichat --model openai:gpt-4o-mini --rag ddm 'Based on the situation and analyses, choose one specific choice from the set. Return only the choice.'"
  outputChosenChoice <- system(command5, intern = TRUE)
  cat(paste0("\nChoiceChosen_", i, ": \n", outputChosenChoice, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # New Info
  infoPromptCustom = paste0("aichat --model openai:gpt-4o-mini --rag ddm Consider P_1 goal. Consider the analyses in Subjective Analysis_",i," and Objective Analysis_",i,". Consider that the ChoiceChosen_",i,"has been chosen. Summarize the new information gained in iteration ",i,". Return back maximum 1 or 2 sentences in plaintext.")
  #command6 <- "aichat --model openai:gpt-4o-mini --rag ddm 'Summarize new information learned so far in iteration. Return only the text as I_delta. Plaintext 1 paragraph max.'"
  infoPromptCustom = remove_parentheses(infoPromptCustom)
  infoPromptCustom = remove_quotes(infoPromptCustom)
  outputNewInfo <- system(infoPromptCustom, intern = TRUE)
  cat(paste0("\nNewInfo_", i, ": \n", outputNewInfo, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # New Goal
  command7 <-paste0("aichat --model openai:gpt-4o-mini --rag ddm Consider P_1 as having progressed onwards. Consider ChoiceChosen_",i," as the next choice taken. Consider new information gained in NewInfo_",i,". Realign your current goal to proceed progressively to the next step in achieving the master plan in P_1. Return only a single statement with the new goal. The new goal statement should differ from the previous P_1")
  #command7 <- "aichat --model openai:gpt-4o-mini --rag ddm 'Based on the information from this step, suggest a new goal for the next step. Return only the goal.'"
  command7 <- remove_parentheses(command7)
  command7 <- remove_quotes(command7)
  
  outputNewGoal <- system(command7, intern = TRUE)
  cat(paste0("\nNewGoal_", i, ": \n", outputNewGoal, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  
  combinedData  <- list(original_goal = list(P),
                        information_vector = list(I),
                        choice_vector = list(paste0(outputChoices,collapse=" ")),
                        subjective_feedback = list(paste0(outputSubjective,collapse=" ")),
                        objective_feedback = list(paste0(outputObjective,collapse=" ")),
                        choice_chosen = list(paste0(outputChosenChoice,collapse=" ")),
                        new_information = list(paste0(outputNewInfo,collapse=" ")),
                        new_goal = list(paste0(outputNewGoal,collapse=" ")))
  
  dataRow <- combinedData %>% as.data.frame()
  colnames(dataRow) <- NULL
  
  colnames(dataRow) <- c('original_goal','information_vector','choice_vector','subjective_feedback','objective_feedback','choice_chosen','new_information','new_goal')
  
  decision_log <- dataRow
  
  # Update for next iteration
  I <- outputNewInfo  # Carry forward new information
  P <- outputNewGoal   # Update the goal for the next step
  
  return(decision_log)
  
}

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

continue_run <- function(i, choicePromptCustom = NULL,
                         subjectivePromptCustom = NULL,
                         objectivePromptCustom = NULL,
                         chosenPromptCustom = NULL,
                         infoPromptCustom = NULL,
                         newGoalPromptCustom = NULL){
  

    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)

    #Suggest choices
  command <- paste0("aichat --model openai:gpt-4o-mini --rag ddm ",choicePromptCustom)
  
  
  outputChoices <- system(command, intern = TRUE)
   cat(paste0("\nD_", i, ":"), file="output.txt", append=TRUE)
   cat(outputChoices, file="output.txt", append=TRUE)
     
    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)

    #Subjective analysis
   command3 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm ",subjectivePromptCustom)
   outputSubjective <- system(command3, intern = TRUE)
   cat(paste0("\n\nSubjective Analysis_", i, ": \n", outputSubjective, "\n"), file="output.txt", append=TRUE)


    #Objective analysis
   command4 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm ",objectivePromptCustom)
   outputObjective <- system(command4, intern = TRUE)
   cat(paste0("\nObjective Analysis_", i, ": \n", outputObjective, "\n"), file="output.txt", append=TRUE)

    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)


    #Choose choice
   command5 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm ",chosenPromptCustom)
   outputChosenChoice <- system(command5, intern = TRUE)
   cat(paste0("\nChoiceChosen_", i, ": \n", outputChosenChoice, "\n"), file="output.txt", append=TRUE)

    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)


    #New Info
   command6 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm ",infoPromptCustom)
   outputNewInfo <- system(command6, intern = TRUE)
   cat(paste0("\nNewInfo_", i, ": \n", outputNewInfo, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # New Goal
  command7 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm ",newGoalPromptCustom)
  outputNewGoal <- system(command7, intern = TRUE)
  cat(paste0("\nNewGoal_", i, ": \n", outputNewGoal, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  
  combinedData <- firstQuery <- list(original_goal = list(decision_log[i,'original_goal']),
                                     information_vector = list(decision_log[i,'information_vector']),
                                     choice_vector = list(paste0(outputChoices,collapse=" ")),
                                     subjective_feedback = list(paste0(outputSubjective,collapse=" ")),
                                     objective_feedback = list(paste0(outputObjective,collapse=" ")),
                                     choice_chosen = list(paste0(outputChosenChoice,collapse=" ")),
                                     new_information = list(paste0(outputNewInfo,collapse=" ")),
                                     new_goal = list(paste0(outputNewGoal,collapse=" ")))

  
  dataRow <- combinedData %>% as.data.frame()
  colnames(dataRow) <- NULL
  
  colnames(dataRow) <- c('original_goal','information_vector','choice_vector','subjective_feedback','objective_feedback','choice_chosen','new_information','new_goal')
  
  
  # Update for next iteration
  I <- outputNewInfo  # Carry forward new information
  P <- outputNewGoal   # Update the goal for the next step
  
  return(dataRow)
  
  
}




# Initial settings
P <- 'Plan a traditional Shabbat dinner for 7. Moroccan style. Focus on the cooking elements. The process should iterate and end up with a planned meal - only food focus'
I <- 'I have access to a Kosher market with everything I need. I also have a nearby liquor store. I am only time-constrained because its Thursday night'

decision_log <-firstIteration(P = P, I = I)


#decision_log <- readr::read_csv("./newMethod2.csv")


n = 5

for(i in 2:n){

  choicePromptCustom = paste0("Consider NewGoal_",i-1," as the new goal. Consider ChoiceChosen_",i-1," as already accomplished.Propose new choices for iteration ",i,". The proposed choices should be different than previously made choices. Return the choices in plaintext. Only the choices. EXCLUDE: ",decision_log$choice_chosen %>% paste(collapse=" ")," Ensure that the new goal is still  very much aligned with the overarching goal of P_1 and in fact is an iterative process related to P_1. The goal should proceed from NewGoal_",i," and ChosenChoice_",i)
  choicePromptCustom = remove_parentheses(choicePromptCustom)
  choicePromptCustom = remove_quotes(choicePromptCustom)
  
  subjectivePromptCustom = paste0("Consider NewGoal_",i-1," as the new goal. Consider ChoiceChosen_",i-1," as already accomplished. Subjectively analyze the choices proposed in D_",i,". Return the analysis in plaintext max 1 paragraph")
  subjectivePromptCustom = remove_parentheses(subjectivePromptCustom)
  subjectivePromptCustom = remove_quotes(subjectivePromptCustom)
  
  objectivePromptCustom = paste0("Consider NewGoal_",i-1," as the new goal. Consider ChoiceChosen_",i-1," as already accomplished. Objectively analyze the choices proposed in D_",i,". Return the analysis in plaintext max 1 paragraph")
  objectivePromptCustom = remove_parentheses(objectivePromptCustom)
  objectivePromptCustom = remove_quotes(objectivePromptCustom)
  
  chosenPromptCustom = paste0("Consider NewGoal_",i-1," as the new goal. Consider ChoiceChosen_",i-1," as already accomplished. Consider the analyses in Subjective Analysis_",i," and Objective Analysis_",i,". Choose one choice from D_",i,". Return ONLY the chosen choice and nothing else. The chosen choice must exclude all previously chosen choices. EXCLUDE: ",decision_log$choice_chosen %>% paste(collapse=" "))
  chosenPromptCustom = remove_parentheses(chosenPromptCustom)
  chosenPromptCustom = remove_quotes(chosenPromptCustom)
  
  infoPromptCustom = paste0("Consider NewGoal_",i-1," as the new goal. Consider ChoiceChosen_",i-1," as already accomplished. Consider the analyses in Subjective Analysis_",i," and Objective Analysis_",i,". Consider that the ChoiceChosen_",i,"has been chosen as the next step. Summarize the new information gained from considering choices D_",i," and determining to choose ChoiceChosen_",i," Return back maximum 1 or 2 sentences in plaintext.")
  infoPromptCustom = remove_parentheses(infoPromptCustom)
  infoPromptCustom = remove_quotes(infoPromptCustom)
  
  newGoalPromptCustom = paste0("Consider NewGoal_",i-1," as having progressed onwards. Consider ChoiceChosen_",i," as the next choice taken. Consider new information gained in NewInfo_",i,". Realign your current goal to proceed progressively to the next step in achieving the master plan in P_1. Return only a single statement with the new goal. The new goal statement should differ from the previous NewGoal_",i-1," and differ from all previous new goals. EXCLUDE: ",decision_log$new_goal %>% paste(collapse=" "),". However, the new goal should be a refined progress from NewGoal_",i-1, " and logically proceed towards the grand goal of P_1.")
  newGoalPromptCustom = remove_parentheses(newGoalPromptCustom)
  newGoalPromptCustom = remove_quotes(newGoalPromptCustom)
  

  copy <- createNewRow(i)
  decision_log <- rbind(decision_log,copy)
  #######################
  newRow <- continue_run(i=i,choicePromptCustom = choicePromptCustom,
                         subjectivePromptCustom = subjectivePromptCustom,
                         objectivePromptCustom = objectivePromptCustom,
                         chosenPromptCustom = chosenPromptCustom,
                         infoPromptCustom = infoPromptCustom,
                         newGoalPromptCustom = newGoalPromptCustom)
  decision_log[i,] <- newRow

}

readr::write_csv(decision_log,'./dinner.csv')


