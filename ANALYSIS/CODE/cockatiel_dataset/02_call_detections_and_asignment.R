# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: cockatiel aligment
# Date started: 11-05-2022
# Date last modified: 07-06-2022
# Author: Simeon Q. Smeele
# Description: This script loads chunks, detects calls and assign them to individuals.
# This version has a fix for multiple folders sharing date and time. 
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

# List folders and loop through
folders = list.files(path_audio, full.names = T) %>% list.files(full.names = T)
for(folder in folders){
  message(folder)
  
  # List major chunks
  chunk_files = list.files(path_chunks, pattern = '*.wav', full.names = T)
  
  # Subset for folder
  dt = list.files(folder, pattern = '*wav', full.names = T)[1] %>% str_split('\\(|\\)') %>% sapply(`[`, 2)
  chunk_files = chunk_files[str_detect(chunk_files, dt)]
  group = folder %>% str_split('DATA/') %>% sapply(`[`, 2) %>% str_split('/') %>% sapply(`[`, 1) %>% tolower
  chunk_files = chunk_files[str_detect(chunk_files, group)]
  
  # Get the chunk _time.wav keys
  starts_chunks = chunk_files %>% str_split('_') %>% unlist %>% unique
  starts_chunks = starts_chunks[str_detect(starts_chunks, '.wav')]
  
  # Run through major chunks
  for(start_chunk in starts_chunks){
    
    # Skip already done chunks
    start_chunkt = str_replace(start_chunk, '.wav', '.pdf')
    strings = c(dt, group, start_chunkt)
    output_exist = list.files(path_calls, full.names = T, pattern = '.pdf')
    pdf_is_there = map_int(output_exist, ~ all(str_detect(., strings)))
    if(any(pdf_is_there) == 1) next  # skip if output is already present in 02_calls 
    
    # Message
    message(sprintf('Running _%s...', start_chunk))
    
    # List files and load
    audio_files = chunk_files[str_detect(chunk_files, start_chunk)]
    
    # Test chunk
    waves = lapply(audio_files, load.wave, from = 0, to = Inf)
    wfs = lapply(audio_files, load.wave, from = 0, to = Inf, ffilter_from = ffilter_from)
    
    # Open PDF
    pdf(sprintf('%s/%s.pdf', 
                path_calls,
                str_remove(basename(audio_files[1]), '.wav')), 
        30*15, 14)
    par(mfrow = c(1*length(audio_files), 1), mar = c(0, 0, 0, 0), oma = c(5, 5, 1, 1))
    
    # Run through files
    for(i in 1:length(audio_files)){
      
      # Load wave
      wave = waves[[i]]
      wf = wfs[[i]]
      temp = wave.detec.wave(wf, 
                             threshold = threshold,
                             msmooth = msmooth,
                             plot_it = F,
                             min_dur = min_dur,
                             return_times = T,
                             return_env = T,
                             return_all = T)
      
      # # Plot envelope
      # plot(temp$env,type = 'l', xaxs = 'i',xaxt = 'n')
      # abline(h = threshold, lty = 2, col = 2)
      
      # Plot wave
      plot(wf, xaxs = 'i', xaxt = 'n', nr = 15*2500)
      
      # Test if any detections else skip
      if(all(is.na(temp))) next  # skip if no calls detected
      
      # Plot spectrogram
      # better.spectro(wave, wl = 100, ovl = 50)
      
      # Run through detections and select
      ## do not consider start and end times that cannot fit a wing
      for(j in (1:length(temp$starts))[temp$ends < (length(wave@left)-wings*wave@samp.rate) &
                                       temp$starts > wings*wave@samp.rate]){
        
        # Get start and end
        start = temp$starts[j]
        end = temp$ends[j]
        
        # Get master chunk
        small_master = wf[start:end]
        cs = c(sum(abs(small_master@left)))
        
        # Load master
        master = wf[(start-wings*wave@samp.rate):(end+wings*wave@samp.rate)]
        step = master@samp.rate*step_size
        starts = seq(1, length(master@left)-step, step)
        s1 = sapply(starts, function(start) sum(abs(master@left[start:(start+step)])))
        
        # Run through children and calculate off-set
        for(l in (1:length(audio_files))[-i]){ 
          
          # Load child
          child = wfs[[l]][(start-wings*wave@samp.rate):(end+wings*wave@samp.rate)]
          
          # Align
          starts = seq(1, length(child@left)-step, step)
          s2 = sapply(starts, function(start) sum(abs(child@left[start:(start+step)])))
          d = simple.cc(s1, s2)*step_size*wave@samp.rate
          
          # If alignment exceeds wings introduce NA in cs (-> this detection is skipped) and warn
          if(abs(d/wave@samp.rate) > wings){
            cs = c(cs, NA)
            warning(sprintf('Wingspan exceeded in folder %s, chunk file %s, start chunk %s and detection %s.',
                            folder, chunk_files[i], start_chunk, l))
          } else {
            
            # Add child chunk
            small_child = child[(wings*child@samp.rate+d):(length(child@left)-wings*child@samp.rate+d)]
            cs = c(cs, sum(abs(small_child@left)))
      
          } # end else
          
        } # end l loop (children)
        
        # Test if master was the loudest
        if(any(is.na(cs))) next 
        if(cs[1] == max(cs)){
          abline(v = start/wave@samp.rate, lty = 2, col = 'green', lwd = 2)
          abline(v = end/wave@samp.rate, lty = 2, col = 'green', lwd = 2)
          writeWave(wave[(start-0.1*wave@samp.rate):(end+0.1*wave@samp.rate)],
                    file = sprintf('%s/%s_%s-%s.wav',
                                   path_calls,
                                   str_remove(basename(audio_files[i]), '.wav'),
                                   start, 
                                   end),
                    extensible = F)
        } 
        
      } # end j loop (starts)
      
    } # end i loop (files)
    
    # Close PDF
    axis(1, at = seq(0, 15*60, 15), format(seq(as.POSIXct('2013-01-01 00:00:00', tz = 'GMT'), 
                                               length.out = 15*4+1, by = '15 sec'), '%M:%S'))
    dev.off()
    
  } # end start_chunk
  
} # end folder loop

# Message
message('All done!')
