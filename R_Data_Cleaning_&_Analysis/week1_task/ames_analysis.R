# Project: Data Cleaning and Preliminary Analysis with R
# Dataset: Ames Housing Dataset (AmesHousing.csv)
# Author:  Nitesh Yadav
# Purpose: Clean, preprocess, and explore the Ames Housing dataset, produce
#          summary statistics, and derive initial insights about residential
#          property sale prices in Ames, Iowa (2006-2010).

## 0. SETUP ------
# install.packages(c("tidyverse","psych","corrplot","VIM","janitor","moments"))
library(tidyverse)   # dplyr, ggplot2, tidyr, readr
library(psych)       # describe()
library(corrplot)    # correlation heatmap
library(VIM)         # aggr() missing-value visualisation
library(janitor)     # clean_names()
library(moments)      # skewness / kurtosis

set.seed(123)

## 1. LOAD THE DATA ------
ames <- read.csv("R_Data_Cleaning_&_Analysis/week1_task/ames_cleaned.csv", stringsAsFactors = FALSE)
ames <- janitor::clean_names(ames)   # snake_case column names

## 1.1 First look
dim(ames)                 # 2930 rows x 82 columns
str(ames)                 # data types / structure
head(ames, 5)
summary(ames$sale_price)  # target variable

## 2. MISSING VALUE ANALYSIS ------
missing_summary <- data.frame(
  variable   = names(ames),
  n_missing  = colSums(is.na(ames)),
  pct_missing = round(colSums(is.na(ames)) / nrow(ames) * 100, 2)
) %>%
  filter(n_missing > 0) %>%
  arrange(desc(n_missing))

print(missing_summary)

# Visualise the missingness pattern for the worst offenders
VIM::aggr(ames[, missing_summary$variable[1:10]],
          numbers = TRUE, sortVars = TRUE,
          cex.axis = .6, gap = 3,
          labels = missing_summary$variable[1:10])

## 3. DATA CLEANING ------

## 3.1 Structural NAs -> "None" (the data dictionary states that NA for
##     these fields means the house does NOT have that feature, so it is
##     not truly "missing" data)
none_cols <- c("pool_qc","misc_feature","alley","fence","fireplace_qu",
               "garage_type","garage_finish","garage_qual","garage_cond",
               "bsmt_qual","bsmt_cond","bsmt_exposure",
               "bsmt_fin_type_1","bsmt_fin_type_2","mas_vnr_type")

ames <- ames %>%
  mutate(across(all_of(none_cols), ~ ifelse(is.na(.x), "None", .x)))

## 3.2 Numeric NAs that mean "0" (no basement / no garage / no masonry)
zero_cols <- c("mas_vnr_area","bsmt_fin_sf_1","bsmt_fin_sf_2","bsmt_unf_sf",
               "total_bsmt_sf","bsmt_full_bath","bsmt_half_bath",
               "garage_cars","garage_area")

ames <- ames %>%
  mutate(across(all_of(zero_cols), ~ ifelse(is.na(.x), 0, .x)))

## 3.3 Garage Yr Blt -> if no garage, use Year Built instead of NA
ames <- ames %>%
  mutate(garage_yr_blt = ifelse(is.na(garage_yr_blt), year_built, garage_yr_blt))

## 3.4 Lot Frontage -> impute with the median frontage of the same
##     neighborhood (properties in the same neighborhood tend to have
##     similar lot geometry)
ames <- ames %>%
  group_by(neighborhood) %>%
  mutate(lot_frontage = ifelse(is.na(lot_frontage),
                                median(lot_frontage, na.rm = TRUE),
                                lot_frontage)) %>%
  ungroup()

## 3.5 Electrical -> single missing value, impute with the mode
mode_electrical <- names(sort(table(ames$electrical), decreasing = TRUE))[1]
ames$electrical[is.na(ames$electrical)] <- mode_electrical

## 3.6 Confirm no missing values remain in columns we plan to model
sum(is.na(ames %>% select(-c())))     # remaining NAs, if any, by design (rare)
colSums(is.na(ames))[colSums(is.na(ames)) > 0]

## 4. OUTLIER DETECTION ------

## 4.1 Boxplot-based visual check on the target and key predictor
boxplot(ames$sale_price, main = "Boxplot of Sale Price", col = "skyblue")
boxplot(ames$gr_liv_area, main = "Boxplot of Above-Grade Living Area", col = "salmon")

## 4.2 IQR rule
iqr_bounds <- function(x) {
  q1 <- quantile(x, .25, na.rm = TRUE); q3 <- quantile(x, .75, na.rm = TRUE)
  iqr <- q3 - q1
  c(lower = q1 - 1.5 * iqr, upper = q3 + 1.5 * iqr)
}
iqr_bounds(ames$sale_price)
iqr_bounds(ames$gr_liv_area)

