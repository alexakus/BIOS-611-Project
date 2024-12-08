library("tidyverse")
library("tidytext")
#import cleaned dataset
path <- "data"

spotify_dataset_clean<-read_csv(file.path(path,"spotify_dataset_clean.csv")) %>% as.tibble()
colnames(spotify_dataset_clean) <- c("user_id","artist","track","playlist")

#pivot to long
spotify_dataset_long <- spotify_dataset_clean %>%
  select(-user_id) %>%
  separate_rows(playlist, sep = " ") %>%  # Split words in 'playlist' into separate rows
  rename(word = playlist)                # Rename 'playlist' to 'word'

data("stop_words")  # Load stop words dataset from tidytext
stop_words <- stop_words %>%
  mutate(word = toupper(word))  # Ensure stop words are uppercase to match

spotify_dataset_long_filtered <- spotify_dataset_long %>%
  mutate(word = gsub("[^a-zA-Z0-9]", "", word)) %>%  # Remove special characters
  filter(!is.na(word) & !word=="") %>%
  anti_join(stop_words, by = "word") %>%      # Remove stop words
  filter(!word %in% c("MUSIC", "PLAYLIST", "ALBUMS", "ARTISTS", "SONGS",
                      "STUFF", "DE"))

spotify_playlist_word_freq <- spotify_dataset_long_filtered %>%
  group_by(artist, track, word) %>%        # Group by artist, track, and word
  summarize(appearances = n(), .groups = "drop") %>% # Count appearances of each word
  arrange(desc(appearances), artist, track)         # Arrange for readability

write_csv(spotify_playlist_word_freq, file.path(path,"spotify_playlist_word_freq.csv"))