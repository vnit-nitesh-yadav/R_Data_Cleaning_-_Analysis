# R_Data_Cleaning_-_Analysis

#  Ames Housing Data Analysis & Predictive Modeling in R

##  From Raw Data to Predictive Insight

An end-to-end data analysis project using the **Ames Housing Dataset**, developed in R across four stages:

1. **Data Cleaning & Preliminary Analysis**
2. **Data Visualization & Exploratory Analysis**
3. **Statistical Analysis & Predictive Modeling**
4. **Comprehensive Final Analysis & Reporting**

The project demonstrates a complete data-analysis workflow, beginning with raw housing data and progressing through data cleaning, exploratory analysis, visualization, statistical hypothesis testing, predictive modeling, model validation, and business-oriented interpretation.

---

##  Project Overview

The Ames Housing Dataset contains information about residential properties sold in **Ames, Iowa, between 2006 and 2010**.

The raw dataset contains:

* **2,930 property records**
* **82 variables**
* Numerical and categorical attributes
* Property characteristics
* Construction and quality information
* Basement and garage information
* Location information
* Sale conditions
* Sale price

The main analytical objective of this project is to understand:

> **Which property characteristics are associated with residential sale prices, and how accurately can sale prices be predicted using statistical modeling?**

The project follows a structured data-science workflow:

```text
Raw Dataset
     │
     ▼
Data Understanding
     │
     ▼
Data Cleaning
     │
     ▼
Missing Value Treatment
     │
     ▼
Outlier Detection
     │
     ▼
Data Transformation
     │
     ▼
Exploratory Data Analysis
     │
     ▼
Data Visualization
     │
     ▼
Statistical Hypothesis Testing
     │
     ▼
Feature Selection
     │
     ▼
Regression Modeling
     │
     ▼
Cross-Validation
     │
     ▼
Model Diagnostics
     │
     ▼
Log-Transformed Model
     │
     ▼
Final Business Insights
```

---

#  Project Objectives

The project was designed with the following objectives:

* Understand the structure and characteristics of the Ames Housing Dataset.
* Identify and handle missing values appropriately.
* Detect and treat unusual observations and documented data anomalies.
* Transform numerical and categorical variables into analysis-ready formats.
* Explore the distribution of residential sale prices.
* Identify important factors associated with sale price.
* Communicate patterns using effective data visualizations.
* Perform formal statistical hypothesis tests.
* Build a multiple linear regression model for sale-price prediction.
* Validate model performance using cross-validation and a held-out test set.
* Diagnose regression assumptions and potential modeling problems.
* Improve the model using a log-transformed target variable.
* Translate statistical results into understandable business insights.

---

#  Repository Structure

```text
R_Data_Cleaning_&_Analysis/
│
├── week1_task/
│   │
│   ├── AmesHousing.csv
│   ├── ames_analysis.R
│   ├── ames_cleaned.csv
│   └── Ames_Housing_Data_Cleaning_Report.docx
│
├── week2_task/
│   │
│   ├── ames_visualization.R
│   └── Week2_Task_Ames_Housing_Data_Visualization_Report.docx
│
├── week3_task/
│   │
│   ├── ames_modeling.R
│   └── Week3_task_Ames_Housing_Statistical_Modeling_Report.docx
│
└── week4_task/
    │
    └── Ames_Housing_Comprehensive_Final_Report.docx
```

---

# Dataset

## Ames Housing Dataset

The project uses the **Ames Housing Dataset**, compiled by **Dean De Cock**.

The dataset contains residential property sales from Ames, Iowa, covering the period **2006–2010**.

### Raw dataset

```text
File:
week1_task/AmesHousing.csv
```

### Dataset dimensions

```text
Rows:    2,930
Columns: 82
```

### Target variable

The primary target variable is:

```text
Sale Price
```

After cleaning, the dataset contains:

```text
2,927 observations
```

because three documented anomalous observations were removed during the cleaning stage.

---

# 🛠️ Technologies and Tools

The project was implemented using **R / RStudio**.

## Main R packages

### Data manipulation

```r
tidyverse
```

Used for:

