---
output:
  pdf_document: 
    latex_engine: xelatex
geometry: margin=2cm
header-includes:
  \usepackage{fontspec}
  \setmainfont{Helvetica}
  \usepackage[symbol]{footmisc}
  \renewcommand{\thefootnote}{\fnsymbol{footnote}}
  \renewcommand{\topfraction}{.85}
  \renewcommand{\bottomfraction}{.7}
  \renewcommand{\textfraction}{.15}
  \renewcommand{\floatpagefraction}{.66}
  \setcounter{topnumber}{3}
  \setcounter{bottomnumber}{3}
  \setcounter{totalnumber}{4}
  \usepackage[labelfont={footnotesize,bf},textfont=footnotesize]{caption}
---

\fontsize{20}{12}\selectfont

APPLICATION

\fontsize{8}{8}\selectfont

\

\fontsize{24}{12}\selectfont

\textbf{\textcolor{purple}{Analysis of backpack microphone recordings using \textit{callsync}}}

\fontsize{10}{12}\selectfont

\

Simeon Q. Smeele $^{1,2,3,†,*}$, Stephen A. Tyndel $^{1,3,†}$, Barbara C. Klump $^{1}$, Mary Brooke McElreath $^{1,2}$, Gustavo Alarcon-Nieto $^{1,3}$ & Lucy M. Aplin $^{1,3,4}$

\fontsize{7}{12}\selectfont

$^1$*Cognitive & Cultural Ecology Research Group, Max Planck Institute of Animal Behavior, Radolfzell, Germany*

$^2$*Department of Human Behavior, Ecology and Culture, Max Planck Institute for Evolutionary Anthropology, Leipzig, Germany*

$^3$*Department of Biology, University of Konstanz, Konstanz, Germany*

$^4$*Division of Ecology and Evolution, Research School of Biology, The Australian National University, Canberra, Australia*

$^†$Co-first author

$^*$Correspondence author. E-mail: <ssmeele@ab.mpg.de>

\fontsize{9}{12}\selectfont


------------------------------------------------------------------------

# Summary

1.  To better understand how vocalisations are used during interactions of multiple individuals captive studies with microphones on the animal are often performed. The resulting recordings are challenging to analyse, since microphones drift and record the vocalisations of non-focal individuals as well as noise.

2.  Here we present audioID, an R package designed to align recordings, detect and assign vocalisations, filter out noise and perform basic analysis on the resulting clips.

3.  We present a case study where the pipeline is used for a new dataset of captive cockatiels. We show that xx calls can be detected and assigned across yy hours of recording. We use the resulting calls to show that individuals can be recognised based on xx, xx, xx features.

4.  The audioID can be used to go from raw recordings to a cleaned dataset of features. The package is designed to be modular and allow users to replace functions as they wish. We also discuss the challenges that might be faced in each step and how the available literature can provide alternatives for each step.


**Keywords:** something about sound, other stuff about sound

# Introduction

The study of vocal signals in animals is a critical tool for understanding the evolution of vocal communication. Recent innovations in on-animal recording technologies have allowed for a dramatic increase of fine scale bioacoustic data collection and research (cite many papers). Studying the ways that animals communicate in ‘real time’ allows us to untangle the complicated dynamics of how group members signal one another (zefi and whale work). These communication networks can help us understand how animals coordinate call response with movement (ari) as well as how group signatures form (budgies). However, as the capability of placing small recording devices on animals increases, so too does the need for tools to process the resulting data streams. Several publicly available R packages exist that measure acoustic parameters from single audio tracks (Seewave, TuneR, WarbleR), but to our knowledge, none address the critical issue of microphone clock drift and the ability to align and process multiple recordings. This poses a serious issue for those studying communication networks of multiple tagged individuals. In this paper, we apply a new R package, callsync, that aligns multiple misaligned audio files, detects vocalisations, assigns these to the focal individual and provides an analytical pipeline for the resulting synchronised data. 

