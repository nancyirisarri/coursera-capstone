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
        sqlQuery <- "select * from txtFreq where feature like '%s_%s_%s' order by rank limit 2"
        
        sqlQuery <- sprintf(sqlQuery, nextToLast, last, "%")

        query <- dbSendQuery(mydb, sqlQuery)
        
        suggestions <- fetch(query, n=-1)
        
        if (length(suggestions$feature) == 0) {
          return(paste("Suggestions based on: ", 
                       paste(nextToLast, last), 
                       ".<br>Sorry, nothing found :(", sep=""
                       )
                 )
        }
        
        toReturn <- paste("Suggestions based on: ", 
                          paste(nextToLast, last), 
                          ".<br>Your next word might be: ", sep="")
        last <- c()
        for (suggestion in suggestions$feature) {
          suggestion <- strsplit(suggestion, "_")[[1]]
          suggestion <- tail(suggestion, n=1)
          last <- c(last, suggestion)
        }
        
        paste(toReturn, last[1], ", ", last[2], ".", sep="")
        
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
      'Enter at least two words and press submit.'
    }
  })
  
})
