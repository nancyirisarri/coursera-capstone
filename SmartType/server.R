#
# This is the server logic of a TypeSmart. 
#

library(shiny)
library(sqldf)
library(RMySQL)

shinyServer(function(input, output) {
  
  connectToDb <- function() {
    tryCatch(
      {
        # Read password from not-shared file.
        dbPassword <- read.table("dbPassword.txt", stringsAsFactors=FALSE)$V1[1]
        
        mydb <- dbConnect(
          MySQL(), user="nancyirisarri", password=dbPassword, dbname="txtFreq",
          host="mydbinstance.cxazfjykboub.us-east-2.rds.amazonaws.com"
        )
        
        return(mydb)
      }, error = function(e) {
        print(paste("Error in connectToDb: ", e))
      }
    )
  }
  
  findSuggestions <- function(userInput) {
    mydb <- connectToDb()
    
    # Get last two words of user input.    
    nextToLast <- userInput[length(userInput)-1]
    last <- userInput[length(userInput)]

    tryCatch({
        sqlQuery <- "select * from txtFreq where feature like '%s_%s_%s' order by rank limit 1"
        
        sqlQuery <- sprintf(sqlQuery, nextToLast, last, "%")

        query <- dbSendQuery(mydb, sqlQuery)
        
        suggestions <- fetch(query, n=-1)
        
        if (length(suggestions$feature) == 0) {
          return(paste('<h4><span style="color:#FAA4BD">Suggestions based on: <strong>', 
                       paste(nextToLast, last), 
                       '</strong>.<br>Sorry, nothing found :(</h4>', sep=""
                       )
                 )
        }
        
        toReturn <- paste('<h4><span style="color:#FAA4BD">Suggestions based on: <strong>', 
                          paste(nextToLast, last), 
                          "</strong>.<br>Your next word might be: <strong>", sep="")
        last <- c()
        for (suggestion in suggestions$feature) {
          suggestion <- strsplit(suggestion, "_")[[1]]
          suggestion <- tail(suggestion, n=1)
          last <- c(last, suggestion)
        }
        
        paste(toReturn, last[1], "</strong>.</span></h4>", sep="")
        
    }, error = function(e) {
      print(paste("Error finding a suggestion: ", e))
    }, finally = {
      # Clear results and disconnect from database.
      dbClearResult(dbListResults(mydb)[[1]])
      dbDisconnect(mydb)
    })
  }
  
  output$suggestions <- renderText({
    userInput <- strsplit(input$userInput, "\\s")
    
    if (length(userInput) > 0 & length(userInput[[1]]) >= 2) {
      findSuggestions(userInput[[1]])
    } else {
      '<h4><span style="color:#FAA4BD">Enter at least two words and press submit.</span></h4>'
    }
  })
  
})
