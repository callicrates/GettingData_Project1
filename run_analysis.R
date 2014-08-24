# Getting and Cleaning Data
#
# Course Project: UCI HAR data set

# The following information is also available in the codebook.  I
# reproduce it here for convenience.
#
# DATA DESCRIPTION:
#
# The data set has two sets of components.
#
# 1. Accelerometer data.  This is a 128-element time series gathered
#    from an accelerometer worn by each subject.  Conceptually, each
#    of those 128 elements contains three vectors: total acceleration,
#    body acceleration and acceleration due to gravity.  In practice
#    these are separated out into their x, y and z components.
#
#    These show up in the data frame as "body_acc_x_nnn" (and
#    'gravity_acc' and 'total_acc') where nnn is a 3-digit integer
#    from 1 to 128.
#
# 2. Feature vectors.  561 different values are computed from each
#    set of accelerometer data.  These are labeled descriptively
#    using names from "features.txt" in the data set.
#
# Each row has two additional columns: "subject" is an integer ID
# uniquely identifying the person to whom the data corresponds, and
# "activity" is a factor describing the activity the subject was
# performing.
#
# WHAT I DID:
#
# Our assignment requires us to compute the mean and standard
# deviation of each measurement.  I interpret "measurement" to refer
# to an entire time series.  If I do that, I end up with a data frame
# with an "average" set of feature vectors that correspond to an
# "average" set of accelerations.  I aggregate across subject IDs but
# preserve activity IDs.
#
# I chose this because it makes a good compromise between summarizing
# the data and preserving the intent of the data set.  Since we have
# feature vectors, we can conclude that the original authors planned
# to use this data set as input to a classification algorithm.  We
# could conceivably compute an average within each time series and
# compute "average total acceleration" (and 'body acceleration' and
# 'gravity') for each different activity but that discards a large
# amount of information.
#
# The result is a data frame with about 1500 columns.  This is
# obviously too wide for human inspection.


# We use genefilter for the rowVars method.  If you don't have it
# installed then do this:
#
# source("http://bioconductor.org/biocLite.R")
# biocLite("genefilter")

library(genefilter)
library(plyr)

# ----------------------------------------------------------------------

# Load a single array of inertial signals from both the training and
# testing data sets.  Concatenate them top-to-bottom (training first,
# then testing) and return the result.
#
# Args:
#   array.name (string): Name of the array to load -- "body_gyro_x" for example.
#   path (string): Path to your HAR data set (defaults to current directory).
#   components (integer): How many values in a column
#   width (integer): How wide is each component?
#
# Returns:
#   Unlabeled data frame with merged training and test data

loadMergedSignalArray <- function(array.name, path=".", components=128, width=16) {
    test.filename <- paste(array.name, "_test.txt", sep="")
    train.filename <- paste(array.name, "_train.txt", sep="")

    test.data <- read.fwf(file.path(path, "Inertial Signals", test.filename), widths=rep(width, components))
    train.data <- read.fwf(file.path(path, "Inertial Signals", train.filename), widths=rep(width, components))

    rbind(train.data, test.data)
}

# Load the array of subject IDs from both the training and testing data sets.
#
# After loading both arrays they will be concatenated top-to-bottom
# (training first, then testing).
#
# Args:
#   path (string): Path to your HAR data set (defaults to current directory).
#
# Returns:
#   Data frame with single numeric column "subject"

loadMergedSubjectIds <- function(path=".") {
    test.data <- read.csv(file.path(path, "test", "subject_test.txt"), header=FALSE)
    train.data <- read.csv(file.path(path, "train", "subject_train.txt"), header=FALSE)

    result <- rbind(train.data, test.data)
    names(result) <- c("subject")

    result
}

# Load the array of activity IDs from both the training and testing data sets.
#
# After loading both arrays they will be concatenated top-to-bottom
# (training first, then testing).
#
# Args:
#   path (string): Path to your HAR data set (defaults to current directory).
#
# Returns:
#   Data frame with single factor column "activity"

