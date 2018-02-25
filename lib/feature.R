#############################################################
### Construct visual features for training/testing images ###
#############################################################

### Authors: Sophie Beiers
### Based off of code by: Yuting Ma/Tian Zheng
### Project 2
### ADS Spring 2018

feature <- function(img_dir, export=T){
  
  ### Construct process features for training/testing images
  ### Sample simple feature: Extract row average raw pixel values as features
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  ### load libraries
  library("EBImage")
  
  # img_train_dir is where image files are stored
  n_files <- length(list.files(img_dir))
  
  ### store vectorized pixel values of images
  dat <- matrix(NA, n_files, ncol = 150) 
  for(i in 1:n_files){
    img     <- readImage(paste0(img_dir, "pet", i, ".jpg"))
    img_bw <- channel(img, "gray")
    img_bw <- resize(img_bw, 150)
    dat[i,] <- rowMeans(img_bw)
  }
  
  ### output constructed features
  if(export){
    save(dat, file = paste0("../output/feature_train.RData"))
  }
  return(dat)
}




