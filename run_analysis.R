# Read all files
# Read training files: training set (X_train), training labels (y_train), training subjects (subject_train)
training_set <- read.table("train/X_train.txt", header = FALSE) # 7352 obs. of 561 variables
training_labels <- read.table("train/y_train.txt", header = FALSE)
training_subjects <- read.table("train/subject_train.txt", header = FALSE)

# Read test files: test set (X_test), test labels (y_test), test subjects (subject_test)
test_set <- read.table("test/X_test.txt", header = FALSE) # 2947 obs. of 561 variables
test_labels <- read.table("test/y_test.txt", header = FALSE)
test_subjects <- read.table("test/subject_test.txt", header = FALSE)

# 1. Merge the training and testing sets
# Merge the corresponding sets
full_set <- rbind(training_set, test_set)
full_labels <- rbind(training_labels, test_labels)
full_subjects <- rbind(training_subjects, test_subjects)

# Free up some memory
rm(list = c("training_set", "training_labels", "training_subjects", "test_set", "test_labels", "test_subjects"))

# Set the proper names to the columns
names(full_subjects) <- c("subject")
names(full_labels) <- c("activity")
features <- read.table("features.txt", header = FALSE, stringsAsFactors = FALSE)$V2
names(full_set) <- features

# Make one dataset with the specified columns
result_data <- cbind(full_set, cbind(full_subjects, full_labels))

# Free up some memory again
rm(list = c("full_set", "full_subjects", "full_labels"))

# 2. Extract only mean and standard deviation for each measurement
# Find which columns contain the measurements needed
selected_features <- c(features[grep("mean\\(\\)|std\\(\\)", features)])

# Subset the data based on the selected features (and the subject and activity columns)
result_data <- subset(result_data, select = c("subject", "activity", selected_features))

# 3. Use descriptive activity names to name the activities in the data set
activities <- read.table("activity_labels.txt", header = FALSE)$V2
result_data$activity <- activities[result_data$activity]

# 4. Appropriately label the data set with descriptive variable names
# Rename the column names according to the features_info file: the prefix "t" means "time" and "f" means "frequency"
names(result_data) <- gsub("^t", "time", names(result_data))
names(result_data) <- gsub("^f", "frequency", names(result_data))

# Free up memory
rm(list = c("activities", "features", "selected_features"))

# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject
second_data <- aggregate(. ~ subject + activity, data = result_data, FUN = mean) # 180 obs. of 68 variables
write.table(second_data, "tidy_data.txt", row.name = FALSE) 