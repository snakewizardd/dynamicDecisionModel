library(dplyr)
library(httr)
library(jsonlite)

firstIteration <- function(i = 1){

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # Suggest choices
  command <- "aichat --model openai:gpt-4o-mini --rag ddm --role choiceGenerator 'Suggest the possible choices for this iteration. Return only the choices in plaintext'"
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
  command6 <- "aichat --model openai:gpt-4o-mini --rag ddm 'Summarize new information learned so far in iteration. Return only the text as I_delta. Plaintext 1 paragraph max.'"
  outputNewInfo <- system(command6, intern = TRUE)
  cat(paste0("\nNewInfo_", i, ": \n", outputNewInfo, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # New Goal
  command7 <- "aichat --model openai:gpt-4o-mini --rag ddm 'Based on the information from this step, suggest a new goal for the next step. Return only the goal.'"
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

continue_run <- function(i){
  

    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)

    #Suggest choices
  command <- paste0("aichat --model openai:gpt-4o-mini --rag ddm using the newly delcared goal from iteration ",i-1," and considering all previous choices as already DONE, suggest the next choices for the iteration. in plaintext ")
  outputChoices <- system(command, intern = TRUE)
   cat(paste0("\nD_", i, ":"), file="output.txt", append=TRUE)
   cat(outputChoices, file="output.txt", append=TRUE)
     
    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)

    #Subjective analysis
   command3 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm in order to advance the current goal in iteration ",i," and considering all previous choices as already DONE, what subjectively should we choose next based on the currently proposed choices")
   outputSubjective <- system(command3, intern = TRUE)
   cat(paste0("\n\nSubjective Analysis_", i, ": \n", outputSubjective, "\n"), file="output.txt", append=TRUE)


    #Objective analysis
   command4 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm in order to advance the current goal in iteration ",i," and considering all previous choices as already DONE, what objectively should we choose next based on the currently proposed choices")
   outputObjective <- system(command4, intern = TRUE)
   cat(paste0("\nObjective Analysis_", i, ": \n", outputObjective, "\n"), file="output.txt", append=TRUE)

    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)


    #Choose choice
   command5 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm based on the subjective and objective analyses from iteration ",i," choose a choice from the choices proposed in iteration ",i,". only return the chosen choice")
   outputChosenChoice <- system(command5, intern = TRUE)
   cat(paste0("\nChoiceChosen_", i, ": \n", outputChosenChoice, "\n"), file="output.txt", append=TRUE)

    #Sync RAG DB
   system("aichat --rag ddm --rebuild-rag", intern = TRUE)


    #New Info
   command6 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm Considering that ALL previous choices were actualized, and the current choice made, summarize the newly acquired information from iteration ",i," given the analyses from iteration ",i," and the choice taken in iteration ",i,". Return your answer in plaintext and short.")
   outputNewInfo <- system(command6, intern = TRUE)
   cat(paste0("\nNewInfo_", i, ": \n", outputNewInfo, "\n"), file="output.txt", append=TRUE)

  # Sync RAG DB
  system("aichat --rag ddm --rebuild-rag", intern = TRUE)

  # New Goal
  command7 <- paste0("aichat --model openai:gpt-4o-mini --rag ddm consider that the choice taken in iteration ",i-1," is accomplished, and we have chosen to do the choice in iteration ",i,", realign the new goal. return only the new goal")
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
P <- 'I want to be a crypto billionaire'
I <- "I live in Sub-Saharan Africa in a shed with no internet and have only $35 to my name"

sink("output.txt")
cat(paste0("P_1: ", P, "\n\n"))
cat(paste0("I_1: ", I, "\n\n"))
sink()

decision_log <-firstIteration()

n = 15

for(i in 2:n){

  copy <- createNewRow(i)
  decision_log <- rbind(decision_log,copy)
  #######################
  newRow <- continue_run(i)
  decision_log[i,] <- newRow

}

readr::write_csv(decision_log,'./newMethod1.csv')


