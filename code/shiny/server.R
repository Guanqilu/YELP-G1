library(shiny)
library(fmsb)
library(wordcloud2)
library(grDevices)
data<-read.csv("./ShinyData - median.csv",encoding = "UTF-8",header=T)
data[,1] <- as.character(data[,1])
data[,"name"] <- as.character(data[,"name"])
data[,"address"] <- as.character(data[,"address"])
data[,"state"] <- as.character(data[,"state"])
data[,"city"] <- as.character(data[,"city"])
data[,24]<- as.character(data[,24])
data[,25]<- as.character(data[,25])
shinyServer(function(input,output){
  output$selectname<-renderUI({
    selectInput("name","Choose Business Name:",
                sort(data[which(data[,"city"]==input$city),"name"]))
  })
  output$selectid<-renderUI({
    selectInput("nameid","Choose Business ID:",
                sort(data[which(data[,"city"]==input$city & data[,"name"]==input$name),1]))
  })
  id <- eventReactive(input$submit,{
    if( input$inputway == "bid" & input$id %in% as.character(data[,1]))
      return( input$id )
    else if( input$inputway == "bname" & is.na(input$nameid)==0)
      return( input$nameid )
    else
      return( 0 )
  })
  output$plot1 <- renderPlot({
    data1<-rbind(data[which(data[,1]==id()),c(7,8,9,10,11)],as.numeric(data[which(data[,1]==id()),c(13,14,15,16,17)]))
    rownames(data1)<-c("Business","Median")
    data1<-rbind(rep(5,5),rep(0,5),data1)
    colors_border=c(  rgb(0.8,0.2,0.5,0.9),rgb(0.2,0.5,0.5,0))
    colors_in=c( rgb(0.8,0.2,0.5,0),rgb(0.2,0.5,0.5,0.4))
    r1<-radarchart( data1, axistype=1, 
                    #custom polygon
                    pcol=colors_border , pfcol=colors_in , plwd=2 , plty=1,
                    #custom the grid
                    cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(1,5,1), cglwd=1,
                    #custom labels
                    vlcex=1,title="By Region"
                    )
    legend(x="bottom", legend = rownames(data1[-c(1,2),]), bty = "n", pch=20 , col=c(rgb(0.8,0.2,0.5,0.9),rgb(0.2,0.5,0.5,0.4)) , text.col = "grey", cex=1.2, pt.cex=3)
    return(r1)
  })
  output$plot2 <- renderPlot({
    data2<-rbind(data[which(data[,1]==id()),c(7,8,9,10,11)],as.numeric(data[which(data[,1]==id()),c(19,20,21,22,23)]))
    rownames(data2)<-c("Business","Median")
    data2<-rbind(rep(5,5),rep(0,5),data2)
    colors_border=c(  rgb(0.8,0.2,0.5,0.9),rgb(0.2,0.5,0.5,0))
    colors_in=c( rgb(0.8,0.2,0.5,0),rgb(0.2,0.5,0.5,0.4))
    r2<-radarchart( data2, axistype=1, 
                    #custom polygon
                    pcol=colors_border , pfcol=colors_in , plwd=2 , plty=1,
                    #custom the grid
                    cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(1,5,1), cglwd=1,
                    #custom labels
                    vlcex=1,title="By Cuisine"
    )
    legend(x="bottom", legend = rownames(data2[-c(1,2),]), bty = "n", pch=20 , col=c(rgb(0.8,0.2,0.5,0.9),rgb(0.2,0.5,0.5,0.4))  , text.col = "grey", cex=1.2, pt.cex=3)
    return(r2)
  })
  output$note1<-renderText({as.character(data[data[,1]==id(),"Suggestion1"])})
  output$note2<-renderText({as.character(data[data[,1]==id(),"Suggestion2"])})
  output$wordcloud2pos<-renderWordcloud2({
    words1<-unlist(strsplit(data[data[,1]==id(),24],split=","))
    wordtab1<-sort(table(words1),decreasing = TRUE)
    wordpos<-as.data.frame(wordtab1)
    if(nrow(wordpos) <= 10){
      size = 0.4} else if(nrow(wordpos) <= 20){
      size = 0.5} else if(nrow(wordpos) <= 40){
      size = 0.6} else if(nrow(wordpos) <= 80){
      size = 0.7} else if(nrow(wordpos) <= 120 ){
      size = 1} else if(nrow(wordpos) <= 160){
      size = 1.5} else{
      size = 2}
    return(wordcloud2(wordpos,size=size))
  })
  output$wordcloud2neg<-renderWordcloud2({
    words2<-unlist(strsplit(data[data[,1]==id(),25],split=","))
    wordtab2<-sort(table(words2),decreasing = TRUE)
    wordneg<-as.data.frame(wordtab2)
    if(nrow(wordneg) <= 10){
      size = 0.4} else if(nrow(wordneg) <= 20){
      size = 0.5} else if(nrow(wordneg) <= 40){
      size = 0.6} else if(nrow(wordneg) <= 80){
      size = 0.7} else if(nrow(wordneg) <= 120 ){
      size = 1} else if(nrow(wordneg) <= 160){
      size = 1.5} else{
      size = 2}
    return(wordcloud2(wordneg,size=size,backgroundColor="black"))
  })
  output$imagetitle1<-renderImage({
    list(src = "like.jpg",
         width=250,
         height=89,
         alt = "OOF! The Pic Seems Broken!")
  },deleteFile = FALSE)
  output$imagetitle2<-renderImage({
    list(src = "dislike.jpg",
         width=250,
         height=89,
         alt = "OOF! The Pic Seems Broken!")
  },deleteFile = FALSE)
  output$nametitle <- renderText({data[data[,1]==id(),"name"]})
  img<-reactive({
    if(id() == 0 )
      return(0)
    else
      return(data[data[,1]==id(),"stars"])
  })
  output$image<-renderImage({
    list(src = paste(img(),"stars",".png",sep=""),
         contentType = 'image/png',
         width=190.4,
         height=37.4,
         alt = "OOF! The Pic Seems Broken!")
  },deleteFile = FALSE)
  output$title<-renderImage({
    list(src = "title.jpg",
         width=153.75,
         height=54.75,
         alt = "OOF! The Pic Seems Broken!")
  },deleteFile = FALSE)
  output$businessid<-renderText({
    paste("Business ID:",id(),sep=" ")
  })
  output$genre<-renderText({
    as.character(data[data[,1]==id(),"Cuisine.Category"])
  })
  output$revnum<-renderText({
    paste(data[data[,1]==id(),26],"reviews")
  })
  
  output$address1<-renderText({
    data[data[,1]==id(),"address"]
  })
  output$address2<-renderText({
    if(id()==0)
      return("oof, seems like there's something wrong with your input")
    else
      return(paste(data[data[,1]==id(),"city"],", ",data[data[,1]==id(),"state"],sep=""))
  })
  output$barplot<-renderPlot({
    barplot(as.numeric(data[which(data[,1]==id()),c(7,8,9,10,11)]),names.arg=c("Food","Service","Ambience","Price","Misc"),col=c("#fbb4ae","#b3cde3","#ccebc5","#decbe4", "#fed9a6"),
            main ="Aspect Scores",ylim=c(0,5))
    abline(h=data[data[,1]==id(),"stars"],col="red",lty=5)
  })
})