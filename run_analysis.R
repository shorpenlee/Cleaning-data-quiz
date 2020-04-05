# Download the zip file and get file ready
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "data_cleaning_project.zip",method = "curl")
unzip(zzipfile = "data_cleaning_project.zip")

# Read the required lables
activity_lable <- read.table("UCI HAR Dataset/activity_labels.txt",sep = " ",col.names = c("activitylables","activityname"))
features <- read.table("UCI HAR Dataset/features.txt",sep = " ",col.names = c("featurelables","featurename"))
totalfeatures<-features[grep("mean|std",features[,2]),]
totalfeatures[grep("Freq",totalfeatures[,2]),]<-c("","")
totalfeatures <- na.omit(totalfeatures)

# Load train datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[,as.numeric(totalfeatures[,1])]
colnames(train) <- totalfeatures[,2]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt",col.names = "Activity")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt",col.names = "Subject")
train <- cbind(train_subjects,train_activities,train)

# Load test datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt")[,as.numeric(totalfeatures[,1])]
colnames(test) <- totalfeatures[,2]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt",col.names = "Activity")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt",col.names = "Subject")
test <- cbind(test_subjects,test_activities,test)

# Combine test and train
combined <- rbind(test,train)

# Merge combined dataset and activity table
combined=merge(combined,activity_lable,by.x="Activity",by.y = "activitylables",all=FALSE)
by_subject <- split(combined,list(combined$Subject,combined$Activity))
submean <- function(x){ ##create a function to compute the mean value of a list
  test <- data.frame()
  for (i in 1:length(x)) {
  temp1 <- aggregate(by_subject[[i]][,3:68],by_subject[[i]][,c(1,2,69)],mean)
  test <- rbind(test,temp1)
  }
  colnames(test)<-colnames(temp1)
  test
}
final<-submean(by_subject)

# Export the final table
write.table(final,file = "tidyData.txt",quote = FALSE, sep = ",")
