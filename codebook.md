Codebook for UCI HAR Data Set
=============================

This file describes the values present in the UCI Human Activity
Recognition data set.

### Original Source

The data set comes from the following URL:
   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

I obtained it from the following URL on the Getting and Cleaning Data Coursera pages:
   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

### Contents (High Level)

The data set contains velocity and acceleration measurements from an
experiment in recognizing human behavior.  Subjects wore an
accelerometer (actually a Samsung Galaxy V) at their waists and
performed one of a number of activities (sitting, standing, walking,
etc).  The accelerometer measurements were recorded for each trial and
then filtered into a time series 128 elements long with measurements
for overall acceleration, acceleration due to body motion and angular
velocity.

Details on the filtering approach are available at the data set's home
page listed under _Original Source_.

In addition to the filtered accelerometer data, each trial includes a
561-component feature vector containing derived quantities.

Finally, each trial is labeled with the subject's numeric ID and the
activity type (one of `WALKING`, `WALKING_UPSTAIRS`,
`WALKING_DOWNSTAIRS`, `SITTING`, `STANDING` and `LAYING`).

### Contents (Low Level)

The acceleration and velocity vectors are specified as three scalar
arrays each.  For example, the `Total Acceleration` measurements are
stored in vectors `total_acc_X`, `total_acc_Y` and `total_acc_Z`.

The components of the feature vector are each stored in their own
columns.  These columns are labeled with the feature names found in
"features.txt" from the root of the data set.

### How to Access Data

The script 'run_analysis.R' contains several functions that will let
you get access to various components of the data:

