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



------------------------------------------------
# Session info

R version 4.1.0 (2021-05-18)

Platform: x86_64-apple-darwin17.0 (64-bit)

Running under: macOS Catalina 10.15.7

Packages: scales_1.1.1, cmdstanr_0.4.0

------------------------------------------------
# Maintainers and contact

Please contact Simeon Q. Smeele, <ssmeele@ab.mpg.de>, if you have any questions or suggestions. 

