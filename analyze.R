library("tidyverse")
library("tidytext")
#import cleaned dataset
path <- "C:/Users/AlexA/OneDrive/Documents/UNC BIOS/BIOS 611/Project/data/"
#path <- "data/"

spotify_dataset_clean<-read_csv(file.path(path,"spotify_dataset_clean.csv")) %>% as.tibble()
colnames(spotify_dataset_clean) <- c("user_id","artist","track","playlist")

#parse out the words from playlist names
spotify_dataset_parsed <- spotify_dataset_clean %>%
  mutate(id = row_number()) %>%              # Add a unique ID if needed
  separate(playlist, into = paste0("word_", 1:10), sep = " ", fill = "right") %>%
  mutate(playlist=spotify_dataset_clean$playlist)

word_counts <- spotify_dataset_parsed %>%
  select(starts_with("word_")) %>%  # Select only word columns
  unlist() %>%                      # Flatten into a vector
  na.omit() %>%                     # Remove NAs
  gsub("[^a-zA-Z0-9]", "", .) %>%   # Remove special characters
  toupper() %>%                     # Convert to uppercase
  as_tibble() %>%                   # Convert to a tibble for easy manipulation
  count(value, name = "count") %>%  # Count occurrences of each unique word
  rename(word = value) %>%          # Rename 'value' to 'word'
  filter(word != "") %>%            # Remove blank words
  arrange(desc(count))              # Sort by count in descending order

data("stop_words")  # Load stop words dataset from tidytext
stop_words <- stop_words %>%
  mutate(word = toupper(word))  # Ensure stop words are uppercase to match

filtered_word_counts <- word_counts %>%
  anti_join(stop_words, by = "word") %>%      # Remove stop words
  filter(!word %in% c("MUSIC", "PLAYLIST", "ALBUMS", "ARTISTS", "SONGS",
                      "STUFF", "DE")) %>%   # Remove useless words
  filter(count>=100)

#pivot to long
spotify_dataset_long <- spotify_dataset_parsed %>%
  select(track, artist, starts_with("word_")) %>%     # Keep 'track', 'artist', and 'word_' columns
  pivot_longer(
    cols = starts_with("word_"),                     # Reshape all 'word_' columns to long format
    values_to = "word",                              # Create a new column for word values
    values_drop_na = TRUE                            # Automatically drop rows with NA values
  ) %>%
  select(track, artist, word)                        # Keep only 'track', 'artist', and 'word'

#this will "overfit" due to people naming playlists after album/song names
#only keep words appearing frequently overall to avoid overfitting
spotify_dataset_long_filtered <- spotify_dataset_long %>%
  inner_join(filtered_word_counts, by = "word") %>%# Join on the 'word' column
  select(-count)

spotify_playlist_word_freq <- spotify_dataset_long_filtered %>%
  group_by(artist, track, word) %>%        # Group by artist, track, and word
  summarise(appearances = n(), .groups = "drop") %>% # Count appearances of each word
  arrange(desc(appearances), artist, track)         # Arrange for readability

write_csv(spotify_playlist_word_freq, file.path(path,"spotify_playlist_word_freq.csv"))