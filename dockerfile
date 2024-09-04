# Use the Rocker image with R and RStudio
FROM rocker/verse

RUN R -e "install.packages(\"matlab\")"
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y python3-pip
RUN pip3 install tensorflow

# Install any additional R packages you need
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'tidyr', 'readr'), repos='https://cloud.r-project.org/')"

# Set the working directory inside the container
WORKDIR /home/rstudio

# Expose ports for RStudio and Shiny (if needed)
EXPOSE 8787
EXPOSE 3838

# Copy any local files to the container (if needed)
# COPY ./your-local-directory /home/rstudio/your-directory

# Set up user permissions (optional, depending on your needs)
RUN chown -R rstudio:rstudio /home/rstudio

# Start RStudio Server (this is default in rocker/verse)
CMD ["/init"]
