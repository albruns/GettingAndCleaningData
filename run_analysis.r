# Loading requiered packages

library(dplyr)

# Reading training data from unzipped directory


training<-read.table("./UCI HAR Dataset/train/X_train.txt")
train_labels<-read.table("./UCI HAR Dataset/train/y_train.txt")
train_subjects<-read.table("./UCI HAR Dataset/train/subject_train.txt")


#Reading test data from unzipped directory

test<-read.table("./UCI HAR Dataset/test/X_test.txt")
test_labels<-read.table("./UCI HAR Dataset/test/y_test.txt")
test_subjects<-read.table("./UCI HAR Dataset/test/subject_test.txt")

# Assign names to variables in dataframes

var_names<-read.table("./UCI HAR Dataset/features.txt")
names(training)<-tolower(var_names$V2)
names(test)<-tolower(var_names$V2)

# Select columns which contain mean and std

col_index<-grep("std|mean",var_names$V2)
training<-training[,col_index]
test<-test[,col_index]

# Bind subject to observations
training<-cbind(training,train_subjects)
test<-cbind(test,test_subjects)

# Bind activity labels to observations

training<-cbind(training,train_labels)
test<-cbind(test,test_labels)

# Add training or test column to each dataset
training$status<-"training"
test$status<-"test"
names(test)[80:81]<-c("subject", "activity")
names(training)[80:81]<-c("subject", "activity")

# Bind training and test dataset by row

DS<-rbind(training,test)

# Assign factor names to activity

activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors=F)
DS$activity<-factor(DS$activity, labels=activity_labels$V2)

# Rename columns 

clean_vars<-names(DS)
clean_vars<-gsub("\\()", "", clean_vars)
clean_vars<-gsub("acc", "acceleration", clean_vars)
clean_vars<-gsub("^f", "FFT", clean_vars)
clean_vars<-gsub("^t", "", clean_vars)
clean_vars<-gsub("^t", "", clean_vars)
names(DS)<-clean_vars

# Order columns and rows

DS<-DS[,c(80,81,82,1:79)]

# Group and execute mean by subject, activity and status

DSgrouped<-group_by(DS,subject, activity, status)
DSgrouped<-summarise_each(DSgrouped, funs(mean))
DSordered<-arrange(DSgrouped, status, subject)
write.table(DSordered, file="output.txt", append=F)
