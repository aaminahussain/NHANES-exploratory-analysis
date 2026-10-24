# install and load packages and data ##############################################
install.packages("NHANES")
library(NHANES)
install.packages("tidyverse")
library(tidyverse)
data("NHANES")
install.packages("ggplot2")
library(ggplot2)

# NHANES is a publicly available dataset consisting of survery data of the American population from 2009-2012
# The sample design is a clustered design and incorporates differential probabilities of selection. 
# If you fail to account for the sampling parameters, you may obtain biased estimates and overstate significance levels.


# Taking a look at the data set ####################################################
colnames(NHANES) # 75 variables per ID
glimpse(NHANES) # 10,000 participants
summary(NHANES) # 40 more females in study, 63.72% of patients are white, just over 10% are either black or mexican
# not a lot of asian representation in this study

# Would be interesting to investigate systolic blood pressure with age and BMI
# Chose this because read a paper showing increase in sbp and dbp with age and BMI
# using hospital in japan. Do these findings reflect the data in the america survey?

# Find distributions and NAs 
summary(NHANES[c("BPSys1", "BPSys2", "BPSys3", "BMI", "Age")])
hist(NHANES$BPSys1) # right skewed, mean>median
hist(NHANES$BPSys2) # slightly right skewed, mean>median
hist(NHANES$BPSys3) # slightly right skewed, mean>median
hist(NHANES$BMI) # slightly right skewed, most participants have BMI 20-40
hist(NHANES$Age) # random distribution, also a lot of under 5s

# Filter for adults
NHANES_adults <- NHANES |>
  filter(Age >= 20)
nrow(NHANES_adults)
# 7235 participants remain

# average the 3 bp readings
NHANES_adults <- NHANES_adults |>
  rowwise() |>
  mutate(Mean_SBP = mean(c(BPSys1, BPSys2, BPSys3), na.rm = TRUE)) |>
  ungroup()
summary(NHANES_adults$Mean_SBP)


# remove NAs
NHANES_analysis <- NHANES_adults |>
  filter(!is.na(Age), !is.na(BMI), !is.na(Mean_SBP))
nrow(NHANES_analysis)

# plot BMI against systolic blood pressure ###############################
ggplot(NHANES_analysis, aes(x = BMI, y = Mean_SBP)) +
  geom_point(alpha = 0.4, size = 0.75) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "BMI and Systolic Blood Pressure",
    x = "BMI (kg/m²)",
    y = "Mean Systolic Blood Pressure (mmHg)"
  )

# quantify the correlation between BMI and sbp
cor.test(NHANES_analysis$BMI, NHANES_analysis$Mean_SBP)
# weak positive correlation between BMI and mean systolic blood pressure among adult NHANES participants
# r = 0.127, 95% CI 0.104–0.150, p < 0.001
# evidence against a 0 correlation

# plot age against systolic blood pressure ################################
ggplot(NHANES_analysis, aes(x = Age, y = Mean_SBP)) +
  geom_point(alpha = 0.4, size = 0.75) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Age and Systolic Blood Pressure",
    x = "Age (years)",
    y = "Mean Systolic Blood Pressure (mmHg)"
  )
# slightly stronger positive correlation, with participants more evenly distributed across x axis 

# quantifying correlation between sbp, age and bmi ##########################

# quantify correlation between age and sbp
cor.test(NHANES_analysis$Age, NHANES_analysis$Mean_SBP)
# moderate positive correlation with strong evidence against a 0 correlation
# age shows a moderate positive correlation with mean systolic blood pressure: r = 0.424, 95% CI 0.405–0.443, p < 0.001. 
# stronger than the weak positive correlation observed between BMI and mean systolic blood pressure.
# These are preliminary, unweighted Pearson correlation results. NHANES uses a complex survey design, does not account for survey weights, strata and clusters.


# investigating if the BMI and blood pressure association is related with age?
model <- lm(Mean_SBP ~ BMI + Age, data = NHANES_analysis)
summary(model)
# Variable: Estimate, p-value, Interpretation
# BMI: 0.277, < 0.001. For each increase in BMI unit, predicted SBP increases by 0.277 mmHg, at the same age.
# Age:	0.424, < 0.001. For each increase in year of age, predicted SBP increases by 0.424 mmHg, at the same BMI.
# Multiple r squared shows the model explains ~19.2% of the variation in SBP
# Adjusted r squared shows similar after accounting for number of predictors. 
# Typical residual size is around 15 mmHg.
# Overall, model is statistically significant <0.001. (p-value: < 2.2e-16)
# Both age and BMI remain positively associated with SBP when included in the same model.
# BMI is still statistically significant after accounting for age - suggests association with SBP is not explained entirely by variation in age

plot(model)
# residuals vs fitted plot shows no other unexpected associations?
# Q-Q plot shows data is heavy tailed 
# scale location shows upward trend; variance increases as predictions get larger 
# residuals vs leverage shows few extreme influential points 

# identifying most influential observations
sort(cooks.distance(model), decreasing = TRUE)[1:10]
# all values are well below 0 so not of concern
plot(model, which = 4)
sort(cooks.distance(model), decreasing = TRUE)[1:5]
NHANES_analysis[c(5123, 5124, 4633),
                c("Age", "BMI", "Mean_SBP")]
# very high BMI, median BMI was 25.98, 3rd qu was 30.89 and they have >47

# are these duplicate readings? ##########################################
NHANES_analysis |>
  filter(Age == 54, BMI == 59.2, Mean_SBP == 202)
NHANES_analysis |>
  filter(ID == 66873)

identical(
  NHANES_analysis[NHANES_analysis$ID == 66873, ][1, ],
  NHANES_analysis[NHANES_analysis$ID == 66873, ][2, ]
)


NHANES |>
  filter(ID == 66873)

NHANES |>
  count(ID) |>
  filter(n > 1)

sum(duplicated(NHANES))

#repeated IDs and exact duplicate rows can arise because the dataset was resampled. They don't necessarily mean someone was surveyed twice or that you accidentally duplicated data during processing.
NHANES |>
  summarise(
    total_rows = n(),
    unique_IDs = n_distinct(ID),
    duplicate_rows = sum(duplicated(NHANES))
  )

NHANES_analysis |>
  filter(ID %in% c(66873)) |>
  select(ID, SurveyYr, Age, BMI, Mean_SBP)


