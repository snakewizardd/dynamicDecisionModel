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
                "Semantic" = "http://localhost:3000/api/v1/prediction/0a36f3cd-b944-45eb-9cde-62da37524fe4",
                "GoalGenerator"    = "http://localhost:3000/api/v1/prediction/d4513974-c13c-4cc3-aa41-6dfe06b61e6c",
                "GoalAnalyzer"  = "http://localhost:3000/api/v1/prediction/dff34b47-cbd9-42cd-a50d-ff74752bff9c",
                "ChoiceChooser"  = "http://localhost:3000/api/v1/prediction/1e19077e-995f-4157-bc95-324cb88bf0e6",
                "DifferenceVector"  = "http://localhost:3000/api/v1/prediction/8d48b58f-9528-47fc-9a44-840f4d726325",
                "GoalReAnalyzer"  = "http://localhost:3000/api/v1/prediction/6db67f48-538f-4717-b889-c2e94fa2501d",
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
  
  previousChoices <- previousChoices %>% mutate(Row = gsub('Choice Chosen: ','',Row))
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
  forwards, but it must be connected logically to the previous steps '
  
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

fullRun <- function(pnull, I1,n){
#pnull = 'i want to grow my futures account from $150 to $500. Each decision and choice should be iterative...'
#I1 = 'I move $25 a week from my bank to fund it. But i just made my first trade, a micro Ethereum contract.'
#n = 3

  reset_messages()
  
  
  performFirstRun(pnull=pnull,
                  I1 = paste0("Information: ",I1,sep = ' '))
  
  
  InfoRow <<- rbind(data.frame(Type= 'Original Goal',Row = paste0('Old Goal: ',iterationRow[1,'pnull'])),
                   data.frame(Type= 'Original Information',Row = paste0('Original Information: ',iterationRow[1,'I1'])),
                   data.frame(Type= 'Choices Considered',Row = paste0('Choices Considered: ',iterationRow[1,'D'])),
                   data.frame(Type= 'Choice Chosen',Row = paste0('Choice Chosen: ',iterationRow[1,'Fn'])),
                   data.frame(Type= 'New Information From Run',Row = paste0('New Information From Run: ',iterationRow[1,'Idelta'])))
  
  #########
  for(i in 2:n){
    
    processAdditionalRuns(i = i)
    
  }
  
  
  reducedMatrix <- iterationRow %>% 
    select(n,pnull,Fn,Idelta) %>% 
    unique()
  
  write_csv(reducedMatrix,'./sampleOutputs/reducedResultsExampleMeal.csv')
  write_csv(iterationRow,'./sampleOutputs/fullResultsExampleMeal.csv')
  
  

  
#   return(iterationRow)
#   
}
# 
# #############################
# 
# runOutput <- fullRun(pnull = 'i want to grow my futures account from $150 to $500. Each decision and choice should be iterative...',
#         I1 = 'I move $25 a week from my bank to fund it. But i just made my first trade, a micro Ethereum contract.',
#         n = 3)

rm(InfoRow)
rm(iterationRow)
rm(newRow)

runOutput <- fullRun(pnull = 'I want to comprehend this article',
                     I1 = "Incredible new details of Shackleton’s sunken Endurance ship revealed in 3D scan

By Jack Guy, CNN

Updated: 11:12 AM EDT, Thu October 10, 2024

Source: CNN

A new 3D scan has revealed previously unseen details of the wreck of Antarctic explorer Ernest Shackleton’s HMS Endurance, which was found in 2022 – more than a century after the ship sank.

The scan, seen by CNN on Thursday, makes it look as though the ship, which sank after being crushed by sea ice in 1915, has been miraculously lifted out of the Weddell Sea onto dry land in one piece.

It shows plates used by the crew scattered across the ship, plus other visible artifacts such as a boot and a flare gun, which remain on deck despite the ship sitting at a depth of 3,008 meters (1.9 miles or about 9,900 feet).

The 3D images have been released as part of a new documentary film “Endurance,” which will premiere at the London Film Festival on Saturday before being released in UK cinemas from Monday and on Disney+ later in the year.

The film, from National Geographic Documentary Films, is directed by Chai Vasarhelyi, Jimmy Chin and Natalie Hewit.

It tells the story of Shackleton’s ill-fated voyage, as well as that of the expedition that discovered the wreck of the Endurance in 2022.

That recent expedition was funded by the Falklands Maritime Heritage Trust (FMHT), which celebrated the release of the documentary in a statement last month.

“As well as locating, surveying and filming the wreck, our aim was to bring the stories of Shackleton and of his ship to new generations,” said FMHT chairman Donald Lamont in the statement.

“They are stories of grit and determination that we hope will inspire people across the globe with the qualities of leadership and perseverance in the face of adversity.”

Prior to the Endurance voyage, Shackleton had established himself as a polar explorer after a career in the merchant navy. He had to leave a 1906 Antarctic expedition due to ill health, but led another successful one south in 1908. His exploits earned him a knighthood, becoming Sir Ernest Shackleton in 1909.

Shackleton’s final Antarctic mission started with grand ambitions. Having recruited 27 men, he was hoping to lead some of them on the first-ever full crossing of Antarctica by land, just a couple of years after Norwegian Roald Amundsen had become the first person to reach the South Pole.

However, the Endurance became stuck in the sea ice, and eventually succumbed to the immense pressures of the frozen landscape and sank.

Shackleton then showed his legendary qualities as a leader by leading a small party across stormy seas to South Georgia, where they enlisted help to rescue the 22 men who remained camped on the ice.

Not a single crew member was lost, cementing Shackleton’s place in the history books.

Sign up for CNN’s Wonder Theory science newsletter. Explore the universe with news on fascinating discoveries, scientific advancements and more.

CNN’s Barry Neild and Lilit Marcus contributed to this report.

",
                     n = 3)

decisionTree <- runOutput %>% select(pnull,D,Fn,#FM,
                                     Idelta) %>% toJSON(pretty=TRUE,auto_unbox = TRUE)
decisionTree

logicExplanation <- runOutput %>% select(pnull,Fn,Idelta) %>% toJSON(pretty=TRUE,auto_unbox = TRUE)
logicExplanation