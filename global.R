library(shiny)
library(DT) #these are called as needed
library(shinycssloaders) # for spiny wheel when loading plot
library(markdown)

# Data management 
library(tidyverse)
library(janitor)
library(writexl)

# Data visualizations
library(ggthemes)
library(ggforce)
library(concaveman)

# Statistics
library(mgcv)
library(itsadug)

# Linguistics-specific
library(stopwords)
library(joeyr) # remotes::install_github("joeystanley/joeyr")
library(tidynorm)


# ── Theme colors (Tabernacle organ palette) ─────────────
PIPE_BROWN       <- "#4a2e1a"   # dark walnut, pipe case
PIPE_BROWN_MID   <- "#7a4a2a"   # mid walnut, hover states
PIPE_BROWN_LIGHT <- "#c4956a"   # lighter wood tone
PIPE_GOLD        <- "#c9a84c"   # antique gold, pipe faces
PIPE_GOLD_LIGHT  <- "#e8d5a3"   # pale gold, backgrounds
PIPE_CREAM       <- "#f9f5ee"   # ivory, main background
PIPE_DARK        <- "#1e1209"   # near-black, text



# Prerender the HTML file of the Readme to sidestep the issue of having the server do that with out-of-date dependencies.
if (!file.exists("www/readme.html")) {
    commonmark::markdown_html(
        paste(readLines("README.md"), collapse = "\n")
    ) |> writeLines("www/readme.html")
}