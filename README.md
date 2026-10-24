# NHANES-exploratory-analysis


## Question - Are age and body mass index (BMI) associated with systolic blood pressure (sbp) among adult participants of the NHANES study?

This exploratory analysis uses the NHANES package in R which is available to the public. It looks at adults 20 years or older and uses the available sbp readings to calculate a participant-level mean.

## Main findings

The analysis included **6,919 complete adult records** after filtering the 10,000-row teaching dataset to adults (7,235 records) and excluding records missing age, BMI, or mean systolic blood pressure.

- BMI had a **weak positive unadjusted correlation** with mean systolic blood pressure (*r* = 0.127, 95% CI 0.104 to 0.150; *p* < 0.001).
- Age had a **moderate positive unadjusted correlation** with mean systolic blood pressure (*r* = 0.424, 95% CI 0.405 to 0.443; *p* < 0.001).
- In a multiple linear regression including both predictors, each additional BMI unit was associated with an estimated **0.277 mm Hg higher** mean systolic blood pressure, adjusting for age (SE 0.028; *p* < 0.001).
- Each additional year of age was associated with an estimated **0.424 mm Hg higher** mean systolic blood pressure, adjusting for BMI (SE 0.011; *p* < 0.001).
- The model explained ~**19.2%** of the observed variation in mean systolic blood pressure (R² = 0.192; adjusted R² = 0.191; residual standard error = 15.38 mm Hg).

These are associations and should not be treated as causative evidence. The correlations are unadjusted; the regression coefficients are adjusted for the other predictor in the model.

## Data preparation

The script calculates `Mean_SBP` as the row mean of `BPSys1`, `BPSys2`, and `BPSys3`, with missing readings ignored. Rows without any systolic reading produce a missing mean and are removed when selecting complete cases. The adult filter is `Age >= 20`.

The package documentation says `NHANES` contains 10,000 rows resampled from `NHANESraw` for educational use. In this extract there were **6,779 unique IDs** and **2,168 rows beyond the first row for each ID**. Exact repeated rows were observed, including two rows for ID 66873 (age 54, BMI 59.2, mean systolic blood pressure 202 mm Hg). Repeated rows were retained because they are part of the package's resampled teaching data; they were not treated as a data-entry error or removed.

## Limitations

- The package describes `NHANES` as an educational resampling of NHANES data, not a research database. The ordinary correlations and `lm()` model here do not account for the original survey design. Do not interpret the reported p-values or confidence intervals as survey-design-valid population inference.
- The model is a simple linear model. Diagnostic plots suggested heavy tails in the residuals and increasing residual spread at higher fitted values, so the usual model uncertainty estimates may be imperfect.
- The analysis uses only age and BMI as predictors. Other factors related to blood pressure are not included, and this exploratory association does not establish causation.
- `Age` is top-coded at 80 in the package data, which limits interpretation for the oldest participants.

For population-level NHANES inference, use the original NHANES files and apply the appropriate sample weights, strata, and primary sampling units as described by NCHS.

## Reproduce the analysis

Install R, then install the required packages once in the R console:

```r
install.packages(c("NHANES", "tidyverse", "ggplot2"))
```

After installation, run the analysis script from the project directory:

```r
source("NHANES sbp analysis.R")
```

The script follows the exploratory workflow in `analysis.R`: it inspects the data, displays histograms and scatterplots, prints the correlation and regression results, and opens the model diagnostic plots. The script contains the package installation commands as comments so they are not rerun every time you source it.

## Repository contents

- `NHANES sbp analysis.R` — data preparation, exploratory plots, correlations, regression, and diagnostics.

