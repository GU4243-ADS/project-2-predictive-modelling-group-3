#color features
library("EBImage")


setwd("/Users/yunli/Documents/GitHub/project-2-predictive-modelling-group-3/data/pets/")
img_names<-list.files("./train/")

Rbin<-seq(0,1,length.out =  10) 
Gbin<-seq(0,1,length.out = 10)
Bbin<-seq(0,1,length.out = 10)

Hbin<-seq(0,1,length.out =  10) 
Sbin<-seq(0,1,length.out = 10)
Vbin<-seq(0,0.005,length.out = 10)


##RGB features
rgb_features<-data.frame(matrix(NA,2000,1001))
colnames(rgb_features)<-c('Image',paste('rbg_',1:1000,sep=""))
rgb_features$Image<-img_names

hsv_features<-data.frame(matrix(NA,2000,1001))
colnames(hsv_features)<-c('Image',paste('hsv_',1:1000,sep=""))
hsv_features$Image<-img_names


for(i in 1:2000){
  # print(i)
  # img<-readImage(img_names)
  img<-readImage(paste("./train/",img_names[i],sep=""))
  if(length(dim(img))!=3){
    next
  }
  img<-resize(img,256,256)
  img_mat<-imageData(img)
  
  ### RGB
  rgb_mat<-img_mat
  rgb_df=as.data.frame(table(factor(findInterval(rgb_mat[,,1],Rbin),levels = 1:10),
                             factor(findInterval(rgb_mat[,,2],Gbin),levels = 1:10),
                             factor(findInterval(rgb_mat[,,3],Bbin),levels = 1:10)))
  rgb_features[i,2:1001]<-rgb_df$Freq/(256^2)
  
  ### HSV
  dim(img_mat)<-c(256*256,3)
  hsv_mat<-rgb2hsv(t(img_mat))
  hsv_df=as.data.frame(table(factor(findInterval(hsv_mat[1,],Hbin),levels = 1:10),
                             factor(findInterval(hsv_mat[2,],Sbin),levels = 1:10),
                             factor(findInterval(hsv_mat[3,],Vbin),levels = 1:10)))
  hsv_features[i,2:1001]<-hsv_df$Freq/(256^2)
}



color_features<-merge(rgb_features,hsv_features,by.x = "Image",by.y="Image")

for (i in 1:length(color_features[,1])){
  color_features[,1] = gsub("[^0-9]","",color_features[,1])
}

color_features[,1] = as.numeric(color_features[,1])
color_features = color_features[order(color_features[,1]),]


write.csv(color_features,"/Users/yunli/Documents/GitHub/project-2-predictive-modelling-group-3/output/color_features2.csv",row.names = F)

