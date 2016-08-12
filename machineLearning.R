###machine learning to determine if playing

injured <- read.csv('injured.csv', stringsAsFactors=FALSE)

##approach 1: probability-based classification
library(RWeka)
modelData <- injured[,c(7,2,3,4,8)]
for(i in 1:ncol(modelData)){
  modelData[,i] <- as.factor(modelData[,i])
}

BNet <- make_Weka_classifier("weka/classifiers/bayes/BayesNet")
K2="weka.classifiers.bayes.net.search.local.K2"
wcontrol <- Weka_control(D=TRUE,Q=K2,"--",P=2)
probModel <- BNet(modelData$played~., data=modelData[,2:5], control=wcontrol)

summary(probModel)

predict(probModel, newdata = modelData, type='probability')



