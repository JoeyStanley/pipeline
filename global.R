if (file.exists("renv/activate.R")) {
    source("renv/activate.R")
}


library(shiny)
library(DT) 
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
library(khroma)   # Paul Tol color schemes
library(pals)     # Kelly, Glasbey, Alphabet palettes

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


# ── Color palettes ───────────────────────────────────────
# Returns an unnamed character vector of `n` hex colors for the chosen scheme.
# Kelly and Glasbey both start with near-white (#F2F3F4), so we skip index 1.
build_palette <- function(n, scheme = "kelly") {
    max_n <- c(tol = 23L, kelly = 21L, glasbey = 31L, alphabet = 26L)
    base_colors <- switch(scheme,
        "tol"      = khroma::color("discreterainbow")(max_n[["tol"]]),
        "kelly"    = unname(pals::kelly(max_n[["kelly"]] + 1L))[-1L],
        "glasbey"  = unname(pals::glasbey(max_n[["glasbey"]] + 1L))[-1L],
        "alphabet" = unname(pals::alphabet(max_n[["alphabet"]]))
    )
    # Shuffle with a fixed seed so similar-hued neighbors in the palette don't
    # land on alphabetically-adjacent allophones (e.g. BAIT/BAT, BOT/BOUGHT).
    set.seed(260531)
    rep_len(sample(base_colors), n)
}

