# Developer-facing diagnostics for errors that only show up on the server. Shiny Server
# sanitizes error messages (users just see "An error has occurred...") and deletes an app's
# log when its R process exits unless `preserve_logs true;` is set, so render errors there
# are otherwise invisible. Each report goes to stderr (-> /var/log/shiny-server/) and is
# appended to logs/render_errors.log when the app directory is writable.
#
# Meant to be called from withCallingHandlers() rather than tryCatch(), so it runs before the
# stack unwinds (the call stack and any open graphics device are still intact) and the error
# still propagates to Shiny afterwards as usual.
log_render_error <- function(e, output_id, context = list()) {

    # req() and validate() signal errors too, but those are expected, not bugs.
    if (inherits(e, c("shiny.silent.error", "validation"))) return(invisible())

    # Never let a failure in here replace the original error.
    try(silent = TRUE, {
        calls <- vapply(sys.calls(), \(x) paste(deparse(x, nlines = 1L), collapse = ""), character(1))

        report <- c(
            strrep("=", 80),
            paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "| error rendering", output_id),
            paste("Message:", conditionMessage(e)),
            paste("Call:   ", paste(deparse(conditionCall(e), nlines = 1L), collapse = "")),
            "",
            "## Session",
            capture.output(str(context, vec.len = 25, nchar.max = 200, give.attr = FALSE)),
            "",
            "## Graphics and library",
            paste("bitmapType:  ", getOption("bitmapType")),
            paste("cairo:       ", capabilities("cairo")),
            paste("Open devices:", length(dev.list()), "(includes this render's own; dozens means a leak)"),
            paste("LANG:        ", Sys.getenv("LANG")),
            paste("Lib paths:   ", paste(.libPaths(), collapse = "; ")),
            "",
            "## Call stack",
            paste0(seq_along(calls), ": ", calls),
            "",
            "## sessionInfo()",
            capture.output(sessionInfo()),
            ""
        )

        message(paste(report, collapse = "\n"))

        tryCatch({
            dir.create("logs", showWarnings = FALSE)
            write(report, file.path("logs", "render_errors.log"), append = TRUE)
        }, warning = \(w) message("Couldn't write logs/render_errors.log: ", conditionMessage(w)),
           error   = \(e) message("Couldn't write logs/render_errors.log: ", conditionMessage(e)))
    })

    invisible()
}
