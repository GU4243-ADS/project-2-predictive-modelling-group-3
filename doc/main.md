---
title: "Project 3 - Main Script"
author: "Alek Anichowski, Sophie Beiers, Mingyue Kong, Yun Li, Keith Rodriguez"
date: "March 5th, 2018"
output: 
  html_document:
    keep_md: true
    toc: true
    toc_float: true
    theme: lumen
    highlight: tango
---
In your final Project 2 repo, there should be an R markdown file called `main.Rmd` that organizes **all computational steps** for evaluating your proposed image classification framework. 

This file is meant to be a template for evaluating models used for image analysis (and could be generalized for any predictive modeling). You should update it according to your models/codes but your final document should have precisely the same structure. 


```r
if(!require("EBImage")){
  source("https://bioconductor.org/biocLite.R")
  biocLite("EBImage")
}
```

```
## Loading required package: EBImage
```

```r
if(!require("gbm")){
  install.packages("gbm")
}
```

```
## Loading required package: gbm
```

```
## Loading required package: survival
```

```
## Loading required package: lattice
```

```
## Loading required package: splines
```

```
## Loading required package: parallel
```

```
## Loaded gbm 2.1.3
```

```r
if(!require("pbapply")){
  install.packages("pbapply")
}
```

```
## Loading required package: pbapply
```

```r
if(!require("pbapply")){
  install.packages("caret")
}

if(!require("FNN")){
  install.packages("FNN")
}
```

```
## Loading required package: FNN
```

```r
library(FNN)
library("EBImage")
library("gbm")
library("pbapply")
library("caret")
```

```
## Loading required package: ggplot2
```

```
## 
## Attaching package: 'caret'
```

```
## The following object is masked from 'package:survival':
## 
##     cluster
```

```r
library(randomForest)
```

```
## randomForest 4.6-12
```

```
## Type rfNews() to see new features/changes/bug fixes.
```

```
## 
## Attaching package: 'randomForest'
```

```
## The following object is masked from 'package:ggplot2':
## 
##     margin
```

```
## The following object is masked from 'package:EBImage':
## 
##     combine
```

## Step 0: Specify directories.

We first set the working directory to the location of this .Rmd file. Then we specify our training and testing data. To train the initial baseline model, we used the `caret` package to partition the data into training and testing sets. This code can be seen commented out. 


```r
setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/doc")
```

Now we provide directories for the raw images. Here we assume the training set and test set are in different subfolders. 

```r
experiment_dir <- "../data/pets/" 
img_train_dir  <- paste(experiment_dir, "train/", sep="")
img_test_dir   <- paste(experiment_dir, "test/", sep="") 
```

## Step 1: Set up controls for model evaluation.

In this step, we have a set of controls for the model evaluation.  The code in the rest of the document runs (or not) according to our choices here. 

+ (number) the seed we use to ensure reproducibility
+ (TRUE/FALSE) whether we are running our models on training data
+ (TRUE/FALSE) whether we are running our models on testing data
+ (TRUE/FALSE) run cross-validation on the training set
+ (number) K, the number of CV folds
+ (TRUE/FALSE) process features for training set
+ (TRUE/FALSE) run evaluation on an independent test set
+ (TRUE/FALSE) process features for test set


```r
set.seed(2018)    # set seed
run.cv            <- FALSE  # run cross-validation on the training set
K                 <- 5     # number of CV folds
run.feature.train <- FALSE # process features for training set
run.test          <- TRUE  # run evaluation on an independent test set
run.feature.test  <- TRUE  # process features for test set
```

Using cross-validation or independent test set evaluation, we compare the performance of different classifiers. In this example, we use GBM with different `depth`. In the following code chunk, we list, in a vector, setups (in this case, `depth`) corresponding to model parameters that we will compare. 


```r
model_values <- seq(5, 10, 2) # trying a few different depths 
model_labels <- paste("GBM with depth =", model_values)
```

## Step 2: Import training and testing images and classification labels.

Below, we code dog as 1 and cat as 0. 

```r
if (run.feature.train){
label_train <- read.table(paste(experiment_dir, "train_label.txt", sep = ""), header = F)
label_train <- as.numeric(unlist(label_train) == "dog") # turn into a binary -- 1 is dog. 
write.csv(label_train, '../output/label_train.csv')
}

if (run.feature.test){
label_test <- read.table(paste(experiment_dir, "test_label.txt", sep = ""), header = F)
label_test <- as.numeric(unlist(label_test) == "dog") # turn into a binary -- 1 is dog.
write.csv(label_test, '../output/label_test.csv')
}
```

## Step 3: Construct visual features

### SIFT features

