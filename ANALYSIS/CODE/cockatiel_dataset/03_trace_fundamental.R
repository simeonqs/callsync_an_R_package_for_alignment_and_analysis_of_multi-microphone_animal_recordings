# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: cockatiels Stephen
# Date started: 06-05-2022
# Date last modified: 14-06-2022
# Author: Simeon Q. Smeele
# Description: This script takes a path for a folder with .wav files. It then runs an amplitude envelope
# with a threshold to detect calls (multiple notes are possible). Within each note the fundamental frequency 
# is traced (saved as a named list per wav file) and measurements on the trace are also saved. 
# This version has improved FM detection. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('tidyverse', 'warbleR', 'parallel', 'pracma')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list=ls()) 

# Paths
source('00_paths.R')

# Import functions
## requires: wave.detec.wave, trace.fund, load.wave
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Audio files 
audio_files = list.files(path_calls,  '*wav', full.names = T)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS: tracing ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Settings
ffilter_from = 700 # from where to filter (Hz) the wave when loading
threshold = c(0.37, 0.47) # threshold for amplitude envelope when detecting call
msmooth = c(500, 95) # smoothening settings of amplitude envelope

thr_trace = 0.15 # threshold for detection of fundamental (amplitude for lowest value of spectrum)
hop = 5 # hop for tracing
spar = 0.3 # how much to smoothen the trace
freq_lim = c(1.2, 3.5) # in what region (kHz) the fundamental should be found
noise_factor = 1.5 # how much more than the average the peak should be
plot_it = F # whether or not to plot a PDF to check the output

snr = 9 # threshold for colouring calls as noisy

# Load waves
waves = lapply(audio_files, load.wave, ffilter_from = ffilter_from)

# Detect call
new_waves = lapply(waves, wave.detec.dev, 
                   threshold = threshold,
                   msmooth = msmooth,
                   plot_it = F)

# Trace fundamental
traces = mclapply(new_waves, function(new_wave)
  trace.fund(new_wave$new_wave, spar = spar, freq_lim = freq_lim, thr = thr_trace, hop = hop,
             noise_factor = noise_factor), mc.cores = 6)
# traces_raw = mclapply(new_waves, function(new_wave)
#   trace.fund(new_wave$new_wave, spar = 0, freq_lim = freq_lim, thr = thr_trace), mc.cores = 6)

# Make data frame to save results
out = data.frame()

# Run through files
if(plot_it) pdf(path_pdf, 7, 5)
for(i in 1:length(audio_files)){
  
  # Load wave
  new_wave = new_waves[[i]]$new_wave
  start = new_waves[[i]]$start
  end = new_waves[[i]]$end
  env = new_waves[[i]]$env

  # Test STN
  signal = mean(abs(new_wave@left))
  noise = mean(abs(waves[[i]][-(start:end)]@left))
  if(signal/noise > snr) col = 1 else col = 2 
  
  # Plot
  if(plot_it){
    par(mfrow = c(2, 2))
    plot(waves[[i]])
    abline(v = c(start/waves[[i]]@samp.rate, end/waves[[i]]@samp.rate), col = col)
    # plot(env, type = 'l')
    # abline(h = threshold, lty = 2, lwd = 2, col = alpha('red', 0.5))
    better.spectro(waves[[i]], wl = 200, ovl = 195, ylim = c(500, 4000),
                   main = basename(audio_files[i]), mar = rep(4, 4))
    # points(traces_raw[[i]]$time + start/waves[[i]]@samp.rate, 
    #        traces_raw[[i]]$fund,
    #        col = alpha('grey', 0.3), pch = 16, cex = 0.2)
    lines(traces[[i]]$time + start/waves[[i]]@samp.rate, 
          traces[[i]]$fund,
          col = alpha('green', 0.3), lty = 1, lwd = 1)
    abline(h = c(mean(traces[[i]]$fund, na.rm = T),
                 max(traces[[i]]$fund, na.rm = T),
                 min(traces[[i]]$fund, na.rm = T)), lty = 2, 
           col = alpha('black', 0.5))
    plot(NULL, xlim = c(0, 1), ylim = c(0, 8), xaxt = 'n', yaxt = 'n', xlab = '', ylab = '')
    text(0, 1:6, adj = 0,
         labels = c(sprintf('mean_fund_hz: %s', round(mean(traces[[i]]$fund, na.rm = T))),
                    sprintf('diff_start_mean: %s', 
                            round(traces[[i]]$fund[1] - mean(traces[[i]]$fund))),
                    sprintf('diff_end_mean: %s', 
                            round(traces[[i]]$fund[nrow(traces[[i]])] - 
                                    mean(traces[[i]]$fund))),
                    sprintf('duration: %s', round((end - start)/waves[[i]]@samp.rate, 2)),
                    sprintf('band_hz: %s',  
                            round(max(traces[[i]]$fund) - min(traces[[i]]$fund))),
                    sprintf('prop_missing_trace: %s', round(length(which(traces[[i]]$missing))/
                                                              length(traces[[i]]$missing), 3))))
  } # end plot_it
  
  # Calculate FM
  temp = calc.fm(trace = traces[[i]]$fund, min_height = 5, plot_it = plot_it)
  
  # Take measurements and save results
  out = rbind(out, data.frame(file = basename(audio_files[i]),
                              mean_fund_hz = mean(traces[[i]]$fund),
                              duration_s = (end - start)/waves[[i]]@samp.rate,
                              band_hz = max(traces[[i]]$fund) - min(traces[[i]]$fund),
                              max_freq_hz = max(traces[[i]]$fund),
                              min_freq_hz = min(traces[[i]]$fund),
                              diff_start_mean = traces[[i]]$fund[1] - mean(traces[[i]]$fund),
                              diff_end_mean = traces[[i]]$fund[nrow(traces[[i]])] - 
                                mean(traces[[i]]$fund),
                              ipi_s = as.numeric(temp$ipi * hop / waves[[i]]@samp.rate),
                              fm_hz = as.numeric(temp$fm),
                              signal_to_noise = signal/noise,
                              sd_trace = sd(traces[[i]]$fund),
                              prop_missing_trace = length(which(traces[[i]]$missing))/
                                length(traces[[i]]$missing)))
  
} # end i loop
if(plot_it) dev.off()

# Save out
save(out, file = path_output_measurements)
names(traces) = basename(audio_files)
save(traces, file = path_output_traces)
message('All done and saved.')