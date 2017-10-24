# Getting and cleaning data
setwd("./datasciencecoursera/Data Cleaning Project/UCI HAR Dataset"
      
install.packages("plyr")
library(plyr)

features<-read.table("./UCI HAR Dataset/features.txt", sep="")
activities<-read.table("./UCI HAR Dataset/activity_labels.txt", sep="")

# Read the data from the test data set
# add the variable names (features)
test_data<-read.table("./UCI HAR Dataset/test/X_test.txt", sep = "", col.names = features[,2])

# Read the subject data and activity data
test_subject<-read.table("./UCI HAR Dataset/test/subject_test.txt", sep = "")
test_activity<-read.table("./UCI HAR Dataset/test/y_test.txt", sep = "")

# Read the data from the train data set and add the variable names (features)
train_data<-read.table("./UCI HAR Dataset/train/X_train.txt", sep = "", col.names = features[,2])
train_subject<-read.table("./UCI HAR Dataset/train/subject_train.txt", sep = "")

# read the activity data
train_activity<-read.table("./UCI HAR Dataset/train/y_train.txt", sep = "")

# Combine various components of test data and create vector for new column to be added
DatasetType<-rep("Test",dim(test_data)[1])

# convert activities vector to a vector with the descriptions
ActivityDescription<-activities$V2[match(test_activity$V1,activities$V1)]

# change column names for subject vectors
names(test_subject)<-"Subject"

# combine the subject, activity, dataset type, and data into one data frame
test_data_combined<-cbind(test_subject,ActivityDescription,DatasetType,test_data)

# Combine various components of train data
# create vector for new column to be added
rm(DatasetType)
DatasetType<-rep("Train",dim(train_data)[1])

# convert activities vector to a vector with the descriptions
rm(ActivityDescription)
ActivityDescription<-activities$V2[match(train_activity$V1,activities$V1)]

# change column names for subject vectors
names(train_subject)<-"Subject"

# combine the subject, activity, dataset type, and data into one data frame
train_data_combined<-cbind(train_data, train_subject,ActivityDescription,DatasetType)

# Combine the two datasets
CombinedData<-rbind(test_data_combined,train_data_combined)

# build a vector of columns with "std" in the column name
std_cols<-grep("std", colnames(CombinedData))

# build a vector of columns with "mean" in the column name
mean_cols<-grep("mean", colnames(CombinedData))

# vector of first three columns
first_cols<-c(1,2,3)

# so, vector of columns to keep
keep_cols<-c(std_cols,mean_cols,first_cols)

# subset reduced data frame
CombinedData_reduced<-CombinedData[,keep_cols]

# make Subject a factor variable
CombinedData_reduced$Subject<-as.factor(CombinedData_reduced$Subject)

# determine number of columns, then subtract 3 for the subject, activity, and dataset type
datacols<-dim(CombinedData_reduced)[2]
datacols<-datacols-3
datacols<-seq(1,datacols)  #will need this vector of column numbers


# Use ddply to apply the correct grouping, then get the column means over the data columns
tidy_data<-ddply(CombinedData_reduced,.(CombinedData_reduced$ActivityDescription,CombinedData_reduced$Subject), function(a) colMeans(a[,datacols]))

# write tidy data to working directory
write.table(tidy_data,file="./tidy_data.txt",col.names=TRUE,row.names = FALSE, sep="\t")

# print completion message
print("Data manipulation complete")
