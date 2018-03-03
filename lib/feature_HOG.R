
### Authors: Sophie Beiers
### Based off of code by: Yuting Ma/Tian Zheng and
### https://cran.r-project.org/web/packages/OpenImageR/vignettes/The_OpenImageR_package.html
### Project 2
### ADS Spring 2018

img_dir <- "../data/pets/train/"

feature<-function(img_dir, export=TRUE){
  
  ### Construct process features for training/testing images
  ### HOG: calculate the "Histogram of Oriented Gradients" for each image
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .Rdata file contains processed features for the images
  
  
  ### load libraries
  library(EBImage)
  library(OpenImageR)

  ### Number of rows/images
  n_files <- length(list.files(img_dir))
  
  ### calculate HOG of images
  data <- matrix(NA, n_files, ncol = 108) 
  for(i in 1:n_files){
    img <- readImage(paste0(img_dir, "pet", i, ".jpg"))
    #img_bw <- channel(img, "gray") # if we choose to make images BW
    img <- resize(img, 150, 150)
    data[i,] <- HOG(img)
  }
  
  ### output constructed features
  if(export){
    save(data, file=paste0("../output/HOG_features.Rdata"))
  }
  return(data)
}

HOG_features <- feature(img_dir)
write.csv(HOG_features,"../output/HOG_features.csv")

