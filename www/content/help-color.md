## Color

Control what variable drives color assignment and which color palette is used.

### One color per…

- **Phoneme** — one color per Wells lexical set (e.g., all FLEECE tokens share a color). Best when you want to compare vowel classes.
- **Allophone** — one color per phoneme–environment combination (e.g., FLEECE-elsewhere and FLEECE-prelateral get different colors). Best when comparing environments within or across vowels.

### Palette

All palettes are designed for categorical data. Colors are shuffled with a fixed random seed so that phonetically similar vowels (which tend to be alphabetically adjacent) receive visually distinct colors.

- **Kelly** — maximum-contrast palette; works well in print and on screen.
- **Paul Tol** — colorblind-safe discrete rainbow; up to 23 colors before recycling.
- **Glasbey** — algorithmically maximized distinctness; up to 31 colors.
- **Alphabet** — perceptually spaced; up to 26 colors.

If more colors are needed than the palette provides, colors are recycled.
