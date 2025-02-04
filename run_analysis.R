# Getting and Cleaning Data
#
# Course Project: UCI HAR data set

# Much of the following information is also available in the codebook
# and README.md.  I reproduce it here for convenience.
#
##### DATA DESCRIPTION:
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
##### WHAT I DID:
#
# Our assignment requires us to compute the mean and standard
# deviation of each measurement.  There are two ways I could interpret
# that.  The first is to construct an average time series including
# the mean and s.d. of acceleration or velocity at each point in the
# series.  This gives us richer information but is harder to interpret
# since the resulting data frame will have about 1500 columns.
#
# The second interpretation, which I employ here, is to aggregate
# within each time series as well as across trials.  This gives us
# quantities like "average acceleration when sitting down".  This
# makes for a clearer summary but isn't as easy to compute with.
#
# Within the feature vector, I compute statistics strictly within each
# column.  Different columns are related so it would not make sense
# to aggregate across them.
#
# There is also an argument to be made that the feature vectors are
# not themselves measurements since they are derived from the
# accelerometer data rather than being sampled in their own right.  If
# you agree with this, you can add the parameter
# "include.feature.vectors=FALSE" to the run_analysis() function.
#
##### HOW THE SCRIPT WORKS:
#
# We treat the accelerometer data and the feature vectors separately.
#
# Accelerometer Data:
#
# We load each component of each array -- (X, Y, Z) x (Total
# Acceleration, Body Acceleration, Body Gyro) -- and compute mean and
# variance for each row of each component.  See above for why I do it
# this way instead of computing statistics separately for each
# component.  Then we combine the data frames for all 9 sets of
# measurements left-to-right.  We take advantage of the fact that all
# the data files have the same number of lines in the same order and
# use cbind() instead of merge().
#
# Look at loadMergedSignalArray(), summarizeAcrossTimeSeries() and
# loadSummarizedInertialSignals() to see how this works.
#
# Feature vectors:
#
# We load the table of feature vectors with loadMergedFeatureVectors()
# and assign column names from 'features_info.txt' that we loaded with
# loadFeatureNames().  We compute summary statistics for each column
# separately and then aggregate within each subject/activity pair in
# summarizeFeatureVectors().
#
# Final assembly:
#
# We take all the components of the data and assemble them in assembleFullFrame.

                                        # Aggregation:
#
# We aggregate trials for each different subject and activity in 

# Since each element of a feature vector is its own quantity

# We take advantage of the fact that all of the data files in a
# section (training or testing) have the same number of lines and
# correspond to the same trials.


# NOTE:
#
# You'll notice that I work with variances instead of standard
# deviations until right down at the end.  That's so that the
# aggregation will work cleanly.  The variance of a sum of independent
# random variables is the sum of their individual variances.  If I
# save the sqrt until right at the end I can use that identity.


## DEPENDENCIES

# We use genefilter for the rowVars method.  If you don't have it
# installed then do this:
#
# source("http://bioconductor.org/biocLite.R")
# biocLite("genefilter")

library(genefilter)
library(plyr)

# ----------------------------------------------------------------------

## Simplest building blocks - load labels

# Load the array of readable activity names
#
# Args:
#   path: Path to your HAR data set (defaults to current directory).
#
# Returns:
#   Data frame with single factor column "activity"

loadActivityNames <- function(path=".") {
    stuff <- read.csv(file.path(path, "activity_labels.txt"), header=FALSE, sep=" ")
    names(stuff) <- c("id", "name")
    stuff
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

loadFeatureNames <- function(path=".") {
    bare.frame <- read.table(file.path(path, "features.txt"), header=FALSE, sep=" ")
    names(bare.frame) <- c("id", "name")
    bare.frame
}

# ----------------------------------------------------------------------

## Next set of building blocks: load feature vectors and signal arrays

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

    test.data <- read.fwf(file.path(path, "test", "Inertial Signals", test.filename), widths=rep(width, components))
    train.data <- read.fwf(file.path(path, "train", "Inertial Signals", train.filename), widths=rep(width, components))

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
    activity.names <- loadActivityNames(path)

    test.activities <- read.csv(file.path(path, "test", "y_test.txt"), header=FALSE)
    train.activities <- read.csv(file.path(path, "train", "y_train.txt"), header=FALSE)

    result <- rbind(train.activities, test.activities)
    names(result) <- c("activity")

    result$activity <- mapvalues(result$activity, from=activity.names$id, to=as.character(activity.names$name))
    result$activity <- as.factor(result$activity)
    result
}

