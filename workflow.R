library(httr)
library(jsonlite)
library(dotenv)
load_dot_env("./.env")



# Define API key and endpoint
api_key <- Sys.getenv("GROQ_API_KEY")

url <- "http://localhost:3000/api/v1/prediction/095ead8d-54fa-4b43-bd42-da04f06ad25a"

original_goal <- "I want to get a job in machine learning"
original_information <- "I am a full stack engineer for 6 years"

payload <- list(
  question = paste0("Original Goal- ",original_goal, "+ ", "Original Information- ", original_information) )

response <- POST(
  url,
  add_headers(
    "Content-Type" = "application/json"
    ),
  body = toJSON(payload, auto_unbox = TRUE),
  encode = "json"
)

content(response)$text

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
decision_log[1,'original_goal'] <- original_goal
decision_log[1,'adjusted_goal'] <- "N/A yet"
decision_log[1,'information_vector'] <- original_information
decision_log[1,'choices_for_step'] <- content(response)$text

state <- paste0("Original Goal- ",
       decision_log[1,'original_goal'],
       "Information Vector - ",
       decision_log[1,'information_vector'],
       "Choice Vector -",
       decision_log[1,'choices_for_step'])

url <- "http://localhost:3000/api/v1/prediction/4077eab3-fbad-462d-aaa8-063ce634e074"

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

content(response)$text

decision_log[1,'subjective_feedback'] <- content(response)$text

url <- "http://localhost:3000/api/v1/prediction/671d04e2-0e79-44c5-99f4-be0eaaf383b4"

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

content(response)$text


decision_log[1,'objective_feedback'] <- content(response)$text

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


url <- "http://localhost:3000/api/v1/prediction/c556616f-35f7-47cd-acc8-825cbc8307dc"

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

content(response)$text

decision_log[1,'choice_chosen'] <- content(response)$text

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


url <- "http://localhost:3000/api/v1/prediction/db4d1260-2b53-43c4-a343-11ffa0475900"

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

content(response)$text

decision_log[1,'new_information_vector'] <- content(response)$text





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


url <- "http://localhost:3000/api/v1/prediction/8b10f724-a9fe-434d-a429-d93b4518c761"

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

content(response)$text

decision_log[1,'new_goal'] <- content(response)$text


decision_log <- decision_log %>% select( iteration,
                                         original_goal,
                                         adjusted_goal,
                                         information_vector,
                                         choices_for_step,
                                         subjective_feedback,
                                         objective_feedback,
                                         choice_chosen,
                                         new_information_vector,
                                         new_goal)

toJSON(decision_log,pretty=TRUE)


copy <- decision_log 
copy[0,]
copy[1,'iteration'] <- 2
copy[1,'original_goal'] <- original_goal
copy[1,"adjusted_goal"] <- decision_log[1,'new_goal']
copy[1,'information_vector'] <- paste0(decision_log[1,'information_vector'], decision_log[1,'new_information_vector'])
copy[1,'choices_for_step'] <- NA
copy[1,'subjective_feedback'] <- NA
copy[1,'objective_feedback'] <- NA
copy[1,'choice_chosen'] <- NA
copy[1,'new_information_vector'] <- NA
copy[1,'new_goal'] <- NA

decision_log <- rbind(decision_log, copy)


toJSON(decision_log,pretty=TRUE)


##################################

