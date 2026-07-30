
# A list of stopwords
# TODO: Make this list flexible like the GSV.
my_stopwords <- c(stopwords(source = "marimo"),
                    "okay", "was", "gonna", "because", "wanna", "got", "mh", "kinda")


# A list of normalization methods and their calls. This is used to reduce the amount of code in server.R
# Track data (multiple rows per token) needs the DCT-based norm_track_* functions, which fit a
# trajectory per token via .token_id_col/.time_col. Points data (one row per token) has no
# trajectory to fit — feeding it to norm_track_* silently returns all-NA formant columns — so it
# needs the plain norm_* functions instead. server.R picks track_fn vs. point_fn based on shape.
norm_methods <- list(
    "lm" = list(suffix = "_lm",
                track_fn = function(df) norm_track_nearey(df,  matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time, .silent = TRUE),
                point_fn = function(df) norm_nearey(df,        matches("F[1234]$"), .by = speaker_id, .silent = TRUE)),
    "z"  = list(suffix = "_z",
                track_fn = function(df) norm_track_lobanov(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time, .silent = TRUE),
                point_fn = function(df) norm_lobanov(df,       matches("F[1234]$"), .by = speaker_id, .silent = TRUE)),
    "df" = list(suffix = "_df",
                track_fn = function(df) norm_track_deltaF(df,  matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time, .silent = TRUE),
                point_fn = function(df) norm_deltaF(df,        matches("F[1234]$"), .by = speaker_id, .silent = TRUE)),
    "wf" = list(suffix = "_wf",
                track_fn = function(df) norm_track_wattfab(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time, .silent = TRUE),
                point_fn = function(df) norm_wattfab(df,       matches("F[1234]$"), .by = speaker_id, .silent = TRUE))
)

# Put the vowels in groups. This is pulled into the UI when selecting vowels.
# TODO: Add Mary-merry-marry and north/force/start but those rely on information beyond what DARLA/newfave gives
vowel_pair_groups <- list(
    "prelateral" = list(
        "feel-fill"      = c("ZEAL",  "GUILT"),
        "fail-fell"      = c("FLAIL", "SHELF"),
        "pull-pole"      = c("WOLF",  "JOLT"),
        "pole-dull"      = c("JOLT",  "MULCH"),
        "pull-dull"      = c("WOLF",  "MULCH")
    ),
    "prenasal" = list(
        "pin-pen"        = c("BIN",  "BEN"),
        "bat-ban"        = c("BAT",  "BAN")
    ),
    "prevelar" = list(
        "vague-beg"      = c("VAGUE", "BEG"),
        "vague-bag"      = c("VAGUE", "BAG"),
        "beg-bag"        = c("BEG",   "BAG"),
        "beg-bet"        = c("BEG",   "BET"),
        "bag-bat"        = c("BAG",   "BAT")
    ),
    "other" = list(
        "cot-caught"     = c("BOT",  "BOUGHT"),
        "goose-fronting" = c("TOOT", "BOOT")
    )
)



# A list of vowel pairs to work with when doing pillai scores.
# vowel_pair_map <- list(
#     "feel-fill"      = c("ZEAL",  "GUILT"),
#     "fail-fell"      = c("FLAIL", "SHELF"),
#     "pull-pole"      = c("WOLF",  "JOLT"),
#     "pole-dull"      = c("JOLT",  "MULCH"),
#     "pull-dull"      = c("WOLF",  "MULCH"),
#     
#     
#     
#     "pin-pen"        = c("BIN",   "BEN"),
#     "bat-ban"        = c("BAT",   "BAN"),
#     
#     "vague-beg"      = c("VAGUE", "BEG"),
#     "vague-bag"      = c("VAGUE", "BAG"),
#     "beg-bag"        = c("BEG",   "BAG"),
#     "beg-bet"        = c("BEG",   "BET"),
#     "bag-bat"        = c("BAG",   "BAT"),
#     
#     "cot-caught"     = c("BOT",  "BOUGHT"),
#     "goose-fronting" = c("TOOT", "BOOT")
# )

# Use this to pull out the pairs from the grouping.
vowel_pair_map <- unlist(
    lapply(vowel_pair_groups, function(group) group),
    recursive = FALSE
)

# Fix names — unlist adds the group prefix e.g. "prelateral.feel-fill"
names(vowel_pair_map) <- sub("^[^.]+\\.", "", names(vowel_pair_map))