* Data loading
* Filtering
* Transformation
* Grouping
* Summarization
* Visualization

### Data cleaning

```r
janitor
```

Used for:

* Standardizing column names
* Converting variable names into `snake_case`

### Missing-value visualization

```r
VIM
```

Used to visualize missing-value patterns.

### Descriptive statistics

```r
psych
```

Used for detailed descriptive statistics.

### Distribution analysis

```r
moments
```

Used for:

* Skewness
* Kurtosis

### Correlation analysis

```r
corrplot
```

Used to generate correlation heatmaps.

### Visualization

```r
ggplot2
scales
ggridges
```

Used for creating publication-quality charts.

### Statistical modeling

```r
caret
car
lmtest
broom
```

Used for:

* Train/test splitting
* Cross-validation
* Multicollinearity analysis
* Heteroscedasticity testing
* Model summaries

### Regression

```r
lm()
```

Used to build multiple linear regression models.

---

# 📅 Week 1 — Data Cleaning & Preliminary Analysis

## Objective

The first stage focuses on converting the raw Ames Housing data into a clean and analysis-ready dataset.

The main tasks were:

1. Load the raw dataset.
2. Inspect its structure.
3. Analyze missing values.
4. Treat missing values according to their meaning.
5. Detect outliers.
6. Remove documented anomalies.
7. Normalize numerical variables.
8. Encode categorical variables.
9. Perform preliminary exploratory analysis.
10. Export the cleaned dataset.

---

## 1. Loading the Dataset

The raw CSV file is loaded using:

```r
ames <- read.csv("AmesHousing.csv", stringsAsFactors = FALSE)
```

Column names are standardized using:

```r
ames <- janitor::clean_names(ames)
```

This converts names such as:

```text
SalePrice
Gr Liv Area
Overall Qual
```

into consistent R-friendly names such as:

```text
sale_price
gr_liv_area
overall_qual
```

---

# 2. Initial Data Inspection

The dataset is inspected using:

```r
dim(ames)
str(ames)
head(ames, 5)
summary(ames$sale_price)
```

This provides:

* Number of observations
* Number of variables
* Variable types
* Sample records
* Sale-price statistics

The raw dataset contains:

```text
2,930 rows
82 columns
```

---

# 3. Missing Value Analysis

Missing values are first identified rather than immediately replaced.

The project calculates:

```r
missing_summary <- data.frame(
  variable = names(ames),
  n_missing = colSums(is.na(ames)),
  pct_missing =
    round(colSums(is.na(ames)) / nrow(ames) * 100, 2)
)
```

This produces a summary showing:

* Variable name
* Number of missing values
* Percentage of missing values

The project identified missing values in **27 of the 82 variables**.

---

# 4. Understanding Why Values Are Missing

A key part of this project is that missing values were **not blindly replaced**.

For several Ames Housing variables, `NA` actually means that the property does not contain that feature.

For example:

```text
Pool QC = NA
```

does not necessarily mean:

> "Pool information was not recorded."

It means:

> "The house does not have a pool."

Therefore, these values should be represented as:

```text
None
```

rather than statistical imputations.

---

# 5. Structural Missing Values

The following types of variables were converted from missing values to `"None"` where the missing value represents absence of a property feature:

```r
none_cols <- c(
  "pool_qc",
  "misc_feature",
  "alley",
  "fence",
  "fireplace_qu",
  "garage_type",
  "garage_finish",
  "garage_qual",
  "garage_cond",
  "bsmt_qual",
  "bsmt_cond",
  "bsmt_exposure",
  "bsmt_fin_type_1",
  "bsmt_fin_type_2",
  "mas_vnr_type"
)
```

Then:

```r
ames <- ames %>%
  mutate(
    across(
      all_of(none_cols),
      ~ ifelse(is.na(.x), "None", .x)
    )
  )
```

---

# 6. Numeric Missing Values Representing Zero

For some numerical variables, a missing value means the property has none of the corresponding feature.

For example:

```text
No garage → Garage Area = 0
No basement → Basement Area = 0
```

Therefore, these variables were converted to zero:

