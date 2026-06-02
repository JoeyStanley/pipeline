## Distribution

Placeholder. Distribution overlays show the spread or density of each vowel class, rather than individual tokens or a single center point.

### Ellipses

Draws a confidence ellipse enclosing approximately 67% of tokens (by default) for each vowel class. This is *not* a hard boundary — tokens outside it are not outliers. The 67% level corresponds roughly to one standard deviation in two dimensions; 95% is the other common choice.

### KDE contours

Kernel density estimation contours show regions of equal token density. More contour lines = finer detail. Useful when the distribution is non-elliptical.

### Minimum tokens

Ellipses and KDE contours are suppressed for any vowel group below this token count. Groups with few tokens produce unreliable or misleading distributions. Individual tokens and center markers are always shown regardless of this threshold.

### One ellipse/contour per…

Controls the grouping level. **Phoneme** draws one shape per Wells keyword; **allophone** draws one per phonological environment.