The primary target for use of this package are researchers that study animal communication systems within groups. The critical issue is that multiple microphones recording simultaneously can drift apart in time (citation). To make matters worse this drift is often non-linear (cite examples). Thus, if several microphone recorders (list examples of bats, etc) are placed on animals, it is critical for researchers to be able to line up all tracks so that calls can be assigned correctly to the focal individual (loudest track). The main functionality of callsync is to align audio tracks, detect calls from each track, determine which individual (even ones in relatively close proximity to one another) is vocalising and segment them, as well as take measurements of the given calls (see Figure X). However, callsync takes a modular approach to aligning, segmenting, and analysing audio tracks so that researchers can use only the components of the package that suit their needs. 

![Flowchart from the `callsync` package. The *alignment* module can be used to align multiple microphones that have non-linear temporal drift. The *detection* module can be used to detect vocalisations in each recording. The *assignment* module can be used to assign a vocalisation to the focal individual, making sure that vocalisations from conspecifics are excluded from the focal recording. The *tracing* module can be used to trace and analyse the fundamental frequency for each vocalisation. Filters can be applied to remove false alarms in the detection module. The final *analysis* module can be used to run spectrographic cross correlation and create a feature vector to compare across recordings.]("../RESULTS/figures/flowchart.pdf")

Current research packages that implement call alignment strategies are either used in matlab (citation), c++ (citation) or python (citation). However these tools have not, up to now, been adapted for the R environment. Many of these tools are not documented publicly (citation) nor open source, and can require high licensing fees (i.e Matlab). While the design of this package is best suited to contexts where all microphones exist in the same spatial area, it is the goal that it can be adapted to more difficult contexts. This package is publicly available on github (cite),is beginner friendly with strong documentation, and does not require extensive programming background. This open source tool will allow researchers to expand the study of bioacoustics and solve an issue that impedes detailed analysis of group-level calls. We will provide a case study and workflow that will demonstrate the use of this package. blah blah blah. 

# Case study: cockatiel contact calls

We present a case study to show how `callsync` functions can be included in a workflow (see Figure X). We used a dataset of domestic cockatiels (*Nymphicus hollandicus*). These birds are a part of an ongoing study at the Max Planck Institute of Animal Behavior. Birds were housed in several groups of six individuals in a 4x3x2.7m aviary facility. We equipped six cockatiels with a TS-systems EDIC-Mini E77 tag inside a sewn nylon backpack fitted via Teflon harness around the wings, with the total weight of all components under 7% of body weight. Audio recordings were scheduled to record for a maximum of 4 hours per day. Each microphone was automatically programmed to turn on and off daily at the same time. For the purposes of demonstration, two full days of recordings (3.5 hours each) were selected for processing where the microphones were scheduled to record from 7:30 until 11:30 in the morning. After several days of deployment, microphone recorders are removed and downloaded as .wav files directly onto the computer from the tag. These tags are placed into the appropriate folder (see workflow instructions) and processed in accordance with our package workflow. 

## Installation and set-up

## Alignment of raw recordings

Raw recordings consist of 3.5 hour long wav files for six cockatiels for each day. We included two days of data in this case study. The backpack microphones have internal clocks that automatically turn them on and off. However, these clocks drift in time both during the off period, creating start times that differ up to a few minutes, and during the recording period, creating additional variable drift up to a minute between recordings. The first step is therefore to align 15 minute chunks of recording to ensure that drift is reduced to mere seconds.

The function `align` can be used for this. It splits the recordings up into shorter chunks, in our case 15 minutes. It aligns all recordings relative to one of the recordings using cross correlation on the energy content (summed absolute amplitude) per time bin, in our case 0.5 seconds.

``` r
align(chunk_size = 15, # minutes
      step_size = 0.5, # seconds
      path_folders = 'ANALYSIS/DATA',
      path_chunks = 'ANALYSIS/RESULTS/chunks', 
      keys_rec = c('_\\(', '\\)_'),
      keys_id = c('bird_', '_tag'),
      blank = 15, # minutes
      wing = 10, # minutes
      save_pdf = TRUE)
```

For cross correlation we load the chunks with additional minutes before and after (option `wing`) to ensure that overlap can be found. The cross correlation is performed using the function `simple.cc`, which takes two vectors (the binned energy content of two recordings) and calculates the absolute difference while sliding the two vectors over each other. It returns the position of minimum summed difference, or in other words the position of maximal overlap. This position is then used to align the recordings relative to the first recording and save chunks that are maximally aligned. Note that due to drift during the recording, the start and end times might still be seconds off; it is the overall alignment of the chunk that is optimised. 

