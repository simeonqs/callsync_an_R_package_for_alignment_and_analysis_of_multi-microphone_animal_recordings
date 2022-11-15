# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II 
# Date started: 16-03-2021
# Date last modified: 13-06-2022
# Author: Simeon Q. Smeele
# Description: Finds the call within a wave object. Returns the new wave object and optionally 
# start and end times and envelop. Returned object is a list. 
# This version includes an option to detect all elements above the threshold. 
# This version includes the options for two thresholds (e.g. for echos).
# This version includes an option to correct for echo. 
# This version returns all start and end times. 
# This version is fixed for not detections under return_all = T. 
# This version is a developmental version for single wave detections that better deals with echo. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

wave.detec.dev = function(wave, # wave object
                          threshold = 0.3, # fraction of max of envelope to use as threshold for start/end
                                           # if vector of two is supplied, the first is used for start
                                           # and second for end (in case of echo)
                          msmooth = c(500, 95), # smoothening of envelope
                          plot_it = F # if T, returns three-panel plot of wave, envelope and spectrogram
){
  
  # Envelope
  env = env(wave, msmooth = msmooth, plot = F) 
  env = ( env - min(env) ) / max( env - min(env) )
  duration = length(wave@left)/wave@samp.rate
  
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
  
  # Re-clip wave
  start_env = start
  if(start == 0) start = 1 # avoid issues when call starts at start clip
  end_env = end
  start = round((start-1) * duration/length(env) * wave@samp.rate)
  end = round((end-1) * duration/length(env) * wave@samp.rate)
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
  temp = list(new_wave = new_wave, 
              start = start, 
              end = end, 
              env = env)
  return(temp)
  
}