```r
# training
if(run.feature.train){
load('100kmeans.rda')

sift_feature_dir <- "../data/train-features/" 
num_images = length(list.files(path = sift_feature_dir))

data = list()

for (i in 1:num_images){
  file = sprintf("pet%i.jpg.sift.RData", i)
  file_path = paste0(sift_feature_dir,file)
  load(file_path)
  feature_clusters <- get.knnx(k.out$centers, features, 1)$nn.index[,1]
  feature_vec <- rep(0,101)
  feature_vec[1] = i
  for (j in 1:length(feature_clusters)){
  c = feature_clusters[j] + 1 #since the first column is reserved for the index
  feature_vec[c] = feature_vec[c]+ 1}
  data[[i]] = feature_vec


}

sift_data_train = do.call("rbind", data)
}


# testing set
if(run.feature.test){
load('100kmeans.rda')
sift_feature_dir <- "../data/test-features/"
num_images = length(list.files(path = sift_feature_dir))

data = list()

for (i in 1:num_images){  
  file = sprintf("pet%i.jpg.sift.RData", i)
  file_path = paste0(sift_feature_dir,file)
  load(file_path)
  feature_clusters <- get.knnx(k.out$centers, features, 1)$nn.index[,1]
  feature_vec <- rep(0,101)
  feature_vec[1] = i
  for (j in 1:length(feature_clusters)){
  c = feature_clusters[j] + 1 #since the first column is reserved for the index
  feature_vec[c] = feature_vec[c]+ 1}
  data[[i]] = feature_vec
}

sift_data_test = do.call("rbind", data)
}
```

### HOG features

```r
# 
# training data
if(run.feature.train){
source("../lib/feature_HOG.R")
tm_feature_train <- NA
  tm_feature_train <- system.time(hog_train <- feature(img_train_dir, export = TRUE))
  save(hog_train, file = "../output/HOG_features_train.RData")
}
# 
# testing data
if(run.feature.test){
source("../lib/feature_HOG_test.R")
tm_feature_test <- NA

  tm_feature_test <- system.time(hog_test <- feature(img_test_dir, export = TRUE))
  save(hog_test, file = "../output/HOG_features_test.RData")
}
```

```
## Warning: package 'OpenImageR' was built under R version 3.4.3
```

```
## 
## Attaching package: 'OpenImageR'
```

```
## The following objects are masked from 'package:EBImage':
## 
##     readImage, writeImage
```

### Combining Features

```r
#Combining Features - SIFTHOG TRAIN
if (run.feature.train){
siftfeature_train <- sift_data_train
siftfeature_train$mergeid <- seq(1, nrow(siftfeature_train), 1)

HOGfeature_train <- hog_train
HOGfeature_train <- data.frame(HOGfeature_train[,-1])
HOGfeature_train$mergeid <- seq(1, nrow(HOGfeature_train), 1)
SIFTHOG_train <- merge(HOGfeature_train, siftfeature_train, by=c("mergeid"))
#write.csv(SIFTHOG_train,"../output/SIFTHOG_train.CSV")

}

#Testing FEATURES
if (run.feature.test){
siftfeature_test <- data.frame(sift_data_test)
siftfeature_test$mergeid <- seq(1, nrow(siftfeature_test), 1)

HOGfeature_test <- data.frame(hog_test)
HOGfeature_test <- data.frame(HOGfeature_test[,-1])
HOGfeature_test$mergeid <- seq(1, nrow(HOGfeature_test), 1)
SIFTHOG_test <- merge(HOGfeature_test, siftfeature_test, by=c("mergeid"))
write.csv(SIFTHOG_test,"../output/SIFTHOG_test.CSV")
}
```


## Step 4: Training Baseline Model
Train a classification model with training images (and the visual features constructed above) & training baseline model on split training data.
Call the train model and test model from library for the baseline training. 

+ `train.R`
  + Input: a path that points to the training set features.
  + Input: an R object of training sample labels.
  + Output: an RData file that contains trained classifiers in the forms of R objects: models/settings/links to external trained configurations.
+ `test.R`
  + Input: a path that points to the test set features.
  + Input: an R object that contains a trained classifier.
  + Output: an R object of class label predictions on the test set. If there are multiple classifiers under evaluation, there should be multiple sets of label predictions. 
  

```r
source("../lib/train.R")
source("../lib/test.R")
```
Train function runs GBM function and test just uses the fitted training model and our data to make some predictions. 

### Model selection with cross-validation

* Do model selection for baseline model.  Here we choose between model parameters, in this case the interaction depth for GBM. 


```r
source("../lib/cross_validation.R")

label.train <- read.csv("../output/label_train.csv",header=TRUE, as.is = TRUE)
label.test <- read.csv("../output/label_test.csv",header=TRUE, as.is = TRUE)


if(run.cv){
  err_cv <- array(dim = c(length(model_values), 2))
  for(k in 1:length(model_values)){
    cat("k=", k, "\n")
    err_cv[k,] <- cv.function(sift_data_train, label.train[,2], model_values[k], K)
  }
  save(err_cv, file = "../output/err_cv.RData")
}
```
Counts number of misclassifications. This now calculates the best decision. 

```r
if(run.cv){
  load("../output/err_cv.RData")
  #pdf("../figs/cv_results_baseline.pdf", width=7, height=5)
  plot(model_values, err_cv[,1], xlab = "Interaction Depth", ylab = "CV Error",
       main = "Cross Validation Error", type = "n", ylim = c(0, 0.30))
  points(model_values, err_cv[,1], col = "blue", pch=16)
  lines(model_values, err_cv[,1], col = "blue")
  arrows(model_values, err_cv[,1] - err_cv[,2], model_values, err_cv[,1] + err_cv[,2], 
        length = 0.1, angle = 90, code = 3)
  #dev.off()
}
```