# Load feature vectors and assign descriptive names.
#
# The training and test data will be concatenated.  Training data will
# occur first.
#
# Args:
#  path (string): path to UCI HAR dataset (defaults to working directory)
#
# Returns:
#  Data frame with 563 columns.  The first is subject IDs.  The second
#  is activity ID.  The rest are the feature vector for each record.

loadMergedFeatureVectors <- function(path=".") {
    featureNames <- loadFeatureNames(path=path)

    test.filename <- c("X_test.txt")
    train.filename <- c("X_train.txt")

    test.data <- read.fwf(file.path(path, "test", test.filename),
                          header=FALSE,
                          widths=rep(16, 561))
    train.data <- read.fwf(file.path(path, "train", train.filename),
                           header=FALSE,
                           widths=rep(16, 561))

    total.data <- rbind(train.data, test.data)
    names(total.data) <- featureNames$name

    total.data
}

# Compute the mean and variance for each row in a 'trials' array.
#
# Args:
#   trials (data.frame): Frame where every row is the data (no extra columns)
#   prefix (character): Prefix for output column names.
#
# Returns:
#   New data.frame with two columns: "basename_mean" and "basename_var"
#

summarizeAcrossTimeSeries <- function(trials, prefix="prefix") {
    means <- rowMeans(trials)
    vars <- rowVars(trials)

    frame <- data.frame(means, vars)
    names(frame) <- c(paste(prefix, "_mean", sep=""),
                      paste(prefix, "_var", sep=""))
    frame
}

# Load and summarize all the inertial measurement data.
#
# There are three inertial measurement arrays, each with 3 components.
# The arrays are 'body_acc', 'body_gyro' and 'total_acc'.  Each one
# has 'x', 'y' and 'z' components.  Args: path (string): Path to your
# HAR data set (defaults to working directory)
#
# Returns:
#  Data frame with '_mean' and '_var' columns for each array component

loadSummarizedInertialSignals <- function(path=".") {
    print("Loading and summarizing inertial data")
    print("    Total Acceleration")
    print("      x")
    total.acc.x <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("total_acc_x", path), prefix="total_acc_x")
    print("      y")
    total.acc.y <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("total_acc_y", path), prefix="total_acc_y")
    print("      z")
    total.acc.z <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("total_acc_z", path), prefix="total_acc_z")

    print("    Body Acceleration")
    print("      x")
    body.acc.x <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("body_acc_x", path), prefix="body_acc_x")
    print("      y")
    body.acc.y <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("body_acc_y", path), prefix="body_acc_y")
    print("      z")
    body.acc.z <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("body_acc_z", path), prefix="body_acc_z")

    print("    Body Angular Velocity")
    print("      x")
    body.gyro.x <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("body_gyro_x", path=path), prefix="body_gyro_x")
    print("      y")
    body.gyro.y <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("body_gyro_y", path=path), prefix="body_gyro_y")
    print("      z")
    body.gyro.z <- summarizeAcrossTimeSeries(
        loadMergedSignalArray("body_gyro_z", path=path), prefix="body_gyro_z")

    print("Creating summary data frame for inertial data")
    inertial.frame <- cbind(total.acc.x, total.acc.y, total.acc.z,
                            body.acc.x, body.acc.y, body.acc.z,
                            body.gyro.x, body.gyro.y, body.gyro.z)
}

