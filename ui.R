#
# TypeSmart Shiny app.
# 

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("TypeSmart finishes your sentences"),
  
  sidebarLayout(
    sidebarPanel(
      h3("TypeSmart uses an algorithm to predict the next word you want to type. Type at least two words to get some suggestions.")
    ),
    
    mainPanel(
      textInput("userInput", h3("Text input"), 
                value = ""),
      submitButton("Submit"),
      htmlOutput("suggestions")
    )
  )
))