* Choose the "best" parameter value


```r
model_best <- model_values[2]
if(run.cv){
  model_best <- model_values[which.min(err_cv[, 1])]
}

par_best <- list(depth = model_best)
```

* Train the model with the entire training set using the selected model (in this case, model parameter) via cross-validation.


```r
# need to edit train.R and test.R with our winning model 
if (run.feature.train){
tm_train <- NA
tm_train <- system.time(baseline_train <- train(sift_data_train, label.train[ ,2], par_best))
save(baseline_train, file = "../output/baseline_train.RData")
}
```

## Step 5. Training Advanced Model


```r
label.train <- read.csv("../output/label_train.csv",header=TRUE, as.is = TRUE)
label.test <- read.csv("../output/label_test.csv",header=TRUE, as.is = TRUE)

in_train <- createDataPartition(y = label.train$x, p = 3/4, list = FALSE)

#if loading from csv
SIFTHOG <- read.csv("../output/SIFTHOG.csv")

SIFTHOG_train = SIFTHOG[in_train,]
SIFTHOG_val = SIFTHOG[-in_train,]

SIFTHOG_train = SIFTHOG_train[,-2]
SIFTHOG_val <- SIFTHOG_val[,-2]

train_labels = label.train[in_train,2]
val_labels = label.train[-in_train,2]
```

## Step 6: Make prediction 

Feed the final training model with the test data.  (Note that for this to truly be 'test' data, it should have had no part of the training procedure used above.) 


```r
#Baseline Model
tm_test <- NA
if(run.test){
  load(file = "../output/baseline_train.RData")
  tm_test <- system.time(pred_test <- test(baseline_train, sift_data_test))
  save(pred_test, file = "../output/pred_test.RData")
}

table(label.test[ ,2], pred_test)
```

```
##    pred_test
##      0  1
##   0  9 10
##   1  1 30
```

```r
mean(label.test[ ,2] == pred_test) ## 72.8% accuracy rate for baseline with SIFT features and random partitioned training set
```

```
## [1] 0.78
```


```r
#Advanced Model

labels = label.test[,2]
#labels = val_labels
SIFTHOG_test <- read.csv("../output/SIFTHOG_test.csv")
combnames = names(SIFTHOG_train)
colnames(SIFTHOG_test) <- c(combnames)
testdata = SIFTHOG_test

#RANDOM FOREST

#val 
#load("../output/randomForest_train.rda") # called rf
load("../output/randomForest_full.rda") # called rf_all


#testingfinal

pred_random <- predict(rf_all, testdata)
pred_random  = as.numeric(pred_random) - 1
error_rate_random <- mean(pred_random != labels)

#SVM

#load("../output/linearsvmtrain-SIFTHOG1500.rda") # called svm1500
load("../output/linearsvmtrain-SIFTHOG2000.rda") # called svm2000

test_svm = function(fit_train, testdata){
  pred = predict(fit_train$fit, newdata = testdata)
  return(pred)
}

pred_svm = test_svm(svm2000,testdata)
pred_svm = as.numeric(pred_svm) - 1
error_rate_svm <- 1 - mean(pred_svm == labels)

#Logistic Regression

#load("../output/logisticregression_SIFT+HOG_1500.rda") #logistic.fit.1500
load("../output/logisticregression_SIFT+HOG_2000.rda") #logistic.fit.2000

logistic_pred <- predict(logistic.fit.2000, newdata = testdata, "response")
```

```
## Warning in predict.lm(object, newdata, se.fit, scale = 1, type =
## ifelse(type == : prediction from a rank-deficient fit may be misleading
```

```r
logistic_pred <- data.frame(logistic_pred)
logistic_pred$V2 = 0.5
for (i in 1:nrow(logistic_pred)){
  logistic_pred[i, 2] <- which.max(logistic_pred[i, ])-1}

pred_lr = logistic_pred[,2]
for (i in 1:length(pred_lr)){
  if (pred_lr[i]){ pred_lr[i] = 0
  }
  else{ pred_lr[i] = 1}
}

error_rate_lr = 1 - mean(pred_lr == labels)

###
pred_combined = rep(0,length(pred_lr))
for (i in 1:length(pred_combined)){
  vote = pred_random[i] + pred_svm[i] + pred_lr[i]
  if (vote > 1){ pred_combined[i] = 1}
}

error_rate_combined = 1 - mean(pred_combined == labels)
```

### Summarize Running Time

Prediction performance matters, so does the running times for constructing features and for training the model, especially when the computation resource is limited. 

Summarizes running time. 

```r
if(run.feature.train){
cat("Time for constructing training features=", tm_feature_train[1], "s \n")
cat("Time for training model=", tm_train[1], "s \n")
}

if(run.feature.test){
cat("Time for constructing testing features=", tm_feature_test[1], "s \n") # later
cat("Time for making prediction=", tm_test[1], "s \n")
}
```

```
## Time for constructing testing features= 1.18 s 
## Time for making prediction= 0.006 s
```
