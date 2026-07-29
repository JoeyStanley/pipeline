## Environments

Filter tokens by their surrounding consonants. This is important because the same vowel can shift dramatically depending on what consonants precede or follow it. 

This allophone classification is done using the [`code_allophones`](https://joeystanley.github.io/joeyr/reference/code_allophones.html) function within the [`joeyr`](https://joeystanley.github.io/joeyr/index.html) package. The function considers the surrounding consonants (usually just the following consonant) when making these classifications. Specifically, Pipeline looks for columns named `pre_seg` and `fol_seg` and assumes they are coded in the way that the [CMU Pronouncing Dictionary](https://en.wikipedia.org/wiki/CMU_Pronouncing_Dictionary) does so.

### Available environments

Here is a list of the environments. Note that Some are only available for certain vowels.  

- **prelateral** — before an /l/ (e.g., *feel*, *fill*, *full*, *fool*)
- **prerhotic** — before an /r/ (e.g., *fear*, *fair*, *fur*)
- **prevelar** — before a velar consonant /k g ŋ/ (e.g., *back*, *bag*, *bang*)
- **prenasal** — before a nasal /m n ŋ/ (e.g., *ban*, *pan*, *pin*)
- **prevelarnasal** — specifically before /ŋ/ (e.g., *bang*, *sing*)
- **prevoiceless** — before a voiceless consonant (e.g., *bit*, *bat*, *but*)
- **post-Y** — after a palatal glide /j/ (e.g., *use*, *cute*)
- **postcoronal** — after a coronal consonant /t d s z n l r/ (e.g., *true*, *drew*)
- **elsewhere** — the default environment; tokens not captured by any of the specific environments below

Selecting **elsewhere** alone gives you the most "canonical" version of each vowel, excluding conditioned allophones. Selecting multiple environments plots each as a separate allophone.
