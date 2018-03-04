#########################################################

### Train a classification model with training images ###

#########################################################

### Author: Mingyue Kong

### Project 2

### ADS Spring 2018



hog_train <- read.csv(file.choose())
n <- nrow(hog_train)
r <- sample(1:n, n)
dat_train <- hog_train[r,]
label_train <- read.csv(file.choose())
label_train <- label_train[,-1]
label_train <- label_train <- label_train[r]
data.all <- as.data.frame(cbind(dat_train, label_train))
colnames(data.all)[ncol(data.all)] <- "Label"
data.all$Label <- as.factor(data.all$Label)
control <- trainControl(method = 'cv', number = 10)
inTrain <- createDataPartition(y = data.all$Label, p=0.75, list=FALSE)
training <- data.all[inTrain, ]
testing <- data.all[-inTrain, ]
svmGrid.linear <- expand.grid(C= 2^c(0,1,2,-1,-2))
svm.linear <- train(Label~., data = training,
                    method = "svmLinear", trControl = control, tuneGrid = svmGrid.linear, preProc = c("center","scale"))
train.svmlinear <- sum(predict(svm.linear, training) != training$Label)/nrow(training)
test.svmlinear <- sum(predict(svm.linear, testing) != testing$Label)/nrow(testing)