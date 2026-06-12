if (file.exists("renv/activate.R")) {
    tryCatch(source("renv/activate.R"), error = function(e) {
        message("renv/activate.R failed: ", conditionMessage(e))
    })
}
