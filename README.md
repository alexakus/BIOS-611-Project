Hi, this is my 611 Data Science Project. More to come.

*****************************************************

To run this code, just build the docker container like this:

```
docker build . -t rstudio
```

And then start an RStudio server like this:

```
docker run -e PASSWORD=mypassword -v "$(pwd):/home/rstudio/work" -p 8787:8787 --rm rstudio
```

And visit http://localhost:8787 in your browser. Log in with user
`rstudio` and password `mypassword`.
