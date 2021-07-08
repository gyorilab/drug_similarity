library(tidyverse)
library(data.table)
library(morgancpp)
library(vroom)
library(here)
library(synapser)
library(synExtra)

dir_data <- here("data")
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

# Warning, 5GB compressed
fingerprint_input <- synPluck(syn_parent, "lsp_fingerprints.csv.gz") %>%
  syn() %>%
  vroom()

## Wrangle phenotypic assay and TAS data for similarity calculations
## Throwing out any

pfp <- pfp_input[
  !is.na(rscore_tr) & is.finite(rscore_tr),
  .(
    lspci_id,
    assay_id,
    rscore_tr
  )
][
  # Remove any compound with less than 6 assays
  ,
  if (.N >= 6) .SD,
  keyby = .(lspci_id)
] %>%
  setkey(assay_id, lspci_id)

fwrite(
  pfp, file.path(dir_data, "phenotypic.csv.gz")
)

tas <- tas_input[
  # Remove any drug with less than 6 tas values
  ,
  if (.N >= 6) .SD,
  keyby = .(lspci_id),
  .SDcols = c("lspci_target_id", "tas")
] %>%
  setkey(lspci_target_id, lspci_id)

fwrite(
  tas, file.path(dir_data, "tas.csv.gz")
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
  file.path(dir_data, "fingerprints.bin"),
  compression_level = 22
)

## Upload all to synapse

syn_store_root <- "syn25928953"
syn_sms_data <- synMkdir(syn_store_root, "sms")

synStoreMany(
  c(file.path(dir_data, "phenotypic.csv.gz"),
    file.path(dir_data, "tas.csv.gz"),
    file.path(dir_data, "fingerprints.bin")),
  parentId = syn_sms_data,
  forceVersion = FALSE
)
