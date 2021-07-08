
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Small Molecule Suite compound similarity

R package for computing chemical, target (TAS) and phenotypic
similarities between compounds.

## Installation

The dependencies `synapser` and `morgancpp` might need to be installed
manually from https://github.com/Sage-Bionetworks/synapser and
https://github.com/labsyspharm/morgancpp.

``` r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("indralab/drug_similarity", subdir = "sms")
```

## Examples

If this is the first time running the package, the data must be
downloaded in the working directory first. They can either be downloaded
manually from the
[Synapse repository](https://www.synapse.org/#!Synapse:syn25955270) to the working
directory or by using the `sms_download()` function.

Synapse login credentials must be saved using
`synapser::synLogin(..., rememberMe = TRUE)`.

``` r
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
#> ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
#> ✓ tibble  3.1.2     ✓ dplyr   1.0.7
#> ✓ tidyr   1.1.3     ✓ stringr 1.4.0
#> ✓ readr   1.4.0     ✓ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(drug.similarity)
sms_download()
#> Welcome, Clemens Hug!Downloading  [--------------------]2.01%   8.0MB/397.8MB (1.1MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#-------------------]4.02%   16.0MB/397.8MB (2.2MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#-------------------]6.03%   24.0MB/397.8MB (3.1MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##------------------]8.04%   32.0MB/397.8MB (4.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##------------------]10.05%   40.0MB/397.8MB (4.8MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##------------------]12.06%   48.0MB/397.8MB (5.6MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###-----------------]14.08%   56.0MB/397.8MB (6.3MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###-----------------]16.09%   64.0MB/397.8MB (7.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [####----------------]18.10%   72.0MB/397.8MB (7.7MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [####----------------]20.11%   80.0MB/397.8MB (8.4MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [####----------------]22.12%   88.0MB/397.8MB (9.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#####---------------]24.13%   96.0MB/397.8MB (9.6MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#####---------------]26.14%   104.0MB/397.8MB (10.1MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [######--------------]28.15%   112.0MB/397.8MB (10.7MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [######--------------]30.16%   120.0MB/397.8MB (11.2MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [######--------------]32.17%   128.0MB/397.8MB (11.8MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#######-------------]34.18%   136.0MB/397.8MB (10.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#######-------------]36.19%   144.0MB/397.8MB (10.2MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [########------------]38.21%   152.0MB/397.8MB (10.3MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [########------------]40.22%   160.0MB/397.8MB (10.6MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [########------------]42.23%   168.0MB/397.8MB (11.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#########-----------]44.24%   176.0MB/397.8MB (11.4MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#########-----------]46.25%   184.0MB/397.8MB (11.8MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##########----------]48.26%   192.0MB/397.8MB (12.1MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##########----------]50.27%   200.0MB/397.8MB (12.5MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##########----------]52.28%   208.0MB/397.8MB (12.6MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###########---------]54.29%   216.0MB/397.8MB (12.6MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###########---------]56.30%   224.0MB/397.8MB (12.8MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [############--------]58.31%   232.0MB/397.8MB (13.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [############--------]60.32%   240.0MB/397.8MB (13.4MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [############--------]62.34%   248.0MB/397.8MB (13.7MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#############-------]64.35%   256.0MB/397.8MB (13.8MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#############-------]66.36%   264.0MB/397.8MB (13.6MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##############------]68.37%   272.0MB/397.8MB (13.9MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##############------]70.38%   280.0MB/397.8MB (14.1MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##############------]72.39%   288.0MB/397.8MB (14.4MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###############-----]74.40%   296.0MB/397.8MB (14.7MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###############-----]76.41%   304.0MB/397.8MB (15.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [################----]78.42%   312.0MB/397.8MB (15.3MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [################----]80.43%   320.0MB/397.8MB (15.2MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [################----]82.44%   328.0MB/397.8MB (15.5MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#################---]84.45%   336.0MB/397.8MB (15.8MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [#################---]86.47%   344.0MB/397.8MB (16.1MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##################--]88.48%   352.0MB/397.8MB (16.4MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##################--]90.49%   360.0MB/397.8MB (16.3MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [##################--]92.50%   368.0MB/397.8MB (16.5MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###################-]94.51%   376.0MB/397.8MB (16.7MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [###################-]96.52%   384.0MB/397.8MB (17.0MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [####################]98.53%   392.0MB/397.8MB (17.2MB/s) sms_fingerprints.bin.synapse_download_78847631     Downloading  [####################]100.00%   397.8MB/397.8MB (17.4MB/s) sms_fingerprints.bin.synapse_download_78847631 Done...
#> NULL
```

Once the data are downloaded we can query compound similarities. If only
a single vector of compound names are provided, these compounds are
compared to all other compounds in the data set.

Here we show the first 10 lines of the result data frames.

``` r
sms_tas_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#> Loading TAS data...
#> Loading compound name data...
#>     target_lspci_id query_lspci_id tas_similarity n_tas n_prior_tas
#>  1:            2373          66153      0.3055556    10          11
#>  2:            2373          78036      0.3164557    10          11
#>  3:            3261          66153      0.3289474     9          17
#>  4:            3261          78036      0.3203883    11          19
#>  5:            4623          66153      0.3157895     6           6
#>  6:            4623          78036      0.3750000     6           6
#>  7:            5052          66153      0.3308081   170         294
#>  8:            5052          78036      0.4045276   171         302
#>  9:            6998          66153      0.4615385     4           5
#> 10:            7551          66153      0.2300000    10          12
#>     query_compound                      target_compound
#>  1:    RUXOLITINIB                         ELLAGIC ACID
#>  2:    TOFACITINIB                         ELLAGIC ACID
#>  3:    RUXOLITINIB                           NORHARMANE
#>  4:    TOFACITINIB                           NORHARMANE
#>  5:    RUXOLITINIB                                IQ-1S
#>  6:    TOFACITINIB                                IQ-1S
#>  7:    RUXOLITINIB                            SP-600125
#>  8:    TOFACITINIB                            SP-600125
#>  9:    RUXOLITINIB                               TDZD-8
#> 10:    RUXOLITINIB 8H-indeno[1,2-d][1,3]thiazol-2-amine
```

``` r
sms_chemical_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#> Loading TAS data...
#>     target_lspci_id query_lspci_id structural_similarity
#>  1:               2          66153            0.12222222
#>  2:               2          66153            0.09183673
#>  3:               2          66153            0.12500000
#>  4:               2          66153            0.00000000
#>  5:               2          78036            0.11702128
#>  6:               2          78036            0.09900990
#>  7:               2          78036            0.13253012
#>  8:               2          78036            0.01724138
#>  9:               2        1686383            0.10975610
#> 10:               2        1686383            0.08988764
#>                                                                     query_compound
#>  1:                                                                    RUXOLITINIB
#>  2:                                                                    RUXOLITINIB
#>  3:                                                                    RUXOLITINIB
#>  4:                                                                    RUXOLITINIB
#>  5:                                                                    TOFACITINIB
#>  6:                                                                    TOFACITINIB
#>  7:                                                                    TOFACITINIB
#>  8:                                                                    TOFACITINIB
#>  9: N-Methyl-N-((3R,4R)-4-methylpiperidin-3-yl)-7H-pyrrolo[2,3-d]pyrimidin-4-amine
#> 10: N-Methyl-N-((3R,4R)-4-methylpiperidin-3-yl)-7H-pyrrolo[2,3-d]pyrimidin-4-amine
#>             target_compound
#>  1: TETRAMETHYLAMMONIUM ION
#>  2: TETRAMETHYLAMMONIUM ION
#>  3: TETRAMETHYLAMMONIUM ION
#>  4: TETRAMETHYLAMMONIUM ION
#>  5: TETRAMETHYLAMMONIUM ION
#>  6: TETRAMETHYLAMMONIUM ION
#>  7: TETRAMETHYLAMMONIUM ION
#>  8: TETRAMETHYLAMMONIUM ION
#>  9: TETRAMETHYLAMMONIUM ION
#> 10: TETRAMETHYLAMMONIUM ION
```

``` r
sms_phenotypic_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#> Loading phenotypic data...
#>    target_lspci_id query_lspci_id phenotypic_correlation n_pfp n_prior_pfp
#> 1:            4870          66153             0.01585451     8          15
#> 2:           31506          78036             0.49136027     4           6
#> 3:           51110          78036             0.45919558     4           6
#> 4:           54590          78036             0.58629032     4           6
#> 5:          466893          78036             0.50237003     4           6
#>    query_compound target_compound
#> 1:    RUXOLITINIB      VORINOSTAT
#> 2:    TOFACITINIB      NSC-401077
#> 3:    TOFACITINIB      VELIFLAPON
#> 4:    TOFACITINIB     PRAVADOLINE
#> 5:    TOFACITINIB     SID 7969543
```
