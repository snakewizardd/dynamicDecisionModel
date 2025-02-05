#source("./scripts/functions.R")



original_goalInput <- "become a crypto billionare"

original_informationInput <- "i have 35$ to my name and i live in sub saharan africa under a shed with no internet"


decision_log <- firstRunInit(original_goal = original_goalInput,
                                           original_information = original_informationInput)


i <- 2

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow


i <- 3

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 4

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 5

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow
i <- 4

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 4

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 5

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 6

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 7

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 8

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 9

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 10

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 11

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 12

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 13

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 14

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow

i <- 15

newEmptyRow <- createNewRow(i)

decision_log <- rbind(decision_log,newEmptyRow )

newestRow <- continueIteration(i)

decision_log[i,] <- newestRow


n <- 3

for(i in 2:n){
  
  
  newEmptyRow <- createNewRow(i)
  
  decision_log <- rbind(decision_log,newEmptyRow )
  
  newestRow <- continueIteration(i)
  
  decision_log[i,] <- newestRow
  

  
}

readr::write_csv(decision_log,'./sampleOutputs/multi-model-test1.csv')
