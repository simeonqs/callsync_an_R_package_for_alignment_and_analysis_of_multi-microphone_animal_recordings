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
bibliography: bibliography.bib
---

\fontsize{20}{12}\selectfont

APPLICATION

\fontsize{8}{8}\selectfont

\

\fontsize{24}{12}\selectfont

\textbf{\textcolor{purple}{Analysis of backpack microphone recordings using \textit{callsync}}}

\fontsize{10}{12}\selectfont

\

Simeon Q. Smeele $^{1,2,3,†,*}$, Stephen A. Tyndel $^{1,3,†}$, Barbara C. Klump $^{1}$, Gustavo Alarcon-Nieto $^{1,3}$ & Lucy M. Aplin $^{1,3,4}$

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

1.  To better understand how vocalisations are used during interactions of multiple individuals captive studies with microphones on the animal are often performed. The resulting recordings are challenging to analyse, since microphones drift non-linearly and record the vocalisations of non-focal individuals as well as noise.

2.  Here we present `callsync`, an R package designed to align recordings, detect and assign vocalisations, trace the fundamental frequency, filter out noise and perform basic analysis on the resulting clips.

3.  We present a case study where the pipeline is used on a new dataset of six captive cockatiels (*Nymphicus hollandicus*) wearing backpack microphones. Recordings initially had drift of ~2 minutes, but were aligned up to ~2 seconds with our package. We detected and assigned 829 calls across two days of 3.5 hours of recording each. We also use function that trace the fundamental frequency and apply spectrographic cross correlation to show that calls coming from the same individual sound more similar. 

4.  The `callsync` package can be used to go from raw recordings to a cleaned dataset of features. The package is designed to be modular and allow users to replace functions as they wish. We also discuss the challenges that might be faced in each step and how the available literature can provide alternatives for each step.

**Keywords:** communication networks, bio acoustics, microphone alignment, recording segmentation

# Introduction

The study of vocal signals in animals is a critical tool for understanding the evolution of vocal communication [@endler1993some]. Recent innovations in on-animal recording technologies have allowed for a dramatic increase of fine scale bioacoustic data collection and research[@wild2022internet,@bravo2021bioacoustic,@gill2016minimum]. Studying the ways that animals communicate in ‘real time’ allows us to untangle the complicated dynamics of how group members signal one another [@gill2015patterns]. These communication networks can help us understand how animals coordinate call response with movement [@demartsev2022signalling] as well as how group signatures form [@dahlin2014test,@knornschild2012learned,nousek2006influence]. However, as the capability of placing small recording devices on animals increases, so too does the need for tools to process the resulting data streams. Several publicly available R packages exist that measure acoustic parameters from single audio tracks [seewave; @sueur2008seewave, tuneR; @ligges2022package, WarbleR; @araya2017warbler], but to our knowledge, none address the critical issue of microphone clock drift and the ability to align and process multiple recordings. This poses a serious issue for those studying communication networks of multiple tagged individuals. In this paper, we apply a new R package, `callsync`, that aligns multiple misaligned audio files, detects vocalisations, assigns these to the focal individual and provides an analytical pipeline for the resulting synchronised data. 

The primary target for use of this package are researchers that study animal communication systems within groups. The critical issue is that multiple microphones recording simultaneously can drift apart in time [@schmid2010interaction]. To make matters worse this drift is often non-linear [@anisimov2014reconstruction]. Thus, if several microphone recorders (whales; @miller2009large,@hayes2000inexpensive, bats; @stidsholt20192) are placed on animals, it is critical for researchers to be able to line up all tracks so that calls can be assigned correctly to the focal individual (loudest track). The main functionality of `callsync` is to align audio tracks, detect calls from each track, determine which individual (even ones in relatively close proximity to one another) is vocalising and segment them, as well as take measurements of the given calls (see Figure 1). However, `callsync` takes a modular approach to aligning, segmenting, and analysing audio tracks so that researchers can use only the components of the package that suit their needs. 

