

# This is the first processing once a raw DARLA file comes in.
prep_darla_data <- function(.df) {
    .df |> 
        
        # Get the columns I want with the names I want in the order I want
        clean_names() |> 
        rowid_to_column("vowel_id") |> 
        select(source_file, speaker_id = name, word, 
               token_id = vowel_id, pre_seg, fol_seg, stress, phoneme = vowel, time = t, duration = dur, 
               matches("F[12]_\\d")) |> 
        
        # Fix transcriptions
        mutate(phoneme = arpa_to_wells(phoneme)) |> 
        
        # light processing
        mutate(word = tolower(word),
               token_id = as.character(token_id)) |>
        rename_with(str_to_title, matches("f\\d")) |> 
        manually_reclassify_some_words() |> 
        
        
        # Reshape
        pivot_longer(cols = matches("_percent"), 
                     names_to = c(".value", "prop_time"), 
                     names_pattern = "(F\\d)_(\\d\\d)") |> 
        mutate(prop_time = as.numeric(prop_time),
               prop_time = prop_time / 100) |> 
        filter(!is.na(F1), 
               !is.na(F2))

}

prep_newfave_data <- function(.df) {
    .df |> 
        # Get the columns I want with the names I want in the order I want
        clean_names() |> 
        select(source_file, speaker_id = file_name, word,
               token_id = id, pre_seg, fol_seg, stress, label, time, duration = dur, prop_time, F1 = f1, F2 = f2, F3 = f3) |>
        
        # Fix transcriptions
        fave_to_wells() |> 
        select(-label) |> 
        
        # light processing
        mutate(word = tolower(word),
               across(c(time, duration, F1:F3, prop_time), ~round(., 4))) |> 
        manually_reclassify_some_words()
}



manually_reclassify_some_words <- function(.df) {
    .df |>
        mutate(phoneme =
                   case_when(
            word %in% c("was", "gonna", "because", "wanna") ~ "STRUT",
            word %in% c("twenty") ~ "STRUT",
            TRUE ~ phoneme))
}




ooo1_code_allophones <- function(.df) {
    .df |> 
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





ooo4_filter_otherwise_good_data <- function(.df) {
    .df |> 
        filter(stress == 1,
               !is_stopword)
}




