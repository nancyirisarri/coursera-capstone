#
# TypeSmart Shiny app.
# 

library(shiny)

shinyUI(
  fluidPage(
    theme="styles.css",
    fluidRow(
      column(1),
      column(10, 
             div(
              div("SmartType",
                  style="float: left; font-size: 20pt; color:#F572B0; font-weight: bold;"), 
              div("Finishes Your Sentences", 
                  style="margin-left: 150px; color:#FAA4BD; font-size: 20pt"),
              style="overflow: hidden;"
             )
             ),
      column(1)
    ),
    fluidRow(
      column(1),
      column(10,
        textInput("userInput", 
                  h4("SmartType uses an algorithm to predict your next word. Type at least two words and get a suggestion.",
                     style="color:#FAA4BD"), 
                  value = "", width="100%"),
        htmlOutput("suggestions"),
        submitButton("Submit"),
        br()
      ),
      column(1)
    ),
    fluidRow(), fluidRow(), fluidRow(), fluidRow(), fluidRow(), fluidRow(), fluidRow(), fluidRow()
  )
)
