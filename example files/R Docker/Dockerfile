# Base image https://rocker-project.org/images/versioned/r-ver.html
FROM rocker/r-ver:4

RUN apt-get update
RUN apt-get install -y git vim

# install packages you need
RUN Rscript -e "install.packages('Rtsne')"
RUN Rscript -e "install.packages('remotes')"
RUN Rscript -e "remotes::install_github('zhexuandliu/RtsneWithP')"


RUN chmod -R 777 /usr/local/lib/ /root/ /tmp/
ENV HOME /root/
ENV USER root