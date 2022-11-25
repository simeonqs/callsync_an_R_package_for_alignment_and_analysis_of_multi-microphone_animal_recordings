# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 22-11-2022
# Date last modified: 23-11-2022
# Author: Simeon Q. Smeele
# Description: This script compares the ground truth tables to the detections. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/00_set_up.R')

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

# Load measurements for filtering
load(path_measurements)

# Load ground truth
gt = load.selection.tables.audacity(path_ground_truth_tables)

# Load waves from gt - to run tracing and filtering
file_gt = sprintf('%s/%s.wav', path_chunks, gt$file)
waves_gt = lapply(1:nrow(gt), function(i) 
  load.wave(file_gt[i], from = gt$start[i], to = gt$end[i], ffilter_from = 700))
names(waves_gt) = basename(file_gt)

# Detect
detections = lapply(waves_gt, call.detect, 
                    threshold = c(0.37, 0.47),
                    msmooth = c(500, 95),
                    plot_it = F)

# Extract one call per wave
new_waves = lapply(1:length(waves_gt), function(i) waves_gt[[i]][detections[[i]]$start:detections[[i]]$end])

# Trace fundamental
traces = mclapply(new_waves, function(new_wave)
  trace.fund(new_wave, spar = spar, freq_lim = freq_lim, thr = thr_trace, hop = hop,
             noise_factor = noise_factor), mc.cores = mc.cores)

# Measure
measurements = measure.trace.multiple(traces = traces, 
                                      new_waves = new_waves, 
                                      waves = waves_gt, 
                                      detections = detections,
                                      path_pdf = NULL)

# Select 
keep = measurements$prop_missing_trace < 0.15 & 
  measurements$signal_to_noise > 4 &
  measurements$band_hz > 400 
gt = gt[keep,]

# Get the associated chunks
all_files = list.files(path_chunks, pattern = '*wav', full.names = T, recursive = T)
path_ground_truth_chunks = all_files[(str_detect(all_files, '@120.wav') | str_detect(all_files, '@135.wav') |
                                        str_detect(all_files, '@150.wav')) & 
                                       str_detect(all_files, '2021_07_16-05_54_59')]

# Run detect and assign on ground truth chunks
d = detect.and.assign(all_files = path_ground_truth_chunks,
                      ffilter_from = 1100,
                      threshold = 0.4, 
                      msmooth = c(1000, 95), 
                      min_dur = 0.1, 
                      max_dur = 0.3,
                      step_size = 1/50, 
                      wing = 10, 
                      save_files = F)

# Filter for calls and fix start/end
b = d
d$fs = sprintf('%s@%s-%s.wav', d$file, d$start, d$end)
d = d[d$fs %in% measurements$file,]
d[c('start', 'end')] = d[c('start', 'end')]/22050

# Calculate performance
perf = calc.perf(d = d, gt = gt)

# Save results
sink(path_perf)
print(perf)
sink()
