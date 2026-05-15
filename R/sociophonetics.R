
# A list of stopwords
# TODO: Make this list flexible like the GSV.
my_stopwords <- c(stopwords(source = "marimo"),
                    "okay", "was", "gonna", "because", "wanna", "got", "mh", "kinda")


# A list of normalization methods and their calls. This is used to reduce the amount of code in server.R
norm_methods <- list(
    # Note that "n" is the "generic" one, which allows for flexiblity in creating a new method. 
    # Without change, it returns the exact same as the input. So "_n" means no normalization.
    "n"  = list(suffix = "_n",  fn = function(df) norm_track_generic(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "lm" = list(suffix = "_lm", fn = function(df) norm_track_nearey(df,  matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "z"  = list(suffix = "_z",  fn = function(df) norm_track_lobanov(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "df" = list(suffix = "_df", fn = function(df) norm_track_deltaF(df,  matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "wf" = list(suffix = "_wf", fn = function(df) norm_track_wattfab(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time))
)


# A list of vowel pairs to work with when doing pillai scores.
vowel_pair_map <- list(
    "feel-fill"      = c("ZEAL",  "GUILT"),
    "fail-fell"      = c("FLAIL", "SHELF"),
    "pull-pole"      = c("WOLF",  "JOLT"),
    "pole-dull"      = c("JOLT",  "MULCH"),
    "pull-dull"      = c("WOLF",  "MULCH"),
    
    # TODO: Add Mary-merry-marry and north/force/start but those rely on information beyond what DARLA/newfave gives
    
    "pin-pen"        = c("BIN",   "BEN"),
    "bat-ban"        = c("BAT",   "BAN"),
    
    "vague-beg"      = c("VAGUE", "BEG"),
    "vague-bag"      = c("VAGUE", "BAG"),
    "beg-bag"        = c("BEG",   "BAG"),
    "beg-bet"        = c("BEG",   "BET"),
    "bag-bat"        = c("BAG",   "BAT"),
    
    "cot-caught"     = c("BOT",  "BOUGHT"),
    "goose-fronting" = c("TOOT", "BOOT")
)