![Flowchart from the `callsync` package. The *alignment* module can be used to align multiple microphones that have non-linear temporal drift. The *detection* module can be used to detect vocalisations in each recording. The *assignment* module can be used to assign a vocalisation to the focal individual, making sure that vocalisations from conspecifics are excluded from the focal recording. The *tracing* module can be used to trace and analyse the fundamental frequency for each vocalisation. Filters can be applied to remove false alarms in the detection module. The final *analysis* module can be used to run spectrographic cross correlation and create a feature vector to compare across recordings.]("ANALYSIS/RESULTS/figures/flowchart.pdf")

Current research packages that implement call alignment strategies are either used in matlab[@malinka2020autonomous,@anisimov2014reconstruction] or c++ [@gill2015patterns]. However these tools have not, up to now, been adapted for the R environment. Many of these tools are not documented publicly nor open source, and can require high licensing fees (i.e Matlab). While the design of this package is best suited to contexts where all microphones exist in the same spatial area, it is the goal that it can be adapted to more difficult contexts. This package is publicly available on github, is beginner friendly with strong documentation, and does not require extensive programming background. This open source tool will allow researchers to expand the study of bioacoustics and solve an issue that impedes detailed analysis of group-level calls. We will provide a case study and workflow that will demonstrate the use of this package. 

# Case study: cockatiel contact calls

We present a case study to show how `callsync` functions can be included in a workflow (see Figure 1). We used a dataset of domestic cockatiels (*Nymphicus hollandicus*). These birds are a part of an ongoing study at the Max Planck Institute of Animal Behavior. Birds were housed in several groups of six individuals in a 4x3x2.7m aviary facility. We equipped six cockatiels with a TS-systems EDIC-Mini E77 tag inside a sewn nylon backpack fitted via Teflon harness around the wings, with the total weight of all components under 7% of body weight. Audio recordings were scheduled to record for a maximum of 4 hours per day. Each microphone was automatically programmed to turn on and off daily at the same time. For the purposes of demonstration, two full days of recordings (4 hours each) were selected for processing where the microphones were scheduled to record from 6:30 until 10:30 in the morning. After several days of deployment, microphone recorders are removed and downloaded as .wav files directly onto the computer from the tag. These tags are placed into the appropriate folder (see workflow instructions) and processed in accordance with our package workflow. 

## Installation and set-up

The package call be installed from CRAN running `install.packages(callsync)` or a developmental version can be installed from GitHub:

``` r
install.packages('devtools')
library(devtools)
devtools::install_github('simeonqs/callsync')
```

All required packages are also automatically installed and loaded for the case study when running the `00_set_up.R` script.

## Alignment of raw recordings

Raw recordings consist of two days with 4 hour long wav files for six cockatiels. The backpack microphones have internal clocks that automatically turn them on and off. However, these clocks drift in time both during the off period, creating start times that differ up to a few minutes, and during the recording period, creating additional variable drift up to a minute between recordings. The function `align` can be used as a first step in order to align the audio recordings. In order to accurately align these tracks, the full audio files are automatically split into shorter 15 minute chunks of recording to ensure that drift is reduced to mere seconds. This value can be adjusted depending on the amount of drift.  The function selects one recording and aligns all the other recordings relative to the selected one recording using cross correlation on the energy content (summed absolute amplitude) per time bin, in our case 0.5 seconds.This value can also be adjusted.

``` r
align(chunk_size = 15,                          # how long should the chunks be in minutes
      step_size = 0.5,                          # bin size for summing in seconds
      path_recordings = 'ANALYSIS/DATA',        # where raw data is stored
      path_chunks = 'ANALYSIS/RESULTS/chunks',  # where to store the chunks
      keys_rec = c('_\\(', '\\)_'),             # how to recognise the recording in the path
      keys_id = c('bird_', '_tag'),             # how to recognise the individiual/microphone in the path
      blank = 15,                               # how much should be discarded before and after in minutes
      wing = 10,                                # how much extra should be loaded for alignment in minutes
      save_pdf = TRUE)                          # should a pdf be saved
```

