# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II 
# Date started: 16-03-2021
# Date last modified: 18-05-2022
# Author: Simeon Q. Smeele
# Description: Finds the call within a wave object. Returns the new wave object and optionally 
# start and end times and envelop. Returned object is a list. 
# This version includes an option to detect all elements above the threshold. 
# This version includes the options for two thresholds (e.g. for echos).
# This version includes an option to correct for echo. 
# This version returns all start and end times. 
# This version is fixed for not detections under return_all = T. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

wave.detec.wave = function(wave, # wave object
                           threshold = 0.3, # fraction of max of envelope to use as threshold for start/end
                                            # if vector of two is supplied, the first is used for start
                                            # and second for end (in case of echo)
                           msmooth = c(500, 95), # smoothening of envelope
                           plot_it = F, # if T, returns three-panel plot of wave, envelope and spectrogram
                           min_dur = 0.01, # minimal duration of an item (only considered for return_all = T)
                           echo_correction = 0, # how many seconds to take off the end to correct for echo
                           return_all = F, # if T, returns all elements above threshold; start is the mini-
                                           # mum, end the maximum, also returns the number of sub-detects
                           return_env = F, # if T, return envelope
                           return_times = F){ # if T, outputs start and end to global environment
  
  # Envelope
  env = env(wave, msmooth = msmooth, plot = F) 
  env = ( env - min(env) ) / max( env - min(env) )
  duration = length(wave@left)/wave@samp.rate
  
  # Either return all or return the loudest
  if(return_all){
    # Find all
    which_above = which(env > threshold)
    start = which_above[1]
    end = which_above[length(which_above)]
    other_starts = which_above[which(diff(which_above) != 1)+1]
    other_ends = which_above[which(diff(which_above) != 1)]
    starts = sort(c(start, other_starts))
    ends = sort(c(end, other_ends))
    # Remove short durations
    r = c()
    if(length(starts) > 1){
      for(j in 1:length(starts)){
        dif = ends[j] - starts[j]
        if(dif * duration/length(env) < min_dur) r = c(r, j)
      }
      if(length(r) > 0){
        starts = starts[-r]
        ends = ends[-r]
      }
    } 
    if(length(starts) != 0){
      start = min(starts)
      end = max(ends)
      # Count and change to time
      n_subs = length(starts)
      other_starts = starts[starts != start]
      other_ends = ends[ends != end]
      other_starts = round((other_starts-1) * duration/length(env) * wave@samp.rate)
      other_ends = round((other_ends-1) * duration/length(env) * wave@samp.rate)
    }
  } else { # find start and end of loudest
    ## Find max location
    where_max = which(env == 1)
    ## Left loop
    start = NA
    j = where_max
    while(is.na(start)){
      j = j - 1
      if(j == 0) start = j else if(env[j] < threshold[1]) start = j
    } 
    ## Right loop
    end = NA
    j = where_max
    while(is.na(end)){
      j = j + 1
      if(j == length(env)) end = j else if(env[j] < threshold[length(threshold)]) end = j
    } 
  }
  
  if(length(starts) != 0){
    # Re-clip wave
    start_env = start
    end_env = end
    start = round((start-1) * duration/length(env) * wave@samp.rate)
    end = round((end-1) * duration/length(env) * wave@samp.rate)
    ## optional correction for echo
    end = end - echo_correction * wave@samp.rate
    if(return_all) if(length(other_starts) > 0){
      for(i in 1:length(other_starts)) 
        wave@left[other_ends[i]:other_starts[i]] = rnorm(other_starts[i]-other_ends[i]+1, 0, 0.05)
    }
    new_wave = wave[start:end]
    
    # Plot
    if(plot_it){
      par(mfrow = c(2, 2))
      plot(env, type = 'l')
      abline(v = c(start_env, end_env))
      abline(h = threshold, lty = 2)
      better.spectro(wave, wl = 512, ovl = 450, ylim = c(500, 4000))
      abline(v = c(start/wave@samp.rate, end/wave@samp.rate))
      plot(wave)
      abline(v = c(start/wave@samp.rate, end/wave@samp.rate))
    }
    
    # Return
    temp = list(new_wave = new_wave)
    if(return_times) {temp$start = start; temp$end = end}
    if(return_env) temp$env = env
    if(return_all){
      temp$n_subs = n_subs
      temp$starts = sort(c(start, other_starts))
      temp$ends = sort(c(end, other_ends))
    } 
    return(temp)
  } else return(NA)
  
}