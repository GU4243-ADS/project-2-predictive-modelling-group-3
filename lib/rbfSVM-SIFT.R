library(caret)
library(e1071)
setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/doc")
siftfeature
siftfeature = data.frame(siftfeature[,-1])
label = read.csv('../output/label_train.csv', header = T)
label = data.frame(label[,-1])
colnames(label) = c("Label")

set.seed(2008)
siftfeature_complete = cbind(label, siftfeature) 
siftfeature_complete$Label = as.factor(siftfeature_complete$Label) 
sift_sep = createDataPartition(siftfeature_complete$Label, p = 0.25, list = F) 
siftfeature_test = siftfeature_complete[sift_sep, ]
siftfeature_train = siftfeature_complete[-sift_sep, ] 


train_svm = function(sift_train){
  fitControl = trainControl(method = 'cv', number = 2)
  svmGrid = expand.grid(sigma= 2^c(-25, -20, -15,-10, -5, 0), C = c(0.5,1,2))
  start_time_svm = Sys.time() 
  svm.fit = train(Label~., 
                  data = sift_train,
                  method = "svmRadial",
                  preProc = c('center', 'scale'),
                  tuneGrid = svmGrid,
                  trControl = fitControl)
  end_time_svm = Sys.time() 
  svm_time = end_time_svm - start_time_svm 
  return(list(fit = svm.fit, time = svm_time))
}

test_svm = function(fit_train, sift_test){
  pred = predict(fit_train$fit, newdata = siftfeature_test)
  return(pred)
}

svm = train_svm(siftfeature_train)

sift_train_accuracy = mean(test_svm(svm,siftfeature_train) == siftfeature_train$Label)
sift_test_accuracy = mean(test_svm(svm,siftfeature_test) == siftfeature_test$Label)
svm_time = svm$time