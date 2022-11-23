# Overview

This repo is associated with the following article: 

```
reference
```

------------------------------------------------
# Requirements

R version 4.1.0 or later. Earlier versions might work if you replace the `|>` function with `%>%`.

Required packages are loaded in the `ANALYSIS/CODE/00_set_up.R` script.

------------------------------------------------
# Workflow

The DATA and RESULTS folders need to be downloaded from the Edmond repository (**LINK**). Once these are place in the ANALYSIS folder everything should work.

Make sure your working directory is the main repo folder. This is automatically the case if you open the `.Rproj` file and run everything from there.

All steps can be sourced individually using the source botton in R Studio or by just running all the lines. `ANALYSIS/CODE/00_set_up.R` gets sourced from within all other scripts and takes care of the set-up. If you want to run the full pipeline you can also run:

```
files = list.files('ANALYSIS/CODE', pattern = '*R', full.names = T)
for(file in files) source(file)
```

This will source all scripts in the correct order. Some of the steps do take several hours, so it might be better to run steps individually at first. 

------------------------------------------------
# Meta data

The DATA and RESULTS folders need to be downloaded from the Edmond repository (**LINK**). Once these are place in the ANALYSIS folder everything should work.

All analysis related files are in `ANALYSIS`.

All scripts are in `ANALYSIS/CODE`:

- bibliography.bib
  - contains all the reference in bibtex format
  
- manuscript.md
  - contains the manuscript in markdown format
  
- manuscript.pdf
  - unfortunately RStudio outputs the pdf of from the markdown here as well
  
- 00_set_up.R
  - installs libraries if not already installed
  - loads libraries
  - cleans all objects from the global environment
  - loads all paths as objects
  - loads custom colours
  
- 01_major_alignment.R
  - runs the `align` function to load the raw data, and write aligned segments/chunks to the `ANALYSIS/RESULTS/chunks` folder

- 02_call_detection_and_asignment.R
  - runs the `detect.and.assign` function to load the chunks of the previous steps, detect calls, filter out the calls from the focal individual for each chunk and save the calls as seperate files in the `ANALYSIS/RESULTS/calls` folder

- 03_trace_fundamental.R




------------------------------------------------
# Session info

R version 4.1.0 (2021-05-18)

Platform: x86_64-apple-darwin17.0 (64-bit)

Running under: macOS Catalina 10.15.7

Packages: scales_1.1.1, cmdstanr_0.4.0

------------------------------------------------
# Maintainers and contact

Please contact Simeon Q. Smeele, <ssmeele@ab.mpg.de>, if you have any questions or suggestions. 

