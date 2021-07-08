# drug_similarity
Implement and combine multiple different methods of computing drug similarity.

## Compund similarities from Small Molecule Suite (SMS)

R package for computing chemical, target (TAS) and phenotypic similarities
between compounds.

### Installation

``` r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("indralab/drug_similarity")
```

### Examples

``` r
sms_tas_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE)
```

```
| target_lspci_id| query_lspci_id| tas_similarity| n_tas| n_prior_tas|query_compound |target_compound |
|---------------|--------------|--------------|-----|-----------|--------------|---------------|
|            2373|          66153|      0.3055556|    10|          11|RUXOLITINIB    |ELLAGIC ACID    |
|            2373|          78036|      0.3164557|    10|          11|TOFACITINIB    |ELLAGIC ACID    |
|            3261|          66153|      0.3289474|     9|          17|RUXOLITINIB    |NORHARMANE      |
|            3261|          78036|      0.3203883|    11|          19|TOFACITINIB    |NORHARMANE      |
|            4623|          66153|      0.3157895|     6|           6|RUXOLITINIB    |IQ-1S           |
|            4623|          78036|      0.3750000|     6|           6|TOFACITINIB    |IQ-1S           |
```

``` r
sms_chemical_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE)
```

```
| target_lspci_id| query_lspci_id| structural_similarity|query_compound |target_compound         |
|---------------|--------------|---------------------|--------------|-----------------------|
|               2|          66153|             0.1222222|RUXOLITINIB    |TETRAMETHYLAMMONIUM ION |
|               2|          66153|             0.0918367|RUXOLITINIB    |TETRAMETHYLAMMONIUM ION |
|               2|          66153|             0.1250000|RUXOLITINIB    |TETRAMETHYLAMMONIUM ION |
|               2|          66153|             0.0000000|RUXOLITINIB    |TETRAMETHYLAMMONIUM ION |
|               2|          78036|             0.1170213|TOFACITINIB    |TETRAMETHYLAMMONIUM ION |
|               2|          78036|             0.0990099|TOFACITINIB    |TETRAMETHYLAMMONIUM ION |
```

``` r
sms_phenotypic_similarity(c("ruxolitinib", "tofacitinib"), show_compound_names = TRUE)
```

```
| target_lspci_id| query_lspci_id| phenotypic_correlation| n_pfp| n_prior_pfp|query_compound |target_compound |
|---------------|--------------|----------------------|-----|-----------|--------------|---------------|
|            4870|          66153|              0.0158545|     8|          15|RUXOLITINIB    |VORINOSTAT      |
|           31506|          78036|              0.4913603|     4|           6|TOFACITINIB    |NSC-401077      |
|           51110|          78036|              0.4591956|     4|           6|TOFACITINIB    |VELIFLAPON      |
|           54590|          78036|              0.5862903|     4|           6|TOFACITINIB    |PRAVADOLINE     |
|          466893|          78036|              0.5023700|     4|           6|TOFACITINIB    |SID 7969543     |
```
