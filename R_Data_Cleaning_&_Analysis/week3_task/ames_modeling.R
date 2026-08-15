# Project: Statistical Analysis and Predictive Modeling using R
# Dataset: Ames Housing Dataset (cleaned in Week 1 -> ames_cleaned.csv)
# Author:  Nitesh Yadav
# Purpose: Test formal hypotheses about the drivers of home sale price, then
#          build, validate, and diagnose a multiple linear regression model
#          that predicts Sale Price from property characteristics.

## 0. SETUP -----
# install.packages(c("tidyverse","caret","car","lmtest","broom","ggplot2"))
library(tidyverse)
library(caret)      # train/test split, k-fold cross-validation
library(car)         # vif() - multicollinearity
library(lmtest)      # bptest() - heteroscedasticity
library(broom)        # tidy model summaries

set.seed(42)

ames <- read.csv("ames_cleaned.csv", stringsAsFactors = FALSE)

## 1. DATASET RATIONALE -----
# The Ames Housing dataset is well suited to predictive modeling: it has a
# continuous, business-relevant target (Sale Price), a rich mix of numeric
# and categorical predictors, enough observations (2,927) for a reliable
# train/test split and k-fold CV, and well-documented ground truth (it is
# widely used as a benchmark regression dataset in the statistics/ML
# community, allowing our results to be sanity-checked against known
# findings). A REGRESSION approach was chosen over classification because
# the natural, most useful prediction target here is the price itself
# (a continuous quantity), not a class label.

## 2. EXPLORATORY STATISTICAL ANALYSIS ------

## 2.1 Normality of Sale Price
shapiro.test(ames$sale_price)   # Shapiro-Wilk (n = 2927, within the 5000 limit)
# H0: Sale Price is normally distributed

ames$log_sale_price <- log(ames$sale_price)
shapiro.test(ames$log_sale_price)

qqnorm(ames$sale_price, main = "Q-Q Plot: Sale Price"); qqline(ames$sale_price, col = "red")
qqnorm(ames$log_sale_price, main = "Q-Q Plot: log(Sale Price)"); qqline(ames$log_sale_price, col = "red")

## 2.2 Hypothesis Test 1 - Independent samples t-test
## H0: mean Sale Price is equal for homes with vs without Central Air
## H1: mean Sale Price differs between the two groups
t.test(sale_price ~ central_air, data = ames)

## 2.3 Hypothesis Test 2 - Pearson correlation test
## H0: true correlation between Gr Liv Area and Sale Price is 0
## H1: true correlation is not 0
cor.test(ames$gr_liv_area, ames$sale_price, method = "pearson")

## 2.4 Hypothesis Test 3 - One-way ANOVA
## H0: mean Sale Price is equal across all Building Types
## H1: at least one Building Type has a different mean Sale Price
anova_model <- aov(sale_price ~ bldg_type, data = ames)
summary(anova_model)
TukeyHSD(anova_model)   # post-hoc pairwise comparisons

## 2.5 Hypothesis Test 4 - Chi-square test of independence
## H0: Central Air and Building Type are independent
## H1: Central Air and Building Type are associated
chisq.test(table(ames$central_air, ames$bldg_type))

## 3. FEATURE SELECTION FOR MODELING ------
model_vars <- c("sale_price","overall_qual","gr_liv_area","total_bsmt_sf",
                 "garage_area","year_built","full_bath","totrms_abvgrd",
                 "lot_area","fireplaces","neighborhood","central_air",
                 "bldg_type")
model_data <- ames[, model_vars]
model_data$central_air <- factor(model_data$central_air)
model_data$bldg_type   <- factor(model_data$bldg_type)
model_data$neighborhood <- factor(model_data$neighborhood)

## 4. TRAIN / TEST SPLIT -------
train_idx <- createDataPartition(model_data$sale_price, p = 0.8, list = FALSE)
train_set <- model_data[train_idx, ]
test_set  <- model_data[-train_idx, ]
nrow(train_set); nrow(test_set)

## 5. MODEL BUILDING: MULTIPLE LINEAR REGRESSION -------

## 5.1 Baseline model - core continuous predictors only
model_base <- lm(sale_price ~ overall_qual + gr_liv_area + total_bsmt_sf +
                    garage_area + year_built + full_bath + totrms_abvgrd +
                    lot_area + fireplaces, data = train_set)
summary(model_base)

## 5.2 Full model - adds categorical predictors (Central Air, Building Type)
model_full <- lm(sale_price ~ overall_qual + gr_liv_area + total_bsmt_sf +
                    garage_area + year_built + full_bath + totrms_abvgrd +
                    lot_area + fireplaces + central_air + bldg_type,
                  data = train_set)
summary(model_full)

## 5.3 Compare nested models
anova(model_base, model_full)

## 6. K-FOLD CROSS-VALIDATION ---------
cv_control <- trainControl(method = "cv", number = 10)
cv_model <- train(sale_price ~ overall_qual + gr_liv_area + total_bsmt_sf +
                     garage_area + year_built + full_bath + totrms_abvgrd +
                     lot_area + fireplaces + central_air + bldg_type,
                   data = train_set, method = "lm", trControl = cv_control)
print(cv_model)          # 10-fold CV RMSE / R-squared / MAE
cv_model$resample        # per-fold performance

## 7. TEST-SET PERFORMANCE ---------
predictions <- predict(model_full, newdata = test_set)
test_results <- postResample(pred = predictions, obs = test_set$sale_price)
print(test_results)      # RMSE, Rsquared, MAE on held-out test data

## 8. MODEL DIAGNOSTICS --------

## 8.1 Residuals vs Fitted (linearity & homoscedasticity)
plot(model_full, which = 1)

## 8.2 Normal Q-Q of residuals (normality of errors)
plot(model_full, which = 2)

## 8.3 Scale-Location (homoscedasticity)
plot(model_full, which = 3)

## 8.4 Residuals vs Leverage (influential points)
plot(model_full, which = 5)

## 8.5 Formal heteroscedasticity test
bptest(model_full)   # Breusch-Pagan test; H0 = homoscedasticity

## 8.6 Multicollinearity check
vif(model_full)

## 8.7 Actual vs Predicted scatter (test set)
plot(test_set$sale_price, predictions,
     xlab = "Actual Sale Price", ylab = "Predicted Sale Price",
     main = "Actual vs Predicted Sale Price (Test Set)")
abline(0, 1, col = "red", lwd = 2)

## 9. LOG-TRANSFORMED MODEL (addressing skew / heteroscedasticity) ----
train_set$log_sale_price <- log(train_set$sale_price)
test_set$log_sale_price  <- log(test_set$sale_price)

model_log <- lm(log_sale_price ~ overall_qual + gr_liv_area + total_bsmt_sf +
                   garage_area + year_built + full_bath + totrms_abvgrd +
                   lot_area + fireplaces + central_air + bldg_type,
                 data = train_set)
summary(model_log)
bptest(model_log)

log_predictions <- exp(predict(model_log, newdata = test_set))  # back-transform
postResample(pred = log_predictions, obs = test_set$sale_price)

## 10. EXPORT MODEL OBJECTS ----------
saveRDS(model_full, "ames_lm_full.rds")
saveRDS(model_log,  "ames_lm_log.rds")


