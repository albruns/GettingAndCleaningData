---
title: "Peer Assignment"
author: "Alexander Bruns"
date: "Wednesday, February 18, 2015"
output: html_document
---

# Loading requiered packages
```{r}

library(dplyr)
```

# Reading training data from unzipped directory

```{r}

training<-read.table("./UCI HAR Dataset/train/X_train.txt")
train_labels<-read.table("./UCI HAR Dataset/train/y_train.txt")
train_subjects<-read.table("./UCI HAR Dataset/train/subject_train.txt")
```


#Reading test data from unzipped directory

```{r}
test<-read.table("./UCI HAR Dataset/test/X_test.txt")
test_labels<-read.table("./UCI HAR Dataset/test/y_test.txt")
test_subjects<-read.table("./UCI HAR Dataset/test/subject_test.txt")

```

# Assign names to variables in dataframes

Variable names are read from the features.txt file

```{r}
var_names<-read.table("./UCI HAR Dataset/features.txt")
names(training)<-tolower(var_names$V2)
names(test)<-tolower(var_names$V2)
```

# Select columns which contain mean and std

columns containing mean and standard deviation data are selecetd by the "grep" command

```{r}
col_index<-grep("std|mean",var_names$V2)
training<-training[,col_index]
test<-test[,col_index]
```

# Bind subject to observations

The subjects are read from a separate file and assigned to rows

```{r}
training<-cbind(training,train_subjects)
test<-cbind(test,test_subjects)
```

# Bind activity labels to observations

```{r}
training<-cbind(training,train_labels)
test<-cbind(test,test_labels)
```

# Add training or test column to each dataset

```{r}
training$status<-"training"
test$status<-"test"
names(test)[80:81]<-c("subject", "activity")
names(training)[80:81]<-c("subject", "activity")
```

# Bind training and test dataset by row

```{r}

DS<-rbind(training,test)
```
# Assign factor names to activity

The activity column is converted to factorial and labeled

```{r}
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors=F)
DS$activity<-factor(DS$activity, labels=activity_labels$V2)
```

# Rename columns 

The "gsub" function is used to clean and rename column names

```{r}
clean_vars<-names(DS)
clean_vars<-gsub("\\()", "", clean_vars)
clean_vars<-gsub("acc", "acceleration", clean_vars)
clean_vars<-gsub("^f", "FFT", clean_vars)
clean_vars<-gsub("^t", "", clean_vars)
clean_vars<-gsub("^t", "", clean_vars)
names(DS)<-clean_vars
```

# Order columns and rows

```{r}

DS<-DS[,c(80,81,82,1:79)]
```

## Group and execute mean by subject, activity and status

```{r}
DSgrouped<-group_by(DS,subject, activity, status)
DSgrouped<-summarise_each(DSgrouped, funs(mean))
DSordered<-arrange(DSgrouped, status, subject)
```
# Write data to file
```{r}
write.table(DSordered, file="output.txt", append=F, row.name=FALSE)
```

