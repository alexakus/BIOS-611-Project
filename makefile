# Define files and dependencies
CLEANED_DATA = data/spotify_dataset_clean.csv
ANALYZED_DATA = data/spotify_playlist_word_freq.csv
RESULTS_DATA = figures/song_trends.png figures/anger.png figures/anticipation.png \
               figures/disgust.png figures/fear.png figures/joy.png figures/sadness.png \
               figures/surprise.png figures/trust.png figures/pop.png figures/edm.png \
               figures/country.png figures/rap.png figures/jazz.png figures/indie.png \
               figures/holiday_playlist.png
REPORT_RMD = report.Rmd
REPORT_PDF = report.pdf

# Default target
all: $(REPORT_PDF)

# Run clean.R
$(CLEANED_DATA): clean.R
	Rscript clean.R

# Run analyze.R
$(ANALYZED_DATA): analyze.R $(CLEANED_DATA)
	Rscript analyze.R

# Run results.R
$(RESULTS_DATA): results.R $(ANALYZED_DATA)
	Rscript results.R

# Render report.pdf
$(REPORT_PDF): $(REPORT_RMD)
	Rscript -e "rmarkdown::render('$<', output_format = 'pdf_document')"

# Individual targets
clean: $(CLEANED_DATA)
analyze: $(ANALYZED_DATA)
results: $(RESULTS_DATA)
report: $(REPORT_PDF)

# Clean up intermediate and output files
.PHONY: clean_all
clean_all:
	rm -f $(CLEANED_DATA) $(ANALYZED_DATA) $(RESULTS_DATA) $(REPORT_RMD) $(REPORT_PDF)
