# install.packages("caret")
library(caret)
setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/doc")

features <- read.csv("../output/SIFTHOG.csv")
label.train <- read.csv("../output/label_train.csv",header=TRUE, as.is = TRUE)
label.train$x <- as.factor(label.train$x) # x is whether photo is dog or cat

set.seed(2008)


y.train <- label.train[ ,-1]
# y.train <- y.train[ , 1]
training <- features
training <- training[,-1]
training <- training[,-1]


#logitic regression
logistic.fit <- glm(y.train~., 
                    data = training, 
                    family = "binomial")
summary(logistic.fit)
# train_end <- Sys.time()
# train_time = train_end - train_start
# #prediction
# pre_start <- Sys.timet()
testing <- read.csv("../output/SIFTHOG_test.csv")
testing <- testing[,-1]

logistic_pred <- predict(logistic.fit, newdata = testing, "response")

# pre_end <- Sys.time()
# 
# pre_time = pre_end - pre_start

logistic_pred <- data.frame(logistic_pred)
logistic_pred$V2 = 0.5
for (i in 1:nrow(logistic_pred)){
  logistic_pred[i, 2] <- which.max(logistic_pred[i, ])-1
}

# accuracy = mean(logistic_pred[,2] == y.test)
# 
# r = list(lr_accuracy = 1-accuracy, lr_train_time = train_time, lr_pre_time = pre_time)
# r         

save(logistic_pred, file = "~/Documents/GitHub/project-2-predictive-modelling-group-3/output/pre_lr.rda")


