#SIFT FEATURES

set.seed(2008)
siftfeature = data_train
siftfeature = data.frame(siftfeature[,-1])
label = read.csv('../output/label_train.csv', header = T)
label = data.frame(label[,-1])
colnames(label) = c("Label")
siftfeature_complete = cbind(label, siftfeature) 
siftfeature_complete$Label = as.factor(siftfeature_complete$Label) 
sift_sep = createDataPartition(siftfeature_complete$Label, p = 0.25, list = F) 
siftfeature_test = siftfeature_complete[sift_sep, ]
siftfeature_train = siftfeature_complete[-sift_sep, ] 

#RANDOM FOREST
randomforestmodel = randomForest(siftfeature_train$Label ~ ., data = siftfeature_train, ntree = 600)

load("randomforestSIFT.rda") # called randomforestmodel

pred_random <- test(randomforestmodel, siftfeature_test[,2:101])
pred_random  = as.numeric(pred_random) - 1
error_rate_random <- mean(pred_random != siftfeature_test$Label)

#SVM

load("../output/linearsvmsift.rda") # called svm

test_svm = function(fit_train, sift_test){
  pred = predict(fit_train$fit, newdata = siftfeature_test)
  return(pred)
}

pred_svm = test_svm(svm,siftfeature_test[,2:101])
pred_svm = as.numeric(pred_svm) - 1
error_rate_svm <- 1 - mean(pred_svm == siftfeature_test$Label)

#Logistic Regression

logistic.fit <- glm(as.factor(siftfeature_train$Label) ~ ., 
                    data = siftfeature_train, 
                    family = "binomial")


logistic_pred <- predict(logistic.fit, newdata = siftfeature_test[,2:101], "response")

logistic_pred <- data.frame(logistic_pred)
logistic_pred$V2 = 0.5
for (i in 1:nrow(logistic_pred)){
  logistic_pred[i, 2] <- which.max(logistic_pred[i, ])-1}

pred_lr = logistic_pred
for (i in 1:length(pred_lr)){
  if (pred_lr[i]){ pred_lr[i] = 0
  }
  else{ pred_lr[i] = 1}
}

error_rate_lr = 1 - mean(pred_lr == siftfeature_test$Label)

###
pred_combined = rep(0,length(pred_lr))
for (i in 1:length(pred_combined)){
  vote = pred_random[i] + pred_svm[i] + pred_lr[i]
  if (vote > 1){ pred_combined[i] = 1}
}

error_rate_combined = 1 - mean(pred_combined == siftfeature_test$Label)

