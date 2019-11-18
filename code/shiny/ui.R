library(shiny)
library(fmsb)
library(wordcloud2)
#setwd("D:/UW-Madison/628/Module3/Yelp")
data<-read.csv("./ShinyData - median.csv",encoding = "UTF-8",header=T)
data[,1] <- as.character(data[,1])
data[,"name"] <- as.character(data[,"name"])
data[,"state"] <- as.character(data[,"state"])
data[,"city"] <- as.character(data[,"city"])
shinyUI(fluidPage(
  titlePanel(fluidRow(
    HTML("<div style='height: 54.75px;'>"),imageOutput("title"),HTML("</div>"))),
  sidebarLayout(
    sidebarPanel(
      radioButtons("inputway", "Find Your Business:",
                  list("Business ID" = "bid",
                       "Business Name" = "bname")),
      conditionalPanel(condition="input.inputway=='bid'",
                       textInput("id","Business ID:",value = "")),
      conditionalPanel(condition="input.inputway=='bname'",
                       selectInput("Country","Choose Country:",
                                   list("Canada"="Canada"))),
      conditionalPanel(condition="input.inputway=='bname'",
                       selectInput("city","Choose City:",
                                   choices=list('Alberta'=list("Airdrie","Calgary"),
                                                'Ontario'=data[which(data[,"state"]=="ON"),"city"],
                                                'Quebec'=data[which(data[,"state"]=="QC"),"city"])
                                   )),
      conditionalPanel(condition="(input.inputway=='bname')",
                       uiOutput("selectname")),
      conditionalPanel(condition="(input.inputway=='bname')",
                       uiOutput("selectid")),
      actionButton("submit", "Submit"),
      tags$hr(),
      helpText("If there are any problems, feel free to contact us. Our email: xchen792@wisc.edu")
  ),
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("Business Overview",h2(strong(textOutput("nametitle"))),
                         fluidRow(column(6,
                                         fluidRow(
                                         column(5,HTML("<div style='height: 37.4px;'>"),
                                         imageOutput("image"),
                                         HTML("</div>")),
                                         column(7,h4(div(textOutput("revnum"),style = "color:grey")))),
                                         h4(textOutput("genre")),
                                         conditionalPanel(condition="input.submit",tags$hr()),
                                         h4(textOutput("address1")),
                                         h4(textOutput("address2")
                                         )),
                                  column(6,plotOutput("barplot")))
                         ),
                tabPanel("Competitor Analysis",
                         fluidRow(column(6,align="center",
                                         plotOutput("plot1"),h4(textOutput("note1"))),
                                  column(6,align="center",
                                         plotOutput("plot2"),h4(textOutput("note2"))))),
                tabPanel("Like & Dislike",
                         fluidRow(column(6,align="center",
                                         HTML("<div style='height: 89px;'>"),conditionalPanel(condition="input.submit",imageOutput("imagetitle1")),HTML("</div>"),wordcloud2Output('wordcloud2pos')),
                                  column(6,align="center",
                                         HTML("<div style='height: 89px;'>"),conditionalPanel(condition="input.submit",imageOutput("imagetitle2")),HTML("</div>"),wordcloud2Output('wordcloud2neg'))))
    )
  )
)))