For cross correlation, `align` loads the chunks with additional minutes before and after (option `wing`) to ensure that overlap can be found. The cross correlation is performed using the function `simple.cc`, which takes two vectors (the binned energy content of two recordings) and calculates the absolute difference while sliding the two vectors over each other. It returns the position of minimum summed difference, or in other words the position of maximal overlap. This position is then used to align the recordings relative to the first recording and save chunks that are maximally aligned. Note that due to drift during the recording, the start and end times might still be seconds off; it is the overall alignment of the chunks that is optimised. The function also allows the user to create a pdf with waveforms of each individual recording and a single page per chunk (see Figure 2), to visually verify if alignment was successful. For our dataset all chunks aligned correctly without a filter. If this is not the case the option `ffilter_from` can be set to apply a high-pass filter to improve alignment. Mis-aligned chunks can also be rerun individually using the option `chunk_seq` in order to avoid re-running the entire dataset.

![Example of the alignment output. Black lines represent the summed absolute amplitude per bin (= 0.5 seconds). Recordings are aligned relative to the first recording (which starts at 0). Note that recording 2-5 start ~2 minutes earlier, but are still aligned. The title displays the start time of the chunk in the raw recording.]("ANALYSIS/RESULTS/figures/alignment example.pdf")

## Call detection and assignment

The next step is to detect calls in each set of chunks and assign them to the correct individual. The `detect.and.assign` function loads the chunks using the function `load.wave` where it optionally applies a high-pass filter to reduce the amount of low frequency noise. To detect calls it calls the function `call.detect.multiple`, which can detect multiple calls in an R wave object. It first applies the `env` function from the *seewave* package to create a smooth Hilbert amplitude envelope. It then detects all the points on the envelope which are above a certain threshold relative to the maximum of the envelope. After removing detections that are shorter than a set minimum duration or longer than a set maximum it returns all the start and end times as a data frame. Because the microphones on non-focal individuals are very likely to record the calls of the vocalising individual as well, we implemented a step that assigns the detected calls to the correct individual. For this `detect.and.assign` calls the function `call.assign`, which runs through all the detections in a given chunk for a given individual and runs the `call.detect` function to more precisely determine the start and end time of the call. It then ensures that minor temporal drift is corrected by rerunning the `simple.cc` function. After alignment it calculates the summed absolute energy content on all recordings for the time frame when the call was detected and compares this to the focal recording. If the focal recording is louder by a set percentage than the second loudest recording, the detection is saved as a separate wav file. If not, this means it’s not possible to determine the focal individual and the detection is discarded. The function also allows the user to create a pdf with all the detections (see Figure 3 for a short example) to manually inspect the results.

``` r
detect.and.assign(ffilter_from = 1100,           # from where to filter in Hz
                  threshold = 0.4,               # fraction of maximum of envelope for detection
                  msmooth = c(1000, 95),         # smoothening argument for `env`
                  min_dur = 0.1,                 # minimum duration in seconds for acceptance
                  max_dur = 0.3,                 # maximum duration in seconds for acceptance
                  step_size = 1/50,              # bin size for summing in seconds
                  wing = 10,                     # how many extra seconds to load for alignment
                  keys_rec = c('_\\(', '\\)_'),  # how to recognise the recording in the path
                  keys_id = c('bird_', '_tag'))  # how to recognise the individiual/microphone in the path
```

For the cockatiel dataset the function detected and assigned 1088 calls, 829 of which were retained after filtering. We manually assigned 174 calls in three chunks with a lot of activity and compared the performance of the `detect.and.assign` function to manually labelled data. The ground truth was performed using the function `calc.perf`. The false positive rate was 1% (single false detection) and the true positive rate was 53%. 


![Example of the detection output. Black lines are the wave forms. Cyan dashed lines with shaded area in between are the detected calls.]("ANALYSIS/RESULTS/figures/detections example.pdf")

## Analysis of single calls and call comparison

To analyse the calls, the short wav clips were loaded and the function `call.detect` was rerun to determine the start and end times of the call. The wave objects were then resized to only include the call (`new_wave`). To trace the fundamental frequency we applied the `trace.fund` function to the resized wave objects. We ran the latter step in parallel using the function `mclapply` from the package *parallel* (see Figure 4a for an example).

