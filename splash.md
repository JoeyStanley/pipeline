# Pipeline

Welcome to Pipeline! This is a tool to help you go from a spreadsheet of raw formant values to interactive visualizations of vowel formant data. You can think of it as the next step in the assembly line of sociophonetic data processing after transcription, forced-alignment, and formant extraction. This tool turns your raw acoustic measurements to cleaned measurements ready for visualization and statistical analysis. In other words, it sends your data through a **pipeline** of sociophonetic analysis methods so that you don't have to worry about it. This lets users (especially students) use the power of R to get decent results without having to learn to code for themselves. 

## What does Pipeline do?

### What does Pipeline do?

Once your data is loaded in (see below), it'll begin to process it in an opinionated but sensible manner (see Stanley [2022a](https://repository.upenn.edu/pwpl/vol28/iss2/17), [2022b](https://www.degruyterbrill.com/document/doi/10.1515/lingvan-2022-0065/html)). Specifically, after doing some preparation like cleaning up column names, it'll reclassify words into phonemes and allophones, then remove outliers, then normalize, and then removed good but otherwise uninteresting data like unstressed vowels. This consistency ensures that plots produced from Pipeline are comparable to each other so long as the input data is also comparable.

Once the data has been processed, you can download it as a new spreadsheet. So even if you don't need the data visualizations, you can at least benefit from the processing portion of Pipeline.

From there, you have a bunch of options to interact with your data. You can subset by speaker, vowel, and phonological environment and toggle between normalization procedures. The plot can be customized to show points, ellipses, means, and words. You can customize elements of the plot like titles, labels, and font sizes and families. And you can download the plot in a variety of formats. 

If you upload formant track data produced by new-fave (that is, a file with `_tracks.csv` in the filename), then you can also create trajectory plots. Most of the same customization options available in the single-point plot are also available for the trajectory plots.

Pipeline also has some rudimentary acoustic analysis. Currently, the focus is on overlap between certain pairs of vowels. Pillai scores are calculated and they are interpreted in light of Stanley & Sneller's ([2023](https://doi.org/10.1121/10.0016757)) threshold given the sample size. I hope to add more statistical analysis soon.

## What can I upload to Pipeline?

### What can I upload to Pipeline?

Currently, Pipeline supports three kinds of input files. 

