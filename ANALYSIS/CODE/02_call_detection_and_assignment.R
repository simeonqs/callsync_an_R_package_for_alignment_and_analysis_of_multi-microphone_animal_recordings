# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 11-01-2023
# Author: Simeon Q. Smeele
# Description: This script loads chunks, detects calls and assigns them to individuals.
# source('ANALYSIS/CODE/02_call_detection_and_assignment.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/00_set_up.R')

# Settings
ffilter_from = 1100 
threshold = 0.18
msmooth = c(1000, 95) 
min_dur = 0.1 
max_dur = 0.3
step_size = 1/50 
wing = 10 
all_files = NULL
save_files = TRUE
save_extra = 0.05

# Run function
detect.and.assign(all_files = all_files,
                  path_chunks = path_chunks,
                  path_calls = path_calls,
                  ffilter_from = ffilter_from,
                  threshold = threshold, 
                  msmooth = msmooth, 
                  min_dur = min_dur, 
                  max_dur = max_dur,
                  step_size = step_size, 
                  wing = wing, 
                  save_files = save_files,
                  save_extra = save_extra) 