# Create mean and standard deviation columns for each column in the feature vector array.
#
# Args:
#   frame (data.frame): Feature vector data
#   subjects (factor): Vector of subject IDs
#   activities (factor): Vector of activity labels
#
# Returns:
#   New data fraome with '_mean' and '_sd' columns for each column in the feature vector

summarizeFeatureVectors <- function(frame, subjects, activities) {
    means <- aggregate(frame, by=list(subjects, activities), FUN=mean)
    names(means) <- paste(names(means), "_mean", sep="")

    sds <- aggregate(frame, by=list(subjects, activities), FUN=sd)
    names(sds)<- paste(names(sds), "_sd", sep="")

    cbind(means[3:ncol(means)], sds[3:ncol(sds)])
}

# ----------------------------------------------------------------------

## Okay, now we're ready to put everything together.  We can build
## summary tables for all the inertial data and load feature vectors
## for each trial.  We have two things left to do:
##
## (1) Aggregate over subject and activity (as the user desires), and
##
## (2) Transform the variances to standard deviations.

# Aggregate all the data so far.
#
# Args:
#  path (character): Path to your data (defaults to current directory)
#  include.feature.vectors (boolean): Whether or not to include the feature vectors in the result
#
# Returns:
#  New data frame with inertial signals and (optionally) feature vectors

assembleFullFrame <- function(path=".", include.feature.vectors=FALSE) {
    subject.frame <- loadMergedSubjectIds(path)
    activity.frame <- loadMergedActivityIds(path)

    # When we get the inertial data back from
    # loadSummarizedInertialSignals it has been summarized within each
    # trial but not across trials.  Handle that aggregation here.
    inertial.data <- loadSummarizedInertialSignals(path)
    inertial.summary <- aggregate(inertial.data, by=list(subject.frame$subject, activity.frame$activity), FUN=sum)
    names(inertial.summary)[1] <- c("subject")
    names(inertial.summary)[2] <- c("activity")

    if (include.feature.vectors) {
        print("Loading feature vectors")
        feature.vectors <- loadMergedFeatureVectors(path)

        print("Summarizing feature vectors")
        feature.summary <- summarizeFeatureVectors(feature.vectors, subject.frame$subject, activity.frame$activity)
        result <- cbind(inertial.summary, feature.summary)
    } else {
        result <- inertial.summary
    }
    result
}

# ----------------------------------------------------------------------

# Convert all variance columns in a frame to standard deviation.
#
# The standard deviation is the square root of variance.  The variance
# column for quantity "foo" has the name "foo_var".  We replace all
# columns like "foo_var" with a corresponding column "foo_sd".
#
# Args:
#   frame (data.frame): Frame containing zero or more variance columns
#
# Returns:
#   New data frame with all variance columns replaced with standard deviation

convertVarToSD <- function(frame) {
    variance.columns <- grep("_var$", names(frame))

    temp <- lapply(variance.columns, function(i) sqrt(frame[, i]))
    frame[, variance.columns] <- temp
    names(frame)[variance.columns] <- sub("_var$", "_sd", names(frame)[variance.columns])
    frame
}

# ----------------------------------------------------------------------

### This is the function you want to start with.

# Compute a summary of the HAR data set
#
# This will load the trial data, label all columns with descriptive
# names, summarize the accelerometer data and feature vector data (if
# requested), and aggregate down to summary data for each subject and
# task.
#
# Args:
#   path (string): Path to your HAR data set (defaults to current directory)
#   include.feature.vectors (boolean): Whether or not to include the feature vectors in the data.  Feature vectors have 561 elements apiece so the final data table will have over 1100 columns if you set this to TRUE.  Defaults to FALSE.
#
# Returns:
#   Summary data table describing distribution of each value for each subject and task

run_analysis <- function(path=".", include.feature.vectors=FALSE) {
    full.table <- assembleFullFrame(path, include.feature.vectors)

    convertVarToSD(full.table)
}

### This function is just for the Coursera assignment

writeCleanedData <- function(filename, ...) {
    clean.data <- run_analysis(...)
    write.table(clean.data, file=filename, sep=",", row.name=FALSE)
}
