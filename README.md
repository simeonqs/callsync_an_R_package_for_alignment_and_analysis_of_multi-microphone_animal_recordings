# Overview

This repo is associated with the following article: 

```
*callsync*: an R package for alignment and analysis of multi-microphone animal recordings
Simeon Q. Smeele, Stephen A. Tyndel, Barbara C. Klump, Gustavo Alarcon-Nieto, Lucy M. Aplin
bioRxiv 2023.02.07.527470; doi: https://doi.org/10.1101/2023.02.07.527470
```

The source code of *callsync* can be found in [this repository](https://github.com/simeonqs/callsync).


# Requirements

R version 4.1.0 or later. Earlier versions might work if you replace the `|>` function with `%>%`.

Required packages are loaded in the `ANALYSIS/CODE/00_set_up.R` script.

The GitHub repository is not complete. Data files and intermediate results are too large and are shared on Edmond. If you want to reproduce the results download the data here (<https://edmond.mpdl.mpg.de/privateurl.xhtml?token=05b4aa17-a9bd-44ac-b62b-bdf620aceebb>). If you want to run on your own data create the following directories:

* `ANALYSIS/DATA` with the data (can be any subdirectory structure within)
* `ANALYSIS/RESULTS/calls`
* `ANALYSIS/RESULTS/chunks`
* `ANALYSIS/RESULTS/figures`
* `ANALYSIS/RESULTS/performance`
* `ANALYSIS/RESULTS/SPCC`
* `ANALYSIS/RESULTS/traces`


# Workflow

The `DATA` and `RESULTS` folders need to be downloaded from the Edmond repository (<https://edmond.mpdl.mpg.de/privateurl.xhtml?token=05b4aa17-a9bd-44ac-b62b-bdf620aceebb>). Once these are place in the `ANALYSIS` folder everything should work.

Make sure your working directory is the main repo folder. This is automatically the case if you open the `project.Rproj` file and run everything from there.

All steps can be sourced individually using the source button in RStudio or by just running all the lines. `ANALYSIS/CODE/00_set_up.R` gets sourced from within all other scripts and takes care of the set-up. If you want to run the full pipeline you can also run:

```
files = list.files('ANALYSIS/CODE', pattern = '*R', full.names = T)
for(file in files) source(file)
```

This will source all scripts in the correct order. Some of the steps do take several hours, so it might be better to run steps individually at first. 


# Meta data

The `DATA` and `RESULTS` folders need to be downloaded from the Edmond repository (**LINK**). Once these are place in the `ANALYSIS` folder everything should work.

All analysis related files are in `ANALYSIS`.

All scripts are in `ANALYSIS/CODE`:
  
- `00_set_up.R`
  - installs libraries if not already installed
  - loads libraries
  - cleans all objects from the global environment
  - loads all paths as objects
  - loads custom colours
  
- `01_major_alignment.R` runs the `align` function to load the raw data, and write aligned segments/chunks to the `ANALYSIS/RESULTS/chunks` folder

- `02_call_detection_and_assignment.R` runs the `detect.and.assign` function to load the chunks of the previous steps, detect calls, filter out the calls from the focal individual for each chunk and save the calls as seperate files in the `ANALYSIS/RESULTS/calls` folder

- `03_trace_fundamental.R`
  - loads the calls using the `load.wave` function
  - detect start and end times more precisely using the `call.detect` function
  - traces the fundamental frequency using the `trace.fund` function
  - takes several measurements on the traces using the `measure.trace.multiple` function
  - filters out noise based on the measurements
  - saves the traces and measurements to the `ANALYSIS/RESULTS/traces` folder

- `04_SPCC.R`
  - reloads the calls that appear in the measurements (filtered for noise)
  - runs spectrographic cross correlation using the `run.spcc` function
  - saves the resulting distance matrix in the `ANALYSIS/RESULTS/SPCC` folder

- `05_final_figures.R` plots the figures used in the manuscript

- `06_performance.R`
  - reruns `detect.and.assign` on a few chunks
  - loads the ground truth using the `load.selection.tables.audacity` function
  - calculates the performance using the `calc.perf` function
  - prints the results to the `ANALYSIS/RESULTS/performance` folder
  
All data is in `ANALYSIS/DATA`:

- `July_15` and `July_16` contain the raw recordings
  - filenames in the folder are of the format: group_bird_xx_irrelevant_info_(date-time)_micid.wav
  
- `ground_truth_xxx_labels.txt` are the ground truth tables from Audacity
  - odd numbered rows contain: start time (s) - end time (s) - file name
  - even numbered rows contain irrelevant information and are discarded when read with the function `load.selection.tables.audacity`
  
All results can be found in `ANALYSIS/RESULTS`:

- `calls` contains the pdfs with call detections and wav files with individual calls (and also noise)

- `chunks` contains the pdfs with alignment and the individual chunks

- `figures` contains the final figures for the manuscript

- `performance` contains a txt with the performance output

- `SPCC` contains the results from spectrographic cross correlation

- `traces` contains the results of the tracing and measurement steps
  
Other than the `ANALYSIS` folder the main folder also contains:

- `bibliography.bib` contains all the reference in bibtex format
  
- `manuscript.md` contains the manuscript in markdown format, if opened in GitHub the formatting isn't working, should be compiled in RStudio to produce the pdf
  
- `manuscript.pdf` the manuscript as pdf

- `README.md` the file you are reading now, should explain everything you need to know

- `project.Rproj` open a new R Project from which all code can be run
  
- `.gitignore` text file that contains all paths of files/folders that should not be tracked by git, these are `DATA` and `RESULTS` and some hidden files


# Session info

R version 4.2.1 (2022-06-23)

Platform: x86_64-apple-darwin17.0 (64-bit)

Running under: macOS Catalina 10.15.7

Packages: parallel,  stats, graphic, grDevice, utils, datasets, methods, base, callsync_0.0.5, scales_1.2.1, dplyr_1.0.10, stringr_1.4.1, tuneR_1.4.1, seewave_2.2.0 


# Maintainers and contact

Please contact Simeon Q. Smeele, <ssmeele@ab.mpg.de>, if you have any questions or suggestions. 