```r
zero_cols <- c(
  "mas_vnr_area",
  "bsmt_fin_sf_1",
  "bsmt_fin_sf_2",
  "bsmt_unf_sf",
  "total_bsmt_sf",
  "bsmt_full_bath",
  "bsmt_half_bath",
  "garage_cars",
  "garage_area"
)
```

---

# 7. Garage Year Built

For missing garage construction years, the project uses the property's construction year:

```r
ames <- ames %>%
  mutate(
    garage_yr_blt =
      ifelse(
        is.na(garage_yr_blt),
        year_built,
        garage_yr_blt
      )
  )
```

This prevents the variable from remaining missing where a reasonable structural assumption can be made.

---

# 8. Lot Frontage Imputation

Lot frontage depends strongly on neighborhood characteristics.

Instead of using the global median, the project calculates the median frontage **within each neighborhood**:

```r
ames <- ames %>%
  group_by(neighborhood) %>%
  mutate(
    lot_frontage =
      ifelse(
        is.na(lot_frontage),
        median(lot_frontage, na.rm = TRUE),
        lot_frontage
      )
  ) %>%
  ungroup()
```

This preserves local geographic characteristics better than a single dataset-wide median.

---

# 9. Electrical Missing Value

Only one missing electrical value was present.

The project uses the most frequent category:

```r
mode_electrical <-
  names(
    sort(
      table(ames$electrical),
      decreasing = TRUE
    )
  )[1]

ames$electrical[
  is.na(ames$electrical)
] <- mode_electrical
```

---

# 10. Outlier Detection

Outliers were examined using:

* Boxplots
* Interquartile Range (IQR)
* Domain knowledge

For example:

```r
boxplot(
  ames$sale_price,
  main = "Boxplot of Sale Price"
)
```

The IQR method was also implemented:

```r
iqr_bounds <- function(x) {
  q1 <- quantile(x, .25, na.rm = TRUE)
  q3 <- quantile(x, .75, na.rm = TRUE)

  iqr <- q3 - q1

  c(
    lower = q1 - 1.5 * iqr,
    upper = q3 + 1.5 * iqr
  )
}
```

---

# 11. Treatment of Documented Ames Outliers

The project removes three documented anomalous observations involving very large homes sold at unusually low prices.

The filtering rule is:

```r
ames_clean <- ames %>%
  filter(
    !(gr_liv_area > 4000 &
      sale_price < 300000)
  )
```

The cleaned dataset therefore contains:

```text
2,927 records
```

---

# 12. Data Transformation

The project applies both normalization and standardization.

## Min-Max Normalization

```r
minmax <- function(x)
  (x - min(x)) /
  (max(x) - min(x))
```

This converts values to approximately:

```text
0 to 1
```

## Z-score Standardization

```r
as.numeric(scale(x))
```

This transforms variables to:

```text
Mean ≈ 0
Standard deviation ≈ 1
```

---

# 13. Categorical Variable Encoding

Categorical variables are divided into:

### Ordinal variables

Variables where the order has meaning.

For example:

```text
None
Po
Fa
TA
Gd
Ex
```

These were converted into ordered numerical values.

```r
qual_levels <- c(
  "None",
  "Po",
  "Fa",
  "TA",
  "Gd",
  "Ex"
)
```

### Nominal variables

Variables where categories do not have an inherent numerical order.

Examples:

```text
Neighborhood
Building Type
House Style
Central Air
Sale Condition
```

These were converted into dummy variables using:

```r
model.matrix()
```

---

# 14. Exploratory Data Analysis

The project then investigates:

* Sale-price distribution
* Skewness
* Kurtosis
* Correlations
* Living area vs sale price
* Overall quality vs sale price
* Neighborhood vs sale price
* House style
* Central air
* Sale condition

For example:

```r
ggplot(
  ames_clean,
  aes(x = sale_price)
) +
  geom_histogram(bins = 40)
```

A log transformation is also examined:

```r
ames_clean$log_sale_price <-
  log(ames_clean$sale_price)
```

---

#  Week 2 — Data Visualization

Week 2 uses the cleaned dataset:

```text
ames_cleaned.csv
```

