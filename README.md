# Overview

This repo is associated with the following article: 

```
Smeele, S. Q., Tyndel, S. A., Klump,B. C., Alarcón-Nieto, G., & Aplin, L. M. (2024). callsync: An Rpackage for alignment and analysis of multi-microphoneanimal recordings. Ecology and Evolution, 14, e11384. https://doi.org/10.1002/ece3.11384
```

The source code of *callsync* and a vignette can be found in [this repository](https://github.com/simeonqs/callsync).


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

- `July_15`, `July_16`, `2022` contain the raw recordings
  - filenames in the folder are of the format: group_bird_xx_irrelevant_info_(date-time)_micid.wav
  
- `xxx_labels.txt` are the ground truth tables from Audacity
  - odd numbered rows contain: start time (s) - end time (s) - file name
  - even numbered rows contain irrelevant information and are discarded when read with the function `load.selection.tables.audacity`
  
All results can be found in `ANALYSIS/RESULTS`:

- `calls` contains the pdfs with call detections and wav files with individual calls (and also noise)

- `chunks` contains the pdfs with alignment, the individual chunks and a log file recording the alignment. The log file has the following columns:
  - `rec` contains the recording key
  - `file` contains the relative path to the file
  - `chunk` contains the start time within the raw recording that was used to align all other chunks (minutes)
  - `from` contains the start time within this raw recording (minutes)
  - `to` contains the end time within this raw recording (minutes)
  - `offset` contains the difference between this chunk and the chunk that was used to align (difference between `from` and `chunk`)

- `figures` contains the final figures for the manuscript and some log files generated by `callsync` when plotting the figures that have no relevance for the manuscript

- `performance` contains a txt with the performance output:
    - `tp` are the rownumbers (in the detection output) for the true positives
    - `fp` are the rownumbers (in the detection output) for the false positives
    - `fn` are the rownumber (in the ground truth) for the false negatives
    - `fp_rate` is the false positive rate (number false positives devided by all detections)
    - `tp_rate` is the true positive rate (number true positives devided by all detections)
    - `fn_rate` is the false negative rate (number false negatives devided by all ground truths)

- `SPCC/spcc_results.RData` contains the results from spectrographic cross correlation, when loaded the environment contains a named matrix `m` with rownames and columnnames being the file names of the small wav file in `calls` and the entries being the acoustic distances between calls

- `traces` contains the results of the tracing and measurement steps, when loaded the environment contains a named list with names being the file names of the small wav file in `calls` and each item in the list being a data.frame with the following structure:
    - `time` contains the time in seconds
    - `fund` contains the fundamental frequency in Hz
    - `missing` contains a bolean stating whether or not that value was imputed (TRUE) or not (FALSE)
  
Other than the `ANALYSIS` folder the main folder also contains:

- `bibliography.bib` contains all the reference in bibtex format

- `license.md` contains the copy right information in markdown format
  
- `manuscript.md` contains the manuscript in markdown format, if opened in GitHub the formatting isn't working, should be compiled in RStudio to produce the pdf
  
- `manuscript.pdf` the manuscript as pdf

- `manuscript.docx` the manuscript as Word document

- `README.md` the file you are reading now, should explain everything you need to know

- `project.Rproj` open a new R Project from which all code can be run
  
- `.gitignore` text file that contains all paths of files/folders that should not be tracked by git, these are `DATA` and `RESULTS` and some hidden files


# Session info

R version 4.3.0 (2023-04-21)

Platform: x86_64-apple-darwin20 (64-bit)

Running under: macOS Monterey 12.3.1

Packages: parallel,  stats, graphic, grDevice, utils, datasets, methods, base, umap_0.2.10.0, callsync_0.1.0 scales_1.2.1, dplyr_1.1.3, stringr_1.5.0, tuneR_1.4.5, seewave_2.2.2 


# Maintainers and contact

Please contact Simeon Q. Smeele, <simeonqs@hotmail.com>, if you have any questions or suggestions. 

