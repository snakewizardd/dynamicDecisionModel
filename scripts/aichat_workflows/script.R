library(dplyr)
library(httr)
library(jsonlite)


P_null = 'I want to be a crypto billionaire'

sink("output.txt")
cat(paste0("P_null: ",P_null))
sink()

cat("\n",file="output.txt",append=TRUE, sep = '\n')


I_0 = "I live in subsaharan africa in a shed with no internet and have only $35 to my name"

cat(paste0("I_0: ",I_0),file="output.txt",append=TRUE, sep = '\n')


#cat(I_0,file="output.txt",append=TRUE, sep = '\n')

command <- "aichat --rag ddm --role choiceGenerator 'Suggest the possible choices for this iteration. Return the choices only, no other text whatsoever. its a vector of possible choices for one to be selected'"

outputChoices <- system(command,intern=TRUE)

#print(outputChoices)

cat("D_1: ",file="output.txt",append=TRUE, sep = '\n')

command2 <- "aichat --rag ddm --rebuild-rag"

cat(outputChoices,file="output.txt",append=TRUE, sep = '\n')

