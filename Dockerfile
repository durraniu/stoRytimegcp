FROM rocker/verse:4.4.2
RUN apt-get update && apt-get install -y  cmake libcurl4-openssl-dev libicu-dev libssl-dev libxml2-dev make pandoc xz-utils zlib1g-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("jsonlite",upgrade="never", version = "1.8.9")'
RUN Rscript -e 'remotes::install_version("bslib",upgrade="never", version = "0.9.0")'
RUN Rscript -e 'remotes::install_version("base64enc",upgrade="never", version = "0.1-3")'
RUN Rscript -e 'remotes::install_version("stringr",upgrade="never", version = "1.5.1")'
RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.2.1.1")'
RUN Rscript -e 'remotes::install_version("httr2",upgrade="never", version = "1.0.5")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.9.1")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.2")'
RUN Rscript -e 'remotes::install_version("httptest2",upgrade="never", version = "1.1.0")'
RUN Rscript -e 'remotes::install_version("slickR",upgrade="never", version = "0.6.0")'
RUN Rscript -e 'remotes::install_version("shinyjs",upgrade="never", version = "2.1.0")'
RUN Rscript -e 'remotes::install_version("quarto",upgrade="never", version = "1.4.4")'
RUN Rscript -e 'remotes::install_version("mirai",upgrade="never", version = "2.2.0")'
RUN Rscript -e 'remotes::install_version("lexicon",upgrade="never", version = "1.2.1")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.5.1")'
RUN Rscript -e 'remotes::install_version("bsicons",upgrade="never", version = "0.1.2")'
RUN Rscript -e 'remotes::install_github("jcpsantiago/sentryR@a24b49ddf71d8d678bb0781bbcc2cf4a89e0d2d3")'
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone
EXPOSE 80
CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');library(storytimegcp);storytimegcp::run_app()"
