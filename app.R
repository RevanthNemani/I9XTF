#library------------------------
library(lubridate)
library(shiny)
library(XML)
library(fst)
library(dplyr)
library(glue)
library(shinyjs)
library(shinyauthr)
library(shinydashboard)
#App------------
options(shiny.maxRequestSize=50*1024^2)
#Defining Header------------------
header <- dashboardHeader(title = "I9 XML to fst",
                          tags$li(class = "dropdown", style = "padding: 4px;",
                                  shinyauthr::logoutUI("logout")
                          ))
sidebar <- dashboardSidebar(collapsed = TRUE, 
                            div(uiOutput("welcome",inline = T), style = "padding: 20px"))
#Defining body------------------
body <- dashboardBody(useShinyjs(),
                      div(id = "main_content",tags$head(tags$link(href="alizz.css",type = "text/css", rel="stylesheet")),
                          shinyjs::useShinyjs(),
                          shinyauthr::loginUI(id = "login"),
                          tags$head(tags$style(".table{margin: 0 auto;}"),
                                    tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                                                type="text/javascript"),
                                    includeScript("Scripts/returnClick.js")),
                          div(class = "pull-right",shinyauthr::logoutUI(id = "logout")),
                          uiOutput(outputId = "page")))
ui <- dashboardPage(header = header,body = body,sidebar = sidebar)
user_base <- readRDS("data/users/user_base.rds")
server <- function(input, output, session) {
  logout_init <- callModule(shinyauthr::logout, 
                            id = "logout", 
                            active = reactive(credentials()$user_auth))
  credentials <- callModule(shinyauthr::login, "login", 
                            data = user_base,
                            user_col = user,
                            pwd_col = password,
                            hashed = TRUE,
                            algo = "sha512",
                            log_out = reactive(logout_init()))
  observe({
    if(credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } 
    else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  user_info <- reactive({credentials()$info})
  output$welcome <- renderUI({
    req(credentials()$user_auth)
    list(icon("user-circle-o","fa-2x"),
         glue(" Welcome {user_info()$name}"))
  })
  output$page <- renderUI({
    req(credentials()$user_auth)
    fluidRow(column(width = 12,
                box(title = "XML to fst converter for IFRS 9 ECL Tool V 1.0.0",
                    status = "success",collapsible = T,width = 12,
                    fileInput(inputId = "xmlinput",
                              multiple = F,
                              label = NULL,
                              accept = ".xml",
                              buttonLabel = "Upload",
                              placeholder = ".xml only"),
                    column(width = 12,offset = 5,uiOutput(outputId = "ready")),
                    br(),br(),br(),br(),br(),br(),
                    column(width = 12,offset = 5,
                           downloadButton('downloadData',
                                          ' Download as fst file ',class = "butt1",
                                          tags$head(
                                            tags$style(".butt1{background-color:#737171;} .butt1{color: #E6E2E2;}")))))))
  })
  observeEvent(input$xmlinput,{
    req(input$xmlinput)
    withProgress(value = .2,message = "Checking your file",{
      intable <- xmlToDataFrame(isolate(input$xmlinput$datapath),stringsAsFactors = F)
      incProgress(amount = 0.5,message = "Getting it ready for ECL calculation...")
      intable[,c("PROFIT_RATE",
                 "NO_MTH_MATURE",
                 "LMT_AMT",
                 "GROSS_FIN",
                 "EXPOSURE",
                 "CURR_DPD_DAYS",
                 "PAST_DPD_DAYS",
                 "CURR_DPD_DAYS_CNT",
                 "PAST_DPD_DAYS_CNT",
                 "MAX_DPD_DAYS_CNT",
                 "MAX_DPD_DAYS",
                 "CCF","LGD")] <- as.data.frame(sapply(intable[,c("PROFIT_RATE",
                                                                  "NO_MTH_MATURE",
                                                                  "LMT_AMT",
                                                                  "GROSS_FIN",
                                                                  "EXPOSURE",
                                                                  "CURR_DPD_DAYS",
                                                                  "PAST_DPD_DAYS",
                                                                  "CURR_DPD_DAYS_CNT",
                                                                  "PAST_DPD_DAYS_CNT",
                                                                  "MAX_DPD_DAYS_CNT",
                                                                  "MAX_DPD_DAYS",
                                                                  "CCF","LGD")], as.numeric))
      intable$CURR_DT <- as.POSIXct(intable$CURR_DT,format = "%m/%d/%Y")
      incProgress(amount = 0.6,message = "Almost Done")
      output$ready <- renderUI({
        list(renderText("Your file is ready for download"),
             tags$img(src = "tick.png",width = "100px",height = "90px",srcset = "tick.png 2000w"))
      })
      beepr::beep(sound = 2)
      incProgress(amount = 1,message = "There we go!")
    })
    output$downloadData <- downloadHandler(
      filename = paste0("IFRS 9 Master data as at ",as.Date(today())," .fst"),
      content = function(file) {
          write.fst(intable, file)
      })
  })
}
# Run the application 
shinyApp(ui = ui, server = server)

