library("tidyverse")
library("tidytext")
library("glue")
library("gt")
library("webshot2")

#import cleaned dataset
path <- "data"
figures_path <- "figures"
  
spotify_playlist_word_freq<-read_csv(file.path(path,"spotify_playlist_word_freq.csv")) %>% as_tibble()

#get associated sentiments from tidytext package
message(1)
sentiments <- get_sentiments("nrc") %>%
  mutate(across(everything(), toupper)) %>%
  filter(as.character(word) != "POP")# POP having negative sentiment throws everything off
message(2)
#note: this dataset has duplicates - only use to summarize by sentiment
#added a unique identifier for each track
spotify_playlist_sentiment <- spotify_playlist_word_freq %>%
  mutate(id = row_number()) %>%
  left_join(
    sentiments %>%
      mutate(word = toupper(word)), # Ensure compatibility with the join
    by = "word"
  )

n_sentiment <- spotify_playlist_sentiment %>%
  filter(!is.na(sentiment)) %>%
  distinct(id) %>%
  count() 

message(glue("{n_sentiment} out of {nrow(spotify_playlist_word_freq)} tracks have associated tidytext sentiments"))

#appears people aren't very creative with their playlist naming
#let's single out some terms and see the top songs
#genres
pop <- spotify_playlist_word_freq %>%
  filter(word=="POP") %>%
  select(-word) %>%
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))

rock <- spotify_playlist_word_freq %>%
  filter(word=="ROCK") %>%
  select(-word) %>%
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))

edm <- spotify_playlist_word_freq %>%
  filter(word=="EDM") %>%
  select(-word) %>%
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))

country <- spotify_playlist_word_freq %>%
  filter(word=="COUNTRY") %>%
  select(-word) %>%
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))

rap <- spotify_playlist_word_freq %>%
  filter(word=="RAP") %>%
  select(-word) %>%
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))

jazz <- spotify_playlist_word_freq %>%
  filter(word=="JAZZ") %>%
  select(-word) %>%
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))

indie <- spotify_playlist_word_freq %>%
  filter(word=="INDIE") %>%
  select(-word) %>%
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))

#sentiment breakdown
spotify_playlist_sentiment_count <- spotify_playlist_sentiment %>%
  filter(!is.na(sentiment)) %>%
  filter(!sentiment %in% c("POSITIVE", "NEGATIVE")) %>% #not very informative
  group_by(sentiment, artist, track) %>%
  count() %>%
  arrange(desc(n))

anger <- spotify_playlist_sentiment_count %>% filter(sentiment=="ANGER") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))
anticipation <- spotify_playlist_sentiment_count %>% filter(sentiment=="ANTICIPATION") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))
disgust <- spotify_playlist_sentiment_count %>% filter(sentiment=="DISGUST") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))
fear <- spotify_playlist_sentiment_count %>% filter(sentiment=="FEAR") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))
joy <- spotify_playlist_sentiment_count %>% filter(sentiment=="JOY") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))
sadness <- spotify_playlist_sentiment_count %>% filter(sentiment=="SADNESS") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))
surprise <- spotify_playlist_sentiment_count %>% filter(sentiment=="SURPRISE") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))
trust <- spotify_playlist_sentiment_count %>% filter(sentiment=="TRUST") %>% head(n=10) %>% ungroup() %>% select(-sentiment) %>% rename_with(~ str_to_title(.))

#people seem to really like naming their playlists after years
#let's see trends in songs over years
year_playlists <- spotify_playlist_word_freq %>%
  filter(str_detect(word, "\\b(19|20)\\d{2}\\b")) %>%  # Filter words matching years
  rename(year = word) %>%                              # Rename 'word' to 'year'
  mutate(year = as.numeric(year))                     # Convert 'year' to numeric

year_playlists_total <- year_playlists %>%
  select(-year) %>%
  group_by(artist, track) %>%
  summarize(appearances = sum(appearances), .groups = "drop") %>%
  arrange(desc(appearances))

#see which songs people associate with the widest range of years
#limit to 2010 - 2018 since (the range of the dataset is January 2010 and October 2017)
year_playlists_count <- year_playlists %>%
  filter(year >= 2010 & year <= 2018) %>%
  select(-year) %>%
  group_by(artist, track) %>%
  summarize(associations = n(), .groups = "drop") %>%  # Count unique associations
  arrange(desc(associations))

