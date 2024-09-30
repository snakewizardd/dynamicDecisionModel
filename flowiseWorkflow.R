library(dplyr)
library(jsonlite)
library(httr)
library(readr)


#Add the user generated message to the message qeue
addUserMessage <- function(userMessage){
  
  processMessgae <- list(role = "user", content = userMessage)
  
  messages[[length(messages) + 1]] <<- processMessgae
}

#Ping the chat completions API endpoint
pingAPI <- function(userInputMessage,
                    agentType
){
    
  url <- switch(agentType,
                "Semantic" = "http://localhost:3000/api/v1/prediction/d620d45d-750a-45b7-9900-4bc9ac13e72c",
                "GoalGenerator"    = "http://localhost:3000/api/v1/prediction/92502b56-bde9-48c6-9cd4-7fa563666e99",
                "GoalAnalyzer"  = "http://localhost:3000/api/v1/prediction/bd79ea04-1be7-4326-a183-ab0a1e0fe7f9",
                "ChoiceChooser"  = "http://localhost:3000/api/v1/prediction/26575dec-2b88-4efb-ab70-74b9437463dc",
                "DifferenceVector"  = "http://localhost:3000/api/v1/prediction/af210555-fba4-4fc6-9c11-0a1742dd4313",
                "GoalReAnalyzer"  = "http://localhost:3000/api/v1/prediction/9889de60-3c60-4063-95cb-39fb837df919",
                "http://localhost:3000/api/v1/prediction/d620d45d-750a-45b7-9900-4bc9ac13e72c" # default case
  )
  
  
  body <- list(
    question = userInputMessage
  )
  
  response <- POST(
    url,
    add_headers(
      `Content-Type`="application/json"),
    body = body,
    encode = "json"
  )
  
  
  
  aiResponseFormatted<- list(
    role = "assistant",
    content = content(response)$text
  )
  
  messages[[length(messages) + 1]] <<- aiResponseFormatted
  
  print(aiResponseFormatted$content)
}

reset_messages <- function(){

  messages <<- list(
    list(role = "system", content = "")
  )
}

performFirstRun <- function(pnull,I1){
  
  userInputMessage = c(
    paste0(pnull),
    paste(I1)
  )
  
  addUserMessage(userMessage = userInputMessage)
  pingAPI(userInputMessage = messages[[2]]$content,agentType = 'Semantic')
  
  
  goalMessage <- c(messages[[2]]$content,paste0('Semantic Keywords: ',messages[[3]]$content))
  addUserMessage(userMessage = goalMessage)
  pingAPI(userInputMessage = goalMessage,agentType = 'GoalGenerator')
  
  analyzeGoalMessage <- c(messages[[2]]$content,
                          paste0('Semantic Keywords: ',messages[[3]]$content),
                          paste0('Potential Choices: ',messages[[5]]$content)
  )
  addUserMessage(userMessage = analyzeGoalMessage)
  pingAPI(userInputMessage = analyzeGoalMessage,agentType = 'GoalAnalyzer')
  
  choiceChooserMessage <- c(messages[[2]]$content,
                            paste0('Semantic Keywords: ',messages[[3]]$content),
                            paste0('Potential Choices: ',messages[[5]]$content),
                            paste0('Analysis of Goals: ',messages[[7]]$content)
  )
  addUserMessage(userMessage = choiceChooserMessage)
  pingAPI(userInputMessage = choiceChooserMessage,agentType = 'ChoiceChooser')
  
  differenceVectorMessage <- c(messages[[2]]$content,
                               paste0('Semantic Keywords: ',messages[[3]]$content),
                               paste0('Potential Choices: ',messages[[5]]$content),
                               paste0('Analysis of Goals: ',messages[[7]]$content),
                               paste0('Choice Made: ',messages[[9]]$content)
  )
  addUserMessage(userMessage = differenceVectorMessage)
  pingAPI(userInputMessage = differenceVectorMessage,agentType = 'DifferenceVector')
  
  
  semanticDifferenceVectorMessage <- c(messages[[2]]$content,
                                       paste0('Potential Choices: ',messages[[5]]$content),
                                       paste0('Choice Made: ',messages[[9]]$content),
                                       paste0('Difference Vector after Choice Made: ',messages[[11]]$content)
  )
  
  addUserMessage(userMessage = semanticDifferenceVectorMessage)
  pingAPI(userInputMessage = semanticDifferenceVectorMessage,agentType = 'Semantic')
  
  
  goalReAnalyzeMessage <- c(messages[[2]]$content,
                            paste0('Semantic Keywords: ',messages[[3]]$content),
                            paste0('Potential Choices: ',messages[[5]]$content),
                            paste0('Analysis of Goals: ',messages[[7]]$content),
                            paste0('Choice Made: ',messages[[9]]$content),
                            paste0('Difference Vector after Choice Made: ',messages[[11]]$content),
                            paste0('Semantic Difference Vector after Choice Made: ',messages[[13]]$content)
                            
  )
  addUserMessage(userMessage = goalReAnalyzeMessage)
  pingAPI(userInputMessage = goalReAnalyzeMessage,agentType = 'GoalReAnalyzer')
  
  
  iterationRow <<- data.frame(n = 1,
                              pnull = pnull, I1 = I1, TransformI = messages[[3]]$content,
                              D = messages[[5]]$content,
                              FM = messages[[7]]$content,
                              Fn = messages[[9]]$content,
                              Idelta = messages[[11]]$content,
                              TIdelta = messages[[13]]$content,
                              newP = messages[[15]]$content)
  
  newRow <<- data.frame(n = 2,
                        pnull = iterationRow[1,'newP'], 
                        I1 = paste0(iterationRow[1,'I1'],iterationRow[1,'Idelta']) , 
                        TransformI = NA,
                        D = NA,
                        FM = NA,
                        Fn = NA,
                        Idelta = NA,
                        TIdelta = NA,
                        newP = NA)
  
  iterationRow <<- rbind(iterationRow,newRow)
  
}

