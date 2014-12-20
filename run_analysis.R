# Getting and Cleaning Data Course Project

getwd()
setwd("./Github/Getting and Cleaning Data")


file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(file, "./CourseProject.zip")

unzip("./CourseProject.zip")

# Reading all test and training sets 

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

features <- read.table("./UCI HAR Dataset/features.txt")

library(dplyr)

# transforming datasets to tbl_df type for use with dplyr package
x_test <- tbl_df(x_test)
y_test <- tbl_df(y_test)
x_train <- tbl_df(x_train)
y_train <- tbl_df(y_train)
subject_test <- tbl_df(subject_test)
subject_train <- tbl_df(subject_train)

# merge data using rbind_list funciton in the dplyr package

merged_XData <- rbind_list(x_test, x_train)
merged_YData <- rbind_list(y_test, y_train)
merged_subjectData <- rbind_list(subject_test, subject_train)

# give descriptive labels to all variables in the X and Y datasets.
names(merged_XData) <- features$V2
names(merged_YData) <- "activity"

# select only those columns that contain mean() and std() values of features.
#Note that for this analysis, meanFreq() was not considered to be a mean of feature and that is why it has been excluded.

merged_XData <- cbind(merged_XData[, grepl("mean()", colnames(merged_XData))], 
                 merged_XData[, grepl("std()", colnames(merged_XData))])

merged_XData <- select(merged_XData, -contains("meanFreq"))

# Use descriptive acitvity names to name the acitivities in the merged_YData dataset.

merged_YData$activity[merged_YData$activity == "1"] <- "WALKING"
merged_YData$activity[merged_YData$activity == "2"] <- "WALKING_UPSTAIRS"
merged_YData$activity[merged_YData$activity == "3"] <- "WALKING_DOWNSTAIRS"
merged_YData$activity[merged_YData$activity == "4"] <- "SITTING"
merged_YData$activity[merged_YData$activity == "5"] <- "STANDING"
merged_YData$activity[merged_YData$activity == "6"] <- "LAYING"

# Use descriptive name to label column in merged_subjectData dataset.

names(merged_subjectData) <- "subject"

# combining subject, acitivty and features variables in one tidy dataset.

tidyDataSet_1 <- cbind(merged_subjectData, merged_YData, merged_XData)


#  Creating a second, independent tidy data set with the average of each variable for each activity and each subject.

tidyDataSet_2 <- tidyDataSet_1 %>%
    group_by(subject, activity) %>%
    summarise_each(funs(mean))

