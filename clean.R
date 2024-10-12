library("tidyverse")
spotify_dataset<-read_csv("data/spotify_dataset.csv")
write_csv(spotify_dataset,"data/spotify_dataset_clean.csv")
