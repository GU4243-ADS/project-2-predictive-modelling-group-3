#############################################################
### Construct visual features for training/testing images ###
#############################################################

### Authors: Yuting Ma/Tian Zheng
### Project 3
### ADS Spring 2017

feature <- function(img_dir, export=T){
  
  ### Construct process features for training/testing images
  ### Sample simple feature: Extract row average raw pixel values as features
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  ### load libraries
  library("EBImage")
  
  # img_train_dir is where image files are stored
  n_files <- length(list.files(img_dir))

  
  ### determine img dimensions
  # img0 <-  readImage(paste0(img_train_dir, "pet", i, ".jpg"))
  # mat1 <- as.matrix(img0)
  # n_r  <- nrow(img0)
  
  ### store vectorized pixel values of images
  dat <- matrix(NA, nrow = n_files, ncol = 3) 
  for(i in 1:n_files){
    img     <- readImage(paste0(img_dir, "pet", i, ".jpg"))
    dat[i,] <- rowMeans(img)
  }
  
  ### output constructed features
  if(export){
    save(dat, file = paste0("../output/feature_.RData"))
  }
  return(dat)
}
