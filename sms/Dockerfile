FROM rocker/r-ver:4.0.5
RUN apt-get update
# Python dependencies for PythonEmbedInR
RUN apt-get -y install wget curl build-essential gdb lcov libbz2-dev libffi-dev \
  libgdbm-dev liblzma-dev libncurses5-dev libreadline6-dev \
  libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev
# drug.similarity dependencies
RUN R -e 'install.packages("remotes"); \
  install.packages("synapser", repos=c("http://ran.synapse.org", "https://cloud.r-project.org/"))'
RUN R -e 'remotes::install_github("labsyspharm/morgancpp", ref = "3cd206fc14ce7ceff8dc782f85e81969c068ab06", upgrade = "never")'
RUN R -e 'remotes::install_github("clemenshug/drug_similarity", ref = "fcb23c6abe9b457acc23e9f45d70124e1e7ad1ad", subdir = "sms", upgrade = "never")'
WORKDIR /app
RUN --mount=type=secret,id=synapse,dst=/root/.synapseConfig R -e 'library(drug.similarity); sms_download()'
COPY docker_entrypoint.R /app
ENTRYPOINT ["/app/docker_entrypoint.R"]"
