Hi, this is my 611 Data Science Project. More to come.

*****************************************************

You can download the Spotify playlist dataset on Kaggle (link below). Name the downloaded dataset "spotify_dataset.csv" and place it in a directory named /data/ located within the current working directory.

```
https://www.kaggle.com/datasets/ashwinik/spotify-playlist/data
```

To run this code, first navigate to the project directory and build the docker container like this:

```
docker build . -t rstudio
```

And then start an RStudio server like this:

```
docker run -e PASSWORD=mypassword -v "$(pwd):/home/rstudio/work" -p 8787:8787 --rm rstudio
```

And visit http://localhost:8787 in your browser. Log in with user 'rstudio' and password 'mypassword'.

We'll need to accept an agreement to download a tinytext dataset. Navigate to the console and type

```
library(tidytext)
get_sentiments("nrc")
1
```

To build the final report, visit the terminal in RStudio and type

```
cd work
make all
```

This will create a report.pdf of the final output.