The objective is to transform the exploratory results into understandable visual insights.

The project creates **12 visualizations**.

---

## Visualization 1 — Sale Price Distribution

A histogram shows:

* Typical price range
* Distribution shape
* Right skew
* High-price observations

---

## Visualization 2 — Average Price by House Style

A bar chart compares average sale prices across architectural styles.

Purpose:

> Identify whether architectural style is associated with different average prices.

---

## Visualization 3 — Price by Overall Quality

A boxplot compares sale prices across quality ratings.

Purpose:

> Determine how strongly construction quality is associated with sale price.

---

## Visualization 4 — Living Area vs Price

A scatter plot examines:

```text
Above-grade living area
          ↓
     Sale Price
```

A trend line is added to identify the relationship.

---

## Visualization 5 — Price by Neighborhood

A boxplot compares sale prices across neighborhoods.

Purpose:

> Investigate the effect of location on housing prices.

---

## Visualization 6 — Sales Seasonality

A line chart examines the number of homes sold by month.

Purpose:

> Identify seasonal patterns in housing transactions.

---

## Visualization 7 — Median Price by Year

A line chart examines median sale price from 2006–2010.

Purpose:

> Understand how the housing market changed over time.

---

## Visualization 8 — Central Air vs Price

A density plot compares price distributions for:

```text
Homes without central air
vs
Homes with central air
```

---

## Visualization 9 — House Style Composition

A stacked bar chart examines house styles within building types.

---

## Visualization 10 — Correlation Heatmap

The heatmap examines relationships among:

```text
Sale Price
Living Area
Basement Area
Garage Area
Overall Quality
Year Built
Bathrooms
Total Rooms
```

---

## Visualization 11 — Garage Type vs Price

A bar chart compares average sale prices by garage type.

---

## Visualization 12 — Price by Quality Tier

Quality is divided into:

```text
Low
Average
Good
Excellent
```

and sale-price distributions are compared.

---

#  Week 3 — Statistical Analysis & Predictive Modeling

The third stage moves from descriptive analysis to formal statistical inference and predictive modeling.

The primary prediction target is:

```text
sale_price
```

Because sale price is continuous, the project uses **regression** rather than classification.

---

# 1. Normality Testing

The Shapiro-Wilk test is used:

```r
shapiro.test(ames$sale_price)
```

The project also tests:

```r
log(ames$sale_price)
```

and compares Q-Q plots.

The log transformation reduces the strong right-skew of raw sale price.

---

# 2. Hypothesis Test — Central Air

The project investigates:

### Null hypothesis

```text
H0:
Mean sale price is equal for homes
with and without central air.
```

### Alternative hypothesis

```text
H1:
Mean sale price differs between the two groups.
```

A Welch two-sample t-test is used:

```r
t.test(
  sale_price ~ central_air,
  data = ames
)
```

---

# 3. Correlation Hypothesis Test

The relationship between:

```text
Above-grade living area
```

and:

```text
Sale price
```

is tested using Pearson correlation:

```r
cor.test(
  ames$gr_liv_area,
  ames$sale_price,
  method = "pearson"
)
```

---

# 4. ANOVA

A one-way ANOVA tests whether mean sale prices differ across building types:

```r
anova_model <-
  aov(
    sale_price ~ bldg_type,
    data = ames
  )

summary(anova_model)
```

Tukey's HSD is then used for pairwise comparisons:

```r
TukeyHSD(anova_model)
```

---

# 5. Chi-Square Test

The project tests whether:

```text
Central Air
```

and:

```text
Building Type
```

are associated.

```r
chisq.test(
  table(
    ames$central_air,
    ames$bldg_type
  )
)
```

---

# 6. Feature Selection

The predictive model uses variables such as:

```text
overall_qual
gr_liv_area
total_bsmt_sf
garage_area
year_built
full_bath
totrms_abvgrd
lot_area
fireplaces
neighborhood
central_air
bldg_type
```

Categorical variables are explicitly converted to factors.

---

# 7. Train/Test Split

The data is divided into:

```text
80% Training
20% Testing
```

using:

```r
createDataPartition()
```