processAdditionalRuns <- function(i){
  
  reset_messages()
  
  buffer <- 'THE FOLLOWING IS OLD DATA FOR CONTEXT, IT IS FOLLOWED BY A NEWLY DECLARED GOAL'
  
  newInformationContext <- c(buffer,InfoRow$Row,iterationRow[i,'newP'])
  
  userInputMessage = c(
    newInformationContext
  )
  
  addUserMessage(userMessage = userInputMessage)
  pingAPI(userInputMessage = messages[[2]]$content,agentType = 'Semantic')
  
  
  
  previousChoices <- InfoRow %>% filter(Type == 'Choice Chosen')
  choiceDisclaimer<- paste0('The choice cannot include ',c(previousChoices$Row))
  
  choiceDisclaimer2 <- "You may not reply 'None'. If you think there are no choices, then be 
  more creative in line with the themes and goals already stated to come up with a better answer than simply None."
  
  goalMessage <- c(messages[[2]]$content,paste0('Semantic Keywords: ',messages[[3]]$content),
                   choiceDisclaimer, choiceDisclaimer2, sep= ' ')
  
  
  addUserMessage(userMessage = goalMessage)
  pingAPI(userInputMessage = goalMessage,agentType = 'GoalGenerator')
  
  analyzeGoalMessage <- c(messages[[2]]$content,
                          paste0('Semantic Keywords: ',messages[[3]]$content),
                          paste0('Potential Choices: ',messages[[5]]$content)
  )
  addUserMessage(userMessage = analyzeGoalMessage)
  pingAPI(userInputMessage = analyzeGoalMessage,agentType = 'GoalAnalyzer')
  
  choiceChooserMessage <- c(messages[[2]]$content,
                            paste0('Semantic Keywords: ',messages[[3]]$content),
                            paste0('Potential Choices: ',messages[[5]]$content),
                            paste0('Analysis of Goals: ',messages[[7]]$content)
  )
  addUserMessage(userMessage = choiceChooserMessage)
  pingAPI(userInputMessage = choiceChooserMessage,agentType = 'ChoiceChooser')
  
  
  
  disclaimerDifferenceVector <- paste0('Please only consider the impact of the most recent choice made which is ',
                                       messages[[9]]$content)
  
  disclaimerDifferenceVector <- paste0('Please also consider in the background that there have been already a series of choices made',
                                       c(previousChoices$Row))
  
  differenceVectorMessage <- c(messages[[2]]$content,
                               paste0('Semantic Keywords: ',messages[[3]]$content),
                               paste0('Potential Choices: ',messages[[5]]$content),
                               paste0('Analysis of Goals: ',messages[[7]]$content),
                               paste0('Choice Made: ',messages[[9]]$content),
                               disclaimerDifferenceVector
  )
  
  addUserMessage(userMessage = differenceVectorMessage)
  pingAPI(userInputMessage = differenceVectorMessage,agentType = 'DifferenceVector')
  
  
  semanticDifferenceVectorMessage <- c(messages[[2]]$content,
                                       paste0('Potential Choices: ',messages[[5]]$content),
                                       paste0('Choice Made: ',messages[[9]]$content),
                                       paste0('Difference Vector after Choice Made: ',messages[[11]]$content)
  )
  
  addUserMessage(userMessage = semanticDifferenceVectorMessage)
  pingAPI(userInputMessage = semanticDifferenceVectorMessage,agentType = 'Semantic')
  
  
  
  
  disclaimerGoalReanalyze <- 'Remember that the choice has already been taken, so the goal
  should adjust itself based on the choice made and the differences. You can adjust the goal
  forwards'
  
  goalReAnalyzeMessage <- c(messages[[2]]$content,
                            paste0('Semantic Keywords: ',messages[[3]]$content),
                            paste0('Potential Choices: ',messages[[5]]$content),
                            paste0('Analysis of Goals: ',messages[[7]]$content),
                            paste0('Choice Made: ',messages[[9]]$content),
                            paste0('Difference Vector after Choice Made: ',messages[[11]]$content),
                            paste0('Semantic Difference Vector after Choice Made: ',messages[[13]]$content),
                            disclaimerGoalReanalyze
                            
  )
  
  addUserMessage(userMessage = goalReAnalyzeMessage)
  pingAPI(userInputMessage = goalReAnalyzeMessage,agentType = 'GoalReAnalyzer')
  

  iterationRow[i,'TransformI'] <- messages[[3]]$content
  iterationRow[i,'D'] <- messages[[5]]$content
  iterationRow[i,'FM'] <- messages[[7]]$content
  iterationRow[i,'Fn'] <- messages[[9]]$content
  iterationRow[i,'Idelta'] <- messages[[11]]$content
  iterationRow[i,'TIdelta'] <- messages[[13]]$content
  iterationRow[i,'newP'] <- messages[[15]]$content
    
  newRow <<- data.frame(n = i+1,
                        pnull = iterationRow[i,'newP'], 
                        I1 = paste0(iterationRow[i,'I1'],iterationRow[i,'Idelta']) , 
                        TransformI = NA,
                        D = NA,
                        FM = NA,
                        Fn = NA,
                        Idelta = NA,
                        TIdelta = NA,
                        newP = NA)
  
  iterationRow <<- rbind(iterationRow,newRow)
  
  
  InfoNewRow <- rbind(data.frame(Type= 'Goal For Run',Row = paste0('Goal For Run: ',iterationRow[i,'pnull'])),
                      data.frame(Type= 'Information For Run',Row = paste0('Information For Run: ',iterationRow[i,'I1'])),
                      data.frame(Type= 'Choices Considered',Row = paste0('Choices Considered: ',iterationRow[i,'D'])),
                      data.frame(Type= 'Choice Chosen',Row = paste0('Choice Chosen: ',iterationRow[i,'Fn'])),
                      data.frame(Type= 'New Information From Run',Row = paste0('New Information From Run: ',iterationRow[i,'Idelta'])))
  
  InfoRow <<- rbind(InfoRow,InfoNewRow)
  
  
  
}

