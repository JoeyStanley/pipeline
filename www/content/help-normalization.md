## Normalization

Vowel normalization removes the effect of speaker-specific vocal tract size on formant frequencies, making it possible to compare vowels across speakers fairly. Without normalization, a male speaker's F1 and F2 values will be systematically lower than a female speaker's even for the same vowel.

### None

No transformation applied. Raw F1 and F2 values in Hz. Suitable for single-speaker analysis or when comparing speakers of similar vocal tract size.

### Nearey (log-mean)

A log-scale transformation that centers each speaker's formants around their own geometric mean. Works well for multi-speaker comparisons. Considered one of the best-performing intrinsic methods.

> **Cite as:** Nearey, T. M. (1978). *Phonetic feature systems for vowels*. Indiana University Linguistics Club.

### Watt & Fabricius

Projects each speaker's vowels relative to a triangle defined by their F1/F2 means for high front, high back, and low vowels. Preserves relative vowel positions while removing overall scale differences.

> **Cite as:** Watt, D., & Fabricius, A. (2002). Evaluation of a technique for improving the mapping of multiple speakers' vowel spaces in the F1–F2 plane. *Leeds Working Papers in Linguistics and Phonetics, 9*, 159–173.

### ΔF (delta-F)

Estimates vocal tract length from the spacing between formants and uses it to scale all formant values. A purely acoustic method requiring no vowel-class information.

> **Cite as:** Johnson, K. (2020). The ΔF method of vocal tract length normalization for vowels. *Laboratory Phonology, 11*(1).

### Lobanov (z-score)

Standardizes each speaker's F1 and F2 independently using their own mean and standard deviation. Simple, widely used, and effective — but can distort the relative positions of vowels within a speaker's system.

> **Cite as:** Lobanov, B. M. (1971). Classification of Russian vowels spoken by different speakers. *Journal of the Acoustical Society of America, 49*(2B), 606–608.
