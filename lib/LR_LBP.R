# install.packages("caret")
library(caret)
setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/doc")

features <- read.csv("../output/lbp-version1.csv")
label.train <- read.csv("../output/label_train.csv",header=TRUE, as.is = TRUE)
label.train$x <- as.factor(label.train$x) # x is whether photo is dog or cat

set.seed(2008)

in_train <- createDataPartition(y = label.train$x,
                                p = 3 / 4, 
                                list = FALSE)

training <- features[ in_train, ]
testing  <- features[-in_train, ]

x.train <- features[ in_train, ]
y.train <- label.train[ in_train, 2 ]

x.test <- features[ -in_train, ]
y.test <- label.train[ -in_train, 2 ]

start <- Sys.time()

#logitic regression
logistic.fit <- glm(y.train~., 
                    data = training, 
                    family = "binomial")
summary(logistic.fit)

#prediction

logistic_pred <- predict(logistic.fit, newdata = testing, "response")
end <- Sys.time()

time = end - start

logistic_pred <- data.frame(logistic_pred)
logistic_pred$V2 = 0.5
for (i in 1:nrow(logistic_pred)){
  logistic_pred[i, 2] <- which.max(logistic_pred[i, ])-1
}

accuracy = mean(logistic_pred[,2] == y.test)

r = list(lr_accuracy = 1-accuracy, lr_time = time)
r         




