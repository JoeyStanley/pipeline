
# Originally part of the Idaho analysis, but I'm going to need this to seamlessly integrate from VoxHumana.
# Takes preliquid codes (e.g. "iyL") and properly turns them back into standard notation.
process_preliquids <- function(.df) {
    .df |> 
        
        # First, fix the false positives because they're across word boundaries.
        mutate(#context = if_else(fol_seg %in% c("L", "R"), "final", context), # turns out I don't keep the context column
               fol_seg = if_else(fol_seg %in% c("L", "R"), "#",     fol_seg)) |> 
        
        # Add a new column to separate out intervocalic laterals (not needed for Pipeline)
        # mutate(is_intervocalic = str_detect(fol_seg, "[a-z@ʌ]"), # <- vowels are always lowercase
        #        fol_seg2 = if_else(str_detect(label, "[LR]"), fol_seg, NA), 
        #        .after = fol_seg) |> 
        
        # Retag following segments
        mutate(fol_seg = case_when(str_detect(label, "\\A[a-z@ʌ]{1,2}L\\Z") ~ "L",
                                   str_detect(label, "\\A[a-z@ʌ]{1,2}R\\Z") ~ "R",
                                   TRUE ~ fol_seg)) |> 
        # Remove the liquids
        mutate(label = str_remove(label, "(?<=[a-z@ʌ]{1,2})[RL]\\Z"))
    
}


# This is the first processing once a raw DARLA file comes in.
prep_darla_data <- function(.df) {
    .df |> 
        
        # Get the columns I want with the names I want in the order I want
        clean_names() |> 
        rowid_to_column("id") |> 
        select(source_file, speaker_id = name, word, 
               token_id = id, pre_seg, fol_seg, stress, phoneme = vowel, time = t, duration = dur, 
               matches("F[12]_\\d")) |> 
        
        # Fix transcriptions
        mutate(phoneme = arpa_to_wells(phoneme)) |> 
        
        # light processing
        mutate(word = tolower(word),
               # Prefix with source_file: id alone is only unique within a single
               # upload, and collides if the same speaker appears across multiple uploads.
               token_id = paste(source_file, token_id, sep = "_")) |>
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
        
        # new-fave's own `id` column is only unique within a single source recording,
        # so it can't be trusted directly as a token identifier: files combining many
        # speakers/tasks into one CSV reset it, causing unrelated tokens to collide.
        select(source_file, speaker_id = file_name, word,
               id, pre_seg, fol_seg, stress, label, time, duration = dur, prop_time, F1 = f1, F2 = f2, F3 = f3) |>

        # Fix transcriptions
        process_preliquids() |>
        fave_to_wells() |> 
        select(-label) |>

        # light processing
        mutate(word = tolower(word),
               # Prefix with source_file: id alone is only unique within a single
               # upload, and collides if the same speaker appears across multiple uploads.
               token_id = paste(source_file, id, sep = "_"),
               across(c(time, duration, F1:F3, prop_time), ~round(., 4))) |>
        manually_reclassify_some_words()
}


# Note that this hard-codes Wells. DARLA data comes in ARPABET and FAVE comes in plotnik codes. 
# Those are both converted before this is called, but it's worth noting the dependency.
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


# Note that this creates the is_stopword column that ooo4 depends on.
ooo2_remove_outliers <- function(.df) {
    .df |> 
        mutate(is_stopword = word %in% my_stopwords) |> 
        mutate(outlier_group = case_when(is_stopword ~ "stopword",
                                         stress == 0 ~ "unstressed",
                                         TRUE ~ allophone)) |> 
        filter(!find_outliers(F1, F2), .by = c(speaker_id, outlier_group))
}


# Note: ooo3 (normalization) is a reactive observer in server.R rather than a
# plain function here, since it needs to cache results and respond to user input.

# Depends on the is_stopword column that ooo2 creates.
ooo4_filter_otherwise_good_data <- function(.df) {
    .df |> 
        filter(stress == 1,
               !is_stopword)
}




