
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Small Molecule Suite compound similarity

R package for computing chemical, target (TAS) and phenotypic
similarities between compounds.

## Installation

The dependencies `synapser` and `morgancpp` might need to be installed
manually from <https://github.com/Sage-Bionetworks/synapser> and
<https://github.com/labsyspharm/morgancpp>.

``` r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("clemenshug/drug_similarity", ref = "sms", subdir = "sms")
```

## Examples

If this is the first time running the package, the data must be
downloaded in the working directory first. They can either be downloaded
manually from the [Synapse
repository](https://www.synapse.org/#!Synapse:syn25955270) to the
working directory or by using the `sms_download()` function.

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
#> NULL
```

### Compound names

Queries can either be `lspci_ids` ([mappings from names to `lspci_id`
are on Synapse](https://www.synapse.org/#!Synapse:syn24874056)) or
compound names.

Compound name queries are matched with the compound name database by
finding the name with the largest overlapping substring.

### Similarity functions

Once the data are downloaded we can query compound similarities. If only
a single vector of compound names is provided, these compounds will be
compared to all other compounds in the SMS data set.

Running these functions for the first time might take a while, because
the data have to be loaded into memory first.

Here we show the first 10 lines of the result data frames.

#### Target similarity

``` r
sms_tas_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#> Loading sms_data_tas...
#> Loading sms_data_compound_names...
#>     query_compound target_compound target_lspci_id query_lspci_id
#>  1:    RUXOLITINIB    ELLAGIC ACID            2373          66153
#>  2:    TOFACITINIB    ELLAGIC ACID            2373          78036
#>  3:    RUXOLITINIB           IPA-3            2810          66153
#>  4:    RUXOLITINIB      NORHARMANE            3261          66153
#>  5:    TOFACITINIB      NORHARMANE            3261          78036
#>  6:    RUXOLITINIB           IQ-1S            4623          66153
#>  7:    TOFACITINIB           IQ-1S            4623          78036
#>  8:    RUXOLITINIB            <NA>            4646          66153
#>  9:    TOFACITINIB            <NA>            4646          78036
#> 10:    RUXOLITINIB       SP-600125            5052          66153
#>     tas_similarity n_tas n_prior_tas
#>  1:      0.3055556    10          11
#>  2:      0.3164557    10          11
#>  3:      0.3000000     4           4
#>  4:      0.3289474     9          17
#>  5:      0.3203883    11          19
#>  6:      0.3157895     6           6
#>  7:      0.3750000     6           6
#>  8:      0.2572115    43          55
#>  9:      0.2985075    43          55
#> 10:      0.3308081   170         294
```

Alternatively, we might only be interested in the similarity between our
two queries and another set of compounds.

When two vectors of compounds are passed to the similarity functions,
all pairwise similarities between the two compound sets are calculated.

``` r
sms_tas_similarity(c("ruxolitinib", "tofacitinib"), c("baricitinib", "fedratinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#>    query_compound target_compound target_lspci_id query_lspci_id tas_similarity
#> 1:    RUXOLITINIB     BARICITINIB           76528          66153      0.3085339
#> 2:    TOFACITINIB     BARICITINIB           76528          78036      0.3145946
#> 3:    RUXOLITINIB      FEDRATINIB           97675          66153      0.3731884
#> 4:    TOFACITINIB      FEDRATINIB           97675          78036      0.3425716
#>    n_tas n_prior_tas
#> 1:   106         337
#> 2:   107         332
#> 3:   286         463
#> 4:   291         453
```

#### Chemical structure similarity

``` r
sms_chemical_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#> Loading sms_data_fingerprints...
#>     query_compound            target_compound target_lspci_id query_lspci_id
#>  1:    RUXOLITINIB                       <NA>               1          66153
#>  2:    TOFACITINIB                       <NA>               1          78036
#>  3:    RUXOLITINIB    TETRAMETHYLAMMONIUM ION               2          66153
#>  4:    TOFACITINIB    TETRAMETHYLAMMONIUM ION               2          78036
#>  5:    RUXOLITINIB                       <NA>               3          66153
#>  6:    TOFACITINIB                       <NA>               3          78036
#>  7:    RUXOLITINIB          TRIMETHYLAMMONIUM               4          66153
#>  8:    TOFACITINIB          TRIMETHYLAMMONIUM               4          78036
#>  9:    RUXOLITINIB Trimethyl-sulfonium iodide               5          66153
#> 10:    TOFACITINIB Trimethyl-sulfonium iodide               5          78036
#>     structural_similarity
#>  1:            0.00000000
#>  2:            0.00000000
#>  3:            0.00000000
#>  4:            0.01724138
#>  5:            0.01851852
#>  6:            0.01724138
#>  7:            0.00000000
#>  8:            0.05357143
#>  9:            0.00000000
#> 10:            0.01724138
```

#### Phenotypic similarity

``` r
sms_phenotypic_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#> Loading sms_data_phenotypic...
#>    query_compound target_compound target_lspci_id query_lspci_id
#> 1:    RUXOLITINIB      VORINOSTAT            4870          66153
#> 2:    TOFACITINIB      NSC-401077           31506          78036
#> 3:    TOFACITINIB      VELIFLAPON           51110          78036
#> 4:    TOFACITINIB     PRAVADOLINE           54590          78036
#> 5:    TOFACITINIB     SID 7969543          466893          78036
#> 6:    RUXOLITINIB            <NA>        10039120          66153
#>    phenotypic_correlation n_pfp n_prior_pfp
#> 1:             0.01585451     8          15
#> 2:             0.49136027     4           6
#> 3:             0.45919558     4           6
#> 4:             0.58629032     4           6
#> 5:             0.50237003     4           6
#> 6:            -0.30492308     4           4
```

#### All similarity metrics

Alternatively, the similarity metrics can be computed all at once into a
single table:

``` r
sms_all_similarities(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE) %>%
  head(n = 10)
#>                          target_compound query_compound query_lspci_id
#>  1:                         ELLAGIC ACID    RUXOLITINIB          66153
#>  2:                                IPA-3    RUXOLITINIB          66153
#>  3:                           NORHARMANE    RUXOLITINIB          66153
#>  4:                                IQ-1S    RUXOLITINIB          66153
#>  5:                                 <NA>    RUXOLITINIB          66153
#>  6:                           VORINOSTAT    RUXOLITINIB          66153
#>  7:                            SP-600125    RUXOLITINIB          66153
#>  8:                               TDZD-8    RUXOLITINIB          66153
#>  9: 8H-indeno[1,2-d][1,3]thiazol-2-amine    RUXOLITINIB          66153
#> 10:                 INDIRUBIN-3-MONOXIME    RUXOLITINIB          66153
#>     target_lspci_id tas_similarity structural_similarity phenotypic_correlation
#>  1:            2373      0.3055556            0.02816901                     NA
#>  2:            2810      0.3000000            0.04285714                     NA
#>  3:            3261      0.3289474            0.10447761                     NA
#>  4:            4623      0.3157895            0.08571429                     NA
#>  5:            4646      0.2572115            0.06944444                     NA
#>  6:            4870             NA            0.05555556             0.01585451
#>  7:            5052      0.3308081            0.06944444                     NA
#>  8:            6998      0.4615385            0.08219178                     NA
#>  9:            7551      0.2300000            0.08219178                     NA
#> 10:            8308      0.3880597            0.06578947                     NA
#>     n_tas n_prior_tas n_pfp n_prior_pfp
#>  1:    10          11    NA          NA
#>  2:     4           4    NA          NA
#>  3:     9          17    NA          NA
#>  4:     6           6    NA          NA
#>  5:    43          55    NA          NA
#>  6:    NA          NA     8          15
#>  7:   170         294    NA          NA
#>  8:     4           5    NA          NA
#>  9:    10          12    NA          NA
#> 10:    13          13    NA          NA
```
