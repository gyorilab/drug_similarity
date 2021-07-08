find_compound_ids <- function(compound_names) {
  if (!exists("sms_data_compound_names", envir = .GlobalEnv)) {
    message("Loading compound name data...")
    assign(
      "sms_data_compound_names", data.table::fread("sms_compound_names.csv.gz"), envir = .GlobalEnv
    )
  }
  if (is.null(compound_names))
    return(NULL)
  key_matches <- purrr::reduce(
    compound_names,
    function(df, query) {
      matches <- stringr::str_detect(
        sms_data_compound_names[["name"]], stringr::fixed(query, ignore_case = TRUE)
      )
      df[
        ,
        `:=`(
          matched = matched | matches,
          original_query = magrittr::inset(original_query, matches, query)
        )
      ]
    }, .init = data.table::copy(sms_data_compound_names)[
      , `:=`(matched = FALSE, original_query = NA_character_)
    ]
  )
  key_matches[
    matched == TRUE
  ][
    ,
    match_len := stringr::str_length(name)
  ][
    order(
      match_len
    )
  ][
    ,
    head(.SD, n = 1),
    by = .(lspci_id),
    .SDcols = c("name", "original_query")
  ] %>%
    unique()
}

merge_compound_names <- function(df) {
  if (!exists("sms_data_compounds", envir = .GlobalEnv)) {
    assign(
      "sms_data_compounds", sms_data_compound_names[rank == 1, .(lspci_id, name)], envir = .GlobalEnv
    )
  }
  purrr::reduce(
    purrr::array_branch(stringr::str_match(names(df), "^(.*)lspci_id$"), margin = 1),
    function(df, match) {
      lspci_id_col <- match[1]
      compound_col <- paste0(match[2], "compound")
      if (any(is.na(c(lspci_id_col, compound_col))))
        return(df)
      merge(
        df,
        sms_data_compounds[lspci_id %in% df[[lspci_id_col]]][
          , .(lspci_id, name)
        ] %>%
          data.table::setnames("name", compound_col),
        by.x = lspci_id_col, by.y = "lspci_id", all = FALSE
      )
    }, .init = df
  )
}

#' Convert compound names to SMS compound IDs (lspci_id)
#'
#' @returns
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
