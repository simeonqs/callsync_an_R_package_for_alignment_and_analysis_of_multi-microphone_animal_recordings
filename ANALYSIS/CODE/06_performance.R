# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 22-11-2022
# Date last modified: 23-11-2022
# Author: Simeon Q. Smeele
# Description: This script compares the ground truth tables to the detections. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/00_set_up.R')

# Load measurements for filtering
load(path_measurements)

# Load ground truth
gt = load.selection.tables.audacity(path_ground_truth_tables)

# Get the associated chunks
all_files = list.files(path_chunks, pattern = '*wav', full.names = T, recursive = T)
path_ground_truth_chunks = all_files[(str_detect(all_files, '@120.wav') | str_detect(all_files, '@135.wav') |
                                        str_detect(all_files, '@150.wav')) & 
                                       str_detect(all_files, '2021_07_16-05_54_59')]

# Run detect and assign on ground truth chunks
d = detect.and.assign(all_files = path_ground_truth_chunks,
                      ffilter_from = 1100,
                      threshold = 0.4, 
                      msmooth = c(1000, 95), 
                      min_dur = 0.1, 
                      max_dur = 0.3,
                      step_size = 1/50, 
                      wing = 10, 
                      # path_calls = '~/Desktop',
                      save_files = F)

# Filter for calls and fix start/end
b = d
d$fs = sprintf('%s@%s-%s.wav', d$file, d$start, d$end)
d = d[d$fs %in% measurements$file,]
d[c('start', 'end')] = d[c('start', 'end')]/22050

# Calculate performance
perf = calc.perf(d = d, gt = gt)

# Save results
write.table(perf, file = path_perf)
