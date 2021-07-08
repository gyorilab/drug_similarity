#' Calculate Target Affinity Spectrum (TAS) similarity
#'
#' Computes similarity between compounds based on the targets they are binding.
#' Binding data is compiled from different sources: Full dose-response assays,
#' single concentration assays and literature assertions. For full description
#' see \href{https://doi.org/10.1016/j.chembiol.2019.02.018}{Moret, N.,
#' Clark, N.A., Hafner, M., Wang, Y., Lounkine, E., Medvedovic, M., Wang, J.,
#' Gray, N., Jenkins, J., and Sorger, P.K. (2019). Cheminformatics Tools for
#' Analyzing and Designing Optimized Small-Molecule Collections and Libraries.
#' Cell Chemical Biology 26, 765-777.e3.}
#'
#' @template similarity-params-template
#' @export
sms_tas_similarity <- function(query_ids, target_ids, min_n = 6) {
  if (!exists("sms_tas_data", envir = .GlobalEnv)) {
    message("Loading TAS data...")
    assign(
      "sms_tas_data", data.table::fread("tas.csv.gz"), envir = .GlobalEnv
    )
  }
  query_tas <- data_tas[lspci_id %in% query_ids, .(lspci_target_id, tas)]
  data_tas[
    ,
    .(lspci_id, lspci_target_id, tas)
  ][
    query_tas,
    on = "lspci_target_id",
    nomatch = NULL
  ][
    ,
    mask := tas < 10 | i.tas < 10
  ][
    ,
    if (sum(mask) >= min_n) .(
      "tas_similarity" = sum(pmin(tas[mask], i.tas[mask])) / sum(pmax(tas[mask], i.tas[mask])),
      "n" = sum(mask),
      "n_prior" = .N
    ) else .(
      tas_similarity = double(),
      n = integer(),
      n_prior = integer()
    ),
    by = "lspci_id"
  ]
}

#' Calculate phenotypic similarity
#'
#' Computes similarity between compounds based on phenotypic assays performed
#' on them that are published in ChEMBL. The similarity metric is the Pearson
#' correlation between the normalized results of all assays shared by both
#' compounds.
#'
#' @template similarity-params-template
#' @export
sms_phenotypic_similarity <- function(query_id, min_n = 6) {
  if (!exists("sms_phenotypic_data", envir = .GlobalEnv)) {
    message("Loading phenotypic data...")
    assign(
      "sms_phenotypic_data", data.table::fread("phenotypic.csv.gz"), envir = .GlobalEnv
    )
  }
  query_pfps <- data_pfp[lspci_id == query_id]
  data.table::merge(
    query_pfps,
    data_pfp,
    by = "assay_id",
    all = FALSE,
    sort = FALSE,
    suffixes = c("_1", "_2")
  )[
    ,
    mask := abs(rscore_tr_1) >= 2.5 | abs(rscore_tr_2) >= 2.5
  ][
    ,
    if(sum(mask) >= min_n) .(
      "pfp_correlation" = cor(rscore_tr_1, rscore_tr_2),
      "n" = sum(mask),
      "n_prior" = .N
    ) else .(
      pfp_correlation = double(),
      n = integer(),
      n_prior = integer()
    ),
    by = lspci_id_2
  ] %>%
    data.table::setnames("lspci_id_2", "lspci_id")
}


#' Calculate chemical similarity
#'
#' Computes the Tanimoto similarity between Morgan fingerprints.
#'
#' @template similarity-params-template
#' @export
sms_chemical_similarity <- function(query_id) {
  if (!exists("sms_fingerprint_data", envir = .GlobalEnv)) {
    message("Loading fingerprint data...")
    assign(
      "sms_fingerprint_data",
      morgancpp::MorganFPS$new("fingerprints.bin", from_file = TRUE),
      envir = .GlobalEnv
    )
  }
  fps <- sms_fingerprint_data$tanimoto_all(query_id)
  data.table::setDT(fps, key = "id")
  colnames(fps) <- c("lspci_id", "structural_similarity")
  fps
}

#' Download Small Molecule Suite data
#'
#' Download SMS compound data from
#' \href{https://www.synapse.org/#!Synapse:syn25955270}{Synapse} to the working
#' directory. Synapse login credentials must be saved using [synapser::synLogin()].
#'
#' `synLogin(email = "xxx", password = "xxx", rememberMe = TRUE)`.
#'
#' @export
sms_download <- function() {
  if (!requireNamespace("synapser", quietly = TRUE)) {
    stop(
      "The package \"synapser\" is required for downloading SMS data.",
      "See https://github.com/Sage-Bionetworks/synapser"
    )
  }
  synapser::synLogin()
  synapser::synGet("syn25955274", downloadLocation = getwd(), ifcollision = "overwrite.local")
  synapser::synGet("syn25955272", downloadLocation = getwd(), ifcollision = "overwrite.local")
  synapser::synGet("syn25955273", downloadLocation = getwd(), ifcollision = "overwrite.local")
  NULL
}
