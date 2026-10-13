# Pipeline

Pipeline is a tool to help you go from a spreadsheet of raw formant values to interactive visualizations of vowel formant data. You can think of it as the next step in the assembly line of sociophonetic data processing after transcription, forced-alignment, and formant extraction. This tool turns your raw acoustic measurements to cleaned measurements ready for visualization and statistical analysis. In other words, it sends your data through a **pipeline** of sociophonetic analysis methods so that you don't have to worry about it. This lets users (especially students) use the power of R to get decent results without having to learn to code for themselves. 

## Where to find it

You can access Pipeline by going to <https://stanley.byu.edu/pipeline>.

## Updates

See [CHANGELOG.md](CHANGELOG.md).

## Citation

If you use Pipeline, please cite it using the following citation:

> Joey Stanley. "Introducing Pipeline: Interactive visualization and analysis of DARLA and new-fave output." New Ways of Analyzing Variation 54. Montreal, Quebec. October 24, 2026.

## Running it locally

If you'd like to try to run Pipeline locally, give it a shot. I make no promises. 

You can clone this repository from Github using the terminal or command line:

```
git clone https://github.com/JoeyStanley/pipeline.git
```

From there, you can open R and the packages used in Pipeline.

```
renv::restore()
```

You can then run the app itself.

```
shiny::runApp()
```

Again, I make no promises, but if you know what you're doing, go for it.