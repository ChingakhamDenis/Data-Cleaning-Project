fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("./UCI HAR Dataset.zip")){
  download.file(fileurl, "./UCI HAR Dataset.zip", mode = "wb")
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}
library(plyr)
library(data.table)
subjectTrain = read.table('./train/subject_train.txt',header=FALSE)
xTrain = read.table('./train/x_train.txt',header=FALSE)
yTrain = read.table('./train/y_train.txt',header=FALSE)

subjectTest = read.table('./test/subject_test.txt',header=FALSE)
xTest = read.table('./test/x_test.txt',header=FALSE)
yTest = read.table('./test/y_test.txt',header=FALSE)

# Merging Train and Test data to a single data set
xDataSet <- rbind(xTrain, xTest)
yDataSet <- rbind(yTrain, yTest)
subjectDataSet <- rbind(subjectTrain, subjectTest)

# Extract only the measurements on the mean and standard deviation for each measurement
xDataSet_mean_std <- xDataSet[,grep("-(mean|std)\\(\\)", read.table("features.txt")[1,2])]
names(xDataSet_mean_std) <- read.table("features.txt")[grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2]), 2]

# Use descriptive activity names to name the activities in the data set
yDataSet[, 1] <- read.table("activity_labels.txt")[yDataSet[, 1], 2]
names(yDataSet) <- "Activity"

# Appropriately label the data set with descriptive activity names
names(subjectDataSet) <- "Subject"
# Organizing and combining all data sets into single one
singleDataSet <- cbind(xDataSet_mean_std, yDataSet, subjectDataSet)

# Defining descriptive names for all variables
names(singleDataSet) <- make.names(names(singleDataSet))
names(singleDataSet) <- gsub("Acc", "Acceleration", names(singleDataSet))
names(singleDataSet) <- gsub("GyroJerk", "AngularAcceleration", names(singleDataSet))
names(singleDataSet) <- gsub("Gyro", "AngularSpeed", names(singleDataSet))
names(singleDataSet) <- gsub("Mag", "Magnitude", names(singleDataSet))
names(singleDataSet) <- gsub("^t", "Timedomain", names(singleDataSet))
names(singleDataSet) <- gsub("^f", "FrequencyDomain",names(singleDataSet))
names(singleDataSet) <- gsub('\\.mean',".Mean",names(singleDataSet))
names(singleDataSet) <- gsub('\\.std',".StandardDeviation",names(singleDataSet))
names(singleDataSet) <- gsub('Freq\\.',"Frequency.",names(singleDataSet))
names(singleDataSet) <- gsub('Freq$',"Frequency",names(singleDataSet))

# Creates a second, independent tidy data set with the average of each 
# variable for each activity and each subject
Data2<-aggregate(. ~Subject + Activity, singleDataSet, mean)
Data2<-Data2[order(Data2$Subject,Data2$Activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