1. A file called `formants.csv` produced by [DARLA](http://darla.dartmouth.edu) (Reddy & Stanford [2015](https://doi.org/10.1515/lingvan-2015-0002)).
1. A file with the suffix `_points.csv` produced by [new-fave](https://forced-alignment-and-vowel-extraction.github.io/new-fave/) (Fruehwald [2025a](https://forced-alignment-and-vowel-extraction.github.io/new-fave/)).
1. A file with the suffix `_tracks.csv` produced by [new-fave](https://forced-alignment-and-vowel-extraction.github.io/new-fave/) (Fruehwald [2025a](https://forced-alignment-and-vowel-extraction.github.io/new-fave/)).

Upload any of these files and Pipeline can handle the rest. I don't anticipate adding new data input sources for now. All three allow for midpoint plots; only the `_tracks.csv` file allows for trajectory plots.

Pipeline supports adding multiple files one at a time. So you can freely add DARLA files and combine them with new-fave files together and view the vowels across subsets or the entire dataset. (Be aware that some processing bugs may be introduced when combining from different sources since they are formatted quite differently from each other.)

## What's happening under-the-hood?

### What's happening under-the-hood?

Pipeline is written in [Shiny](https://shiny.posit.co) in R. Much of the heavy sociophonetic lifting is done through the [joeyr](https://joeystanley.github.io/joeyr/) (Stanley 2021) and [tidynorm](https://jofrhwld.github.io/tidynorm/) (Fruehwald [2025b](https://doi.org/10.32614/CRAN.package.tidynorm)) packages.

* Reclassifying allophones happens using [joeyr::code_allophones()](https://joeystanley.github.io/joeyr/reference/code_allophones.html). I hope to add some flexibility to this function soon.
* Outlier detection and removal happens using Modified Mahalanobis Distance method as implemented in [joeyr::find_outliers()](https://joeystanley.github.io/joeyr/reference/find_outliers.html) (see Stanley [2020](https://doi.org/10.1215/00031283-8820642) where I introduce this method). I hope to add more flexibility to this soon.
* Normalization happens using [tidynorm::norm_tracks_*()](https://jofrhwld.github.io/tidynorm/articles/normalizing_formant_tracks.html) functions. Currently, Pipeline lets you toggle between Nearey, Watt & Fabricius, ΔF, and Lobanov normalization methods. See more about those [here](https://jofrhwld.github.io/tidynorm/articles/norm-methods.html).
* The stopwords that are removed are [Marimo set](https://github.com/koheiw/marimo/blob/master/yaml/stopwords_en.yml) as implemented in the {{stopwords}} package ([Benoit, Muhr, & Watanabe 2021](https://doi.org/10.32614/CRAN.package.stopwords)). I hope to add flexibility to this soon. 
* Vowel overlap is calculated using [joeyr::pillai()](https://joeystanley.github.io/joeyr/reference/pillai.html). 

The data processing and visualizations are done using the various packages within the [tidyverse](https://tidyverse.org), especially [ggplot2](https://ggplot2.tidyverse.org). 

See the "Citations and References" tab to the left for how to cite each of these component parts.

## Bugs, Updates, and Future Work

### Bugs

Please be patient as I work on Pipeline. There are many moving parts and I can't foresee all the use cases users present me with. 

If you are stuck, feel free to email me (Joey Stanley) at pipeline.ling@gmail.com.

### Updates

Pipeline is regularly being updated, so here are full details on updates, versions, and dates. 

```{r, results = "asis"}
print_changelog()
```

### Future Work

Here are my plans for inclusion in future updates:

* Better handling in plots and stats for multiple speakers.
* Incorporation of DCTs (a là Fruehwald [2024](https://jofrhwld.github.io/blog/posts/2024/07/2024-07-19_dct-r/), [2025](https://jofrhwld.github.io/dct_normalization/)) for analysis and visualization.
* Customization in how allophones are classified.
* Additional and custom stopword lists
* Additional and customization of outlier removal methods
* Toggle between transcription systems (Wells, IPA, FAVE, Trager & Block, etc.)
* Flexibility in vowel pairs for overlap analysis.
* Additional quantitative analyses besides Pillai scores
* A downloadable log that fully reproduces the plot.

While I would like to add support for languages besides English, I do not foresee that happening soon. Since I work primarily with English, I don't know the nuances of allophone classification, stopwords, and transcription systems. I apologize for those hoping to see vowel plots in non-English languages.

## AI Disclosure

### AI Disclosure

Most of the code is written by me. However, Pipeline has expanded in functionality, desire for certain features has increased, and interfacing with the server on which this is hosted has required security and other enhancements I did not foresee. The demand on my time has led me to turn to Claude to speed up the process. Therefore, some of the "higher-level" features, like security and data management beyond sociophonetic stuff, were written by Claude. The bulk of the sociophonetic processing, visualization, and analysis is still my code. 

AI does not touch your data. It is not incorporated into the analysis that Pipeline itself does. Once the app is running, there is no AI use whatsoever.

## Security and Privacy

### Security and Privacy

All processing happens on a server hosted by the [Office of Digital Humanities](https://odh.byu.edu) at Brigham Young University. Your interaction with Pipeline is in a private session and is not accessible by other users, even if they are using Pipeline at the same time as you. When your session ends by you closing the app, the app closing itself after a few minutes of inactivity, or it crashes, your data is immediately removed from the server. Nothing is sent offsite or to third-party servers. I can never access your uploaded data.

Pipeline does write and save error logs, which saves the name of the file that was uploaded, manually entered information (titles, subtitles, and name of the exported file), the names of all speakers, column names, processing choices (normalization, etc), and error messages. 

## Citation and References

### Citing Pipeline

If you use Pipeline, please cite it using the following citation:

> Joey Stanley. "Introducing Pipeline: Interactive visualization and analysis of DARLA and new-fave output." New Ways of Analyzing Variation 54. Montreal, Quebec. October 24, 2026.

### Recommended additional citations

Here are some additional references for software and ideas incorporated into Pipeline. I encourage you to cite any that you used.

* Benoit Kenneth, Davi Muhr, & Kohei Watanabe (2021). *stopwords: Multilingual Stopword Lists*. [doi:10.32614/CRAN.package.stopwords](https://doi.org/10.32614/CRAN.package.stopwords). R package version 2.3.

* Fruehwald, Josef. 2025a. new-fave. [https://forced-alignment-and-vowel-extraction.github.io/new-fave/](https://forced-alignment-and-vowel-extraction.github.io/new-fave/).

* Fruehwald, Josef. 2025b. tidynorm: Tools for Tidy Vowel Normalization. [https://doi.org/10.32614/CRAN.package.tidynorm](https://doi.org/10.32614/CRAN.package.tidynorm).

* Reddy, Sravana & James N. Stanford. 2015. Toward completely automated vowel extraction: Introducing DARLA. *Linguistics Vanguard* 15–28. [https://doi.org/10.1515/lingvan-2015-0002](https://doi.org/10.1515/lingvan-2015-0002).

* Stanley, Joseph A. "The Absence of a Religiolect among Latter-Day Saints in Southwest Washington." In *Speech in the Western States: Volume 3, Understudied Varieties*, by Valerie Fridland, Alicia Beckford Wassink, Lauren Hall-Lew, and Tyler Kendall, 95–122. Publication of the American Dialect Society 105. Durham, NC: Duke University Press, 2020. [https://doi.org/10.1215/00031283-8820642](https://doi.org/10.1215/00031283-8820642).

* Stanley, Joseph A. 2021. joeyr: Functions for Vowel Data (R package version 0.11. [https://joeystanley.github.io/joeyr/](https://joeystanley.github.io/joeyr/)

* Stanley, Joseph A. 2022a. Order of Operations in Sociophonetic Analysis. In *University of Pennsylvania Working Papers in Linguistics*, vol. Vol. 28: Iss. 2, Article 17. Available at: [https://repository.upenn.edu/pwpl/vol28/iss2/17](https://repository.upenn.edu/pwpl/vol28/iss2/17).

* Stanley, Joseph A. 2022b. Interpreting the order of operations in a sociophonetic analysis. *Linguistics Vanguard* 8(1). [https://doi.org/10.1515/lingvan-2022-0065](https://doi.org/10.1515/lingvan-2022-0065).

* Stanley, Joseph A. & Betsy Sneller. 2023. Sample size matters in calculating Pillai scores. *The Journal of the Acoustical Society of America* 153(1). 54–67. [https://doi.org/10.1121/10.0016757](https://doi.org/10.1121/10.0016757).

* Hadley Wickham. 2016. *ggplot2: Elegant Graphics for Data Analysis*. Springer-Verlag New York.

* Hadley Wickham, Mara Averick, Jennifer Bryan, Winston Chang, Lucy D'Agostino McGowan, Romain François, Garrett Grolemund, Alex Hayes, Lionel Henry, Jim Hester, Max Kuhn, Thomas Lin Pedersen, Evan Miller, Stephan Milton Bache, Kirill Müller, Jeroen Ooms, David Robinson, Dana Paige Seidel, Vitalie Spinu, Kohske Takahashi, Davis Vaughan, Claus Wilke, Kara Woo, and Hiroaki Yutani. 2019. "Welcome to the tidyverse." *Journal of Open Source Software*, 4 (43), 1686. [doi:10.21105/joss.01686](https://doi.org/10.21105/joss.01686).

### Session Info

Here's the full log of R packages and version numbers currently used. 

```{r}
cat(R.version.string, "\n\n")
print(sapply(sessionInfo()$otherPkgs, `[[`, "Version"), width = 80, quote = FALSE)
```




## Backstory

### Backstory

I enjoy learning about the backstory of publications, so here's some of that for Pipeline. 

In grad school, I was on the team working on the Digital Archive of Southern Speech (DASS) as part of the Linguistic Atlas Project. We were getting lots of data processed and were anxious to see the results. Since my role on the team was to do the bulk of the quantitative analysis, it was my responsibility to produce the plots. However, I was getting so many requests by team members to make plots--one person was completely serious when they said they wanted me to save a plot of "every conceivable subset" of the data! 

Around that time, I heard about R Shiny, mostly through Dan Johnson's presentation on vowel overlap at NWAV44 in Toronto. I looked into it, and it seemed like a useful tool for interactive vowel plots. So, I spent some time learning Shiny. (And not to sound old, but all the official help at the time at the time was a single 3-hour video---no [websites](https://shiny.posit.co), no [books](https://shiny.posit.co), or anything!) 

I eventually created an interactive vowel plot for our data and called it the *Gazetteer of Southern Vowels* (GSV). I [presented](https://joeystanley.com/downloads/180105-ads2018-gsv.pdf) the GSV at the American Dialect Society Annual Meeting in Salt Lake City in 2018 and [again](https://joeystanley.com/blog/dh2019/index.html) at the Digital Humanities 2019 conference in Utrecht, Netherlands. While it never really was used much beyond team members, at least they could go make their own dang plots! 😉 

The GSV is now defunct since no one work worked on it is at UGA anymore. The ideas behind it were useful though. Given a dataset, users could subset it however they like---selecting speakers, vowels, allophones, etc---and create a vowel plot of the resulting data. Users could then customize the plot by viewing dots, words, ellipses, etc until it looked good. This could then be downloaded.

Fast-forward a few years, and in 2022 I was teaching introductory phonetics and linguistic methods courses at BYU. I [taught about DARLA](https://joeystanley.com/blog/darla/index.html), but wasn't super satisfied with the plots that it returned to students. I realized then that something like the GSV would be helpful for students who want to make better plots. So I whipped up a new Shiny app that borrowed much of the same data visualization code as the GSV, but had the additional step of allowing users to upload their DARLA-generated data. Around that time, I was thinking and publishing about sociophonetic methods (see Stanley [2022a](https://repository.upenn.edu/pwpl/vol28/iss2/17), [2022b](https://www.degruyterbrill.com/document/doi/10.1515/lingvan-2022-0065/html)) so I thought I'd incorporate those methods into this pedagogical tool, especially because students typically use less-than-pristine audio and they don't know enough about vowel plots to spot outliers and their effect on the results. 

This was a useful tool for my students, so in 2026 I decided to "go public" with it. The core of what you now see is largely the same as the pedagogical tool I created in 2022 (which, in turn, borrowed heavily from the GSV!), but I've had to add quite a lot of additional stuff for enhanced security and robustness. Furthermore, new-fave was released since then, [DARLA has been sunset](https://jstanford.host.dartmouth.edu/DARLA_notification.html), and my other tool ([VoxHumana](https://stanley.byu.edu/VoxHumana/)) is now live, which increases the kind of inputs Pipeline has to be able to handle. 

Pipeline version 1.0.0 came out October 24, 2026 when I presented it at NWAV54 in Montreal. 

## Why "Pipeline"?

*Pipeline* comes from the idea that we send our data through a "pipeline" of sociophonetic processing steps. But I also play the pipe organ, so there are also subtle and not-so-subtle nods to pipe organs throughout. The color palette comes from the [Salt Lake Tabernacle Organ](https://en.wikipedia.org/wiki/Salt_Lake_Tabernacle_organ). The visual similarity between ([VoxHumana](https://stanley.byu.edu/VoxHumana/)) and Pipeline is intentional and supports the goal of having them work seamlessly together.



