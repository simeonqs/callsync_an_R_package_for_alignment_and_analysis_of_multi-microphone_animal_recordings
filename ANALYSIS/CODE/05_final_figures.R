# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 17-11-2022
# Date last modified: 20-11-2022
# Author: Simeon Q. Smeele
# Description: This script plot the final figures for the paper. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Set-up ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Set-up
source('ANALYSIS/CODE/00_set_up.R')

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Major alignment ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Subset to one set of files
all_files = list.files(path_folders, full.names = T, recursive = T)
all_files = all_files[str_detect(all_files, '2022_11_10-07_29_59')][c(1, 2)]

# Run main function
chunk_list = align(chunk_size = 2,
                   all_files = all_files,
                   step_size = 0.5,
                   path_recordings = NULL,
                   path_chunks = NULL, 
                   keys_rec = c('_\\(', '\\)_'),
                   keys_id = c('bird_', '_tag'),
                   blank = 15,
                   wing = 10,
                   save_pdf = FALSE)

# Plot
pdf(path_pdf_alignment_example, 10, 5)
par(mfrow = c(2, 1), mar = c(0, 0, 0, 0), oma = c(5, 1, 1, 1))
plot(chunk_list$`file_4_(2022_11_10-07_29_59)_ASWMUX209133@01@2022_11_10-07_29_59@75`,
     xaxt = 'n', yaxt = 'n', xlim = c(0, 60))
plot(readWave(all_files[2], from = 75, to = 76, units = 'minutes'),
     col = 'grey', yaxt = 'n', cex.axis = 1)
mtext('time [s]', 1, 3, cex = 1)
par(new=TRUE)
plot(chunk_list$`file_4_(2022_11_10-07_29_59)_ASWMUX209139@02@2022_11_10-07_29_59@75`,
     xaxt = 'n', yaxt = 'n', bty = 'n', xlim = c(0, 60))
dev.off()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Detection and assignment ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# List files and detect recording IDs
all_files = list.files(path_chunks, pattern = '*wav', full.names = T, recursive = T)
all_files = all_files[str_detect(all_files, '2022_11_10-07_29_59@75')][1:2]

# Run function
detections = detect.and.assign(ffilter_from = 1100,
                               threshold = 0.4, 
                               msmooth = c(1000, 95) , 
                               min_dur = 0.1,
                               max_dur = 0.3,
                               step_size = 1/50,
                               wings = 10,
                               all_files = all_files,
                               save_files = FALSE)
detections$start = detections$start - 0.1*22050
detections$end = detections$end + 0.1*22050

# Plot
pdf(path_pdf_example_detections, 10, 5)
par(mfrow = c(2, 1), mar = c(0, 0, 0, 0), oma = c(5, 5, 1, 1))

plot(readWave(all_files[1], from = 0, to = 2, units = 'minutes'), xaxt = 'n', xlab = '')
sub = detections[str_detect(detections$file, '@06@'),]
abline(v = sub$start/22050, lty = 2, col = 'green', lwd = 2)
abline(v = sub$end/22050, lty = 2, col = 'green', lwd = 2)
for(i in 1:nrow(sub)) 
  rect(xleft = sub$start[i]/22050, xright = sub$end[i]/22050, 
       ybottom = par("usr")[3], ytop = par("usr")[4],
       border = NA, col = alpha('green', 0.3))

plot(readWave(all_files[2], from = 0, to = 2, units = 'minutes'))
sub = detections[str_detect(detections$file, '@03@'),]
abline(v = sub$start/22050, lty = 2, col = 'green', lwd = 2)
abline(v = sub$end/22050, lty = 2, col = 'green', lwd = 2)
for(i in 1:nrow(sub)) 
  rect(xleft = sub$start[i]/22050, xright = sub$end[i]/22050, 
       ybottom = par("usr")[3], ytop = par("usr")[4],
       border = NA, col = alpha('green', 0.3))

dev.off()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Tracing ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# List files and load wave
all_files = list.files(path_calls, pattern = '*wav', full.names = T, recursive = T)
wave = load.wave(all_files[2])

# Detect trace
det = call.detect(wave, threshold = c(0.37, 0.47))
trace = trace.fund(wave[det$start:det$end], freq_lim = c(1.2, 3.5), thr = 0.15, spar = 0.3, 
                   noise_factor = 1.5)

# Plot spectrogram and trace
pdf(path_pdf_trace_example, 4, 4)
better.spectro(wave, wl = 200, ovl = 190, ylim = c(700, 3500), mar = c(4, 4, 2, 1))
lines(trace$time + det$start/wave@samp.rate, trace$fund, lwd = 3, col = alpha(3, 0.8))
abline(v = det/wave@samp.rate, lty = 2, lwd = 3, col = alpha(1, 0.8))
dev.off()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Spec object ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Load wave
audio_files = list.files('ANALYSIS/RESULTS/ARCHIVE/calls',  '*wav', full.names = T)
wave = load.wave(audio_files[13], ffilter_from = 500)

# Plot
pdf(path_pdf_spec_object_example, 8, 4)
par(mfrow = c(1, 2), oma = c(4, 4, 1, 1))
better.spectro(wave, wl = 256, ovl = 250, ylim = c(700, 3500), mar = rep(1, 4))
mtext('time [s]', 1, 3)
mtext('frequency [Hz]', 2, 3)
spec_object = create.spec.object(wave, freq_range = c(700, 3500),
                                 plot_it = F,
                                 thr_low = 0.45,
                                 thr_high = 0.6,
                                 wl = 256,
                                 ovl = 250,
                                 method = 'max',
                                 sum_one = TRUE)
image(t(spec_object), col = hcl.colors(12, 'Blue-Yellow', rev = T), xaxt = 'n', yaxt = 'n', mar = rep(1, 4)) 
dev.off()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# SPCC ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Load data
load(path_spcc_results)

# Run pco and plot
pco_out = pcoa(m)
inds = rownames(m) %>% strsplit('@') %>% sapply(`[`, 2)
pdf(path_pdf_pco, 4, 4)
plot(pco_out$vectors[,1:2], pch = 16, col = cols[as.numeric(inds)],
     xlab = 'dimension 1', ylab = 'dimension 2')
dev.off()
