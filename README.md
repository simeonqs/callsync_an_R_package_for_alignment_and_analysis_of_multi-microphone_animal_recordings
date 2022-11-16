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
- `plot_it`: if `TRUE`, returns three-panel plot of wave form, envelope and spectrogram to current plotting window. Default is `FALSE`.

## call.detect.multiple

`call.detect.multiple` can be used to detect multiple calls in an R `wave` object. 

Arguments: 

- `wave` (required): a wave object in R. Can be loaded using `load.wave`.
- `threshold`: fraction of maximum of the envelope to use as threshold for start and end. Can be a single numeric value between 0 and 1 or if a vector of two values is supplied, the first is used for start and second for end (in case of echo). Default is `0.3`.
- `msmooth`: used as argument for the `seewave::env` function. *A vector of length 2 to smooth the amplitude envelope with a mean sliding window. The first component is the window length (in number of points). The second component is the overlap between successive windows (in \%).* Default is `c(500, 95)`.
- `min_dur`: the mininum duration in seconds for a detection to be returned. Default is `0.01`.
- `plot_it`: if `TRUE`, returns three-panel plot of wave form, envelope and spectrogram to current plotting window. Default is `FALSE`.

## load.wave

`load.wave` is a wrapper function for the `readWave` function from *tuneR* and includes an optional `ffilter` from *seewave*. 

Arguments:

- `path_audio_file` (required): the path to the audio file that should be loaded. 
- `from`: time in seconds from where to start the loading of the audio file. Default is `0` which loads the whole file.
- `to`: time in seconds until where to load the audio file. Default is `Inf` which loads the whole file. 
- `ffilter_from`: frequency in Hz for the high-pass filter. Default is `NULL`, which does not apply a filter. 

## o.to.m

`o.to.m` can be used to transform a vector into a matrix. It assumes that the vector values are the lower triangular of the matrix: `m[lower.tri(m)] = o`.

Arguments:

- `o` (required): the vector containing the values for the lower triangular.
- `n` (required): the names for the rows and columns of the matrix. 

## simple.cc

`simple.cc` can be used to run cross correlation between two vectors. Both vectors are zero-padded and slid over each other. For each step the difference is computed. The function returns the absolute difference at the point at the minimum (maximal signal overlap). 

Arguments:

- `s1` (required): the first numeric vector.
- `s2` (required): the second numeric vector.
- `norm`: if `TRUE` the final difference is divided by the length of the longest vector.

## sliding.pixel.comparison

`sliding.pixel.comparison` can be used to run spectrographic cross correlation. Both spectrograms are zero-padded and slid over each other. For each step the difference is computed. The function returns the absolute difference at the point at the minimum (maximal signal overlap). 

Arguments:

- `s1` (required): the first spectrogram (matrix).
- `s2` (required): the second numeric spectrogram (matrix).
- `step_size`: how many pixels should be moved for each step. Default is `1`.

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

