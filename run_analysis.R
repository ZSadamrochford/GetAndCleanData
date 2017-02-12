library(dplyr)
dir <- getwd()
dir.data <- paste0(dir, "/UCI HAR Dataset")

if (!file.exists(dir.data)) {dir.create(dir.data)}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", file.path(dir.data, "data.zip"))
unzip(paste0(dir.data,"/data.zip"))

setwd(dir.data)

# load initial data
activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")

colnames(features) <- c("id", "name")
colnames(activity_labels) <- c("id", "name")

# load train
subject_train <- read.table("train/subject_train.txt")
x_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
train <- cbind(subject_train, y_train, x_train)
rm(subject_train, y_train, x_train)

# load test
subject_test <- read.table("test/subject_test.txt")
x_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
test <- cbind(subject_test, y_test, x_test)
rm(subject_test, y_test, x_test)

# merge test and train
full_data <- rbind(train, test)

# use features to set col names and remove all but mean/stdev
colnames(full_data) <- c("subject", "activity", as.character(features$name))
full_data <- full_data[, c(1,2, grep("mean|std", colnames(full_data)))]

full_data <- merge(full_data, activity_labels, by.y = "id", by.x = "activity")
full_data <- rename(full_data, activity_name = name)

# tidy col names
colnames(full_data) <- tolower(colnames(full_data))
colnames(full_data) <- sub("\\(\\)", "", colnames(full_data))
colnames(full_data) <- gsub("-", "_", colnames(full_data))
colnames(full_data) <- sub("tbody", "rawbody", colnames(full_data))
colnames(full_data) <- sub("tgravity", "rawgravity", colnames(full_data))
colnames(full_data) <- sub("fbody", "feature", colnames(full_data))
full_data <- select(full_data, subject, activity, activity_name, everything())

# group and calculate mean
activity_subj_mean <- full_data %>% group_by(subject, activity, activity_name) %>% summarize_each(funs(mean)) %>% ungroup()

write.table(activity_subj_mean, file = "activity_subj_mean.txt", row.names = FALSE)