continueIteration <- function(i){
  
  url <- "http://localhost:3000/api/v1/prediction/095ead8d-54fa-4b43-bd42-da04f06ad25a"
  
  original_goal <- decision_log[i,'original_goal']
  information_vector <- decision_log[i,'information_vector']
  
  payload <- list(
    question = paste0("Original Goal- ",original_goal, "+ ", " Information- ", information_vector) )
  
  response <- POST(
    url,
    add_headers(
      "Content-Type" = "application/json"
    ),
    body = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  content(response)$text
  
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
  decision_logRow[1,'original_goal'] <- decision_log[i,'original_goal']
  decision_logRow[1,'adjusted_goal'] <- decision_log[i,'adjusted_goal']
  decision_logRow[1,'information_vector'] <- decision_log[i,'information_vector']

  decision_logRow[1,'choices_for_step'] <- content(response)$text
  
  state <- paste0("Original Goal- ",
                  decision_logRow[1,'original_goal'],
                  "Information Vector - ",
                  decision_logRow[1,'information_vector'],
                  "Choice Vector -",
                  decision_logRow[1,'choices_for_step'])
  
  url <- "http://localhost:3000/api/v1/prediction/4077eab3-fbad-462d-aaa8-063ce634e074"
  
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
  
  content(response)$text
  
  decision_logRow[1,'subjective_feedback'] <- content(response)$text
  
  url <- "http://localhost:3000/api/v1/prediction/671d04e2-0e79-44c5-99f4-be0eaaf383b4"
  
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
  
  content(response)$text
  
  
  decision_logRow[1,'objective_feedback'] <- content(response)$text
  
  state <- paste0("Original Goal- ",
                  decision_logRow[1,'original_goal'],
                  "Information Vector - ",
                  decision_logRow[1,'information_vector'],
                  "Choice Vector -",
                  decision_logRow[1,'choices_for_step'],
                  "Subjective Analysis - ",
                  decision_logRow[1,'subjective_feedback'],
                  
                  "Objective Analysis -",
                  decision_logRow[1,'objective_feedback']
                  
  )
  
  
  url <- "http://localhost:3000/api/v1/prediction/c556616f-35f7-47cd-acc8-825cbc8307dc"
  
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
  
  content(response)$text
  
  decision_logRow[1,'choice_chosen'] <- content(response)$text
  
  state <- paste0("Original Goal- ",
                  decision_logRow[1,'original_goal'],
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
  
  
  url <- "http://localhost:3000/api/v1/prediction/db4d1260-2b53-43c4-a343-11ffa0475900"
  
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
  
  content(response)$text
  
  decision_logRow[1,'new_information_vector'] <- content(response)$text
  
  
  
  
  
  state <- paste0("Original Goal- ",
                  decision_logRow[1,'original_goal'],
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
  
  
  url <- "http://localhost:3000/api/v1/prediction/8b10f724-a9fe-434d-a429-d93b4518c761"
  
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
  
  content(response)$text
  
  decision_logRow[1,'new_goal'] <- content(response)$text
  
  
  decision_logRow <- decision_logRow %>% select( iteration,
                                           original_goal,
                                           adjusted_goal,
                                           information_vector,
                                           choices_for_step,
                                           subjective_feedback,
                                           objective_feedback,
                                           choice_chosen,
                                           new_information_vector,
                                           new_goal)
  
  return(decision_logRow)
  
}

#newestRow <- continueIteration(2)

#decision_log[i,] <- newestRow


createNewRow <- function(i){
  
  copy <- decision_log[1,]
  copy[0,]
  copy[1,'iteration'] <- i + 1
  copy[1,'original_goal'] <- decision_log[1,'original_goal']
  copy[1,"adjusted_goal"] <- decision_log[i,'new_goal']
  copy[1,'information_vector'] <- paste0(decision_log[i,'information_vector'], decision_log[i,'new_information_vector'])
  copy[1,'choices_for_step'] <- NA
  copy[1,'subjective_feedback'] <- NA
  copy[1,'objective_feedback'] <- NA
  copy[1,'choice_chosen'] <- NA
  copy[1,'new_information_vector'] <- NA
  copy[1,'new_goal'] <- NA
  
  return(copy)
  
}

#newEmptyRow <- createNewRow(2)

#decision_log <- rbind(decision_log,newEmptyRow )

n <- 5

for(i in 2:n){
  
  newestRow <- continueIteration(i)
  
  decision_log[i,] <- newestRow
  
  newEmptyRow <- createNewRow(i)
  
  decision_log <- rbind(decision_log,newEmptyRow )
  
}
