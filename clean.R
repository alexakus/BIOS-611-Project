library("tidyverse")
library("glue")
library("stringi")

path <- "data"

#import raw lines to remove mismatched quotes (e.g., [12" version])
raw_data <- as_tibble(readLines(file.path(path,"spotify_dataset.csv")))

colnames(raw_data) <- c("line")

cleaned_data <- raw_data %>% filter(str_count(line, "\"") == 8)
removed_data <- raw_data %>% filter(str_count(line, "\"") != 8) %>% mutate(count=str_count(line, "\""))

message(glue("{nrow(removed_data)} lines with excess quotations removed"))

#write back to csv
writeLines(cleaned_data$line, file.path(path,"spotify_dataset_preprocessed.csv"))
rm(raw_data)
rm(cleaned_data)
rm(removed_data)

#import pre-processed dataset
spotify_dataset_raw <- read_csv(file.path(path,"spotify_dataset_preprocessed.csv")) %>% as.tibble()
colnames(spotify_dataset_raw) <- c("user_id","artist","track","playlist")

#remove some more observations that could confound the analysis
cleaned_data <- spotify_dataset_raw %>% filter(!is.na(artist))
removed_data <- anti_join(spotify_dataset_raw, cleaned_data, by = c("user_id", "artist", "track", "playlist"))

message(glue("{nrow(removed_data)} observations with missing/blank artist removed"))

spotify_dataset_raw <- cleaned_data
rm(cleaned_data)
rm(removed_data)

#change accented text to standard (e.g., Beyoncé to Beyonce)
message("Changing accented text (e.g., Beyoncé) to Latin-ASCII (i.e., Beyonce)")
message("This may take a few minutes")
spotify_dataset_raw <- spotify_dataset_raw %>% mutate(across(everything(), ~ stri_trans_general(., "Latin-ASCII")))

#remove non-standard characters
keep <- "^[a-zA-Z0-9,!?()&'.:/+$*;#\\[\\]\\- ]+$"
cleaned_data <- spotify_dataset_raw %>% filter( str_detect(user_id, keep) &
                                                str_detect(artist, keep) &
                                                str_detect(track, keep) &
                                                str_detect(playlist, keep))
removed_data <- anti_join(spotify_dataset_raw, cleaned_data, by = c("user_id", "artist", "track", "playlist"))

message(glue("{nrow(removed_data)} observations with non-standard characters removed"))

spotify_dataset_raw <- cleaned_data
rm(cleaned_data)
rm(removed_data)

#remove generic "intro" song title and generic/default playlist names
cleaned_data <- spotify_dataset_raw %>%
  filter( toupper(track) != "INTRO" &
          !toupper(playlist) %in% c("STARRED", 
                                    "LIKED FROM RADIO", 
                                    "FAVORITAS DE LA RADIO", 
                                    "NEW PLAYLIST", 
                                    "IPHONE", 
                                    "ALL LIVE FILES", 
                                    "MY SHAZAM TRACKS", 
                                    "ITUNES",
                                    "HOME ITUNES",
                                    "MUSIC",
                                    "FAVORITES",
                                    "RECENTLY ADDED") &
          !str_starts(toupper(playlist), "LIBRARY & STREAMS"))
removed_data <- anti_join(spotify_dataset_raw, cleaned_data, by = c("user_id", "artist", "track", "playlist"))

message(glue("{nrow(removed_data)} observations with generic (e.g., Intro) song titles and generic/default playlist names (e.g., Starred, Liked from radio, etc.) removed"))

spotify_dataset_raw <- cleaned_data
rm(cleaned_data)
rm(removed_data)

#remove playlists named after the artist
cleaned_data <- spotify_dataset_raw %>%
  filter(
    !str_detect(
      toupper(playlist),
      str_c("\\b", str_replace_all(toupper(artist), "([\\+\\.\\^\\$\\*\\?\\(\\)\\[\\]\\{\\}\\|\\\\])", "\\\\\\1"), "\\b")
    )  # Only check the playlist for matches with the artist's name
  )

removed_data <- anti_join(spotify_dataset_raw, cleaned_data, by = c("user_id", "artist", "track", "playlist"))

message(glue("{nrow(removed_data)} observations with playlist named after the artist removed"))

spotify_dataset_raw <- cleaned_data
rm(cleaned_data)
rm(removed_data)

write_csv(spotify_dataset_raw, file.path(path,"spotify_dataset_clean.csv"))