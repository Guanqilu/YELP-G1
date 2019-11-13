########################################
# READ DATA, PREPROCESSING
########################################
rm(list = ls())
getwd()
setwd("./Desktop/")
rawdata = read.csv("score_output2_normalize+review count+stars.csv")
View(rawdata)

table(rawdata$star)
quantile(rawdata$star)      
rawdata$response = rawdata$star >=3.5 # turns to binary response
table(rawdata$response) # proportion of T : F is close to 1:1
summary(rawdata[,14:23])
apply(rawdata[,14:23], 2, sd)

rawdata$f.prop = rawdata$fp/(rawdata$fp-rawdata$fn) #negative score is always negative, so we take absolute (using minus sign)
rawdata$s.prop = rawdata$sp/(rawdata$sp-rawdata$sn)
rawdata$a.prop = rawdata$ap/(rawdata$ap-rawdata$an)
rawdata$p.prop = rawdata$pp/(rawdata$pp-rawdata$pn)
rawdata$m.prop = rawdata$mp/(rawdata$mp-rawdata$mn)
summary(rawdata[,c("f.prop", "s.prop", "a.prop", "p.prop", "m.prop")])
#There are NA since some of the category doesn't appear in the reviews
# check NA value
# rawdata[model0$na.action, 20:23]

##################################################
#Model0 use "positive score/(positive score+negative score), 
#to see the significance of each variable 
##################################################
model0 = glm(response ~ f.prop + s.prop + a.prop + p.prop + m.prop ,
             family = binomial, data = rawdata)# weights = review.counts, 
summary(model0) 
# every category is significant

#calculate AUC
model0.pred = model0$fitted.values>=0.5
table(rawdata$response[-model0$na.action], model0.pred)
library(pROC)
roc_curve0 <- roc(rawdata$response[-model0$na.action],model0$fitted.values)
names(roc_curve0)
x <- 1-roc_curve0$specificities
y <- roc_curve0$sensitivities
library(ggplot2)
p0 <- ggplot(data = NULL, mapping = aes(x= x, y = y))
p0 + geom_line(colour = 'red') + geom_abline(intercept = 0, slope = 1) + 
  annotate('text', x = 0.4, y = 0.5, label =paste('AUC=',round(roc_curve0$auc,2))) +
  labs(x = '1-specificities',y = 'sensitivities', title = 'ROC Curve') # AUC greater than 0.8, significant

##################################################
#Model1 use positive scores and negative scores 
#to compare the importance of positive score and negative score 
##################################################
model1 = glm(response ~ fp + fn + sp + sn + ap + an + pp + pn + mp + mn,
             family = binomial,  data = rawdata)# weights = review.counts,
summary(model1)
# model12 = glm(response ~ food.pos + food.neg + service.pos + service.neg + ambience.pos + ambience.neg + price.pos + price.neg + misc.pos + misc.neg,
#              family = binomial, weights = review.counts, data = rawdata)
# summary(model12)

model1.pred = model1$fitted.values>=0.5
table(rawdata$response, model1.pred)
roc_curve1 <- roc(rawdata$response,model1$fitted.values)
names(roc_curve1)
x <- 1-roc_curve1$specificities
y <- roc_curve1$sensitivities
p1 <- ggplot(data = NULL, mapping = aes(x= x, y = y))
p1 + geom_line(colour = 'red') + geom_abline(intercept = 0, slope = 1) + 
  annotate('text', x = 0.4, y = 0.5, label =paste('AUC=',round(roc_curve1$auc,2))) +
  labs(x = '1-specificities',y = 'sensitivities', title = 'ROC Curve') # AUC greater than 0.8

##################################################
#Calculate adjusted proportion
##################################################
model1$coefficients
rawdata$adj.fp = model1$coefficients[2]*rawdata$food.pos/(model1$coefficients[2]*rawdata$food.pos-model1$coefficients[3]*rawdata$food.neg)
rawdata$adj.sp = model1$coefficients[4]*rawdata$service.pos/(model1$coefficients[4]*rawdata$service.pos-model1$coefficients[5]*rawdata$service.neg)
rawdata$adj.ap = model1$coefficients[6]*rawdata$ambience.pos/(model1$coefficients[6]*rawdata$ambience.pos-model1$coefficients[7]*rawdata$ambience.neg)
rawdata$adj.pp = model1$coefficients[8]*rawdata$price.pos/(model1$coefficients[8]*rawdata$price.pos-model1$coefficients[9]*rawdata$price.neg)
rawdata$adj.mp = model1$coefficients[10]*rawdata$misc.pos/(model1$coefficients[10]*rawdata$misc.pos-model1$coefficients[11]*rawdata$misc.neg)
summary(rawdata$adj.fp*5)
summary(rawdata$adj.sp*5)
summary(rawdata$adj.ap*5)
summary(rawdata$adj.pp*5)
summary(rawdata$adj.mp*5)
##################################################
#Model2 use "adjusted positive score/(positive score+negative score), 
#to see the significance of each variable again
##################################################
model2 = glm(response ~ adj.fp + adj.sp + adj.ap + adj.pp + adj.mp ,
             family = binomial, data = rawdata)# weights = review.counts, 
summary(model2) #if both model0 and model2 use weights, AIC will improve using adjusted proportion
# every category is significant

##################################################
#Normalize ratings for each category
##################################################
rawdata$norm.fp = ((rawdata$adj.fp-min(rawdata$adj.fp))/(max(rawdata$adj.fp)-min(rawdata$adj.fp)))*5
rawdata$norm.sp = ((rawdata$adj.sp-min(rawdata$adj.sp))/(max(rawdata$adj.sp)-min(rawdata$adj.sp)))*5
rawdata$norm.ap = ((rawdata$adj.ap-min(rawdata$adj.ap))/(max(rawdata$adj.ap)-min(rawdata$adj.ap)))*5
rawdata$norm.pp = ((rawdata$adj.pp-min(rawdata$adj.pp, na.rm = T))/(max(rawdata$adj.pp, na.rm = T)-min(rawdata$adj.pp, na.rm = T)))*5
rawdata$norm.mp = ((rawdata$adj.mp-min(rawdata$adj.mp, na.rm = T))/(max(rawdata$adj.mp, na.rm = T)-min(rawdata$adj.mp, na.rm = T)))*5
summary(rawdata$norm.fp)
summary(rawdata$norm.sp)
summary(rawdata$norm.ap)
summary(rawdata$norm.pp)
summary(rawdata$norm.mp)

write.csv(rawdata, file = "cat_rating_raw.csv")
score = rawdata[-model0$na.action,c("business_id","norm.fp","norm.sp","norm.ap","norm.pp","norm.mp")]
write.csv(score, file = "cat_rating.csv")
