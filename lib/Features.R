if(!require("EBImage")){
  source("https://bioconductor.org/biocLite.R")
  biocLite("EBImage")
}

if(!require("gbm")){
  install.packages("gbm")
}

if(!require("pbapply")){
  install.packages("pbapply")
}

if(!require("pbapply")){
  install.packages("caret")
}

if(!require("FNN")){
  install.packages("FNN")
}

library(FNN)
library("EBImage")
library("gbm")
library("pbapply")
library("caret")

# Sift Feature Extraction
load('/Users/Clairiakong/Desktop/project-2-predictive-modelling-group-3/doc/100kmeans.rda')

closest.cluster <- function(x) {
  cluster.dist <- apply(k.out$centers, 1, function(y) sqrt(sum((x-y)^2)))
  return(which.min(cluster.dist)[1])
}

sift_feature_dir <- "/Users/Clairiakong/Desktop/project-2-predictive-modelling-group-3/data/train-features/" # This will be modified for different data sets.

data = list()

for (i in 1:2000){
  print(i)
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

siftdata = do.call("rbind", data)
siftfeature <- siftdata
siftfeature$mergeid <- seq(1, nrow(siftfeature), 1)

# SIFT + HOG

HOGfeature <- read.csv("/Users/Clairiakong/Desktop/project-2-predictive-modelling-group-3/output/HOG_features.csv")
HOGfeature <- data.frame(HOGfeature[,-1])
HOGfeature$mergeid <- seq(1, nrow(HOGfeature), 1)
SIFTHOG <- merge(HOGfeature, siftfeature, by=c("mergeid"))
write.csv(SIFTHOG,"/Users/Clairiakong/Desktop/SIFTHOG.CSV")

#SIFT+HOG+LBP

LBPfeature <- read.csv("/Users/Clairiakong/Desktop/project-2-predictive-modelling-group-3/output/lbp-version2.csv")
LBPfeature <- data.frame(LBPfeature[,-1])
LBPfeature$mergeid <- seq(1, nrow(LBPfeature), 1)
SIFTHOGLBP <- merge(SIFTHOG, LBPfeature, by=c("mergeid"))
write.csv(SIFTHOGLBP,"/Users/Clairiakong/Desktop/SIFTHOGLBP.CSV")

#SIFT+HOG+LBP+COLOR
colorfeature <- read.csv("/Users/Clairiakong/Desktop/project-2-predictive-modelling-group-3/output/color_features.csv")
colorfeature <- data.frame(colorfeature[,-1])
colorfeature$mergeid <- seq(1, nrow(colorfeature), 1)
SIFTHOGLBPCOLOR <- merge(SIFTHOGLBP, colorfeature, by=c("mergeid"))
write.csv(SIFTHOGLBPCOLOR,"/Users/Clairiakong/Desktop/SIFTHOGLBPCOLOR.CSV")