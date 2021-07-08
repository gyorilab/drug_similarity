#' @param query_ids Compounds (`lspci_ids`) for which to calculate
#'   similarity. If no target_ids are provided, the similarity of
#'   all query compounds with each other are calculated.
#' @param target_ids `lspci_ids` of compounds. If provided, all pairwise
#'   similarities between query and target compounds are calculated.
#' @details Before similarity functions can be used, compound data needs
#'   to be downloaded to the working directory from
#'   \href{https://www.synapse.org/#!Synapse:syn25955270}{Synapse} or
#'   automatically using the [sms_download()] function.
#'
#' Compound names can be mapped to `lspci_ids` using the `lsp_compound_names`
#' table from \url{https://labsyspharm.shinyapps.io/smallmoleculesuite}.
#'
#' @return A 3 column data frame with query_id, target_id, and similarity
#' @seealso [sms_download()] for downloading SMS data
#' @family similarity functions
