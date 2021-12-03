#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

source("../census.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
    leafletOutput("mymap"),
    p(),
    # Application title
    titlePanel("Old Faithful Geyser Data"),
    actionButton("recalc","New points")
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$mymap <- renderLeaflet({
        get_leaflet_map("Idaho Falls")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
