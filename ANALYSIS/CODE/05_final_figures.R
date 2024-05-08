# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 17-11-2022
# Date last modified: 13-01-2023
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
all_files = list.files(path_recordings, full.names = T, recursive = T)
all_files = all_files[str_detect(all_files, '2021_07_16-05_54_59')]

# Run main function
chunk_size = 15 
step_size = 0.5
save_pdf = T 
chunk_seq = 60
keys_rec = c('_\\(', '\\)_')
keys_id = c('ASWMUX', '.wav')
blank = 15
wing = 10
ffilter_from = NULL
chunk_list = align(chunk_size = chunk_size,
                   all_files = all_files,
                   step_size = step_size,
                   path_recordings = path_recordings,
                   path_chunks = path_figures, 
                   chunk_seq = chunk_seq,
                   keys_id = keys_id,
                   keys_rec = keys_rec,
                   blank = blank, 
                   wing = wing, 
                   ffilter_from = ffilter_from,
                   save_pdf = save_pdf)
file.rename(path_example_chunk_before, path_example_chunk_after)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Detection and assignment ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# List files for example
all_files = list.files(path_chunks, pattern = '*wav', full.names = T, recursive = T)
all_files = all_files[str_detect(all_files, '2021_07_16-05_54_59@150')]

# Run function
ffilter_from = 1100
threshold = 0.18
msmooth = c(1000, 95)
min_dur = 0.1 
max_dur = 0.3
step_size = 1/50 
wing = 10
keys_id = c('bird_', '_tag')
keys_rec = c('_\\(', '\\)_')
save_files = FALSE
save_extra = 0.05
d = detect.and.assign(all_files = all_files,
                      path_chunks = NULL,
                      path_calls = NULL,
                      ffilter_from = ffilter_from,
                      threshold = threshold, 
                      msmooth = msmooth, 
                      min_dur = min_dur, 
                      max_dur = max_dur,
                      step_size = step_size, 
                      wing = wing, 
                      save_files = save_files) 

# Plot
pdf(path_pdf_example_detections, 10, 5)
par(mfrow = c(6, 1), mar = c(0, 0, 0, 0), oma = c(5, 1, 1, 1))
for(i in 1:length(all_files)){
  plot(readWave(all_files[i], from = 7*60+35, to = 8*60+5, units = 'seconds'), 
       yaxt = 'n', xaxt = 'n', xlab = '')
  bird = all_files[i] |> strsplit('@') |> sapply(`[`, 2)
  sub = d[str_detect(d$file, bird),]
  for(j in 1:nrow(sub)){
    rect(xleft = sub$start[j]/22050-7*60-35-0.1, xright = sub$end[j]/22050-7*60-35+0.1, 
         ybottom = par("usr")[3], ytop = par("usr")[4],
         border = NA, col = alpha('#3a586e', 0.3))
    abline(v = sub$start[j]/22050-7*60-35-0.1, lty = 2, col = '#3a586e', lwd = 2)
    abline(v = sub$end[j]/22050-7*60-35+0.1, lty = 2, col = '#3a586e', lwd = 2)
  }
}
axis(1, cex.axis = 1.5)
mtext('time [s]', 1, 3)
dev.off()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Tracing and spec object ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# List files and load wave
audio_files = list.files('ANALYSIS/RESULTS/calls',  '*wav', full.names = T)
wave = load.wave(audio_files[2], ffilter_from = 500)

# Detect trace
det = call.detect(wave, threshold = c(0.3, 0.3))
trace = trace.fund(wave[det$start:det$end], freq_lim = c(1.2, 3.5), thr = 0.15, spar = 0.3, 
                   noise_factor = 1.5)

# Plot spectrogram and trace
pdf(path_pdf_trace_and_spec_object_example, 7, 3.5)
par(mfrow = c(1, 2), oma = c(3.5, 3.5, 0, 0))
better.spectro(wave, wl = 200, ovl = 190, ylim = c(700, 3500), mar = c(1, 1, 1, 1), 
               cex.axis = 0.01, cex.lab = 0.1)
text(x = 0.04, y = 3250, labels = 'a)', font = 2, cex = 1)
mtext('time [s]', 1, 2.5, cex = 1)
mtext('frequency [Hz]', 2, 2.5, cex = 1)
lines(trace$time + det$start/wave@samp.rate, trace$fund, lwd = 3, col = alpha(3, 0.8))
abline(v = det/wave@samp.rate, lty = 2, lwd = 3, col = alpha(1, 0.8))

spec_object = create.spec.object(wave, freq_range = c(700, 3500),
                                 plot_it = F,
                                 thr_low = 0.45,
                                 thr_high = 0.6,
                                 wl = 256,
                                 ovl = 250,
                                 method = 'max',
                                 sum_one = TRUE)
image(t(spec_object), col = hcl.colors(12, 'Blue-Yellow', rev = T), xaxt = 'n', yaxt = 'n', mar = rep(1, 4)) 
text(x = 0.08, y = 0.92, labels = 'b)', font = 2)
dev.off()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# SPCC ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Load data
load(path_spcc_results)

# Run pco and plot
umap_out = umap(m)
year = rownames(m) %>% strsplit('@') %>% sapply(`[`, 3) %>% 
  strsplit('_') %>% sapply(`[`, 1) %>% as.factor %>% as.integer
pdf(path_pdf_umap, 3.5, 4)
plot(umap_out$layout, pch = as.numeric(year), col = alpha(cols[as.numeric(year)], 0.8),
     xlab = 'Dimension 1', ylab = 'Dimension 2', xaxt = 'n', yaxt = 'n',
     xlim = c(-6, 6), ylim = c(-6.5, 7))
axis(1, c(-6, -3, 0, 3, 6))
axis(2, c(-6, -3, 0, 3, 6))
dev.off()
