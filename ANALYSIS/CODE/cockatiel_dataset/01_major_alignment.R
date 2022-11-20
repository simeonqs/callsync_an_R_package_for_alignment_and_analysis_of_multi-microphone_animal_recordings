# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 15-11-2022
# Author: Simeon Q. Smeele
# Description: This script loads six tapes at a time and aligns chunks, which are saved as wav files. 
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

# Settings
chunk_size = 15 # size of chunk in minutes
step_size = 0.5 # step size in seconds
save_pdf = T  # if T saves a single PDF per folder with 1 chunk per page
keys_rec = c('_\\(', '\\)_')
keys_id = c('bird_', '_tag')
blank = 15
wing = 7
all_files = NULL

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Run main function
align(chunk_size = chunk_size,
      all_files = all_files,
      step_size = step_size,
      path_folders = path_folders,
      path_chunks = path_chunks, 
      keys_id = keys_id,
      keys_rec = keys_rec,
      blank = blank, 
      wing = wing, 
      save_pdf = save_pdf)

# Message
message('All done!')