``` r
traces = mclapply(new_waves, function(new_wave)  # apply the function to each new_wave
  trace.fund(wave = new_wave,                    # use the new_wave
             spar = 0.3,                         # smoothing argument for the `smooth.spline` function
             freq_lim = c(1.2, 3.5),             # only consider trace between 1.2 and 3.5 Hz 
             thr = 0.15,                         # threshold for detection, fraction of max of spectrum
             hop = 5,                            # skip five samples per step
             noise_factor = 1.5),                # only accept if trace is 1.5 times greater than noise
  mc.cores = 4)                                  # run on four threads, has to be 1 on Windows
```

![a) Spectrogram of a cockatiel call with start and end (black dashed lines) and the fundamental frequency trace (green solid line). b) Noise reduced spectrogram where darker colours indicate higher intensity.]("ANALYSIS/RESULTS/figures/spec_object and trace example")

The call detection step also picks up on a lot of noise (birds scratching, flying, walking around) as well as calls. We therefore ran a final step to filter the measurements and traces before these were saved.

``` r
keep = measurements$prop_missing_trace < 0.1 &                     # max 10% missing points
  measurements$signal_to_noise > 5 &                               # signal to noise at least 5
  measurements$band_hz > 600 &                                     # bandwidth at least 600 Hz
measurements = measurements[keep,]                                 # keep only these measurements
traces = traces[keep]                                              # and these traces
```

Another way to analyse calls is to measure their similarity directly. A frequently used method is SPCC - spectrographic cross correlation [@cortopassi2000comparison], where two spectrograms are slid over each other and the pixelwise difference is computed for each step. At the point where the signals maximally overlap one will find the minimal difference. This score is then used as a measure of acoustic distance between two calls. The function `run.spcc` runs SPCC and includes several methods to reduce noise in the spectrogram before running cross correlation (for an example see Figure 4b). To visualise the resulting feature vector from running SPCC on the cockatiel calls we used the function `umap` from the *umap* package [@umap] to run uniform manifold approximation, and plotted the first two dimensions. Calls clearly cluster by individual, but there is also a lot of overlap between individuals (see Figure 5).

![Call distribution in uniform manifold approximation space. Dots represents calls and are coloured by individual.]("ANALYSIS/RESULTS/figures/umap.pdf")

# Discussion

We present a case study and workflow to demonstrate `callsync`. Each of the modular components (alignment, detection, assignment, tracing, and analysis) successfully achieved the stated goals in the cockatiels system. Misaligned audio tracks were accurately aligned in a first step (see Figure 2), calls were correctly identified in the aligned recordings (see Figure 3), the focal individual making the call was selected (see Figure 3), and downstream data analysis was performed (figure 4). callsync can perform alignment even on drift that lasts at least minutes as well as handle unpredictable and non-linear drift patterns on different microphones. 

With tracks aligned to only a single second and only one mislabelled recording (1% of total ground truth dataset), we are confident that `callsync` is a robust and useful tool for bio acoustics research. The true positive rate of our results was 53%, meaning that about half of the manually selected calls for ground truthing were not detected by the `detect.calls` function. However, it should be noted that the manual selection procedure included all call types while detect.and.assign were isolated to the typical cockatiel ‘contact call’. Thus, one would need to run several detect.and.assign iterations to capture every type of vocalisation that were selected manually. Also settings were such that very little noise was detected and all noise was filtered out. Researchers themselves can decide the importance of whether obtaining every call type is needed or just particular types and apply the function accordingly. 

The microphones used in this case study were implemented in a captive setting where all calls were within hearing range of each other and each microphone. Thus, all microphones contained a partially shared noisescape. Despite their proximity to one another, it should be noted that each microphone still contained unique vocal attributes, such as wing beats and scratching, and that the major alignment step still aligned all chunks correctly. It is possible that researchers find that the noise differences between microphones is too high for the first alignment step to perform adequately. This would be particularly salient in field settings where individuals within fission-fusion groups find themselves in the proximity of other group members only some of the time [@furmankiewicz2011social, @buhrman2008individual,@balsby2009vocal], or in situations where animals constantly move (i.e., flying) or do independent behaviours that other group members do not [@demartsev2022signalling]. Researchers will have to assess their own dataset and test this package to determine whether the first step will perform well on their dataset. If it does not, `callsync` is a modular package and other approaches, such as deep learning [@o2016radio] can be used instead of the first align function, while still using other components of the pipeline. 