loadMergedActivityIds <- function(path=".") {
    activity.names <- read.csv(file.path(path, "activity_labels.txt"), header=FALSE)
    names(activity.names) <- c("activity")

    test.activities <- read.csv(file.path(path, "test", "y_test.txt"), header=FALSE)
    train.activities <- read.csv(file.path(path, "train", "y_train.txt"), header=FALSE)

    test.data <- read.csv(file.path(path, "test", "subject_test.txt"))
    train.data <- read.csv(file.path(path, "train", "subject_train.txt"))

    result <- rbind(train.data, test.data)
    names(result) <- c("activity")

    # I'm trusting here that the levels will come out in sorted order.
    result$activity <- as.factor(result$activity)
    attr(result$activity, "levels") <- activity.names$activity

    result
}

# Load activity IDs for either the training or test data
#
# Args:
#   category (string): either "train" or "test"
#   path (string): path to your copy of the UCI HAR dataset
#
# Returns:
#   Data frame with one integer column named "activity"

loadActivityIds <- function(category="train", path="UCI HAR DATASET") {
    activity.filename <- paste("activity_", category, ".txt", sep="")
    bare.frame <- read.table(file.path(path, category, activity.filename), header=FALSE, delimiter=" ")
    names(bare.frame) <- c("activity")
    bare.frame
}

# Load column names for feature vectors
#
# These names can be used to usefully label the components of the
# feature vectors.
#
# Args:
#   path (string): path to your copy of the UCI HAR dataset
#
# Returns:
#   Data frame with one character column named "features"

loadFeatureNames <- function(path="UCI HAR DATASET") {
    bare.frame <- read.table(os.path.join(path, "features.txt"), header=FALSE, delimiter=" ")
    names(bare.frame) <- c("features")
    bare.frame
}

# Load feature vectors and assign descriptive names.
#
# Args:
#  category (string): either "train" or "test"
#  path (string): path to UCI HAR datset if not the default
#
# Returns:
#  Data frame with 563 columns.  The first is subject IDs.  The second
#  is activity ID.  The rest are the feature vector for each record.

loadFeatureVectors <- function(category="train", path=".") {
    subjectIds <- loadSubjectIds(category=category, path=path)
    activityIds <- loadActivityIds(category=category, path=path)
    featureNames <- loadFeatureNames(path=path)

    feature.filename <- paste("X_", category, ".txt", sep="")
    features <- read.fwf(file.path(path, category, feature.filename),
                         header=FALSE,
                         widths=rep(16, 561))
    names(features) <- featureNames

    features$subject <- subjectIds$subject
    features$activity <- activityIds$activity

    features
}

# Load all the acceleration data for testing or training data.
#
# Args:
#  category (string): either "train" or "test"
#  path (string): path to your UCI HAR data (defaults to current directory)
#
# Returns:
#
#  Data frame with 'subject' and 'activity' columns as well as 128
#  columns for each of the component arrays.  The components are
#  'body_acc_x', 'body_acc_y', 'body_acc_z', 'body_gyro_x',
#  'body_gyro_y', 'body_gyro_z', 'total_acc_x', 'total_acc_y', and
#  'total_acc_z'.  The columns for the individual components are named
#  'body_acc_x_1' ... 'body_acc_x_128' and so on.

loadRawAccelerations <- function(category="train", path=".") {
    subjectIds <- loadSubjectIds(category=category, path=path)
    activityIds <- loadActivityIds(category=category, path=path)

    loadArray <- function(array.name) {
        x.name <- paste(array.name, "_x", sep="")
        y.name <- paste(array.name, "_y", sep="")
        z.name <- paste(array.name, "_z", sep="")

        x.file <- paste(x.name, "_", category, ".txt", sep="")
        y.file <- paste(y.name, "_", category, ".txt", sep="")
        z.file <- paste(z.name, "_", category, ".txt", sep="")

        x.frame <- read.table(file.path(path, category, x.file), header=FALSE, sep=" ")
        names(x.frame) <- paste(x.name, "_", 1:128, sep="")

        y.frame <- read.table(file.path(path, category, y.file), header=FALSE, sep=" ")
        names(y.frame) <- paste(y.name, "_", 1:128, sep="")

        z.frame <- read.table(file.path(path, category, z.file), header=FALSE, sep=" ")
        names(z.frame) <- paste(z.name, " ", 1:128, sep="")

        cbind(x.frame, y.frame, z.frame)
    }

    total.acc <- loadArray("total_acc")
    body.acc <- loadArray("body_acc")
    body.gyro <- loadArray("body_gyro")

    final.frame <- colbind(subjectIds, activityIds, total.acc, body.acc, body.gyro)
    final.frame
}


