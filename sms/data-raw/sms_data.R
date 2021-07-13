library(tidyverse)
library(data.table)
library(morgancpp)
library(vroom)
library(here)
library(synapser)
library(synExtra)

dir_data <- here("sms_data")
dir.create(dir_data)

synLogin()
syn <- synDownloader(dir_data, followLink = TRUE, ifcollision = "overwrite.local")

chembl_version <- "27"

syn_root <- "syn18457321"
syn_parent <- synPluck(syn_root, paste0("chembl_v", chembl_version), "db_tables")

## Download Small Molecule Suite data from Synapse

pfp_input <- synPluck(syn_parent, "lsp_phenotypic_agg.csv.gz") %>%
  syn() %>%
  fread()

tas_input <- synPluck(syn_parent, "lsp_tas.csv.gz") %>%
  syn() %>%
  fread()

compound_name_input <- synPluck(syn_parent, "lsp_compound_names.csv.gz") %>%
  syn() %>%
  fread()

# Warning, 5GB compressed
fingerprint_input <- synPluck(syn_parent, "lsp_fingerprints.csv.gz") %>%
  syn() %>%
  vroom()

## Wrangle compound names

compound_names <- compound_name_input[
  , rank := seq_len(.N), keyby = .(lspci_id)
]

fwrite(
  compound_names, file.path(dir_data, "sms_compound_names.csv.gz")
)

## Wrangle phenotypic assay and TAS data for similarity calculations
## Throwing out any compounds with less than 4 data points

pfp <- pfp_input[
  !is.na(rscore_tr) & is.finite(rscore_tr),
  .(
    lspci_id,
    assay_id,
    rscore_tr
  )
][
  # Remove any compound with less than 4 assays
  ,
  if (.N >= 4) .SD,
  keyby = .(lspci_id)
] %>%
  setkey(assay_id, lspci_id)

fwrite(
  pfp, file.path(dir_data, "sms_phenotypic.csv.gz")
)

tas <- tas_input[
  # Remove any drug with less than 4 tas values
  ,
  if (.N >= 4) .SD,
  keyby = .(lspci_id),
  .SDcols = c("lspci_target_id", "tas")
] %>%
  setkey(lspci_target_id, lspci_id)

fwrite(
  tas, file.path(dir_data, "sms_tas.csv.gz")
)

## Store fingerprints in efficient binary format

fingerprints_morgan_normal <- fingerprint_input %>%
  filter(fingerprint_type == "morgan_normal") %>%
  with(
    set_names(fingerprint, lspci_id)
  )

fingerprints <- MorganFPS$new(
  fingerprints_morgan_normal
)

fingerprints$save_file(
  file.path(dir_data, "sms_fingerprints.bin"),
  compression_level = 22
)

## Upload all to synapse

syn_store_root <- "syn25928953"
syn_sms_data <- synMkdir(syn_store_root, "sms")

synStoreMany(
  c(file.path(dir_data, "sms_phenotypic.csv.gz"),
    file.path(dir_data, "sms_tas.csv.gz"),
    file.path(dir_data, "sms_fingerprints.bin"),
    file.path(dir_data, "sms_compound_names.csv.gz")),
  parentId = syn_sms_data,
  forceVersion = FALSE
)