One possible challenge with the `call.detect` function could be that certain call types are not easily distinguishable from background noise (i.e. broadband signals; seals, monk parakeets, cockatoos). In these situations, `call.detect` is likely to pick up a significant amount of background noise instead of calls. Function parameters can be adapted and should function on most call-types, as can post-processing thresholding. For example, machine learning approaches [Animal-SPOT, @cohen2022automated,@stowell2019automatic] or image recognition tools [@smith2020individual,@valletta2017applications] can be later applied to separate additionally detected noise. As well, in particularly difficult cases, once the align function is performed, the entire `call.detect` function can be swapped out for programs such as ANIMAL-SPOT (in review). However, this function should perform very well in most cases. 

One critical issue when assigning a focal bird can be the proximity to other group members. If the group members spend time too close to one another (within roosts; @boughman1998greater,@kloepper2018recording), it will become more difficult to distinguish the calling bird from other surrounding individuals. In the context of this case study, it was sufficient to only select a focal bird when the second loudest call was at least 5% quieter than the focal call. This threshold can be adapted if needed, or the assignment part can be removed entirely if so chosen. In addition, other tools such as accelerometry data [@gill2015patterns,@anisimov2014reconstruction], and video footage [@forrester2008multidimensional] as well as discriminant analysis [@mcilraith1997birdsong] or cepstral coefficients [@lee2006automatic] can be used when separating individuals is particularly difficult. 

Lastly, both fundamental frequency tracing and SPCC work well in certain contexts. For example, automatic fundamental frequency traces works best for tonal calls while SPCC works best when the signal to noise ratio is sufficiently low [@cortopassi2000comparison]. However, if these criteria are not met, several other tools can be used instead such as Luscinia [@lachlan2018cultural], manual tracing [@araya2017warbler], or the researchers preferred analytical methodology for their system. While it is important to consider all possible limitations of `callsync` it should also be noted that there are few tools that exist that perform this much needed task. Indeed, the fine scale alignment step of `callsync` allows for call and response dynamics to be measured regardless of how close the calls are to one another. While this paper has thus far only addressed on-board microphones, other systems that implement like PAM systems [@thode2006portable] and microphone arrays [@blumstein2011acoustic] should also find benefit within this package depending on the setup and degree of drift. Possible future research opportunities include trying to incorporate machine learning and noise reduction techniques so that the major alignment can perform in all contexts. 

## Conclusion

This package is publicly available on github and open source. We welcome all continued suggestions and believe that our package will result in an increase in the possibilities and amount of bio acoustic research. Our package provides functions that allow alignment, detection, assignment, tracing and analysis of calls in a multi-recorder captive setting. The package can be used to generate a fully automated pipeline from raw recordings to the final feature vectors. We show that such a pipeline works well on a captive dataset with 4 hour long recordings from backpack microphones on six cockatiels which experience non-linear drift up to several minutes. Each module can also be replaced with alternatives and can be further developed. This package is, to our knowledge, the first R package that performs this task. We hope this package expands the amount of data researchers can process and contribute to understanding the dynamics of animal communication.

# Acknowledgements

We thank Dr. Ariana Strandburg-Peshkin for early feedback. SQS and SAT received from the International Max Planck Research School for Organismal Biology and the International Max Planck Research School for Quantitative Behaviour, Ecology and Evolution. SAT received additional funding from a DAAD PhD fellowship. The authors declare no conflicts of interest.

# Data accessibility

All code is publicly available on GitHub (https://github.com/simeonqs/methods_paper). All data and code is also publicly available on Edmond (**link**) A DOI for the Edmond repository will be added when the manuscript is accepted and assigned a DOI. The `callsync` package can be installed from CRAN and a developmental version can be found on GitHub (<https://github.com/simeonqs/callsync>).

# References

