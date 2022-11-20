# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 20-11-2022
# Author: Simeon Q. Smeele
# Description: This script loads chunks, detects calls and assigns them to individuals.
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('warbleR', 'tidyverse', 'scales', 'callsync')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list = ls()) 

# Paths
source('ANALYSIS/CODE/cockatiel_dataset/00_paths.R')

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*.R', full.names = T), source)

# Settings
ffilter_from = 1100 # from where to filter (Hz) the wave when loading
threshold = 0.4 # threshold for amplitude envelope when detecting call
msmooth = c(1000, 95) # smoothening settings of amplitude envelope
min_dur = 0.1 # minimal duration for a note to be included in seconds
max_dur = 0.3
step_size = 1/50 # step size in seconds for the alignment
wing = 10 # how many seconds to load before and after detection for alignment
keys_id = c('bird_', '_tag')
keys_rec = c('_\\(', '\\)_')
all_files = NULL

# Run function
.detections = detect.and.assign(all_files = NULL,
                                path_chunks = path_chunks,
                                ffilter_from = ffilter_from, # from where to filter (Hz) the wave when loading
                                threshold = threshold, # threshold for amplitude envelope when detecting call
                                msmooth = msmooth, # smoothening settings of amplitude envelope
                                min_dur = min_dur, # minimal duration for a note to be included in seconds
                                max_dur = max_dur,
                                step_size = step_size, # step size in seconds for the alignment
                                wing = wing) # how many seconds to load before and after detection for alignment

