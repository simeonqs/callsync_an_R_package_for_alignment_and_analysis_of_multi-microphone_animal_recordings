# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: methods paper
# Date started: 14-11-2022
# Date last modified: 23-11-2022
# Author: Simeon Q. Smeele
# Description: This script sets up the R environment for all other scripts. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('seewave', 'tuneR', 'stringr', 'dplyr', 'scales', 'callsync', 'parallel')
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
path_pdf_pco = 'ANALYSIS/RESULTS/figures/pco.pdf'
path_pdf_alignment_example = 'ANALYSIS/RESULTS/figures/alignment example.pdf'
path_pdf_example_detections = 'ANALYSIS/RESULTS/figures/detections example.pdf'
path_pdf_spec_object_example = 'ANALYSIS/RESULTS/figures/spec_object example.pdf'
path_pdf_trace_example = 'ANALYSIS/RESULTS/figures/trace example.pdf'
path_ground_truth_tables = 'ANALYSIS/DATA'
path_ground_truth_chunks = '~/ownCloud/Shared Stephen - Simeon/ground_truth'

# Colours
cols = c('#d11141', '#00b159', '#00aedb', '#f37735', '#ffc425')