This allows the final model to be evaluated on data that was not used during training.

---

# 8. Baseline Regression Model

A multiple linear regression model is built using core numerical predictors:

```r
model_base <- lm(
  sale_price ~
    overall_qual +
    gr_liv_area +
    total_bsmt_sf +
    garage_area +
    year_built +
    full_bath +
    totrms_abvgrd +
    lot_area +
    fireplaces,
  data = train_set
)
```

---

# 9. Full Regression Model

The full model adds categorical predictors:

```r
model_full <- lm(
  sale_price ~
    overall_qual +
    gr_liv_area +
    total_bsmt_sf +
    garage_area +
    year_built +
    full_bath +
    totrms_abvgrd +
    lot_area +
    fireplaces +
    central_air +
    bldg_type,
  data = train_set
)
```

The two models are compared using:

```r
anova(
  model_base,
  model_full
)
```

---

# 10. 10-Fold Cross-Validation

The model is validated using:

```r
trainControl(
  method = "cv",
  number = 10
)
```

This divides the training data into 10 folds and repeatedly trains/tests the model.

The main evaluation metrics include:

```text
RMSE
R-squared
MAE
```

---

# 11. Held-Out Test Set

Predictions are generated using:

```r
predictions <-
  predict(
    model_full,
    newdata = test_set
  )
```

Performance is evaluated using:

```r
postResample(
  pred = predictions,
  obs = test_set$sale_price
)
```

This provides an independent assessment of predictive performance.

---

# 12. Regression Diagnostics

Several diagnostics are performed.

### Residuals vs Fitted

Checks:

* Linearity
* Homoscedasticity

### Normal Q-Q

Checks:

* Normality of residuals

### Scale-Location

Checks:

* Constant variance

### Residuals vs Leverage

Checks:

* Influential observations

---

# 13. Heteroscedasticity

The Breusch-Pagan test is used:

```r
bptest(model_full)
```

This checks whether residual variance changes across predicted values.

---

# 14. Multicollinearity

Variance Inflation Factors are calculated:

```r
vif(model_full)
```

This helps identify predictors that contain highly overlapping information.

---

# 15. Actual vs Predicted Plot

The project compares:

```text
Actual Sale Price
vs
Predicted Sale Price
```

using a scatter plot and a reference line.

A good model should have predictions reasonably close to the:

```text
y = x
```

line.

---

# 16. Log-Transformed Regression

Because sale price is strongly right-skewed, a second model predicts:

```text
log(Sale Price)
```

instead of raw Sale Price.

```r
model_log <- lm(
  log_sale_price ~
    overall_qual +
    gr_liv_area +
    total_bsmt_sf +
    garage_area +
    year_built +
    full_bath +
    totrms_abvgrd +
    lot_area +
    fireplaces +
    central_air +
    bldg_type,
  data = train_set
)
```

Predictions are converted back to the original dollar scale using:

```r
log_predictions <-
  exp(
    predict(
      model_log,
      newdata = test_set
    )
  )
```

The transformed model is then compared with the original model.

---

# 📋 Week 4 — Comprehensive Final Report

Week 4 integrates the entire project into a single report.

The final report combines:

```text
Week 1
Data Cleaning
       +
Week 2
Visualization
       +
Week 3
Statistical Modeling
       ↓
Week 4
Comprehensive Analysis
```

The final report covers:

* Introduction
* Methodology
* Data preparation
* Visualization
* Statistical analysis
* Predictive modeling
* Model diagnostics
* Results
* Business implications
* Discussion
* Lessons learned
* Future directions
* Conclusion

---

# Major Findings

The complete analysis identifies several important patterns.

## 1. Overall Quality is a Major Price Driver

Overall construction/material quality shows one of the strongest relationships with sale price.

The final analysis reports a correlation of approximately:

```text
r ≈ 0.80
```

between overall quality and sale price.

---

## 2. Living Area is Strongly Related to Price

Larger above-grade living areas generally correspond to higher sale prices.

The Week 3 analysis reports a Pearson correlation of approximately:

```text
r ≈ 0.727
```

between living area and sale price.

---

