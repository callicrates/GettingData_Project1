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
accelerometer (actually a Samsung Galaxy S) at their waists and
performed one of a number of activities (sitting, standing, walking,
etc).  The accelerometer measurements were recorded for each trial and
then filtered into a time series 128 elements long with measurements
for overall acceleration, acceleration due to body motion and angular
velocity.

Details on the filtering approach are available at the data set's home
page listed under _Original Source_.  The data set's original codebook
is available in this repository in the file
`original_data/README.txt`.

In addition to the filtered accelerometer data, each trial includes a
561-component feature vector containing derived quantities.

Finally, each trial is labeled with the subject's numeric ID and the
activity type (one of `WALKING`, `WALKING_UPSTAIRS`,
`WALKING_DOWNSTAIRS`, `SITTING`, `STANDING` and `LAYING`).

The following measurements were collected from the accelerometer with
a frequency of 50 Hz:

* Total Acceleration (`total_acc`): Total 3-axis acceleration.  Units are standard gravities (9.8 m/sec^2).
* Body Acceleration (`body_acc`): The 3-axis acceleration of the subject's body with the Earth's gravity factored out.  Units are standard gravities.
* Body Angular Velocity (`body_gyro`): 3-axis angular velocity measured at the accelerometer.  Units are radians per second.

### Contents (Low Level)

The acceleration and velocity vectors are specified as three scalar
arrays each.  For example, the `Total Acceleration` measurements are
stored in vectors `total_acc_X`, `total_acc_Y` and `total_acc_Z`.

The components of the feature vector are each stored in their own
columns.  These columns are labeled with the feature names found in
`features.txt` from the root of the data set.

### How to Access Data

The script `run_analysis.R` contains several functions that will give
you access to various components of the data.  Start with the function
`run_analysis()` and work backwards from there.  Functions are
provided to load each different component of the data.

### Variables

The `run_analysis` script creates a data frame with either 20 or XXXX
columns depending on whether you specified
`include.feature.vectors=TRUE` when you called `run_analysis`.

* The `subject` column is a unique numeric ID for the person who wore the accelerometer for each individual trial.
* The `activity` column is a string describing the activity the subject was directed to perform.  It has been created by replacing the numeric values in `y_{test,train}.txt` with the names in `activity_labels.txt`.
* Mean and standard deviations (denoted `foo_mean` and `foo_sd`) for each of the following quantities:
** `total_acc` (x, y and z components):  Average of total acceleration value (by component) within a trial for each subject and activity.  Units are standard gravities (1 g = 9.8 meters / sec^2).
** `body_acc` (x, y and z components): Average of body acceleration (total acceleration minus gravity) within a trial for each subject and activity.  Units are standard gravities.
** `body_gyro` (x, y and z) components: Average of angular velocity within a trial for each subject and activity.  Units are radians per second.
* Feature vectors all have their own meanings.  See the file `features_info.txt` for descriptions.  Each feature has been normalized to fall within the range [-1, 1].

Further information on how the measurements were obtained and filtered
is available in the file `original_data/README.txt`.  This file
contains the codebook for the original data set.

If you have requested feature vectors in your analysis, each element of the feature vector will have its own column for mean and standard deviation.