top_songs_year <- inner_join(year_playlists, year_playlists_count, by = c("track", "artist")) %>%
  filter(year >= 2010 & year <= 2018)

top_songs <- top_songs_year %>%
  filter(associations >= 6) %>% #want some with some staying power
  arrange(desc(appearances)) %>%
  slice_head(n = 6) %>% # Select the top 6 to avoid overcrowding
  select(artist, track)
  
trend <- inner_join(top_songs_year, top_songs, by = c("track", "artist")) %>%
  filter(year >= 2010 & year <= 2018)

song_trends <- ggplot(trend, aes(x = year, y = appearances, color = track, group = track)) +
  geom_point(size = 2) +          # Add scatterplot points
  geom_line(size = 0.75) +           # Connect the dots for each song
  labs(
    title = "Appearance of Top Songs in Year-themed Playlists",
    x = "Year",
    y = "Number of Playlist Appearances",
    color = "Track"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")  # Optional: Position the legend below the plot

#in the spirit of winter break, let's make a holiday playlist
holiday_playlist <- spotify_playlist_word_freq %>%
  filter(word %in% c("CHRISTMAS","HOLIDAY","HOLIDAYS","MERRY","WINTER","JOLLY","HANUKKAH","KWANZAA")) %>%
  select(-word) %>%
  group_by(artist, track) %>%                       # Group by the new category
  summarize(appearances = sum(appearances), .groups = "drop") %>%  # Sum up appearances
  arrange(desc(appearances)) %>%
  head(n=10) %>%
  rename_with(~ str_to_title(.))


if (!dir.exists(figures_path)) {
  dir.create(figures_path, recursive = TRUE)
}

write_csv(anger, file.path(figures_path,"anger.csv"))
write_csv(anticipation, file.path(figures_path,"anticipation.csv"))
write_csv(disgust, file.path(figures_path,"disgust.csv"))
write_csv(fear, file.path(figures_path,"fear.csv"))
write_csv(joy, file.path(figures_path,"joy.csv"))
write_csv(sadness, file.path(figures_path,"sadness.csv"))
write_csv(surprise, file.path(figures_path,"surprise.csv"))
write_csv(trust, file.path(figures_path,"trust.csv"))

write_csv(pop, file.path(figures_path,"pop.csv"))
write_csv(rock, file.path(figures_path,"rock.csv"))
write_csv(edm, file.path(figures_path,"edm.csv"))
write_csv(country, file.path(figures_path,"country.csv"))
write_csv(rap, file.path(figures_path,"rap.csv"))
write_csv(jazz, file.path(figures_path,"jazz.csv"))
write_csv(indie, file.path(figures_path,"indie.csv"))

ggsave("song_trends.png", plot=song_trends, path=figures_path, width = 8, height = 6)

write_csv(holiday_playlist, file.path(figures_path,"holiday_playlist.csv"))

anger %>% gt() %>% gtsave(file.path(figures_path, "anger.png"))
anticipation %>% gt() %>% gtsave(file.path(figures_path, "anticipation.png"))
disgust %>% gt() %>% gtsave(file.path(figures_path, "disgust.png"))
fear %>% gt() %>% gtsave(file.path(figures_path, "fear.png"))
joy %>% gt() %>% gtsave(file.path(figures_path, "joy.png"))
sadness %>% gt() %>% gtsave(file.path(figures_path, "sadness.png"))
surprise %>% gt() %>% gtsave(file.path(figures_path, "surprise.png"))
trust %>% gt() %>% gtsave(file.path(figures_path, "trust.png"))

pop %>% gt() %>% gtsave(file.path(figures_path, "pop.png"))
rock %>% gt() %>% gtsave(file.path(figures_path, "rock.png"))
edm %>% gt() %>% gtsave(file.path(figures_path, "edm.png"))
country %>% gt() %>% gtsave(file.path(figures_path, "country.png"))
rap %>% gt() %>% gtsave(file.path(figures_path, "rap.png"))
jazz %>% gt() %>% gtsave(file.path(figures_path, "jazz.png"))
indie %>% gt() %>% gtsave(file.path(figures_path, "indie.png"))
holiday_playlist %>% gt() %>% gtsave(file.path(figures_path, "holiday_playlist.png"))