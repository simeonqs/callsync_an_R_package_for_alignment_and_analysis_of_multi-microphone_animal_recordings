# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 22-11-2022
# Author: Simeon Q. Smeele
# Description: This script runs the partitioning and alignment of raw recordings.
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/cockatiel_dataset/00_set_up.R')

# Settings
chunk_size = 15 
step_size = 0.5
save_pdf = T 
chunk_seq = NULL
keys_rec = c('_\\(', '\\)_')
keys_id = c('ASWMUX', '.wav')
blank = 15
wing = 10
ffilter_from = NULL
all_files = list.files(path_recordings, full.names = T, recursive = T)
# all_files = all_files[str_detect(all_files, 'file_3')]
  
# Run main function
align(chunk_size = chunk_size,
      all_files = all_files,
      step_size = step_size,
      path_recordings = path_recordings,
      path_chunks = path_chunks, 
      chunk_seq = chunk_seq,
      keys_id = keys_id,
      keys_rec = keys_rec,
      blank = blank, 
      wing = wing, 
      ffilter_from = ffilter_from,
      save_pdf = save_pdf)

# Message
message('All done!')