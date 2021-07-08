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
#' In the output, `n_tas_prior` represents the number of annotated targets shared
#' between compounds. `n_tas` is the number of annotated targets actually used
#' for similarity calculation. It requires that at least one of the two compounds
#' has a binding assertion < 10 for the given target.
#'
#' @template similarity-params-template
#' @param min_n Minimum number of shared targets with TAS annotation
#' @export
sms_tas_similarity <- function(query_ids, target_ids = NULL, min_n = 4, show_compound_names = FALSE) {
  if (!exists("sms_data_tas", envir = .GlobalEnv)) {
    message("Loading TAS data...")
    assign(
      "sms_data_tas", data.table::fread("tas.csv.gz"), envir = .GlobalEnv
    )
  }
  query_ids <- sms_compound_ids(query_ids)
  target_ids <- sms_compound_ids(target_ids)

  query_tas <- sms_data_tas[
    lspci_id %in% query_ids,
    .(query_lspci_id = lspci_id, lspci_target_id, tas)
  ] %>%
    unique()
  target_tas <- sms_data_tas[
    if (is.null(target_ids)) TRUE else lspci_id %in% target_ids,
    .(target_lspci_id = lspci_id, lspci_target_id, tas)
  ] %>%
    unique()
  res <- target_tas[
    query_tas,
    on = .(lspci_target_id),
    nomatch = NULL,
    allow.cartesian = TRUE
  ][
    query_lspci_id != target_lspci_id
  ][
    ,
    mask := tas < 10 | i.tas < 10
  ][
    ,
    if (sum(mask) >= min_n) .(
      "tas_similarity" = sum(pmin(tas[mask], i.tas[mask])) / sum(pmax(tas[mask], i.tas[mask])),
      "n_tas" = sum(mask),
      "n_prior_tas" = .N
    ) else .(
      tas_similarity = double(),
      n_tas = integer(),
      n_prior_tas = integer()
    ),
    by = .(query_lspci_id, target_lspci_id)
  ]
  if (show_compound_names)
    res <- merge_compound_names(res)
  res
}

#' Calculate chemical similarity
#'
#' Computes the Tanimoto similarity between Morgan fingerprints.
#'
#' @template similarity-params-template
#' @export
sms_chemical_similarity <- function(query_ids, target_ids = NULL, show_compound_names = FALSE) {
  if (!exists("sms_data_fingerprints", envir = .GlobalEnv)) {
    message("Loading TAS data...")
    assign(
      "sms_data_fingerprints",
      morgancpp::MorganFPS$new("fingerprints.bin", from_file = TRUE),
      envir = .GlobalEnv
    )
  }
  query_ids <- sms_compound_ids(query_ids)
  target_ids <- sms_compound_ids(target_ids)

  res <- query_ids %>%
    purrr::set_names() %>%
    purrr::map(
      ~sms_data_fingerprints$tanimoto_all(.x) %>%
        data.table::setDT() %>% {
          .[
            if (is.null(target_ids)) TRUE else id %in% target_ids
          ]
        }
    ) %>%
    data.table::rbindlist(idcol = "query_lspci_id") %>% {
      .[
        ,
        .(
          query_lspci_id = as.integer(query_lspci_id),
          target_lspci_id = id,
          structural_similarity
        )
      ][
        query_lspci_id != target_lspci_id
      ]
    }
  if (show_compound_names)
    res <- merge_compound_names(res)
  res
}

#' Calculate phenotypic similarity
#'
#' Computes similarity between compounds based on phenotypic assays performed
#' on them that are published in ChEMBL. The similarity metric is the Pearson
#' correlation between the normalized results of all assays shared by both
#' compounds.
#'
#' @template similarity-params-template
#' @param min_n Minimum number of shared assays between compounds
#' @export
sms_phenotypic_similarity <- function(query_ids, target_ids = NULL, min_n = 4, show_compound_names = FALSE) {
  if (!exists("sms_data_phenotypic", envir = .GlobalEnv)) {
    message("Loading phenotypic data...")
    assign(
      "sms_data_phenotypic", data.table::fread("phenotypic.csv.gz"), envir = .GlobalEnv
    )
  }
  query_ids <- sms_compound_ids(query_ids)
  target_ids <- sms_compound_ids(target_ids)

  query_pfps <- sms_data_phenotypic[
    lspci_id %in% query_ids
  ] %>%
    unique()
  target_pfps <- sms_data_phenotypic[
    if (is.null(target_ids)) TRUE else lspci_id %in% target_ids
  ] %>%
    unique()

  res <- merge(
    query_pfps,
    target_pfps,
    by = "assay_id",
    all = FALSE,
    suffixes = c("_1", "_2")
  )[
    lspci_id_1 != lspci_id_2
  ][
    ,
    mask := abs(rscore_tr_1) >= 2.5 | abs(rscore_tr_2) >= 2.5
  ][
    ,
    if(sum(mask) >= min_n) .(
      "phenotypic_correlation" = cor(rscore_tr_1, rscore_tr_2),
      "n_pfp" = sum(mask),
      "n_prior_pfp" = .N
    ) else .(
      phenotypic_correlation = double(),
      n_pfp = integer(),
      n_prior_pfp = integer()
    ),
    by = .(lspci_id_1, lspci_id_2)
  ] %>%
    data.table::setnames(
      c("lspci_id_1", "lspci_id_2"),
      c("query_lspci_id", "target_lspci_id")
    )
  if (show_compound_names)
    res <- merge_compound_names(res)
  res
}
