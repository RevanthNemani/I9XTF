#library------------------------
library(lubridate)
library(shiny)
library(XML)
library(fst)
library(dplyr)
library(shinyjs)
library(shinyauthr)
library(shinydashboard)
#App------------
options(shiny.maxRequestSize=50*1024^2)
#Defining Header------------------
header <- dashboardHeader(title = "I9 XML to fst",
                          tags$li(class = "dropdown", style = "padding: 4px;",
                                  #tags$a(href="#inputrender",class="btn-btn-default","Login"),
                                  shinyauthr::logoutUI("logout")
                          ))
sidebar <- dashboardSidebar(collapsed = TRUE, 
                            div(uiOutput("welcome",inline = T), style = "padding: 20px"))
#Defining body------------------
body <- dashboardBody(useShinyjs(),
                      div(id = "main_content",tags$head(tags$link(href="alizz.css",type = "text/css", rel="stylesheet")),
                          shinyjs::useShinyjs(),
                          tags$head(tags$style(".table{margin: 0 auto;}"),
                                    tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                                                type="text/javascript"),
                                    includeScript("Scripts/returnClick.js")),
                          div(class = "pull-right",shinyauthr::logoutUI(id = "logout")),
                          fluidRow(column(width = 12,
                                          box(title = "XML to fst converter for IFRS 9 ECL Tool V 1.0.0",
                                              status = "success",collapsible = T,width = 12,
                                              fileInput(inputId = "xmldata",
                                                        multiple = F,
                                                        label = NULL,
                                                        accept = ".xml",
                                                        buttonLabel = "Upload",
                                                        placeholder = ".xml only"),
                                              br(),br(),br(),br(),br(),br(),
                                          column(width = 12,offset = 5,
                                                 downloadButton('downloadData', ' Download as fst file ',class = "butt1",
                                                                tags$head(tags$style(".butt1{background-color:#737171;} .butt1{color: #E6E2E2;}")))))))))
ui <- dashboardPage(header = header,body = body,sidebar = sidebar)
server <- function(input, output, session) {
}
# Run the application 
shinyApp(ui = ui, server = server)

