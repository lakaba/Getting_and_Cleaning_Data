Getting_and_Cleaning_Data
=========================
### Summary
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following. 

    1. Merges the training and the test sets to create one data set.
    2. Extracts only the measurements on the mean and standard deviation for each measurement. 
    3. Uses descriptive activity names to name the activities in the data set
    4. Appropriately labels the data set with descriptive variable names. 
    5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

Getting_and_Cleaning_Data
=========================
The script is broken in three parts: Prepare test data, prepare train data and apppend both data sets with averaged by subject and activity as a master data
## Load data.table package
if (!require("data.table")) {
  install.packages("data.table")
}
library("data.table")

## Load reshape package
if (!require("reshape2")) {
  install.packages("reshape2")
}
library("reshape2")

############################################################################
# 1. Prepare test data
############################################################################
# Load features, x_test, y_test, subject test and activity labels
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
names(x_test) <- features
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
activity <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Flag the mean and standard deviation from features using regular expression
features_reduced <- grepl("mean|std", features)

# Use the features_reduced to reduce x_test data
x_test <- x_test[,features_reduced]

# Merge activity to test data using column 1 from y test as the common ID
y_test[,2] <- activity[y_test[,1]]
names(y_test) <- c("ID", "Activity")
names(subject_test) <- "subject"

# Merge data
test_master <- cbind(as.data.table(subject_test), y_test, x_test)

############################################################################
# 2. Prepare train data
############################################################################
# Load activity labels, features, x_test, y_test and subject test
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
names(x_train) <- features
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Use the features_reduced to reduce x_train data
x_train <- x_train[,features_reduced]

# Add activity column to train data
y_train[,2] <- activity[y_train[,1]]
names(y_train) <- c("ID", "Activity")
names(subject_train) <- "subject"

# Merge data
train_master <- cbind(as.data.table(subject_train), y_train, x_train)

############################################################################
# 3. Append test and train data sets and provide summary statistics
############################################################################
# Append train and test data
master <- rbind(test_master, train_master)

# Average data set by subject and label
tidy_data <- aggregate(data=master,. ~ subject+Activity,FUN=mean)

# Output data set
write.table(tidy_data, file = "./tidy_data.txt")
