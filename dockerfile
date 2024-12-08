# Start with a base R image with RStudio
FROM rocker/verse

# Install required system tools
RUN apt-get update && apt-get install -y make
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# Install TinyTeX and R packages
RUN R -e "install.packages(c('tinytex', 'stringi', 'tidyverse', 'tidytext', 'glue', 'textdata', 'gt', 'webshot2'), repos='https://cloud.r-project.org/')"
RUN R -e "tinytex::install_tinytex(force = TRUE)"

# Run the libraries (CAUSES ISSUES)
#RUN echo "library(tinytex)" >> /home/rstudio/.Rprofile
#RUN echo "library(stringi)" >> /home/rstudio/.Rprofile
#RUN echo "library(tidyverse)" >> /home/rstudio/.Rprofile
#RUN echo "library(tidytext)" >> /home/rstudio/.Rprofile
#RUN echo "library(glue)" >> /home/rstudio/.Rprofile
#RUN echo "library(textdata)" >> /home/rstudio/.Rprofile
#RUN echo "library(gt)" >> /home/rstudio/.Rprofile
#RUN echo "library(webshot2)" >> /home/rstudio/.Rprofile

# Set working directory and expose RStudio port
WORKDIR /home/rstudio
EXPOSE 8787

# Default command
CMD ["/init"]
# Set the working directory
WORKDIR /home/rstudio

# Expose the RStudio port
EXPOSE 8787

# Default command to run
CMD ["/init"]
