
# Increase max upload size from 5MG to 100MB: https://stackoverflow.com/questions/18037737/how-to-change-maximum-upload-size-exceeded-restriction-in-shiny-and-save-user
options(shiny.maxRequestSize=100*1024^2)

function(input, output, session) {
    
    ## Add and remove data ----
    
    full_df <- reactiveVal(NULL)
    loaded_files   <- reactiveVal(character(0))  # tracks file names for the UI list
    selected_files <- reactiveVal(character(0))  # tracks which are checked for removal
    
    # Keep track of which normalizations have been done on this dataset. (Updates when dataset changes.)
    completed_normalizations <- reactiveVal(character(0))
    
    # Loading data (first or subsequent)
    observeEvent(input$process_uploaded_button, {
        withProgress(message = "Processing data…",
                     detail = "This may take a few seconds.",
                     value = 0,
                     {
                         incProgress(1/4, detail = "Reading file…")
                         # Get the data path. If uploaded, then pull from there. If sample, then pull from local data.
                         if (input$data_source == "sample") {
                             path_to_data <- "data/joey_darla.csv"
                             this_file_name    <- "joey_darla.csv"
                         } else {
                             req(input$uploaded_data)
                             path_to_data <- input$uploaded_data$datapath
                             this_file_name    <- input$uploaded_data$name
                         }
                         
                         # Don't crash if darla data is uploaded with the new-fave button and vice versa
                         tryCatch({
                             raw <- read_csv(path_to_data, show_col_types = FALSE) |> 
                                 # keep source file to allow for removing later on
                                 mutate(source_file = this_file_name) 
                             
                             # Prep data according to data source.
                             incProgress(1/4, detail = "Prepping data…")
                             cleaned <- if (input$data_source == "new-fave") {
                                 prep_newfave_data(raw)
                             } else {
                                 prep_darla_data(raw)
                             }
                             
                             incProgress(1/4, message = "Applying Order of Operations", detail = "Step 1: Coding allophones…")
                             ooo1 <- ooo1_code_allophones(cleaned)
                             
                             incProgress(1/4, detail = "Step 2: Removing outliers… (Note: this is the most time consuming step)")
                             ooo2 <- ooo2_remove_outliers(ooo1)
                             
                             # Save/add to the new datasets
                             if (is.null(full_df())) {
                                 full_df(ooo2)
                             } else {
                                 full_df(bind_rows(full_df(), ooo2))
                             }
                             loaded_files(c(loaded_files(), this_file_name))
                             
                             # Strip any previously normalized columns so they get recomputed fresh
                             full_df(full_df() |> select(-matches("F[1234]_[a-z]+$")))
                             # After adding data, reset what normalization procedures have been done.
                             completed_normalizations(character(0))
                             
                         }, error = function(e) {
                             showNotification(
                                 ui       = paste("Processing failed. Please check that your data source selection (e.g. DARLA vs. new-fave)",
                                                  "matches the file you uploaded.",
                                                  "\nIf the problem persists, the error was:", conditionMessage(e)),
                                 type     = "error",
                                 duration = NULL   # stays until user dismisses it
                             )
                         })
                     })
    })
    
    # Update button label dynamically
    observe({
        label <- if (is.null(full_df())) "Process my data" else "Process and add to existing data"
        updateActionButton(session, "process_uploaded_button", label = label)
    })
    
    
    # Update the list of speakers whenever the full dataset changes.
    observe({
        req(full_df())
        list_of_speakers <- full_df() |> pull(speaker_id) |> unique()
        
        # Keep current selection of speakers if it's still valid, otherwise default to first
        current_selection <- isolate(input$speaker_selection)
        still_valid <- intersect(current_selection, list_of_speakers)
        new_selection <- if (length(still_valid) > 0) still_valid else head(list_of_speakers, 1)
        
        updateSelectInput(session, "speaker_selection",
                          choices  = list_of_speakers,
                          selected = new_selection)
        
    })
    
    
    # Keep selected_files in sync with the checkboxes
    observe({
        selected_files(input$selected_for_removal %||% character(0))
    })
    
    # Remove selected datasets
    observeEvent(input$remove_data_button, {
        
        to_remove <- selected_files()
        req(length(to_remove) > 0)
        
        remaining <- setdiff(loaded_files(), to_remove)
        loaded_files(remaining)
        selected_files(character(0))
        
        if (length(remaining) == 0) {
            # explicitly NULL when last dataset removed
            full_df(NULL)  
        } else {
            
            # Re-filter the data to only keep rows from remaining files
            full_df(full_df() |> filter(source_file %in% remaining))
            
            # Strip any previously normalized columns so they get recomputed fresh
            full_df(full_df() |> select(-matches("F[1234]_[a-z]+$")))
            
        }
        
        # After removing data, reset what normalization procedures have been done.
        completed_normalizations(character(0))
    })
    
    
    # Render the dynamic checklist of loaded files
    output$loaded_datasets_list <- renderUI({
        files <- loaded_files()
        if (length(files) == 0) {
            p("No datasets loaded yet.", style = "color: gray;")
        } else {
            checkboxGroupInput("selected_for_removal",
                               label = NULL,
                               choices = files,
                               selected = NULL)
        }
    })
    
    
    ### Get subsets----
    
    #### Normalize ----
    # Because it's a reactive thing, I'll put it here. 
    
    observe({
        # Make sure there is data and it's not empty.
        req(full_df())
        req(nrow(full_df()) > 0)
        
        # Get the normalization methods from the list saved in sociophonetics.R
        method <- input$norm_method
        info   <- norm_methods[[method]]
        
        # Only run normalization if we haven't done it before
        if (!method %in% completed_normalizations()) {
            withProgress(message = "Applying Order of Operations", detail = "Step 3: Normalizing…", {
                full_df(info$fn(full_df()))
            })
            completed_normalizations(c(completed_normalizations(), method))
        }
        
        # Create a copy of this new column and call it "norm" for ease of subsequent processing.
        full_df(full_df() |>
                    mutate(F1_norm = .data[[paste0("F1", info$suffix)]],
                           F2_norm = .data[[paste0("F2", info$suffix)]]))
    })
    
    # Create just a midpoints df.
    midpoints_df <- reactive({ 
        req(full_df())
        
        full_df() |> 
            ooo4_filter_otherwise_good_data() |>
            filter(prop_time > 0.4,
                   prop_time < 0.6) |>
            summarize(across(matches("F[1234]"), mean, na.rm = TRUE),
              .by = -c(prop_time, time, matches("F\\d")))
    })
    
    # Create a trajectory df. Same as the normed df, but here for clarity.
    trajectories_df <- reactive({ full_df() |>  ooo4_filter_otherwise_good_data() })
    
    
    ### Show all data ----
    output$show_all_data <- DT::renderDataTable(DT::datatable({
        full_df()
    }))

    ### Export data ----
    
    output$export_processed <- downloadHandler(
        filename = function() { "pipeline_output.csv" },
        content  = function(file) {
            full_df() %>% write_csv(file = file)
        }
    )
    
    

    ## Download image ----

    output$fig_download <- downloadHandler(
        filename = function() { paste0(input$fig_filename, ".", tolower(input$fig_filetype)) },
        content = function(file) {
            ggsave(file,
                   plot   = generate_plot(),
                   height = input$fig_height,
                   width  = input$fig_width,
                   dpi    = input$fig_dpi,
                   device = ifelse(input$fig_filetype == "PDF", cairo_pdf, tolower(input$fig_filetype)))
        }
    )


    ## Generate the main plot ----
    # Take that generated plot and push it to the output object.
    # Note that having a separate function to generate and call the plot is better because of the downloading code.
    output$midpoints_plot <- renderPlot({
        generate_plot()
    })
    
    midpoint_df_to_plot <- reactive({
        req(midpoints_df())
        midpoints_df() |> 
            filter(speaker_id %in% input$speaker_selection,
                   phoneme %in% input$vowels,
                   allophone_environment %in% input$environments)
    })
    trajectories_df_to_plot <- reactive({
        req(trajectories_df())
        trajectories_df() |> 
            filter(speaker_id %in% input$speaker_selection,
                   phoneme %in% input$vowels,
                   allophone_environment %in% input$environments)
    })
    vowel_space_df_for_hull <- reactive({
        req(midpoints_df())
        midpoints_df() |> 
            filter(speaker_id %in% input$speaker_selection,
                   allophone %in% c("BEET", "BIT", "BAIT", "BET", "BAT", "BOT", "BOUGHT", "BOAT", "PUT", "BOOT")) %>%
            group_by(speaker_id, allophone) %>%
            summarize(across(matches("F[1234]_norm"), mean, na.rm = TRUE), .groups = "drop_last")
    })

    # A function for generating the plot.
    generate_plot <- function() {
        
        ### Get the data. (Offloaded to reactive so it only reruns data prep if needed and not for small plot changes.)
        midpoint_df <- midpoint_df_to_plot()
        trajectories_df <- trajectories_df_to_plot()
        # Elsewhere allophones, for the hull
        vowel_space <- vowel_space_df_for_hull()

            
        # Get different summaries of the data for trajectories.
        summarized_trajectories_df <- trajectories_df |> 
            mutate(plotting_group = token_id)
        if (input$trajectory_type == "mean") {
            summarized_trajectories_df <- trajectories_df %>%
                group_by(phoneme, allophone, prop_time) %>%
                summarize(across(matches("F[1234]"), .fns = mean), .groups = "drop_last") %>%
                mutate(plotting_group = allophone)
        } else if (input$trajectory_type == "median") {
            summarized_trajectories_df <- trajectories_df %>%
                group_by(phoneme, allophone, prop_time) %>%
                summarize(across(matches("F[1234]"), .fns = median), .groups = "drop_last") %>%
                mutate(plotting_group = allophone)
        } else if (input$trajectory_type == "smoothed") {
            summarized_trajectories_df <- trajectories_df %>%
                pivot_longer(cols = matches("F[1234]"), names_to = "formant", values_to = "hz") %>%
                group_by(phoneme, allophone, formant) %>%
                nest() %>%
                mutate(mdl = map(data, ~gam(hz ~ prop_time + s(prop_time, k = 4), data = .)),
                       preds = map(mdl, ~get_predictions(., cond = list(prop_time = 20:80),
                                                         print.summary = FALSE,
                                                         rm.ranef = FALSE))) %>%
                select(-data, -mdl) %>%
                unnest(preds) %>%
                rename(hz = fit) %>%
                select(-CI) %>%
                pivot_wider(names_from = formant, values_from = hz) %>%
                mutate(plotting_group = allophone)
        }

        # Labels (mean for points, onset for trajectories)
        if (input$show_trajectories & input$trajectory_type != "raw") {
            labels_df <- summarized_trajectories_df |> 
                filter(prop_time == min(prop_time))
        } else{
            labels_df <- midpoint_df %>%
                group_by(phoneme, allophone) %>%
                summarize(across(matches("F\\d_norm"), mean, na.rm = TRUE), .groups = "drop_last")
        }

        # Reference points
        reference_points <- vowel_space %>%
            filter(speaker_id %in% input$speaker_selection,
                   allophone %in% c("BEET", "BOAT", "BOT", "BAT"))

        ### Basic elements ----
        p <- ggplot(midpoint_df, aes(F2_norm, F1_norm))

        ### Optional elements ----
        if (input$main_reference_points) {
            p <- p + geom_text(data = reference_points, aes(label = allophone), color = "gray20", size = 10)
        }
        if (input$main_vowel_space) {
            p <- p + geom_mark_hull(data = vowel_space, aes(group = 1), color = "gray20")
        }
        if (input$show_points) {
            p <- p + geom_point(aes(color = .data[[input$color_variable]]),
                                size = input$points_size, alpha = input$points_alpha)
        }
        if (input$show_ellipses) {
            p <- p + stat_ellipse(aes(group = .data[[input$ellipse_variable]], color = .data[[input$color_variable]]),
                                  level = input$ellipses_size/100, alpha = input$ellipses_alpha)
        }
        if (input$show_means) {
            p <- p +
                geom_text(data = labels_df,
                          aes(color = .data[[input$color_variable]], label = .data[[input$label_variable]]),
                          size = input$means_size, alpha = input$means_alpha)
        }
        if (input$show_words) {
            p <- p + geom_text(aes(label = word,
                                   color = .data[[input$color_variable]]),
                               size = input$words_size, alpha = input$words_alpha)
        }
        if (input$show_trajectories) {
            p <- p + geom_path(data = summarized_trajectories_df, 
                               aes(group = plotting_group, color = .data[[input$color_variable]]),
                               arrow = joey_arrow(), alpha = input$trajectories_alpha, linewidth = input$trajectories_size)
        }
        # if (!is.na(input$trajectory_label_location)) {
        #   p <- p + geom_text(data = trajectory_labels_df,
        #                      aes(color = .data[[input$color_variable]], label = .data[[input$label_variable]]),
        #                      size = input$means_size, alpha = input$means_alpha)
        # }

        ### Final elements----
        p <- p +
            scale_x_reverse() +
            scale_y_reverse() +
            labs(title = input$title,
                 subtitle = input$subtitle,
                 x = input$x_label,
                 y = input$y_label) +
            theme_minimal(base_size = input$base_size, base_family = input$base_family) +
            theme(legend.position = if_else(input$show_legend, "right", "none"))

        p

    }



    ## Pillai scores ----
    ### Pillai scores data ----
    pillai_df <- reactive({
        midpoints_df() %>%
            filter(speaker_id %in% input$speaker_selection,
                   allophone %in% case_when(input$vowel_pair == "feel-fill"  ~ c("ZEAL",  "GUILT"),
                                            input$vowel_pair == "fail-fell"  ~ c("FLAIL", "SHELF"),
                                            input$vowel_pair == "pull-pole"  ~ c("WOLF",  "JOLT"),
                                            input$vowel_pair == "pole-dull"  ~ c("JOLT",  "MULCH"),
                                            input$vowel_pair == "pull-dull"  ~ c("WOLF",  "MULCH"),

                                            # TODO: Add Mary-merry-marry
                                            # input$vowel_pair == "Mary-merry"  ~ c("WOLF",  "MULCH"),
                                            # input$vowel_pair == "merry-marry"  ~ c("WOLF",  "MULCH"),
                                            # input$vowel_pair == "Mary-marry"  ~ c("WOLF",  "MULCH"),
                                            # input$vowel_pair == "north/force-card"  ~ c("WOLF",  "MULCH"),

                                            input$vowel_pair == "pin-pen"    ~ c("BIN",   "BEN"),
                                            input$vowel_pair == "bat-ban"    ~ c("BAT",   "BAN"),

                                            input$vowel_pair == "vague-beg"  ~ c("VAGUE", "BEG"),
                                            input$vowel_pair == "vague-bag"  ~ c("VAGUE", "BAG"),
                                            input$vowel_pair == "beg-bag"    ~ c("BEG",   "BAG"),
                                            input$vowel_pair == "beg-bet"    ~ c("BEG",   "BET"),
                                            input$vowel_pair == "bag-bat"    ~ c("BAG",   "BAT"),

                                            input$vowel_pair == "cot-caught"     ~ c("BOT",  "BOUGHT"),
                                            input$vowel_pair == "goose-fronting" ~ c("TOOT", "BOOT")),
                   !is.na(F1_norm),
                   !is.na(F2_norm))
    })
    ### Pillai data summary table ----
    output$pillai_pairs_summary <- renderTable({
        pillai_df() %>%
            count(allophone, name = "number of tokens")
    })
    ### Pillai plot ----
    output$vowel_pair_plot <- renderPlot({
        group_means <- pillai_df() %>%
            group_by(allophone) %>%
            summarize(across(matches("F[1234]"), mean), .groups = "drop_last")
        
        # Elsewhere allophones, for the hull
        vowel_space <- vowel_space_df_for_hull()
        
        # Reference points
        reference_points <- vowel_space %>%
            filter(allophone %in% c("BEET", "BOAT", "BOT", "BAT"))

        # Basic plot. Note that this uses raw values instead of normalized values.
        # My blog post shows that doing raw vs. normalized (at least for a few normalization methods) doesn't matter.
        # If I want to do normalized values, I'd have to add a new tab to toggle between procedures.
        p <- ggplot(pillai_df(), aes(F2, F1, color = allophone))

        if (input$pillai_reference_points) {
            p <- p + geom_text(data = reference_points, aes(label = allophone), color = "gray20", size = 10)
        }
        if (input$pillai_vowel_space) {
            p <- p + geom_mark_hull(data = vowel_space, aes(group = 1), color = "gray20")
        }

        p +
            geom_text(aes(label = word)) +
            stat_ellipse() +
            geom_text(data = group_means, aes(label = allophone), size = 10) +
            scale_color_ptol() +
            scale_x_reverse() +
            scale_y_reverse() +
            theme_minimal() +
            theme(legend.position = "none")

    })
    ### Pillai results ----
    output$pillai_total_n <- renderPrint({
        cat(nrow(pillai_df()))
    })
    output$pillai_total_n_message <- renderPrint({
        warning <- if_else(nrow(pillai_df()) < 30,
                           "(It's recommended that you have at least 30 tokens.)",
                           "")
        cat(paste("Here is the total number of tokens you're using to calculate a Pillai score.", warning))
    })
    output$pillai_threshold <- renderPrint({
        cat(round(exp(1)/(nrow(pillai_df())/2),3))
    })
    output$pillai_threshold_message <- renderPrint({
        cat("Assuming your speaker is underlyingly merged, their Pillai score is expected to be below this value. This is based on how much data you have.")
    })
    output$pillai_score <- renderPrint({
        pillai_df() %>%
            summarize(pillai = pillai(cbind(F1, F2) ~ allophone), .groups = "drop_last") %>%
            pull() %>%
            round(3) %>%
            cat()
    })
    output$pillai_score_message <- renderText({
        "Here is the Pillai score. Values range from 0 (=complete overlap) to 1 (complete separation)."
    })
    output$pillai_p <- renderPrint({
        p <- pillai_df() %>%
            summarize(p = manova_p(cbind(F1, F2) ~ allophone), .groups = "drop_last") %>%
            pull()
        cat(ifelse(p < 0.001, "< 0.001", round(p, 3)))
    })
    output$pillai_p_message <- renderText({
        "Here is the p-value. If it's less than 0.05, it means the difference between the two vowels is statistically significant."
    })
}
