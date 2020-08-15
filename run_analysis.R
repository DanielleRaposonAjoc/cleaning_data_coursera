library(dplyr)
#getting the features
features<-read.table("./UCI/features.txt")%>%
  select(label=V2)
#features with mean or std
features_mean_std<-features[grepl("mean",features$label) | grepl("std",features$label),]

#getting the activity type
activity_type <- read.table("./UCI/activity_labels.txt")
colnames(activity_type)<-c("activity_id","activity_type")
  
#getting the subjects train
subjects_train<- read.table("./UCI/train/subject_train.txt")
colnames(subjects_train)<-c("subject_id")

#getting x train or the features value
x_train<- read.table("./UCI/train/X_train.txt")
#rename x_train columns with features 
colnames(x_train)<-features[,1]
#select only columns with std or     mean
#dim is 7352 and 79
x_train<- select(x_train,all_of(features_mean_std))

#dim is 7352 and 1
#getting y train or the activity id
y_train<- read.table("./UCI/train/y_train.txt")
colnames(y_train)<-c("activity_id")
#combine x_train and y_train
xy_train<-cbind(subjects_train,y_train,x_train)

#combine activity type and xy_train
xy_train_combined<-merge(activity_type,xy_train,by="activity_id")



#getting the subjects test
subjects_test<- read.table("./UCI/test/subject_test.txt")
colnames(subjects_test)<-c("subject_id")

#getting x test or the features value
x_test<- read.table("./UCI/test/X_test.txt")
#rename x_test columns with features 
colnames(x_test)<-features[,1]
#select only columns with std or mean
#dim is 7352 and 79
x_test<- select(x_test,all_of(features_mean_std))

#dim is 7352 and 1
#getting y test or the activity id
y_test<- read.table("./UCI/test/y_test.txt")
colnames(y_test)<-c("activity_id")
#combine x_test and y_test
xy_test<-cbind(subjects_test,y_test,x_test)

#combine activity type and xy_test
xy_test_combined<-merge(activity_type,xy_test,by="activity_id")



#merge train and test
xy_test_train_combined<-bind_rows(xy_test_combined,xy_train_combined)

#remove activty_id column cuz it is redundant with activity_type
xy_test_train_combined<-select(xy_test_train_combined,-c("activity_id"))

#get average of each column
xy_test_train_grouped<-group_by(xy_test_train_combined,subject_id,activity_type)
avg<-summarise(xy_test_train_grouped,across(where(is.numeric),mean))

# Export train and test combined tables to text file
write.table(xy_test_train_combined, './test_train_combined.txt',sep='\t', row.names = FALSE)
# Export group by subject id and activity type to text file
write.table(avg, './cols_avg.txt',sep='\t', row.names = FALSE)
