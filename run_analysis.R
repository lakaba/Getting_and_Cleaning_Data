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
