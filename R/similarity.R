#' Small Molecule Suite (SMS) compound similarity functions
#'
#' @param query_ids Compounds (`lspci_ids`) for which to calculate
#'   similarity. If no target_ids are provided, the similarity of
#'   all query compounds with each other are calculated.
#' @param target_ids `lspci_ids` of compounds. If provided, all pairwise
#'   similarities between query and target compounds are calculated.
#' @name similarity_functions
NULL

#' Calculate Target Affinity Spectrum (TAS) similarity
#'
#' TAS asdf
#'
#' @rdname similarity_functions
#' @export
sms_tas_similarity <- function(query_ids, target_ids, min_n = 6) {
  query_tas <- data_tas[lspci_id == query_id, .(lspci_target_id, tas)]
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
#' Phenotypic asdf
#'
#' @rdname similarity_functions
#' @export
sms_phenotypic_similarity <- function(query_id, min_n = 6) {
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
#' @rdname similarity_functions
#' @export
sms_chemical_similarity <- function(query_id) {
  fps <- data_fingerprints$tanimoto_all(query_id)
  data.table::setDT(fps, key = "id")
  colnames(fps) <- c("lspci_id", "structural_similarity")
  fps
}

#' Download Small Molecule Suite data
#'
#' @export
sms_download <- function() {

}