## 3. Central Air is Associated with Higher Prices

The statistical analysis found a substantial difference in average sale price between properties with and without central air.

This relationship was investigated visually in Week 2 and formally tested in Week 3.

---

## 4. Location Matters

Neighborhood analysis demonstrates substantial differences in sale prices across Ames.

Therefore, location is an important factor when explaining housing prices.

---

## 5. Sale Price is Right-Skewed

The distribution of sale price contains a long right tail.

This motivated the use of:

```text
log(Sale Price)
```

as an alternative modeling target.

---

## 6. Regression Provides Useful Predictive Performance

The final model explains a substantial proportion of variation in sale prices.

The final report compares the original and log-transformed models using:

* R²
* RMSE
* MAE
* Cross-validation
* Test-set performance

---

# Key Data Science Concepts Demonstrated

This project demonstrates a broad range of practical data-science techniques:

### Data Preparation

```text
Data inspection
Missing-value analysis
Imputation
Outlier detection
Normalization
Standardization
Categorical encoding
```

### Exploratory Analysis

```text
Descriptive statistics
Distribution analysis
Skewness
Kurtosis
Correlation
Group comparisons
```

### Visualization

```text
Histogram
Bar chart
Boxplot
Scatter plot
Line chart
Density plot
Stacked bar chart
Heatmap
Faceted histogram
```

### Statistical Analysis

```text
Shapiro-Wilk test
Welch t-test
Pearson correlation test
ANOVA
Tukey HSD
Chi-square test
```

### Machine Learning / Modeling

```text
Multiple Linear Regression
Train/Test Split
10-Fold Cross-Validation
RMSE
MAE
R²
```

### Model Diagnostics

```text
Residual analysis
Q-Q plots
Scale-location
Leverage
Breusch-Pagan test
VIF
```

### Model Improvement

```text
Log transformation
```

---

# How to Run the Project

## Step 1 — Install R

Install R from the official R website and optionally install RStudio.

---

## Step 2 — Open the Project

Open the project directory in RStudio.

---

## Step 3 — Install Required Packages

Run:

```r
install.packages(
  c(
    "tidyverse",
    "psych",
    "corrplot",
    "VIM",
    "janitor",
    "moments",
    "scales",
    "ggridges",
    "caret",
    "car",
    "lmtest",
    "broom"
  )
)
```

---

#  Run Week 1

Set the working directory to:

```text
week1_task/
```

Then execute:

```r
source("ames_analysis.R")
```

This performs the cleaning and preliminary analysis.

The main output is:

```text
ames_cleaned.csv
```

The script also creates:

```text
ames_model_ready.csv
```

---

# Run Week 2

The Week 2 script uses the cleaned Ames dataset.

Set the working directory appropriately and run:

```r
source("ames_visualization.R")
```

This produces the visualization analysis used in the Week 2 report.

---

# Run Week 3

Week 3 uses:

```text
ames_cleaned.csv
```

Run:

```r
source("ames_modeling.R")
```

This performs:

```text
Hypothesis Testing
       ↓
Feature Selection
       ↓
Train/Test Split
       ↓
Regression
       ↓
Cross-Validation
       ↓
Test Evaluation
       ↓
Diagnostics
       ↓
Log-Transformed Model
```

The model objects are exported as:

```text
ames_lm_full.rds
ames_lm_log.rds
```

---

#  Reports

Each stage has a corresponding report.

## Week 1

```text
Ames_Housing_Data_Cleaning_Report.docx
```

Documents:

* Dataset overview
* Missing-value analysis
* Cleaning
* Outlier treatment
* Transformation
* Encoding
* EDA
* Initial insights

## Week 2

```text
Week2_Task_Ames_Housing_Data_Visualization_Report.docx
```

Documents the 12 visualizations and their interpretations.

## Week 3

```text
Week3_task_Ames_Housing_Statistical_Modeling_Report.docx
```

Documents:

* Hypothesis testing
* Regression
* Cross-validation
* Diagnostics
* Log-transformed modeling

## Week 4

```text
Ames_Housing_Comprehensive_Final_Report.docx
```

Provides the integrated final analysis.

