# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 24-11-2022
# Author: Simeon Q. Smeele
# Description: This script loads chunks, detects calls and assigns them to individuals.
# source('ANALYSIS/CODE/02_call_detection_and_assignment.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/00_set_up.R')

# Settings
ffilter_from = 1100 
threshold = 0.4 
msmooth = c(1000, 95) 
min_dur = 0.1 
max_dur = 0.3
step_size = 1/50 
wing = 10 
keys_id = c('bird_', '_tag')
keys_rec = c('_\\(', '\\)_')
all_files = NULL
save_files = TRUE

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
                  save_files = save_files) 
