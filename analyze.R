library("tidyverse")
library("tidytext")
#import cleaned dataset
path <- "data/"

spotify_dataset_clean<-read_csv(file.path(path,"spotify_dataset_clean.csv")) %>% as.tibble()
colnames(spotify_dataset_clean) <- c("user_id","artist","track","playlist")

#parse out the words from playlist names
spotify_dataset_parsed <- spotify_dataset_clean %>%
  mutate(id = row_number()) %>%              # Add a unique ID if needed
  separate(playlist, into = paste0("word_", 1:5), sep = " ", fill = "right") %>%
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

view(word_counts)

data("stop_words")  # Load stop words dataset from tidytext
stop_words <- stop_words %>%
  mutate(word = toupper(word))  # Ensure stop words are uppercase to match

filtered_word_counts <- word_counts %>%
  anti_join(stop_words, by = "word")  # Remove stop words




