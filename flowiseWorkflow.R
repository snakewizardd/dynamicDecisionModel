library(dplyr)
library(jsonlite)
library(httr)

#Add the user generated message to the message qeue
addUserMessage <- function(userMessage){
  
  processMessgae <- list(role = "user", content = userMessage)
  
  messages[[length(messages) + 1]] <<- processMessgae
}

#Ping the chat completions API endpoint
pingAPI <- function(userInputMessage,
                    agentType
){
  
  #url <- "https://api.openai.com/v1/chat/completions"
  #url <- "https://api.groq.com/openai/v1/chat/completions"
  
  url <- switch(agentType,
                "Semantic" = "http://localhost:3000/api/v1/prediction/d620d45d-750a-45b7-9900-4bc9ac13e72c",
                "GoalGenerator"    = "http://localhost:3000/api/v1/prediction/92502b56-bde9-48c6-9cd4-7fa563666e99",
                "GoalAnalyzer"  = "http://localhost:3000/api/v1/prediction/bd79ea04-1be7-4326-a183-ab0a1e0fe7f9",
                "ChoiceChooser"  = "http://localhost:3000/api/v1/prediction/26575dec-2b88-4efb-ab70-74b9437463dc",
                "DifferenceVector"  = "http://localhost:3000/api/v1/prediction/af210555-fba4-4fc6-9c11-0a1742dd4313",
                "GoalReAnalyzer"  = "http://localhost:3000/api/v1/prediction/9889de60-3c60-4063-95cb-39fb837df919",
                "http://localhost:3000/api/v1/prediction/d620d45d-750a-45b7-9900-4bc9ac13e72c" # default case
  )
  
  #url <- "http://localhost:3000/api/v1/prediction/d620d45d-750a-45b7-9900-4bc9ac13e72c"
  
  #apiKey <- importedAPIKey
  #apiKey <-  groqKey
  
  body <- list(
    #model = "gpt-3.5-turbo",
    #model = "llama3-70b-8192",
    #model = "mixtral-8x7b-32768",
    question = userInputMessage
    #messages=messages
  )
  
  response <- POST(
    url,
    add_headers(#`Authorization` = paste("Bearer", apiKey),
      `Content-Type`="application/json"),
    body = body,
    encode = "json"
  )
  
  
  
  aiResponseFormatted<- list(
    role = "assistant",
    content = #content(response)$choices[[1]]$message$content
      content(response)$text
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
  
  # newFullInformationVector <- c(paste0('Original Goal and Information: ',messages[[2]]$content),
  #                             paste0('Choice Made: ',messages[[9]]$content),
  #                             paste0('Difference Vector after Choice Made: ',messages[[11]]$content),
  #                             paste0('Semantic Difference Vector after Choice Made: ',messages[[13]]$content),
  #                             paste0('New Goal Declared: ',messages[[15]]$content)
  #   )
  
  #######
  # InformationVector <- c(paste0('Original Goal and Information: ',messages[[2]]$content),
  #                       paste0('Choice Made: ',messages[[9]]$content),
  #                       paste0('Difference Vector after Choice Made: ',messages[[11]]$content),
  #                       paste0('Semantic Difference Vector after Choice Made: ',messages[[13]]$content),
  #                       paste0('New Goal Declared: ',messages[[15]]$content)
  # )
  #newGoal <- paste0('New Goal: ',messages[[15]]$content)
  
  #newState <- c(newGoal,'AND FOR CONTEXT: ', InformationVector)
  
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

#############################
reset_messages()

performFirstRun(pnull='Successfuly conduct the Design-Build-Team for generating a mission statement',
                I1 = paste0('We only have three weeks',
                            'Its been a difficult restructuring',
                            'I personally have moved from a 3 person team to 45 people', sep = ' '))

# iterationRow[1,'pnull']
# iterationRow[1,'I1']
# iterationRow[1,'D']
# iterationRow[1,'Fn']
# iterationRow[1,'Idelta']
# iterationRow[1,'TIdelta']
# iterationRow[1,'newP']

InfoRow <- rbind(data.frame(Type= 'Original Goal',Row = paste0('Old Goal: ',iterationRow[1,'pnull'])),
data.frame(Type= 'Original Information',Row = paste0('Original Information: ',iterationRow[1,'I1'])),
data.frame(Type= 'Choices Considered',Row = paste0('Choices Considered: ',iterationRow[1,'D'])),
data.frame(Type= 'Choice Chosen',Row = paste0('Choice Chosen: ',iterationRow[1,'Fn'])),
data.frame(Type= 'New Information From Run',Row = paste0('New Information From Run: ',iterationRow[1,'Idelta'])))

#buffer <- 'THE FOLLOWING IS OLD DATA FOR CONTEXT, IT IS FOLLOWED BY A NEWLY DECLARED GOAL'

#newInformationContext <- c(buffer,InfoRow$Row,iterationRow[1,'newP'])
#########

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
  goalMessage <- c(messages[[2]]$content,paste0('Semantic Keywords: ',messages[[3]]$content),
                   choiceDisclaimer)
  
  
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
  
  # newFullInformationVector <- c(paste0('Original Goal and Information: ',messages[[2]]$content),
  #                             paste0('Choice Made: ',messages[[9]]$content),
  #                             paste0('Difference Vector after Choice Made: ',messages[[11]]$content),
  #                             paste0('Semantic Difference Vector after Choice Made: ',messages[[13]]$content),
  #                             paste0('New Goal Declared: ',messages[[15]]$content)
  #   )
  
  #######
  # InformationVector <- c(paste0('Original Goal and Information: ',messages[[2]]$content),
  #                       paste0('Choice Made: ',messages[[9]]$content),
  #                       paste0('Difference Vector after Choice Made: ',messages[[11]]$content),
  #                       paste0('Semantic Difference Vector after Choice Made: ',messages[[13]]$content),
  #                       paste0('New Goal Declared: ',messages[[15]]$content)
  # )
  #newGoal <- paste0('New Goal: ',messages[[15]]$content)
  
  #newState <- c(newGoal,'AND FOR CONTEXT: ', InformationVector)
  #i <- 2
  iterationRow[i,'TransformI'] <- messages[[3]]$content
  iterationRow[i,'D'] <- messages[[5]]$content
  iterationRow[i,'FM'] <- messages[[7]]$content
  iterationRow[i,'Fn'] <- messages[[9]]$content
  iterationRow[i,'Idelta'] <- messages[[11]]$content
  iterationRow[i,'TIdelta'] <- messages[[13]]$content
  iterationRow[i,'newP'] <- messages[[15]]$content
  
  #iterationRow <<- rbind(iterationRow,newRow)
  
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

for(i in 2:5){
  
  processAdditionalRuns(i = i)
  
  
}



