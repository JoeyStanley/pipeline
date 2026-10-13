# Renders a markdown file as tabs, one per "## " heading, so a long page like splash.md can
# stay a single file. Anything before the first "## " heading (the title and intro) goes
# above the tabs. Headings inside ``` code blocks are left alone.
markdown_tabs <- function(path, id = NULL) {
    lines <- readLines(path, encoding = "UTF-8", warn = FALSE)

    in_code    <- cumsum(grepl("^```", lines)) %% 2 == 1
    is_heading <- grepl("^## ", lines) & !in_code
    chunks     <- split(lines, cumsum(is_heading))

    # Rendered the same way as includeMarkdown(). R chunks run after the split, so headings
    # they output stay inside their own tab.
    render <- function(x) HTML(markdown::mark(text = paste(run_r_chunks(x), collapse = "\n"), output = NULL))

    intro <- if ("0" %in% names(chunks)) render(chunks[["0"]])
    tabs  <- lapply(chunks[names(chunks) != "0"], function(chunk) {
        tabPanel(title = trimws(sub("^## ", "", chunk[1])), render(chunk[-1]))
    })

    tagList(
        intro,
        do.call(navlistPanel, c(unname(tabs), list(id = id, widths = c(3, 9), well = FALSE)))
    )
}

# A plain .md file can't run R code, so this runs each ```{r} chunk once (when the UI is built)
# and swaps in a plain code block of what it prints. Only the output is shown, not the code.
# As in knitr, a chunk with results = "asis" in its header has its output used as markdown
# instead. An error shows up in place of the output rather than keeping the app from starting.
run_r_chunks <- function(lines) {
    for (start in rev(grep("^```\\{r", lines))) {
        end <- start + match(TRUE, grepl("^```\\s*$", lines[-seq_len(start)]))
        if (is.na(end)) next  # unclosed chunk
        code   <- lines[seq_len(end - start - 1) + start]
        asis   <- grepl("results\\s*=\\s*['\"]asis['\"]", lines[start])
        output <- tryCatch(
            capture.output(source(exprs = parse(text = code), local = new.env(), print.eval = TRUE)),
            error = \(e) paste("Error:", conditionMessage(e))
        )
        if (!asis) output <- c("```", output, "```")
        lines <- c(head(lines, start - 1), output, tail(lines, -end))
    }
    lines
}

# Prints CHANGELOG.md as markdown for an asis chunk in splash.md: without its own title and
# intro, with its headings moved down two levels to sit under "### Updates", and in a
# scrolling box (.changelog in pipeline.css) so it doesn't push the rest of the tab down.
print_changelog <- function(path = "CHANGELOG.md") {
    lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
    lines <- lines[cumsum(grepl("^## ", lines)) > 0]
    lines <- sub("^(#+) ", "##\\1 ", lines)
    cat('<div class="changelog">', "", lines, "", "</div>", sep = "\n")
}
