# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 19-12-2023
# Author: Simeon Q. Smeele
# Description: This script sets up the R environment for all other scripts. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('seewave', 'tuneR', 'stringr', 'dplyr', 'scales', 'callsync', 'parallel', 'umap')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list = ls()) 

# Paths to be used by other scripts
path_functions = 'ANALYSIS/CODE/functions'
path_recordings = 'ANALYSIS/DATA'
path_chunks = 'ANALYSIS/RESULTS/chunks'
path_calls = 'ANALYSIS/RESULTS/calls'
path_traces = 'ANALYSIS/RESULTS/traces/traces.RData'
path_measurements = 'ANALYSIS/RESULTS/traces/measurements.RData'
path_pdf_traces = 'ANALYSIS/RESULTS/traces/traces.pdf'
path_pdf_samples_filtering = 'ANALYSIS/RESULTS/traces/samples filtering.pdf'
path_pdf_samples_spec_objects = 'ANALYSIS/RESULTS/SPCC/samples spec_objects.pdf'
path_spcc_results = 'ANALYSIS/RESULTS/SPCC/spcc_results.RData'
path_pdf_umap = 'ANALYSIS/RESULTS/figures/umap.pdf'
path_figures = 'ANALYSIS/RESULTS/figures'
path_example_chunk_before = 
  'ANALYSIS/RESULTS/figures/p4_c7_bird_01_bg_060_tag_07_file_4_(2021_07_16-05_54_59)_ASWMUX221163.pdf'
path_example_chunk_after = 'ANALYSIS/RESULTS/figures/alignment example.pdf'
path_pdf_example_detections = 'ANALYSIS/RESULTS/figures/detections example.pdf'
path_pdf_trace_and_spec_object_example = 'ANALYSIS/RESULTS/figures/spec_object and trace example.pdf'
path_ground_truth_tables = 'ANALYSIS/DATA'
path_perf = 'ANALYSIS/RESULTS/perfomance/performance.txt'
  
# Colours
cols = c('#d11141', '#00aedb', '#00b159', '#f37735', '#ffc425')
