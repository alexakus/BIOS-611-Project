library("tidyverse")
library("glue")
#import raw lines to remove mismatched quotes (e.g., [12" version])
raw_data <- tibble(readLines("C:/Users/AlexA/OneDrive/Documents/UNC BIOS/BIOS 611/Project/data/spotify_dataset.csv"))
colnames(raw_data) <- c("line")

cleaned_data <- raw_data %>% filter(str_count(line, "\"") == 8) %>% as.tibble()
removed_data <- raw_data %>% filter(str_count(line, "\"") != 8) %>% mutate(count=str_count(line, "\"")) %>% as.tibble()

message(glue("{nrow(removed_data)} lines with excess quotations removed"))

#write back to csv
writeLines(cleaned_data$line, "C:/Users/AlexA/OneDrive/Documents/UNC BIOS/BIOS 611/Project/data/spotify_dataset_clean.csv")