The function also allows the user to create a pdf with wave forms per individual and a single page per chunk, to visually verify if alignment was successful. To illustrate the alignment we ran the function on two minute chunks and plottet the aligned wave forms for two individuals in Figure X.

For our dataset all chunks correctly aligned without filter. If this is not the case the option `ffilter_from` can be set to apply a highpass filter. Chunks can also be rerun individually using the option `chunk_seq`.

![Example of two aligned waveforms (black). The grey waveform in the background is before alignment.]("../RESULTS/figures/alignment example.pdf")

## Call detection and assignment

The next step is to detect calls and assign them to the correct individual.

For detection we load the chunks using the wrapper function `load.wave` where we apply a high-pass filter from 1100 Hz. To detect calls we used the `call.detect.multiple` which can detect multiple calls in an R wave object. It first applies the `env` function from the *seewave* package with `msmooth = c(1000, 95)` create a smooth Hilbert amplitude envelope. It then detects all the points on the envelope which are above a certain threshold relative to the maximum of the envelope. After removing detections that are shorter than a set minimum duration it returns all the start and end times as a dataframe.

Because the microphones on non-focal individuals are very likely to record the calls of the vocalising individual as well, we implemented a step that assigns the detected calls to the correct individual. This step runs through all the detections in a given chunk for a given individual and runs the `call.detect` function to more precisely determine the start and end time of the call. It then aligns this call with all the recordings of all other individuals by rerunning the `simple.cc` function to ensure that minor temporal drift is corrected. After alignment it calculates the summed absolute energy content for the time frame when the call was detected on all recordings and compares this to the focal recording. If the focal recording is the loudest, the detection is saved as a separate wav file. If not, the detection is discarded.

## Analysis of single calls and call comparison

To analyse the calls, the short wav clips were loaded and the `call.detect` function was rerun to determine the start and end times of the call. The wave objects were then resized to only include the call. To trace the fundamental frequency we applied the `trace.fund` function to the resized wave objects:

``` r
traces = mclapply(new_waves, function(new_wave)
  trace.fund(new_wave, spar = spar, freq_lim = freq_lim, thr = thr_trace, hop = hop,
             noise_factor = noise_factor), mc.cores = mc.cores)
```

We used the `mclapply` function from *parallel* to run multiple tracings in parallel. We then used `measure.trace.multiple` to take basic measurements on the resulting trace:

``` r
measurements = measure.trace.multiple(traces, new_waves, waves, snr = snr, 
                                      path_pdf = path_pdf_traces)
```

An example of the resulting trace can be seen in Figure X. 

![Spectrogram of a cockatiel call with start and end (black dashed lines) and the fundamental frequency trace (green solid line).]("../RESULTS/figures/trace example.pdf")

The call detection step also picks up on a lot of noise (birds scratching, flying, walking around) as well as calls. We therefore ran a final step to filter the measurements and traces before these were saved:

``` r
keep = measurements$prop_missing_trace < 0.1 & 
  measurements$signal_to_noise > 5 &
  measurements$band_hz > 600 & 
  measurements$duration_s > 0.10 & measurements$duration_s < 0.3
measurements = measurements[keep,]
traces = traces[keep]
```

Another way to analyse calls is to measure their similarity directly. A frequently used method is spectrographic cross correlation (SPCC), where two spectrograms are slid over each other and the pixelwise difference is computed for each step. At the point where the signals maximally overlap one will find the minimal difference. This score is than used as a measure of acoustic distance between two calls. The function `xxx` runs SPCC and includes several methods to reduce noise in the spectrogram before running cross correlation (for an example see Figure X). 

![Example spectrogram (left) and noise reduced spectrogram (right) of a cockatiel call. Darker colours indicate higher intensity.]("../RESULTS/figures/spec_object example.pdf")

To visualise the resulting of SPCC on the cockatiel calls we used principle coordinate analysis, and plotted the first two coordinates in Figure X. 

![Call distribution in PCO space. Dots represents calls and are coloured by individual.]("../RESULTS/figures/pco.pdf")

# Discussion

# Acknowledgements

# Data accessibility


