# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 16-11-2022
# Date last modified: 16-11-2022
# Author: Simeon Q. Smeele
# Description: This script runs spectrographic cross correlation on single wav files and constructs a 
# distance matrix based on the output. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('tidyverse', 'warbleR', 'oce', 'signal', 'parallel', 'umap')
for(i in libraries){
  if(! i %in% installed.packages()) lapply(i, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list=ls()) 

# Paths
source('ANALYSIS/CODE/cockatiel_dataset/00_paths.R')

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Audio files 
audio_files = list.files(path_calls,  '*wav', full.names = T)

# Filter out contact calls
load(path_measurements)
audio_files = audio_files[basename(audio_files) %in% measurements$file]

# Generate spec_ojects
spec_objects = sapply(1:length(audio_files), function(i){
  file = audio_files[i]
  wave = readWave(file)
  wave = ffilter(wave, from = 700, output = 'Wave')
  spec_object = cutted.spectro(wave, freq_range = c(700, 3500), plot_it = F, 
                               thr_low = 0.45, thr_high = 0.6, wl = 256, ovl = 250,
                               method = 'max',
                               sum_one = T)
})

# Test examples
#image(t(spec_objects[[1]]), col = hcl.colors(12, 'Blue-Yellow', rev = T)) 

# Plot all
pdf(path_pdf_spec_objects, 6, 3)
par(mfrow = c(1, 2))
for(i in 1:length(audio_files)){
  better.spectro(readWave(audio_files[i]) %>% ffilter(from = 700, output = 'Wave'), 
                 main = audio_files[i], wl = 256, ovl = 250)
  image(t(spec_objects[[i]]), col = hcl.colors(12, 'Blue-Yellow', rev = T)) 
} 
dev.off()

# Get combinations and run function
c = combn(1:length(spec_objects), 2)
o = mclapply(1:ncol(c), function(i)
  sliding.pixel.comparison(spec_objects[[c[1,i]]], spec_objects[[c[2,i]]], step_size = 10),
             mc.cores = 4) %>% unlist
o = o/max(o)
m = o.to.m(o, str_remove(basename(audio_files), '.wav'))
save(m, file = path_m)

# Message
message('Done!')
