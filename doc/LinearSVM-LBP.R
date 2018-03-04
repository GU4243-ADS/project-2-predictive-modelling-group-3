library(caret)
library(e1071)
setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/doc")

LBPfeature = read.csv('../output/lbp-version2.csv',header = T)
LBPfeature = data.frame(LBPfeature[,-1])
label = read.csv('../output/label_train.csv', header = T)
label = data.frame(label[,-1])
colnames(label) = c("Label")

set.seed(2008)
LBPfeature_complete = cbind(label, LBPfeature) 
LBPfeature_complete$Label = as.factor(LBPfeature_complete$Label) 
LBP_sep = createDataPartition(LBPfeature_complete$Label, p = 0.25, list = F) 
LBPfeature_test = LBPfeature_complete[LBP_sep, ]
LBPfeature_train = LBPfeature_complete[-LBP_sep, ] 


train_svm = function(LBP_train){
  fitControl = trainControl(method = 'cv', number = 2)
  svmGrid = expand.grid(C = c(0.5,1,2))
  start_time_svm = Sys.time() 
  svm.fit = train(Label~., 
                  data = LBP_train,
                  method = "svmLinear",
                  preProc = c('center', 'scale'),
                  tuneGrid = svmGrid,
                  trControl = fitControl)
  end_time_svm = Sys.time() 
  svm_time = end_time_svm - start_time_svm 
  return(list(fit = svm.fit, time = svm_time))
}

test_svm = function(fit_train, LBP_test){
  pred = predict(fit_train$fit, newdata = LBPfeature_test)
  return(pred)
}

svm = train_svm(LBPfeature_train)

LBP_train_accuracy = mean(test_svm(svm,LBPfeature_train) == LBPfeature_train$Label)
LBP_test_accuracy = mean(test_svm(svm,LBPfeature_test) == LBPfeature_test$Label)
svm_time = svm$time

