# Overview

This repo is associated with the following article: 

```
reference
```



------------------------------------------------

# Requirements

------------------------------------------------

# Functions

## call.detect

`call.detect.R` can be used to detect a single call in an R `wave` object. 

Arguments: 

- `wave` (required): a wave object in R. Can be loaded using `load.wave`.
- `threshold`: fraction of maximum of the envelope to use as threshold for start and end. Can be a single numeric value between 0 and 1 or if a vector of two values is supplied, the first is used for start and second for end (in case of echo). Default is `0.3`.
- `msmooth`: used as argument for the `seewave::env` function. 'A vector of length 2 to smooth the amplitude envelope with a mean sliding window. The first component is the window length (in number of points). The second component is the overlap between successive windows (in \%).' Default is `c(500, 95)`.


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

