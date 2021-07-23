#!/usr/bin/env Rscript

library(drug.similarity)
library(data.table)

if (!dir.exists("/results"))
  stop("Mount local working directory in the docker container by including `docker run -v \"$PWD\":/results ...`")

args <- commandArgs(trailingOnly = TRUE)
cmpds <- if (length(args) == 1 && file.exists(args[1]))
  fread(args[1], col.names = "cmpd", header = FALSE) else args

message(
  "Calculating similarity for ", length(cmpds), " queries: ",
  paste("\"", head(cmpds, n = 10), "\"", sep = "", collapse = " "),
  if (length(cmpds) > 10) " ..."
)
res <- sms_chemical_similarity(cmpds, show_compound_names = TRUE)
message(nrow(res), " similarities")
fwrite(res, paste0("/results/similarity_result_", format(Sys.time(), format="%Y-%m-%d_%T"), ".csv"))
