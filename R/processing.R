

# This is the first processing once a raw DARLA file comes in.
clean_darla_columns <- function(.df) {
    .df |> 
        clean_names() |> 
        select(speaker_id = name, everything(),
               -matches("lobanov"), -b1, -b2, -b3, -beg, -end, -matches("word_trans"), -matches("_word"), -n_formants) |>
        rename_with(ucfirst, matches("f\\d")) |>
        rename(phoneme = vowel) |>
        mutate(word = tolower(word)) |>
        rowid_to_column("vowel_id")
}







manually_reclassify_some_words <- function(.df) {
    .df |> 
        mutate(phoneme = 
                   case_when(
            word %in% c("was", "gonna", "because", "wanna") ~ "AH",
            word %in% c("twenty") ~ "AH",
            TRUE ~ phoneme))
}

# Reshape the trajectories. This is still part of the pre-OoO data processing.
reshape_trajectories <- function(.df) {
    .df |> 
        select(-F1, -F2, -F3) |> 
        pivot_longer(cols = matches("_percent"), 
                     names_to = c(".value", "percent"), 
                     names_pattern = "(F\\d)_(\\d\\d)") |> 
        mutate(percent = as.numeric(percent)) |> 
        filter(!is.na(F1), 
               !is.na(F2))
    
}




ooo1_code_allophones <- function(.df) {
    .df |> 
        mutate(phoneme = arpa_to_wells(phoneme)) %>%
        code_allophones(phoneme, .fol_seg = fol_seg, .pre_seg = pre_seg)
}



ooo2_remove_outliers <- function(.df) {
    .df |> 
        mutate(is_stopword = word %in% c(stopwords(source = "marimo"),
                                         "was", "gonna", "because", "wanna", "got", "mh", "kinda")) |> 
        mutate(outlier_group = case_when(is_stopword ~ "stopword",
                                         stress == 0 ~ "unstressed",
                                         TRUE ~ allophone)) |> 
        filter(!find_outliers(F1, F2), .by = c(speaker_id, outlier_group))
}


# TODO: Normalize
ooo3_normalize <- function(.df) {
    #|> 
    # group_by(speaker_id, phoneme) %>%
    # mutate(across(.cols = c(F1, F2),
    #               .fns = c(`z` = scale, `log` = log10),
    #               .names = "{.col}_{.fn}")) %>%
    # ungroup() %>%
    # norm_logmeans(c(F1_log, F2_log),
    #               .speaker_col = speaker_id,
    #               .vowel_col = phoneme)
    .df
}

ooo4_filter_otherwise_good_data <- function(.df) {
    .df |> 
        filter(stress == 1,
               !is_stopword)
}
