find_compound_ids <- function(compound_names) {
  if (!exists("sms_data_compound_names", envir = .GlobalEnv)) {
    message("Loading compound name data...")
    assign(
      "sms_data_compound_names",
      fst::read_fst("sms_compound_names.fst", as.data.table = TRUE),
      envir = .GlobalEnv
    )
  }
  if (is.null(compound_names))
    return(NULL)
  key_matches <- purrr::reduce(
    compound_names,
    function(df, query) {
      matches <- stringr::str_locate(
        sms_data_compound_names[["name"]], stringr::fixed(query, ignore_case = TRUE)
      )
      # Replace non-matches (NA) with 0. Length 0 matches are when a single
      # character matches so adding 1
      match_len <- data.table::fcoalesce(
        matches[, 2] - matches[, 1] + 1, 0
      ) / sms_data_compound_names[["len"]]
      # Locations of improved matches
      better_match_idx <- match_len > df[["match_prop"]]
      # Compute what proportion of the name match is covered by each query
      df[
        ,
        `:=`(
          match_prop = data.table::fifelse(better_match_idx, match_len, match_prop),
          original_query = data.table::fifelse(better_match_idx, query, original_query)
        )
      ]
    }, .init = data.table::copy(sms_data_compound_names)[
      , `:=`(match_prop = -1, original_query = NA_character_)
    ]
  )
  # Only return first match of each original query. Should be highest quality match
  data.table::setorder(key_matches, -match_prop)[
    match_prop > 0
  ][
    ,
    head(.SD, n = 1),
    by = .(original_query),
    .SDcols = c("match_prop", "name", "lspci_id")
  ]
}

merge_compound_names <- function(df) {
  if (!exists("sms_data_compound_names", envir = .GlobalEnv)) {
    message("Loading compound name data...")
    assign(
      "sms_data_compound_names",
      fst::read_fst("sms_compound_names.csv.gz", as.data.table = TRUE),
      envir = .GlobalEnv
    )
  }
  if (!exists("sms_data_compounds", envir = .GlobalEnv)) {
    assign(
      "sms_data_compounds", sms_data_compound_names[rank == 1, .(lspci_id, name)], envir = .GlobalEnv
    )
  }
  # Merging compound names for every column that contains _lspci_id
  res <- df
  for (match in purrr::array_branch(stringr::str_match(names(df), "^(.*)lspci_id$"), margin = 1)) {
    lspci_id_col <- match[1]
    compound_col <- paste0(match[2], "compound")
    if (any(is.na(c(lspci_id_col, compound_col))))
      next
    res <- merge(
      res,
      sms_data_compounds,
      by.x = lspci_id_col, by.y = "lspci_id", all.x = TRUE, all.y = FALSE
    )
    data.table::setnames(res, "name", compound_col)
  }
  similarity_cols <- c(
    "tas_similarity", "structural_similarity", "phenotypic_correlation"
  )
  res <- dplyr::relocate(
    res, ends_with("compound"), ends_with("lspci_id"), any_of(similarity_cols)
  )
  res
}

#' Convert compound names to SMS compound IDs (lspci_id)
#'
#' @returns A named vector with lspci_ids as values and corresponding queries
#'   as names
#' @export
sms_compound_ids <- function(ids) {
  if (is.null(ids))
    NULL
  else if (is.numeric(ids))
    # Assume it's already lspci_ids
    purrr::set_names(ids)
  else {
    find_compound_ids(ids) %>%
      with(purrr::set_names(lspci_id, original_query))
  }
}
