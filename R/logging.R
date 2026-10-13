# Developer-facing diagnostics for errors that only show up on the server. Shiny Server
# sanitizes error messages (users just see "An error has occurred...") and deletes an app's
# log when its R process exits unless `preserve_logs true;` is set, so errors there are
# otherwise invisible. Each report goes to stderr (-> /var/log/shiny-server/) and is
# appended to logs/errors.log when the app directory is writable.
#
# Ideally called from withCallingHandlers() rather than tryCatch(), so it runs before the
# stack unwinds (the call stack and any open graphics device are still intact) and the error
# still propagates as usual afterwards. When it's called after the fact instead (e.g. from
# onUnhandledError()), it uses the stack trace Shiny captured on the condition, if there is one.
log_error <- function(e, where, context = list()) {

    # req() and validate() signal errors too, but those are expected, not bugs.
    if (inherits(e, c("shiny.silent.error", "validation"))) return(invisible())

    # Never let a failure in here replace the original error.
    try(silent = TRUE, {
        stack <- if (!is.null(conditionStackTrace(e))) {
            capture.output(printStackTrace(e, full = TRUE), type = "message")
        } else {
            calls <- vapply(sys.calls(), \(x) paste(deparse(x, nlines = 1L), collapse = ""), character(1))
            paste0(seq_along(calls), ": ", calls)
        }

        report <- c(
            strrep("=", 80),
            paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "| error in", where, "|", app_version),
            paste("Message:", conditionMessage(e)),
            paste("Call:   ", paste(deparse(conditionCall(e), nlines = 1L), collapse = "")),
            "",
            "## Session",
            capture.output(str(context, vec.len = 25, nchar.max = 200, give.attr = FALSE)),
            "",
            "## Graphics and library",
            paste("bitmapType:  ", getOption("bitmapType")),
            paste("cairo:       ", capabilities("cairo")),
            paste("Open devices:", length(dev.list()), "(includes a failed render's own; dozens means a leak)"),
            paste("LANG:        ", Sys.getenv("LANG")),
            paste("Lib paths:   ", paste(.libPaths(), collapse = "; ")),
            "",
            "## Call stack",
            stack,
            "",
            "## sessionInfo()",
            capture.output(sessionInfo()),
            ""
        )

        message(paste(report, collapse = "\n"))

        tryCatch({
            dir.create("logs", showWarnings = FALSE)
            write(report, file.path("logs", "errors.log"), append = TRUE)
        }, warning = \(w) message("Couldn't write logs/errors.log: ", conditionMessage(w)),
           error   = \(e) message("Couldn't write logs/errors.log: ", conditionMessage(e)))
    })

    invisible()
}

# Runs once when the app starts. If the app directory isn't writable, reports only reach
# stderr, which Shiny Server deletes when the R process exits unless `preserve_logs true;` is
# set, so say so up front rather than finding out after an error has gone missing.
local({
    dir.create("logs", showWarnings = FALSE)
    if (file.access("logs", mode = 2) != 0) {
        message("Pipeline: logs/ isn't writable, so error reports will only go to stderr.")
    }
})
