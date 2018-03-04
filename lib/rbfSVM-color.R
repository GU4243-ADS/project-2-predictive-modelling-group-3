library(caret)
library(e1071)
setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/doc")

colorfeature = read.csv('../output/color_features.csv',header = T)
colorfeature = data.frame(colorfeature[,-1])
label = read.csv('../output/label_train.csv', header = T)
label = data.frame(label[,-1])
colnames(label) = c("Label")

set.seed(2008)
colorfeature_complete = cbind(label, colorfeature) 
colorfeature_complete$Label = as.factor(colorfeature_complete$Label) 
color_sep = createDataPartition(colorfeature_complete$Label, p = 0.3, list = F) 
colorfeature_test = colorfeature_complete[color_sep, ]
colorfeature_train = colorfeature_complete[-color_sep, ] 


train_svm = function(color_train){
  fitControl = trainControl(method = 'cv', number = 2)
  svmGrid = expand.grid(sigma= 2^c(-25, -20, -15,-10, -5, 0), C = c(0.5,1,2))
  start_time_svm = Sys.time() 
  svm.fit = train(Label~., 
                  data = color_train,
                  method = "svmRadial",
                  preProc = c('center', 'scale'),
                  tuneGrid = svmGrid,
                  trControl = fitControl)
  end_time_svm = Sys.time() 
  svm_time = end_time_svm - start_time_svm 
  return(list(fit = svm.fit, time = svm_time))
}

test_svm = function(fit_train, color_test){
  pred = predict(fit_train$fit, newdata = colorfeature_test)
  return(pred)
}

svm = train_svm(colorfeature_train)

color_train_accuracy = mean(test_svm(svm,colorfeature_train) == colorfeature_train$Label)
color_test_accuracy = mean(test_svm(svm,colorfeature_test) == colorfeature_test$Label)
svm_time = svm$time