n_outliers_price <- sum(ames$sale_price > iqr_bounds(ames$sale_price)["upper"])
n_outliers_area  <- sum(ames$gr_liv_area > iqr_bounds(ames$gr_liv_area)["upper"])

## 4.3 Well-documented Ames outliers: very large homes sold at unusually
##     low prices (data-entry / partial-sale anomalies noted by the
##     dataset's creator, Dean De Cock). Remove them.
ames_clean <- ames %>%
  filter(!(gr_liv_area > 4000 & sale_price < 300000))

dim(ames_clean)   # rows dropped

## 5. NORMALIZATION / SCALING --------
num_vars <- c("sale_price","gr_liv_area","total_bsmt_sf","lot_area",
              "year_built","overall_qual","garage_area")

# Min-max scaling (0-1)
minmax <- function(x) (x - min(x)) / (max(x) - min(x))
ames_scaled <- ames_clean %>%
  mutate(across(all_of(num_vars), minmax, .names = "{.col}_norm"))

# Z-score standardization (mean 0, sd 1) - alternative used for correlation /
# modeling stability
ames_scaled <- ames_scaled %>%
  mutate(across(all_of(num_vars), ~ as.numeric(scale(.x)), .names = "{.col}_z"))

## 6. ENCODING CATEGORICAL VARIABLES ---

## 6.1 Ordinal encoding for quality/condition scales (Po < Fa < TA < Gd < Ex)
qual_levels <- c("None","Po","Fa","TA","Gd","Ex")
qual_cols <- c("exter_qual","exter_cond","bsmt_qual","bsmt_cond",
               "heating_qc","kitchen_qual","fireplace_qu",
               "garage_qual","garage_cond")

ames_scaled <- ames_scaled %>%
  mutate(across(all_of(qual_cols),
                ~ as.integer(factor(.x, levels = qual_levels, ordered = TRUE))))

## 6.2 Nominal encoding: one-hot / dummy variables for modeling-ready data
nominal_cols <- c("ms_zoning","neighborhood","bldg_type","house_style",
                   "central_air","sale_condition")

dummies <- model.matrix(~ . - 1, data = ames_scaled[, nominal_cols] %>%
                           mutate(across(everything(), as.factor)))
ames_encoded <- cbind(ames_scaled, as.data.frame(dummies))

dim(ames_encoded)   # final width after one-hot encoding

## 7. EXPLORATORY DATA ANALYSIS -----

## 7.1 Structure & summary statistics
str(ames_clean)
summary(ames_clean[, num_vars])
psych::describe(ames_clean[, num_vars])

## 7.2 Distribution of the target variable
ggplot(ames_clean, aes(x = sale_price)) +
  geom_histogram(bins = 40, fill = "steelblue", color = "white") +
  labs(title = "Distribution of Sale Price", x = "Sale Price ($)", y = "Count")

skewness(ames_clean$sale_price)
kurtosis(ames_clean$sale_price)

## Log transform to address right-skew
ames_clean$log_sale_price <- log(ames_clean$sale_price)
ggplot(ames_clean, aes(x = log_sale_price)) +
  geom_histogram(bins = 40, fill = "darkgreen", color = "white") +
  labs(title = "Distribution of log(Sale Price)")

## 7.3 Correlation analysis among numeric predictors
corr_matrix <- cor(ames_clean %>% select(all_of(num_vars)), use = "complete.obs")
round(corr_matrix, 2)
corrplot(corr_matrix, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black", number.cex = .7)

## 7.4 Relationship between predictors and Sale Price
ggplot(ames_clean, aes(x = gr_liv_area, y = sale_price)) +
  geom_point(alpha = .4, color = "steelblue") +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Sale Price vs Above-Grade Living Area")

ggplot(ames_clean, aes(x = factor(overall_qual), y = sale_price)) +
  geom_boxplot(fill = "orange") +
  labs(title = "Sale Price by Overall Quality Rating", x = "Overall Quality (1-10)")

ggplot(ames_clean, aes(x = reorder(neighborhood, sale_price, median),
                        y = sale_price)) +
  geom_boxplot(fill = "lightgreen") +
  coord_flip() +
  labs(title = "Sale Price by Neighborhood", x = "Neighborhood")

## 7.5 Categorical composition
table(ames_clean$house_style)
table(ames_clean$central_air)
prop.table(table(ames_clean$sale_condition)) * 100

## 8. EXPORT THE CLEANED DATASET -----
write.csv(ames_clean,   "ames_cleaned.csv",   row.names = FALSE)
write.csv(ames_encoded, "ames_model_ready.csv", row.names = FALSE)


