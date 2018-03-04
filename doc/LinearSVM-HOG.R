library(caret)
library(e1071)
setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/doc")

HOGfeature = read.csv('../output/HOG_features.csv',header = T)
HOGfeature = data.frame(HOGfeature[,-1])
label = read.csv('../output/label_train.csv', header = T)
label = data.frame(label[,-1])
colnames(label) = c("Label")

set.seed(2008)
HOGfeature_complete = cbind(label, HOGfeature) 
HOGfeature_complete$Label = as.factor(HOGfeature_complete$Label) 
HOG_sep = createDataPartition(HOGfeature_complete$Label, p = 0.25, list = F) 
HOGfeature_test = HOGfeature_complete[HOG_sep, ]
HOGfeature_train = HOGfeature_complete[-HOG_sep, ] 


train_svm = function(HOG_train){
  fitControl = trainControl(method = 'cv', number = 2)
  svmGrid = expand.grid(C = c(0.5,1,2))
  start_time_svm = Sys.time() 
  svm.fit = train(Label~., 
                  data = HOG_train,
                  method = "svmLinear",
                  preProc = c('center', 'scale'),
                  tuneGrid = svmGrid,
                  trControl = fitControl)
  end_time_svm = Sys.time() 
  svm_time = end_time_svm - start_time_svm 
  return(list(fit = svm.fit, time = svm_time))
}

test_svm = function(fit_train, HOG_test){
  pred = predict(fit_train$fit, newdata = HOGfeature_test)
  return(pred)
}

svm = train_svm(HOGfeature_train)

HOG_train_accuracy = mean(test_svm(svm,HOGfeature_train) == HOGfeature_train$Label)
HOG_test_accuracy = mean(test_svm(svm,HOGfeature_test) == HOGfeature_test$Label)
svm_time = svm$time
