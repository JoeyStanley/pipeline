

library(shiny)
#library(DT)

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
library(joeyr)

# Increase max upload size from 5MG to 50MB: https://stackoverflow.com/questions/18037737/how-to-change-maximum-upload-size-exceeded-restriction-in-shiny-and-save-user
options(shiny.maxRequestSize=50*1024^2)

## Process data ----
process_data <- function(df) {
    df %>%
        clean_names() %>%
        select(speaker_id = name, everything(),
               -matches("lobanov"), -b1, -b2, -b3, -beg, -end, -matches("word_trans"), -matches("_word"), -n_formants) %>%
        rename_with(ucfirst, matches("f\\d")) %>%
        rename(phoneme = vowel) %>%
        mutate(word = tolower(word)) %>%
        rowid_to_column("vowel_id") %>%
        # Reclassify
        mutate(phoneme = case_when(word %in% c("was", "gonna", "because", "wanna") ~ "AH",
                                   word %in% c("twenty") ~ "AH",
                                   TRUE ~ phoneme)) %>%
        
        # Reshape 
        select(-F1, -F2, -F3) %>%
        pivot_longer(cols = matches("_percent"), 
                     names_to = c(".value", "percent"), 
                     names_pattern = "(F\\d)_(\\d\\d)") %>%
        mutate(percent = as.numeric(percent)) %>%
        filter(!is.na(F1), !is.na(F2)) %>%
        
        # OoO1 Allophones
        mutate(phoneme = arpa_to_wells(phoneme)) %>%
        code_allophones(phoneme, .fol_seg = fol_seg, .pre_seg = pre_seg) %>%
        
        # OoO2 Outliers
        mutate(is_stopword = word %in% c(stopwords::stopwords(source = "marimo"), 
                                         "was", "gonna", "because", "wanna", "got", "mh", "kinda")) %>%
        mutate(outlier_group = case_when(is_stopword ~ "stopword",
                                         stress == 0 ~ "unstressed",
                                         TRUE ~ allophone)) %>%
        group_by(speaker_id, outlier_group) %>%
        filter(!find_outliers(F1, F2)) %>%
        ungroup() %>%
        
        # OoO3 Normalization
        # group_by(speaker_id, phoneme) %>%
        # mutate(across(.cols = c(F1, F2),
        #               .fns = c(`z` = scale, `log` = log10),
        #               .names = "{.col}_{.fn}")) %>%
        # ungroup() %>%
        # norm_logmeans(c(F1_log, F2_log),
        #               .speaker_col = speaker_id,
        #               .vowel_col = phoneme) %>%
        
        # OoO4 Remove other data?
        filter(stress == 1,
               !is_stopword) %>%
        # print() %>%
        return()
}