---

# 🔗 Relationship Between Project Files

The project follows this dependency structure:

```text
AmesHousing.csv
      │
      ▼
ames_analysis.R
      │
      ├──────────────► ames_cleaned.csv
      │
      └──────────────► ames_model_ready.csv
                           │
                           │
                           ▼
                 ames_visualization.R
                           │
                           ▼
                    Week 2 Insights
                           │
                           ▼
                    ames_modeling.R
                           │
                           ▼
                 Statistical Analysis
                           │
                           ▼
                  Predictive Modeling
                           │
                           ▼
                Model Validation
                           │
                           ▼
               Week 4 Final Report
```

---

# 📌 Important Design Decisions

## Why regression?

Sale Price is a continuous numerical variable.

Therefore:

```text
Regression
```

is more appropriate than classification.

---

## Why multiple linear regression?

Multiple linear regression provides:

* Interpretability
* Easy coefficient analysis
* Strong baseline performance
* Direct understanding of predictor effects
* A useful benchmark for more advanced models

---

## Why log-transform Sale Price?

Sale Price is right-skewed.

The log transformation:

```r
log(sale_price)
```

reduces skewness and can improve the behavior of regression residuals.

---

## Why use cross-validation?

A single train/test split can produce a result that depends partly on the particular observations selected.

10-fold cross-validation provides a more robust estimate of model performance across multiple training/validation partitions.

---

# Project Limitations

Despite the strong results, the project has several limitations.

### Dataset limitations

The dataset represents historical transactions from:

```text
2006–2010
```

Therefore, the model should not be interpreted as a current real-estate pricing system.

### Geographic limitation

The analysis focuses on:

```text
Ames, Iowa
```

and therefore may not generalize directly to other housing markets.

### Modeling limitation

The primary predictive model is multiple linear regression.

More advanced models such as:

```text
Random Forest
Gradient Boosting
XGBoost
LightGBM
```

could potentially improve predictive performance.

### Feature limitation

The current model uses a selected subset of the available variables rather than all 82 original variables.

---

# Future Improvements

Future versions of this project could include:

* Random Forest regression
* Gradient Boosting
* XGBoost
* Regularized regression such as Ridge and Lasso
* Hyperparameter tuning
* Feature importance analysis
* SHAP explanations
* Automated model comparison
* Time-based validation
* Interactive dashboards
* Shiny application
* Deployment as a prediction API
* More advanced feature engineering

---

#  Project Outcome

This project demonstrates a complete analytical workflow:

```text
Raw Data
   ↓
Clean Data
   ↓
Exploration
   ↓
Visualization
   ↓
Statistical Testing
   ↓
Predictive Modeling
   ↓
Model Validation
   ↓
Business Interpretation
```

The main outcome is not simply a predictive model. The project demonstrates how **data quality, exploratory analysis, statistical reasoning, visualization, and predictive modeling work together** to turn raw housing transactions into actionable analytical insights.

---

#  Author

**Nitesh Yadav**

Data Analysis / Data Science Project

Tools:

```text
R
RStudio
Tidyverse
ggplot2
Caret
Car
lmtest
Corrplot
Janitor
VIM
Psych
Moments
```

---

#  License / Dataset Attribution

The Ames Housing Dataset was compiled by **Dean De Cock** and is publicly available for educational and analytical use.

This repository is intended for **educational, analytical, and portfolio purposes**.

---

##  Project Summary

| Stage  | Main Objective       | Main Output          |
| ------ | -------------------- | -------------------- |
| Week 1 | Clean & explore data | `ames_cleaned.csv`   |
| Week 2 | Visualize patterns   | 12 visualizations    |
| Week 3 | Test & predict       | Regression models    |
| Week 4 | Integrate findings   | Comprehensive report |

**End-to-end pipeline:**

```text
AmesHousing.csv
      ↓
Data Cleaning
      ↓
Exploratory Analysis
      ↓
Visualization
      ↓
Hypothesis Testing
      ↓
Regression
      ↓
Cross-Validation
      ↓
Model Diagnostics
      ↓
Log Transformation
      ↓
Final Insights
```