# Load and summarize all the acceleration data for testing or training data.
#
# Args:
#  by (character vector): zero to two of "subject" and "activity"
#  category (string): either "train" or "test"
#  path (string): path to your UCI HAR data (defaults to current directory)
#
# Returns:
#
#  Data frame with two columns for each data array and zero to two ID
#  columns.  The data arrays are 'body_acc_x', 'body_acc_y',
#  'body_acc_z', 'body_gyro_x', 'body_gyro_y', 'body_gyro_z',
#  'total_acc_x', 'total_acc_y', and 'total_acc_z'.  Each of those
#  will be represented with arrays like 'body_acc_x_mean' and
#  'body_acc_x_stddev' for mean and standard deviation, respectively.
#
#  There will also be ID columns corresponding to the entries in the
#  "by" parameter.

loadSummarizedAccelerations <- function(by=c("subject, activity"), category="train", path=".") {
    subjectIds <- loadSubjectIds(category=category, path=path)
    activityIds <- loadActivityIds(category=category, path=path)

    summarizeComponent <- function(array.name, component) {
        filename <- paste(array.name, "_", component, "_", category, ".txt", sep="")
        raw.data <- read.fwf(file.path(path, category, "Inertial Signals", filename), widths=rep(16, 128), header=FALSE)

        column.name <- paste(array.name, "_", component, sep="")
        summary.frame <- cbind(rowMeans(raw.data), rowVars(raw.data))
        names(summary.frame) <- c(paste(column.name, "_mean", sep=""),
                                  paste(column.name, "_var", sep=""))
        summary.frame
    }

    summarizeArray <- function(array.name) {
        x.summary <- summarizeComponent(array.name, "x")
        y.summary <- summarizeComponent(array.name, "y")
        z.summary <- summarizeComponent(array.name, "z")

        whole.frame <- cbind(subjectIds$subject,
                             activityIds$activity,
                             x.summary,
                             y.summary,
                             z.summary)

        # Aggregation: The mean of a sum of random variables is just
        # the sum of the means.  The variance of a sum of
        # *independent* random variables (which we have here; each
        # trial is independent) is the sum of the variances of each
        # variable.
        summary.frame <- NULL
        if (length(by) > 0) {
            print(
                paste("Aggregating variable", array.name, "over", by)
                )
            summary.frame <- aggregate(whole.frame, by=by)
            names(summary.frame)[1:length(by)] <- by
        } else {
            print(paste("No aggregation requested for variable", array.name)
            summary.frame <- whole.frame # no summary needed
        }

        # The last thing we need to do is convert the variances to
        # standard deviations.  First we fix the values...
        x.var.name <- paste(array.name, "_x_var", sep="")
        y.var.name <- paste(array.name, "_y_var", sep="")
        z.var.name <- paste(array.name, "_z_var", sep="")

        summary.frame[x.var.name] = sqrt(summary.frame[x.var.name])
        summary.frame[y.var.name] = sqrt(summary.frame[y.var.name])
        summary.frame[z.var.name] = sqrt(summary.frame[z.var.name])

        # Then we fix the names.
        x.sd.name <- paste(array.name, "_x_sd", sep="")
        y.sd.name <- paste(array.name, "_y_sd", sep="")
        z.sd.name <- paste(array.name, "_z_sd", sep="")

        names(summary.frame)[names(summary.frame) == x.var.name] <- x.sd.name
        names(summary.frame)[names(summary.frame) == y.var.name] <- y.sd.name
        names(summary.frame)[names(summary.frame) == z.var.name] <- z.sd.name

        summary.frame
    }

    total.acc <- summarizeArray("total_acc")
    body.acc <- summarizeArray("body_acc")
    body.gyro <- summarizeArray("body_gyro")

    final.frame <- merge(total.acc, body.acc, body.gyro, by=c("subject", "activity"))
    final.frame
}

