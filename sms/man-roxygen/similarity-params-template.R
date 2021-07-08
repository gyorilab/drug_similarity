#' @param query_ids Compounds (names or `lspci_ids`) for which to calculate
#'   similarity. If no targets are provided, the pairwise similarity of
#'   the query compounds with all other compounds is calculated.
#' @param target_ids If provided (names or `lspci_ids`), all pairwise
#'   similarities between query and target compounds are calculated.
#' @param show_compound_names Add columns with compound names to output
#' @details Before similarity functions can be used compound data needs
#'   to be downloaded to the working directory from
#'   \href{https://www.synapse.org/#!Synapse:syn25955270}{Synapse} or
#'   automatically using the [sms_download()] function.
#'
#' Compound names can be provided directly to the function,
#' mapped to `lspci_ids` using the [sms_compound_ids()]
#' function, or using the `lsp_compound_names` table from
#' \url{https://labsyspharm.shinyapps.io/smallmoleculesuite}.
#'
#' @return A 3 column data frame with query_id, target_id, and similarity
#' @seealso [sms_download()] for downloading SMS data
#' @family similarity functions