function(input, output, session) {
    
    # Loading sample data wasn't working. But that code would go here.


    ## Get data (and subsets) ----
    full_df <- eventReactive(input$process_uploaded_button, {
        withProgress(message = "Processing…",
                     detail = "This may take a few seconds.",
                     value =- 0,
                     {
                         req(input$uploaded_data)
                         read_csv(input$uploaded_data$datapath, show_col_types = FALSE) %>%
                             process_data()
                     })
    })

    midpoints_df <- eventReactive(input$process_uploaded_button, {
        req(input$uploaded_data)
        full_df() %>%
            filter(percent == 50)
    })

    trajectories_df <- eventReactive(input$process_uploaded_button, {
        req(input$uploaded_data)
        full_df()
    })

    ## Show all data ----
    output$show_all_data <- DT::renderDataTable(DT::datatable({
        full_df()
    }))

    ## Export data ----
    output$export_processed <- downloadHandler(
        filename = function() { "formants_processed.csv" },
        content  = function(file) {
            full_df() %>%
                write_csv(file = file)
        }
    )

    ## Update UI ----
    observe({
        list_of_speakers <- full_df() %>%
            pull(speaker_id) %>%
            unique()

        updateSelectInput(session, "speaker_selection",
                          choices = list_of_speakers,
                          selected = head(list_of_speakers, 1)
        )
    })


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

    # A function for generating the plot.
    generate_plot <- function() {

        ### Prep the data ----
        midpoint_df <- midpoints_df() %>%
            filter(speaker_id %in% input$speaker_selection,
                   phoneme %in% input$vowels,
                   allophone_environment %in% input$environments)

        trajectories_df <- full_df() %>%
            filter(speaker_id %in% input$speaker_selection,
                   phoneme %in% input$vowels,
                   allophone_environment %in% input$environments)

        # Get different summaries of the data for trajectories.
        summarized_trajectories_df <- trajectories_df %>%
            mutate(plotting_group = vowel_id)
        if (input$trajectory_type == "mean") {
            summarized_trajectories_df <- trajectories_df %>%
                group_by(phoneme, allophone, percent) %>%
                summarize(across(c(F1, F2), .fns = mean), .groups = "drop_last") %>%
                mutate(plotting_group = allophone)
        } else if (input$trajectory_type == "median") {
            summarized_trajectories_df <- trajectories_df %>%
                group_by(phoneme, allophone, percent) %>%
                summarize(across(c(F1, F2), .fns = median), .groups = "drop_last") %>%
                mutate(plotting_group = allophone)
        } else if (input$trajectory_type == "smoothed") {
            summarized_trajectories_df <- trajectories_df %>%
                pivot_longer(cols = c(F1, F2), names_to = "formant", values_to = "hz") %>%
                group_by(phoneme, allophone, formant) %>%
                nest() %>%
                mutate(mdl = map(data, ~gam(hz ~ percent + s(percent, k = 4), data = .)),
                       preds = map(mdl, ~get_predictions(., cond = list(percent = 20:80),
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
            labels_df <- summarized_trajectories_df %>%
                filter(percent == min(percent))
        } else{
            labels_df <- midpoint_df %>%
                group_by(phoneme, allophone) %>%
                summarize(across(matches("F\\d"), mean), .groups = "drop_last")
        }

        # Elsewhere allophones, for the hull
        vowel_space <- midpoints_df() %>%
            filter(speaker_id %in% input$speaker_selection,
                   allophone %in% c("BEET", "BIT", "BAIT", "BET", "BAT", "BOT", "BOUGHT", "BOAT", "PUT", "BOOT")) %>%
            group_by(speaker_id, allophone) %>%
            summarize(across(c(F1, F2), mean), .groups = "drop_last")

        # Reference points
        reference_points <- vowel_space %>%
            filter(speaker_id %in% input$speaker_selection,
                   allophone %in% c("BEET", "BOAT", "BOT", "BAT"))

        ### Basic elements ----
        p <- ggplot(midpoint_df, aes(F2, F1))

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
                               aes(group = quote(plotting_group), color = .data[[input$color_variable]]),
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
                   !is.na(F1),
                   !is.na(F2))
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
            summarize(across(c(F1, F2), mean), .groups = "drop_last")

        # Elsewhere allophones, for the hull
        vowel_space <- midpoints_df() %>%
            filter(allophone %in% c("BEET", "BIT", "BAIT", "BET", "BAT", "BOT", "BOUGHT", "BOAT", "PUT", "BOOT")) %>%
            group_by(allophone) %>%
            summarize(across(c(F1, F2), mean), .groups = "drop_last")
        # Reference points
        reference_points <- vowel_space %>%
            filter(allophone %in% c("BEET", "BOAT", "BOT", "BAT"))

        # Basic plot
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
    output$pillai_score_message <- renderPrint({
        cat("Here is the Pillai score. Values range from 0 (=complete overlap) to 1 (complete separation).")
    })
    output$pillai_p <- renderPrint({
        p <- pillai_df() %>%
            summarize(p = manova_p(cbind(F1, F2) ~ allophone), .groups = "drop_last") %>%
            pull()
        cat(ifelse(p < 0.001, "< 0.001", round(p, 3)))
    })
    output$pillai_p_message <- renderPrint({
        cat("Here is the p-value. If it's less than 0.05, it means the difference between the two vowels is statistically significant.")
    })
}
