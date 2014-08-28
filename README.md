Getting and Cleaning Data Course Project
========================================

This is my submission for the course project for Getting and Cleaning
Data.

## READ THIS FIRST

Late-breaking update!  As I've begun to evaluate other students'
submissions I've recognized that I may have misunderstood the
instructions.  I believed that I was to *create* columns with means
and standard deviations instead of just using those that were already
there.  If you find yourself confused, it's almost certainly me, not
you.

(I promise that I have not changed anything at all about my submission
since the deadline except to add the paragraph above.)

## Contents

Here are the files you need to be aware of:

* `README.md`: this file.
* `CODEBOOK.md`: description of the variables added to the data by my analysis and pointers to the original data source
* `run_analysis.R`: Code to aggregate and summarize the entire data set.  Look at the function runAnalysis() at the bottom of the file to get started.
** Data Files:
** `features_info.txt`: High-level description of the elements in the feature vectors
** `features.txt`: Per-column names for the elements of the feature vectors
** `activity_labels.txt`: Human-readable names for activity IDs
** `test/`: Directory containing subset of data for testing
** `train/`: Directory containing subset of data for training

Within the `test/` and `train/` directories we find the actual data:
* `X_{test,train}.txt`: Feature vectors
* `y_{test,train}.txt`: Activity IDs (numeric)
* `subject_{test,train}.txt`: Subject IDs (numeric)
* `Inertial Signals/*.txt`: Sampled and filtered time series data measured from accelerometers

## Generating the tidy data set

In R, set your working directory to the directory containing this file and run the following commands:

`> source("run_analysis.R")`
`> summary.frame <- run_analysis()`

This will give you a summary data set that does not include the (very
large) feature vectors.  If you want to include those do this:

`> big.summary <- run_analysis(include.feature.vectors=TRUE)`

## About the data

The data set used here is from the UCI Human Activity Recognition
project.  Please see the file CODEBOOK.md for a full description.

