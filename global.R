# ── TEMPORARY STARTUP DIAGNOSTICS ──────────────────────────
# Collects any errors encountered during startup so they can be displayed
# in the browser (the app can't reach server logs directly).
STARTUP_ERRORS <- character(0)

safe_step <- function(label, expr) {
    tryCatch(
        expr,
        error = function(e) {
            STARTUP_ERRORS[[length(STARTUP_ERRORS) + 1]] <<- paste0(label, ": ", conditionMessage(e))
        }
    )
}

safe_library <- function(pkg) {
    safe_step(paste0("library(", pkg, ")"),
              suppressWarnings(suppressMessages(library(pkg, character.only = TRUE))))
}
# ────────────────────────────────────────────────────────────

library(shiny) # needed to render the diagnostics page itself

safe_step("renv", {
    if (file.exists("renv/activate.R")) {
        source("renv/activate.R")
    }
})

safe_step("app_version", {
    app_version <- paste0("v", read.dcf("DESCRIPTION", fields = "Version")[1])
})
if (!exists("app_version")) app_version <- "v?"

for (pkg in c("DT", "shinycssloaders", "markdown",
              "tidyverse", "janitor", "writexl",
              "ggthemes", "ggforce", "concaveman", "khroma", "pals",
              "mgcv", "itsadug",
              "stopwords", "joeyr", "tidynorm")) {
    safe_library(pkg)
}


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

