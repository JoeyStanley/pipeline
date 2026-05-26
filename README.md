# Pipeline

Welcome to Pipeline! This is a tool to help you go from a spreadsheet of raw formant values to interactive visualizations of vowel formant data. You can think of it as the next step in the assembly line of sociophonetic data processing after DARLA. DARLA can take you from raw audio to raw acoustic measurements. This tool takes you from raw acoustic measurements to cleaned measurements ready for visualization and statistical analysis. In other words, it sends your data through a **pipeline** of sociophonetic analysis methods so that you don't have to worry about it. This lets users (especially students) use the power of R to get decent results without having to learn to code for themselves. 

For anyone familiar with my *Gazeteer of Southern Vowels* I made in 2015, it's conceptually similar to that (especially the data visualization portion), only this time users can upload their own data and it does some processing first. 

I created a basic version of Pipeline in 2022 as a classroom aid. It was only in 2026 that I decided to "go public" with it. I plan on presenting it at NWAV54 in October. The name comes from the idea that we send our data through a "pipeline" of sociophonetic processing steps. I hope to add visual nods to pipe organs once the app is ready for presentation.


## How it works

Once your data is loaded in (see below), it'll begin to process it in an opinionated manner (see Stanley [2022a](https://repository.upenn.edu/pwpl/vol28/iss2/17)). Specifically, after doing some preparation like cleaning up column names, it'll reclassify words into phonemes and allophones, then remove outliers, then normalize, and then removed good but otherwise uninteresting data like unstressed vowels. This order is consistent and sensible (Stanley [2022b](https://www.degruyterbrill.com/document/doi/10.1515/lingvan-2022-0065/html)). 

Once the data has been processed, you can download it as a new spreadsheet. So even if you don't need the data visualizations, you can at least benefit from the processing portion of Pipeline.

From there, you have a bunch of options to interact with your data. You can subset by speaker, vowel, and phonological environment and toggle between normalization procedures. The plot can be customized to show points, ellipses, means, words, and trajectories. (Note that trajectory plots are a little buggy at the moment.) You can customize elements of the plot like titles, labels, and font sizes and families. And you can download the plot in a variety of formats. 

Pipeline also has some rudimentary acoustic analysis. Currently, the focus is on overlap between certain pairs of vowels. Pillai scores are calculated and they are interpreted in light of Stanley & Sneller's ([2023](https://doi.org/10.1121/10.0016757)) threshold given the sample size. I hope to add more statistical analysis soon.

## How to get started

Pipeline is available at [stanley.byu.edu/pipeline](https://stanley.byu.edu/pipeline/). On the tab to the left, follow the instructions to upload a spreadsheet of formant measurements. 

## Data options

Currently, Pipeline supports two kinds of input files. 

1. A file called `formants.csv` produced by [DARLA](http://darla.dartmouth.edu) (Reddy & Stanford [2015](https://doi.org/10.1515/lingvan-2015-0002)).
1. A file a file with the suffix `_tracks.csv` produced by [new-fave](https://forced-alignment-and-vowel-extraction.github.io/new-fave/) (Fruehwald [2025a](https://forced-alignment-and-vowel-extraction.github.io/new-fave/)).

Upload either of those files and Pipeline can handle the rest. I don't anticipate adding new data input sources for now.

Pipeline supports adding multiple files (individually). So you can freely add DARLA files and combine them with new-fave files together and view the vowels across subsets or the entire dataset. 

## How is it powered?

Pipeline is written in [Shiny](https://shiny.posit.co) in R. Much of the heavy sociophonetic lifting is done through the {{[joeyr](https://joeystanley.github.io/joeyr/)}} (Stanley 2021) and {{[tidynorm](https://jofrhwld.github.io/tidynorm/)}} (Fruehwald [2025b](https://doi.org/10.32614/CRAN.package.tidynorm)) packages.

* Reclassifying allophones happens using [joeyr::code_allophones()](https://joeystanley.github.io/joeyr/reference/code_allophones.html). I hope to add some flexibility to this function soon.
* Outlier detection and removal happens using Modified Mahalanobis Distance method as implemented in [joeyr::find_outliers()](https://joeystanley.github.io/joeyr/reference/find_outliers.html) (see Stanley [2020](https://doi.org/10.1215/00031283-8820642) where I introduce this method). I hope to add more flexibility to this soon.
* Normalization happens using [tidynorm::norm_tracks_*()](https://jofrhwld.github.io/tidynorm/articles/normalizing_formant_tracks.html) functions. Currently, Pipeline lets you toggle between Nearey, Watt & Fabricius, ΔF, and Lobanov normalization methods. See more about those [here](https://jofrhwld.github.io/tidynorm/articles/norm-methods.html).
* Vowel overlap is calculated using [joeyr::pillai()](https://joeystanley.github.io/joeyr/reference/pillai.html). 

The data processing and visualizations are done using the various packages within the [tidyverse](https://tidyverse.org), especially [ggplot2](https://ggplot2.tidyverse.org). 

## Issues and future work

Pipeline hasn't been tested robustly yet, so there will likely be issues. Please be patient as I develop this because I can't foresee all the use cases users present me with.

Here are my short-term plans for inclusion in future updates:

* Better handling in plots and stats for multiple speakers.
* Plotting trajectories
* Incorporation of DCTs (a là Fruehwald [2024](https://jofrhwld.github.io/blog/posts/2024/07/2024-07-19_dct-r/), [2025](https://jofrhwld.github.io/dct_normalization/))
* Additional and custom stopword lists
* Alternative outlier removal methods
* Toggle between transcription systems (Wells, IPA, FAVE, Trager & Block, etc.)
* Mary-merry-marry vowel pairs
* Additional quantitative analyses besides pillai scores

## References

* Fruehwald, Josef. 2025a. new-fave. [https://forced-alignment-and-vowel-extraction.github.io/new-fave/](https://forced-alignment-and-vowel-extraction.github.io/new-fave/).

* Fruehwald, Josef. 2025b. tidynorm: Tools for Tidy Vowel Normalization. [https://doi.org/10.32614/CRAN.package.tidynorm](https://doi.org/10.32614/CRAN.package.tidynorm).

* Reddy, Sravana & James N. Stanford. 2015. Toward completely automated vowel extraction: Introducing DARLA. *Linguistics Vanguard* 15–28. [https://doi.org/10.1515/lingvan-2015-0002](https://doi.org/10.1515/lingvan-2015-0002).

* Stanley, Joseph A. "The Absence of a Religiolect among Latter-Day Saints in Southwest Washington." In *Speech in the Western States: Volume 3, Understudied Varieties*, by Valerie Fridland, Alicia Beckford Wassink, Lauren Hall-Lew, and Tyler Kendall, 95–122. Publication of the American Dialect Society 105. Durham, NC: Duke University Press, 2020. [https://doi.org/10.1215/00031283-8820642](https://doi.org/10.1215/00031283-8820642).

* Stanley, Joseph A. 2021. joeyr: Functions for Vowel Data (R package version 0.11. [https://joeystanley.github.io/joeyr/](https://joeystanley.github.io/joeyr/)

* Stanley, Joseph A. 2022a. Order of Operations in Sociophonetic Analysis. In *University of Pennsylvania Working Papers in Linguistics*, vol. Vol. 28: Iss. 2, Article 17. Available at: [https://repository.upenn.edu/pwpl/vol28/iss2/17](https://repository.upenn.edu/pwpl/vol28/iss2/17).

* Stanley, Joseph A. 2022b. Interpreting the order of operations in a sociophonetic analysis. *Linguistics Vanguard* 8(1). [https://doi.org/10.1515/lingvan-2022-0065](https://doi.org/10.1515/lingvan-2022-0065).

* Stanley, Joseph A. & Betsy Sneller. 2023. Sample size matters in calculating Pillai scores. *The Journal of the Acoustical Society of America* 153(1). 54–67. [https://doi.org/10.1121/10.0016757](https://doi.org/10.1121/10.0016757).

