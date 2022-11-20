# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 16-11-2022
# Date last modified: 20-11-2022
# Author: Simeon Q. Smeele
# Description: This script runs spectrographic cross correlation on single wav files and constructs a 
# distance matrix based on the output. 
# source('ANALYSIS/CODE/cockatiel_dataset/04_SPCC.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/cockatiel_dataset/00_set_up.R')

# Settings
ffilter_from = 500
freq_range = c(700, 3500)
plot_it = FALSE
thr_low = 0.45
thr_high = 0.6
wl = 256
ovl = 250
method = 'max'
sum_one = TRUE
cols = c('#d11141', '#00b159', '#00aedb', '#f37735', '#ffc425')

# Audio files 
audio_files = list.files(path_calls,  '*wav', full.names = T)

# Filter out contact calls
load(path_measurements)
audio_files = audio_files[basename(audio_files) %in% measurements$file]

# Load waves
waves = lapply(audio_files, load.wave, ffilter_from = ffilter_from)
names(waves) = basename(audio_files)

# Run function
message('Starting spcc...')
m = run.spcc(waves,
             freq_range = freq_range,
             thr_low = thr_low,
             thr_high = thr_high,
             wl = wl,
             ovl = ovl,
             method = method,
             sum_one = sum_one,
             mc.cores = 4)

# Save
save(m, file = path_spcc_results)

# Message
message('Done!')
