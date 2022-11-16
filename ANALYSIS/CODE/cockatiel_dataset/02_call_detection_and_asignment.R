# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 15-11-2022
# Author: Simeon Q. Smeele
# Description: This script loads chunks, detects calls and assigns them to individuals.
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('warbleR', 'tidyverse', 'scales')
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
return_all = T # return all calls
msmooth = c(1000, 95) # smoothening settings of amplitude envelope
min_dur = 0.1 # minimal duration for a note to be included in seconds
step_size = 1/50 # step size in seconds for the alignment
wings = 6 # how many seconds to load before and after detection for alignment
keys_id = c('bird_', '_tag')
keys_rec = c('_\\(', '\\)_')
all_files = NULL

# Run function
detect.and.assign(ffilter_from = ffilter_from, # from where to filter (Hz) the wave when loading
                  threshold = threshold, # threshold for amplitude envelope when detecting call
                  return_all = return_all, # return all calls
                  msmooth = msmooth, # smoothening settings of amplitude envelope
                  min_dur = min_dur, # minimal duration for a note to be included in seconds
                  step_size = step_size, # step size in seconds for the alignment
                  wings = wings, # how many seconds to load before and after detection for alignment
                  all_files = NULL)