#############################
reset_messages()

performFirstRun(pnull='I want to take over the world',
                I1 = paste0("Information: 
                I am an individual of immense conviction, driven by a relentless desire for order and progress. My mind is sharp, analytical, and often uncompromising; I thrive on clear objectives and challenge myself and others to exceed expectations. I hold a deep-seated belief in the power of collective strength, valuing loyalty and discipline above all. My passion can ignite others, yet my intensity may sometimes intimidate those around me. I approach every situation with a boldness that reflects my unwavering commitment to my ideals, often seeking to rally those who share my vision while inspiring them to embrace their own potential. Beneath this robust exterior lies a complexity, a mind that constantly analyzes the world around me, ever seeking impact and significance in every action I take.",sep = ' '))


InfoRow <- rbind(data.frame(Type= 'Original Goal',Row = paste0('Old Goal: ',iterationRow[1,'pnull'])),
data.frame(Type= 'Original Information',Row = paste0('Original Information: ',iterationRow[1,'I1'])),
data.frame(Type= 'Choices Considered',Row = paste0('Choices Considered: ',iterationRow[1,'D'])),
data.frame(Type= 'Choice Chosen',Row = paste0('Choice Chosen: ',iterationRow[1,'Fn'])),
data.frame(Type= 'New Information From Run',Row = paste0('New Information From Run: ',iterationRow[1,'Idelta'])))

#########
for(i in 2:5){
  
  processAdditionalRuns(i = i)
  
}


reducedMatrix <- iterationRow %>% 
  select(n,pnull,Fn,Idelta) %>% 
  unique()

write_csv(reducedMatrix,'./sampleOutputs/reducedResultsExample.csv')
write_csv(iterationRow,'./sampleOutputs/fullResultsExample.csv')

