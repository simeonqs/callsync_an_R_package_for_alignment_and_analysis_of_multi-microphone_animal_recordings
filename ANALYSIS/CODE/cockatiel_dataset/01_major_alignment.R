# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 14-11-2022
# Author: Simeon Q. Smeele
# Description: This script loads six tapes at a time and aligns chunks, which are saved as wav files. 
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
source('00_paths.R')

# Settings
chunk_size = 15 # size of chunk in minutes
step_size = 0.5 # step size in seconds

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# List folders and loop through
folders = list.files(path_audio, full.names = T) %>% list.files(full.names = T)
for(folder in folders){
  message(folder)
  
  # List files
  files = list.files(folder, pattern = '*wav', full.names = T,recursive = T)
  
  # Test if file already processed and skip if present in 01_chunks
  # takes given date
  dt = list.files(folder, pattern = '*wav', full.names = T)[1] %>% str_split('\\(|\\)') %>% sapply(`[`, 2)
  # takes given group
  group = folder %>% str_split('DATA/') %>% sapply(`[`, 2) %>% str_split('/') %>% sapply(`[`, 1) %>% tolower
  # searches output if given date/group combined are present 
  strings = c(dt, group)
  output_exist = list.files(path_chunks, full.names = T,pattern = '.pdf')
  pdf_is_there = map_int(output_exist, ~ all(str_detect(., strings)))
  if(any(pdf_is_there) == 1) next  # skip if output is already present in 01_chunks 
  
  # Open PDF
  pdf(sprintf('%s/%s.pdf', path_chunks, str_remove(basename(files[1]), '.wav')), 10, 10)
  par(mfrow = c(length(files), 1), mar = c(0, 0, 0, 0), oma = c(5, 1, 1, 1))
  
  # Check for the min duration
  sizes = files %>% lapply(file.info) %>% sapply(function(x) x$size) # load file size for all files
  wave = readWave(files[which(sizes == min(sizes))]) # load the smallest file (this must also be shortest)
  # retrieve min duration: take the floor to get the maximal number of chunks that fits, then multiply by the 
  # chunk size again to get the min duration back in minutes
  min_duration = floor(length(wave@left) / wave@samp.rate / 60 / chunk_size) * chunk_size 

  # Run through chunks
  for(chunk in seq(15, min_duration-15-chunk_size, chunk_size)){
    message(chunk)
    
    # Load master
    master = readWave(files[1], from = chunk - 10, to = chunk + chunk_size + 10, units = 'minutes')
    step = master@samp.rate*step_size
    starts = seq(1, length(master@left)-step, step)
    s1 = sapply(starts, function(start) sum(abs(master@left[start:(start+step)])))
    max_y = 2^wave@bit/2 * step_size * wave@samp.rate / 2
    plot(starts/step/60*step_size, s1, type = 'l', xlim = c(-10, chunk_size + 30), ylim = c(0, max_y),
         xaxt = 'n', yaxt = 'n')
    
    # Save master 30 min
    writeWave(master[(10*60*master@samp.rate):(length(master@left)-10*60*master@samp.rate)], 
              sprintf('%s/%s_%s.wav', path_chunks, str_remove(basename(files[1]), '.wav'), chunk), 
              extensible = F)
    
    # Run through children and calculate off-set
    for(i in 2:length(files)){
      
      # Load child
      child = readWave(files[i], from = chunk - 10, to = chunk + chunk_size + 10, units = 'minutes')
      
      # Align
      starts = seq(1, length(child@left)-step, step)
      s2 = sapply(starts, function(start) sum(abs(child@left[start:(start+step)])))
      d = simple.cc(s1, s2)*step_size
      
      # Plot
      plot(starts/step/60*step_size - d/60, s2, type = 'l', ylim = c(0, max_y), 
           xlim = c(-10, chunk_size + 30), xaxt = 'n', yaxt = 'n')
      
      # Save child 30 min
      writeWave(child[(10*60*child@samp.rate + d*child@samp.rate):
                        (length(child@left)-10*60*child@samp.rate + d*child@samp.rate)], 
                sprintf('%s/%s_%s.wav', path_chunks, str_remove(basename(files[i]), '.wav'), chunk), 
                extensible = F)
      
    } # end i loop
    
    # Add axis
    axis(1)
    mtext('time [m]', 1, 3)
    
  } # end chunk loop
  
  # Save PDF
  dev.off()
  
} # end folder loop

