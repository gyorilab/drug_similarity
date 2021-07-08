# drug_similarity
Implement and combine multiple different methods of computing drug similarity.

## Compund similarities from Small Molecule Suite (SMS)

R package for computing chemical, target (TAS) and phenotypic similarities
between compounds.

[See SMS R package README](sms/README.md)

[Interactive queries at https://labsyspharm.shinyapps.io/smsquery/](https://labsyspharm.shinyapps.io/smsquery/)

### Installation

``` r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("indralab/drug_similarity", subdir = "sms")
```
