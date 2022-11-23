# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 16-11-2022
# Date last modified: 22-11-2022
# Author: Simeon Q. Smeele
# Description: This script takes a path for a folder with .wav files. It then runs an amplitude envelope
# with a threshold to detect calls (multiple notes are possible). Within each note the fundamental frequency 
# is traced (saved as a named list per wav file) and measurements on the trace are also saved. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/00_set_up.R')

# Audio files 
audio_files = list.files(path_calls,  '*wav', full.names = T)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS: tracing ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Settings
set.seed(1)
ffilter_from = 700 # from where to filter (Hz) the wave when loading
threshold = c(0.37, 0.47) # threshold for amplitude envelope when detecting call
msmooth = c(500, 95) # smoothening settings of amplitude envelope

thr_trace = 0.15 # threshold for detection of fundamental (amplitude for lowest value of spectrum)
hop = 5 # hop for tracing
spar = 0.3 # how much to smoothen the trace
freq_lim = c(1.2, 3.5) # in what region (kHz) the fundamental should be found
noise_factor = 1.5 # how much more than the average the peak should be
mc.cores = 6 # how many threads to use in parallel (should be 1 on Windows)

snr = 9 # threshold for colouring calls as noisy

# Load waves
waves = lapply(audio_files, load.wave, ffilter_from = ffilter_from)
names(waves) = basename(audio_files)

# Detect call
detections = lapply(waves, call.detect, 
                    threshold = threshold,
                    msmooth = msmooth,
                    plot_it = F)

# Extract one call per wave
new_waves = lapply(1:length(waves), function(i) waves[[i]][detections[[i]]$start:detections[[i]]$end])

# Trace fundamental
traces = mclapply(new_waves, function(new_wave)
  trace.fund(new_wave, spar = spar, freq_lim = freq_lim, thr = thr_trace, hop = hop,
             noise_factor = noise_factor), mc.cores = mc.cores)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS: measurements ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Run function
measurements = measure.trace.multiple(traces = traces, 
                                      new_waves = new_waves, 
                                      waves = waves, 
                                      detections = detections,
                                      path_pdf = path_pdf_traces)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS: filter and save ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Filter measurements and traces object
keep = measurements$prop_missing_trace < 0.1 & 
  measurements$signal_to_noise > 4 &
  measurements$band_hz > 600 & 
  measurements$duration_s > 0.10 & measurements$duration_s < 0.45
mb = measurements
measurements = measurements[keep,]
traces = traces[keep]

# Plot samples of noise and samples of none noise
pdf(path_pdf_samples_filtering, 10, 10)
par(mfrow = c(4, 4))
signal = sample(which(keep), 8, replace = T)
noise = sample(which(!keep), 8, replace = T)
for(i in c(signal, noise)){
  better.spectro(waves[[i]], wl = 200, ovl = 195, ylim = c(500, 4000),
                 main = i)
  abline(v = detections[[i]]/waves[[i]]@samp.rate, lwd = 3, lty = 2)
} 
dev.off()

# Save measurements
names(traces) = basename(audio_files[keep])
save(traces, file = path_traces)
save(measurements, file = path_measurements)
message('All done and saved.')