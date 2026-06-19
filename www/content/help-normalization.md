## Normalization

Vowel normalization seeks to remove the effects of speaker-specific vocal tract sizes on formant frequencies so that it's possible to compare vowels across speakers fairly. Without normalization, a tall person's F1 and F2 values will likely be lower than a shorter person's, even for the same vowel.

Pipeline offers a variety of normalization procedures, all of which are powered by the `tidynorm` package.

> **Cite as:** Fruehwald, Josef (2025). *tidynorm: Tools for Tidy Vowel Normalization*. <https://doi.org/10.32614/CRAN.package.tidynorm>. R package version 0.4.0, <https://CRAN.R-project.org/package=tidynorm>.

The normalization options are briefly explained below. Please read more about each one [here](https://jofrhwld.github.io/tidynorm/articles/norm-methods.html) and [here](https://lingtools.uoregon.edu/norm/norm1_methods.php) and cite the method you use. 

### None

No transformation applied; raw F1 and F2 values are displayed in Hz. This is suitable for analyses of a single-speaker.

### Nearey (log-mean)

A log-scale transformation that centers each speaker's formants around their own geometric mean. Recent research suggests that this method comes closest to mimicking human perception (Barreda 2025).

> **Cite as:** Nearey, Terrance Michael (1978). *Phonetic feature systems for vowels*. Indiana University Linguistics Club.

### Watt & Fabricius

Projects each speaker's vowels relative to a triangle defined by their F1/F2 means for /i, u, a/. 

> **Cite as:** Watt, D., & Fabricius, A. (2002). Evaluation of a technique for improving the mapping of multiple speakers' vowel spaces in the F1–F2 plane. *Leeds Working Papers in Linguistics and Phonetics, 9*, 159--173.

### ΔF (delta-F)

Estimates wvocal tract length from formants and uses it to scale all formant values.

> **Cite as:** Johnson, Keith (2020). "The ΔF Method of Vocal Tract Length Normalization for Vowels." *Laboratory Phonology: Journal of the Association for Laboratory Phonology* 11 (11): 10. <https://doi.org/10.5334/labphon.196>.

### Lobanov (z-score)

Standardizes each speaker's F1 and F2 independently using their own mean and standard deviation. Widely used but can distort the relative positions of vowels within a speaker's system.

> **Cite as:** Lobanov, Boris (1971). "Classification of Russian Vowels Spoken by Different Listeners." *Journal of the Acoustical Society of America* 49: 606--8. <https://doi.org/10.1121/1.1912396>.


## Meta-Analyses of Normalization

Careful analysis should consider which one to use based on the latest meta-analyses of normalization procedures. Here is a recommended article that readers may find informative.

> Barreda, Santiago (2025). Normalization, essentialization, and the erasure of social and linguistic variation. *Journal of Phonetics* 110. 101409. <https://doi.org/10.1016/j.wocn.2025.101409>.