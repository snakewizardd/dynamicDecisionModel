library(dplyr)
library(httr)
library(jsonlite)


#########INITIAL SETTINGS
P_null = 'I want to be a crypto billionaire'

sink("output.txt")
cat(paste0("P_null: ",P_null))
sink()

cat("\n",file="output.txt",append=TRUE, sep = '\n')


I_0 = "I live in subsaharan africa in a shed with no internet and have only $35 to my name"

cat(paste0("I_0: ",I_0),file="output.txt",append=TRUE, sep = '\n')


cat(I_0,file="output.txt",append=TRUE, sep = '\n')

#######SYNC RAG DB
command2 <- "aichat --rag ddm --rebuild-rag"
system(command2,intern=TRUE)

#######SUGGEST CHOICES
command <- "aichat --model openai:gpt-4o-mini --rag ddm --role choiceGenerator 'Suggest the possible choices for this iteration. Return the choices only, no other text whatsoever. its a vector of possible choices for one to be selected'"
outputChoices <- system(command,intern=TRUE)
#print(outputChoices)
cat(paste0("\nD_1: "),file="output.txt",append=TRUE, sep = '\n')
cat(outputChoices,file="output.txt",append=TRUE, sep = '\n')

#######SYNC RAG DB
command2 <- "aichat --rag ddm --rebuild-rag"
system(command2,intern=TRUE)

#####SUBJECTIVE ANALYSIS
command3 <- "aichat --model openai:gpt-4o-mini --rag ddm Hey perform a subjective analysis and suggest one of the choices please in 1st person. should be a plaintext paragraph"
outputSubjective <- system(command3,intern=TRUE)
outputStringSubjective <- paste0('\nSubjective Analysis_1: \n',outputSubjective)
cat(outputStringSubjective,file="output.txt",append=TRUE, sep = '\n')

#####OBJECTIVE ANALYSIS
command4 <- "aichat --model openai:gpt-4o-mini --rag ddm Hey perform an objective analysis and suggest one of the choices please in 1st person. should be a plaintext paragraph"
outputObjective <- system(command4,intern=TRUE)
outputStringObjective <- paste0('\nObjective Analysis_1: \n',outputObjective)
cat(outputStringObjective,file="output.txt",append=TRUE, sep = '\n')

#######SYNC RAG DB
command2 <- "aichat --rag ddm --rebuild-rag"
system(command2,intern=TRUE)

#####CHOOSE CHOICE
command5 <- "aichat --model openai:gpt-4o-mini --rag ddm Based on the situation and analyses, choose one specific choice from the choice set. Output only the choice"
outputChosenChoice <- system(command5,intern=TRUE)
outputStringChosenChoice <- paste0('\nChoiceChosen_1: \n',outputChosenChoice)
cat(outputStringChosenChoice,file="output.txt",append=TRUE, sep = '\n')


#######SYNC RAG DB
command2 <- "aichat --rag ddm --rebuild-rag"
system(command2,intern=TRUE)

#####NEW INFO
command6 <- "aichat --model openai:gpt-4o-mini --rag ddm okay so what new information did we learn so far in iteration 1. Construct an output for I_Delta from this stage. output just a sentence or sentences to consider as I_delta_1. no other text. in 1st person objective"
outputNewInfo <- system(command6,intern=TRUE)
outputStringNewInfo <- paste0('\nNewInfo_1: \n',outputNewInfo)
cat(outputStringNewInfo,file="output.txt",append=TRUE, sep = '\n')

#######SYNC RAG DB
command2 <- "aichat --rag ddm --rebuild-rag"
system(command2,intern=TRUE)

#####NEW GOAL
command7 <- "aichat --model openai:gpt-4o-mini --rag ddm based on the information in the step 1 suggest a new goal for step 2. only output the text of the new goal"
outputNewGoal <- system(command7,intern=TRUE)
outputStringNewGoal<- paste0('\nNewGoal_1: \n',outputNewGoal)
cat(outputStringNewGoal,file="output.txt",append=TRUE, sep = '\n')


