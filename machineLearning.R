###machine learning to determine if playing
setwd('C:/Users/ian.p.kloo/Documents')
injured <- read.csv('injured.csv', stringsAsFactors=FALSE)

#naive model
unique(train$Game.Status)

#out or IR = 0%
#doubtful = 25%
#questionable = 50%
#probable or day-to-day = "very likely" or "virtually certain" 90%
prob <- rep(NA, nrow(injured))
for(i in 1:nrow(injured)){
  if(injured$Game.Status[i] == 'Out' | injured$Game.Status[i] == 'Injured Reserve (DFR)'){
    prob[i] <- 0
  } else if(injured$Game.Status[i] == 'Doubtful'){
    prob[i] <- .25
  } else if(injured$Game.Status[i] == 'Questionable'){
    prob[i] <- .5
  } else if(injured$Game.Status[i] == 'Probable'){
    prob[i] <- .9
  } else if(injured$Game.Status[i] == 'Day-to-Day'){
    prob[i] <- .9
  }
}

pred <- rep(NA, nrow(injured))
for(i in 1:nrow(injured)){
  if(injured$Game.Status[i] == 'Out' | injured$Game.Status[i] == 'Injured Reserve (DFR)'){
    pred[i] <- 'no'
  } else if(injured$Game.Status[i] == 'Doubtful'){
    pred[i] <- sample(c('yes','no'), size=1, prob=c(.25,.75))
  } else if(injured$Game.Status[i] == 'Questionable'){
    pred[i] <- sample(c('yes','no'), size=1, prob=c(.5,.5))
  } else if(injured$Game.Status[i] == 'Probable'){
    pred[i] <- sample(c('yes','no'), size=1, prob=c(.90,.1))
  } else if(injured$Game.Status[i] == 'Day-to-Day'){
    pred[i] <- sample(c('yes','no'), size=1, prob=c(.90,.1))
  }
}

confusionMatrix(injured$played, pred)

#performance = 68.07%



#bayes net
library(RWeka)
modelData <- injured[,c(7,2,3,4,5,8)]
for(i in 1:ncol(modelData)){
  modelData[,i] <- as.factor(modelData[,i])
}

trainingNum <- sample(nrow(modelData), .8*nrow(modelData))
train <- modelData[trainingNum,]
test <- modelData[-trainingNum,]

BNet <- make_Weka_classifier("weka/classifiers/bayes/BayesNet")
K2="weka.classifiers.bayes.net.search.local.K2"
wcontrol <- Weka_control(D=TRUE,Q=K2,"--",P=2)
probModel <- BNet(train$played~., data=train[,2:6], control=wcontrol)

summary(probModel)

prob <- predict(probModel, newdata = test, type='probability')
pred <- predict(probModel, newdata = test)

confusionMatrix(test$played, pred)

#performance = 73.9%


#nural net
require(caret)
data <- injured[,c(7,2,3,4,5,8)]
data$Team[which(is.na(data$Team))] <- 'Unknown'

trainingNum <- sample(nrow(data), .8*nrow(data))
train <- data[trainingNum,]
test <- data[-trainingNum,]

model <- train(played~., data=train, method='nnet')
probs <- predict(model, test, type='prob')
pred <- predict(model, test)

confusionMatrix(test$played, pred)

#performance = 81.29%


#svm
data <- injured[,c(7,2,3,4,5,8)]
data$Team[which(is.na(data$Team))] <- 'Unknown'
for(i in 1:ncol(data)){
  data[,i] <- as.factor(data[,i])
}

trainingNum <- sample(nrow(data), .8*nrow(data))
train <- data[trainingNum,]
test <- data[-trainingNum,]

model <- train(played~., data=train, method='svmLinear', trControl = trainControl(method = "repeatedcv", repeats = 5, classProbs =  TRUE))
probs <- predict(model, test, type='prob')
pred <- predict(model, test)

confusionMatrix(test$played, pred)

#performance = 80.14%

#random forest
data <- injured[,c(7,2,3,4,5,8)]
data$Team[which(is.na(data$Team))] <- 'Unknown'
for(i in 1:ncol(data)){
  data[,i] <- as.factor(data[,i])
}

trainingNum <- sample(nrow(data), .8*nrow(data))
train <- data[trainingNum,]
test <- data[-trainingNum,]

model <- train(played~., data=train, method='parRF')
probs <- predict(model, test, type='prob')
pred <- predict(model, test)

confusionMatrix(test$played, pred)

#performance = 80.6%


#rule-based
data <- injured[,c(7,2,3,4,5,8)]
data$Team[which(is.na(data$Team))] <- 'Unknown'
for(i in 1:ncol(data)){
  data[,i] <- as.factor(data[,i])
}

trainingNum <- sample(nrow(data), .8*nrow(data))
train <- data[trainingNum,]
test <- data[-trainingNum,]

model <- train(played~., data=train, method='PART')
probs <- predict(model, test, type='prob')
pred <- predict(model, test)

confusionMatrix(test$played, pred)

varImp(model)

#performance = 77.83%


#j48 decision trees
data <- injured[,c(7,2,3,4,5,8)]
data$Team[which(is.na(data$Team))] <- 'Unknown'
for(i in 1:ncol(data)){
  data[,i] <- as.factor(data[,i])
}

trainingNum <- sample(nrow(data), .8*nrow(data))
train <- data[trainingNum,]
test <- data[-trainingNum,]

model <- train(played~., data=train, method='J48')
probs <- predict(model, test, type='prob')
pred <- predict(model, test)

confusionMatrix(test$played, pred)

plot(model$finalModel)

#performance = 81.99%
