#########################################################
### Train a classification model with training images ###
#########################################################

### Author: Yun Li
### Project 2
### ADS Spring 2018



##### Logistic Regression #####

train_lr = function(dat_train){
  
  ###  dat_train: processed features from images also contains label
  
  library(nnet)
  
  start_time_lr = Sys.time() # Model Start Time
  lr.fit = glm(Label~., 
                    data = dat_train, 
                    family = "binomial")
  end_time_lr = Sys.time() # Model End time
  end_time_lr - start_time_lr
  
  lr_time = end_time_lr - start_time_lr #Total Running Time
  
  
  return(list(fit = lr.fit, time = lr_time))
}
