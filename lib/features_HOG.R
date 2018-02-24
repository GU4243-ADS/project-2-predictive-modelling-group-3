# Based on code by: 
### Authors: Yuting Ma/Tian Zheng
### Project 3
### ADS Spring 2017

setwd("~/Documents/GitHub/project-2-predictive-modelling-group-3/lib")
img_dir <- "../data/pets/train/"


feature<-function(img_dir, export=TRUE){
  
  ### Construct process features for training/testing images
  ### HOG: calculate the Histogram of Oriented Gradient for an image
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .Rdataa file contains processed features for the images
  
  
  ### load libraries
  library("EBImage")
  library("OpenImageR")
  
  dir_names <- list.files(img_dir)
  n_files <- length(dir_names)
  
  ### calculate HOG of images
  data <- matrix(NA, n_files, 50) 
  for(i in 1:n_files){
    img <- readImage(paste0(img_dir,  dir_names[i]))
    data[i,] <- HOG(img)
  }
  
  ### output constructed features
  if(export){
    save(data, file=paste0("../output/HOG_features.Rdata"))
  }
  return(data)
}

data_HOG<-feature(img_dir)
write.csv(data_HOG,"../output/HOG_features.csv")
