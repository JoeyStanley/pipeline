# A list of normalization methods and their calls. This is used to reduce the amount of code in server.R
norm_methods <- list(
    "n"  = list(suffix = "_n",  fn = function(df) norm_track_generic(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "lm" = list(suffix = "_lm", fn = function(df) norm_track_nearey(df,  matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "z"  = list(suffix = "_z",  fn = function(df) norm_track_lobanov(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "df" = list(suffix = "_df", fn = function(df) norm_track_deltaF(df,  matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time)),
    "wf" = list(suffix = "_wf", fn = function(df) norm_track_wattfab(df, matches("F[1234]$"), .by = speaker_id, .token_id_col = token_id, .time_col = prop_time))
)