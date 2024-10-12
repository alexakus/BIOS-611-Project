all:spotify_dataset_clean.csv

OUTPUT_FILE = data/spotify_dataset_clean.csv

#Clean original dataset
data/spotify_dataset_clean.csv: /home/rstudio/work/data/spotify_dataset.csv
	Rscript clean.R data/spotify_dataset_clean.csv /home/rstudio/work/data/spotify_dataset.csv

report.Rmd:spotify_dataset_clean.csv

#Turn report.Rmd into the final PDF format
report.pdf: report.Rmd
	R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"

clean:
	rm -f data/spotify_dataset_clean.csv






#TEMPORARY NOTES
#report.pdf: deps...
#	R -r "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"
#report.pdf: deps...
#	R -r "tinytex.pdflatex(\"report.tex\")"