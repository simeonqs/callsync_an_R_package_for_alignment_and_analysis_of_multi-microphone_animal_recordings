# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 22-11-2022
# Date last modified: 19-12-2023
# Author: Simeon Q. Smeele
# Description: This script compares the ground truth tables to the detections. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/00_set_up.R')

# Settings
set.seed(1)

thr_trace = 0.15 # threshold for detection of fundamental (amplitude for lowest value of spectrum)
hop = 5 # hop for tracing
spar = 0.3 # how much to smoothen the trace
freq_lim = c(1.2, 3.5) # in what region (kHz) the fundamental should be found
noise_factor = 1.5 # how much more than the average the peak should be
mc.cores = 6 # how many threads to use in parallel (should be 1 on Windows)

snr = 9 # threshold for colouring calls as noisy

# Load ground truth
gt = load.selection.tables.audacity(path_ground_truth_tables)

# Add little bit before and after for signal to noise
gt$start = gt$start - 0.05
gt$end = gt$end + 0.05

# Load waves from gt - to run tracing and filtering
file_gt = sprintf('%s/%s.wav', path_chunks, gt$file)
waves_gt = lapply(1:nrow(gt), function(i) 
  load.wave(file_gt[i], from = gt$start[i], to = gt$end[i], ffilter_from = 700))
names(waves_gt) = basename(file_gt)

# Detect on the manual selections
detections_gt = lapply(waves_gt, call.detect, 
                       threshold = c(0.3, 0.3), # 0.37, 0.47
                       msmooth = c(700, 95), # 500, 95
                       plot_it = F)

# Extract one call per wave from the manual selections
new_waves = lapply(1:length(waves_gt), 
                   function(i) waves_gt[[i]][detections_gt[[i]]$start:detections_gt[[i]]$end])

# Trace fundamental on manual selections
traces = mclapply(new_waves, function(new_wave)
  trace.fund(new_wave, spar = spar, freq_lim = freq_lim, thr = thr_trace, hop = hop,
             noise_factor = noise_factor), mc.cores = mc.cores)
names(traces) = basename(file_gt)

# Measure on the manual selections
measurements_gt = measure.trace.multiple(traces = traces, 
                                         new_waves = new_waves, 
                                         waves = waves_gt, 
                                         detections = detections_gt,
                                         path_pdf = NULL)

# Select from ground truth based on measurements on manual selections
gb = gt
keep = measurements_gt$prop_missing_trace < 0.1 & 
  measurements_gt$signal_to_noise > 6 &
  measurements_gt$band_hz > 400 &
  measurements_gt$duration_s > 0.1 &    # this is not filtered for the automatic detections, but is included
  measurements_gt$duration_s < 0.3   #      in the detect.and.assign function
gt = gt[keep,]

# Get the associated chunks to run automatic detection
all_files = list.files(path_chunks, pattern = '*wav', full.names = T, recursive = T)
path_ground_truth_chunks = all_files[(((str_detect(all_files, '@120.wav') | str_detect(all_files, '@135.wav') |
                                          str_detect(all_files, '@150.wav')) & 
                                         str_detect(all_files, '2021_07_16-05_54_59'))) |
                                       (str_detect(all_files, '@45.wav') & 
                                          str_detect(all_files, '2022_12_08-07_59_59'))]

# Run detect and assign on ground truth chunks
d = detect.and.assign(all_files = path_ground_truth_chunks,
                      ffilter_from = 1100,
                      threshold = 0.18, # 0.25
                      msmooth = c(1000, 95), 
                      min_dur = 0.1, 
                      max_dur = 0.3,
                      step_size = 1/50, 
                      wing = 10, 
                      save_files = F,
                      save_extra = 0.05)

# Load waves from d - to run tracing and filtering
waves_d = lapply(seq_len(nrow(d)), function(i) 
  load.wave(sprintf('ANALYSIS/RESULTS/chunks/%s.wav', d$file[i]), 
            from = d$start[i]/22050, to = d$end[i]/22050, ffilter_from = 700))
names(waves_d) = basename(d$file)

# Detect on the manual selections
detections_d = lapply(waves_d, call.detect, 
                      threshold = c(0.3, 0.3), # 0.37, 0.47
                      msmooth = c(700, 95), # 500, 95
                      plot_it = F)

# Extract one call per wave from the manual selections
new_waves = lapply(seq_len(length(waves_d)), function(i) 
  waves_d[[i]][detections_d[[i]]$start:detections_d[[i]]$end])

# Trace fundamental on manual selections
traces = mclapply(new_waves, function(new_wave)
  trace.fund(new_wave, spar = spar, freq_lim = freq_lim, thr = thr_trace, hop = hop,
             noise_factor = noise_factor), mc.cores = mc.cores)
names(traces) = names(waves_d)

# Measure on the automatic detections
measurements_d = measure.trace.multiple(traces = traces, 
                                        new_waves = new_waves, 
                                        waves = waves_d, 
                                        detections = detections_d,
                                        path_pdf = NULL)

# Select from automatic detections
b = d
keep = measurements_d$prop_missing_trace < 0.1 & 
  measurements_d$signal_to_noise > 6 &
  measurements_d$band_hz > 400 
d = d[keep,]

# Fix start/end
d[c('start', 'end')] = d[c('start', 'end')]/22050
b[c('start', 'end')] = b[c('start', 'end')]/22050

# Calculate performance
perf = calc.perf(d = d, gt = gt)

calc.perf(d = d, gt = gb)

# Save results
sink(path_perf)
print(perf)
sink()
