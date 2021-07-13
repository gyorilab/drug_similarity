find_compound_ids <- function(compound_names) {
  if (!exists("sms_data_compound_names", envir = .GlobalEnv)) {
    message("Loading compound name data...")
    assign(
      "sms_data_compound_names",
      data.table::fread("sms_compound_names.csv.gz")[
        # Adding length of name for fast calculation of the match proportion
        , len := stringr::str_length(name)
      ] %>%
        data.table::setkey(lspci_id),
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
  #   ,
  #   match_len := stringr::str_length(name)
  # ][
  #   order(
  #     match_len
  #   )
  # ][
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
      data.table::fread("sms_compound_names.csv.gz")[
        # Adding length of name for fast calculation of the match proportion
        , len := stringr::str_length(name)
      ],
      envir = .GlobalEnv
    )
  }
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
        sms_data_compounds[
          , .(lspci_id, name)
        ] %>%
          data.table::copy() %>%
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
