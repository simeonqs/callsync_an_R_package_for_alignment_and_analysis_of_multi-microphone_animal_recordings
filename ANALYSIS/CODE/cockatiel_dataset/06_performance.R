# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 22-11-2022
# Date last modified: 22-11-2022
# Author: Simeon Q. Smeele
# Description: This script compares the ground truth tables to the detections. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/cockatiel_dataset/00_set_up.R')

# Run detect and assign on ground truth chunks
d = detect.and.assign(path_chunks = path_ground_truth_chunks,
                      ffilter_from = 1100,
                      threshold = 0.4, 
                      msmooth = c(1000, 95), 
                      min_dur = 0.1, 
                      max_dur = 0.3,
                      step_size = 1/50, 
                      wing = 10, 
                      save_files = F)
d[c('start', 'end')] = d[c('start', 'end')]/22050

# Load ground truth
gt = load.selection.tables.audacity(path_ground_truth_tables)


