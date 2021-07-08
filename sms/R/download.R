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
