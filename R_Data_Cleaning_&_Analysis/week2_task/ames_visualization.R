##############################################################################
# Project: Data Visualization and Insight Communication using R
# Dataset: Ames Housing Dataset (cleaned in Week 1 -> ames_cleaned.csv)
# Author:  [Your Name]
# Purpose: Build a suite of ggplot2 visualizations that communicate the key
#          drivers of residential sale price in Ames, Iowa to a non-technical
#          audience.
##############################################################################

## 0. SETUP -----------------------------------------------------------------
# install.packages(c("tidyverse","scales","corrplot","forcats","ggridges"))
library(tidyverse)   # ggplot2, dplyr, forcats
library(scales)      # dollar/percent axis labels
library(corrplot)    # correlation heatmap
library(ggridges)    # ridgeline plots

ames <- read.csv("ames_cleaned.csv", stringsAsFactors = FALSE)

theme_report <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(color = "grey30"),
        panel.grid.minor = element_blank())
theme_set(theme_report)

## 1. DATA OVERVIEW -----------------------------------------------------------
dim(ames)
str(ames[, c("sale_price","gr_liv_area","overall_qual","neighborhood",
             "house_style","yr_sold","mo_sold","central_air")])
summary(ames$sale_price)

## 2. VISUALIZATION 1 — HISTOGRAM: Distribution of Sale Price ----------------
ggplot(ames, aes(x = sale_price)) +
  geom_histogram(bins = 45, fill = "#4C72B0", color = "white") +
  geom_vline(xintercept = median(ames$sale_price), linetype = "dashed", color = "red") +
  scale_x_continuous(labels = dollar_format()) +
  labs(title = "Most Ames Homes Sell Between $100K and $220K",
       subtitle = "Distribution of Sale Price (2006-2010) — dashed line = median",
       x = "Sale Price", y = "Number of Homes")

## 3. VISUALIZATION 2 — BAR CHART: Average Sale Price by House Style ---------
style_summary <- ames %>%
  group_by(house_style) %>%
  summarise(avg_price = mean(sale_price), n = n()) %>%
  arrange(desc(avg_price))

ggplot(style_summary, aes(x = reorder(house_style, avg_price), y = avg_price)) +
  geom_col(fill = "#55A868") +
  geom_text(aes(label = dollar(round(avg_price,0))), hjust = -0.1, size = 3.2) +
  coord_flip() +
  scale_y_continuous(labels = dollar_format(), expand = expansion(mult = c(0,.18))) +
  labs(title = "Two-Story and Split-Level Homes Command the Highest Prices",
       subtitle = "Average Sale Price by House Style",
       x = NULL, y = "Average Sale Price")

## 4. VISUALIZATION 3 — BOXPLOT: Sale Price by Overall Quality Rating --------
ggplot(ames, aes(x = factor(overall_qual), y = sale_price)) +
  geom_boxplot(fill = "#DD8452", outlier.alpha = .3) +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "Sale Price Rises Sharply and Consistently with Build Quality",
       subtitle = "Sale Price by Overall Quality Rating (1 = Poor, 10 = Excellent)",
       x = "Overall Quality Rating", y = "Sale Price")

## 5. VISUALIZATION 4 — SCATTER PLOT: Living Area vs Sale Price, colored by Quality
ggplot(ames, aes(x = gr_liv_area, y = sale_price, color = overall_qual)) +
  geom_point(alpha = .55, size = 1.6) +
  geom_smooth(method = "lm", color = "black", se = FALSE, linewidth = .6) +
  scale_color_gradient(low = "#FDE725", high = "#440154", name = "Overall\nQuality") +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "Bigger AND Better-Built Homes Sell for More",
       subtitle = "Sale Price vs Above-Grade Living Area, colored by Overall Quality",
       x = "Above-Grade Living Area (sq ft)", y = "Sale Price")

## 6. VISUALIZATION 5 — BOXPLOT: Sale Price by Top 10 Neighborhoods ----------
top_nb <- ames %>% count(neighborhood, sort = TRUE) %>% slice_head(n = 10) %>% pull(neighborhood)

ames %>%
  filter(neighborhood %in% top_nb) %>%
  ggplot(aes(x = reorder(neighborhood, sale_price, median), y = sale_price)) +
  geom_boxplot(fill = "#8172B2") +
  coord_flip() +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "Location Drives a 2-3x Swing in Median Sale Price",
       subtitle = "Sale Price by Neighborhood (10 most active neighborhoods)",
       x = NULL, y = "Sale Price")

## 7. VISUALIZATION 6 — LINE CHART: Home Sales Volume by Month (Seasonality) --
monthly <- ames %>%
  group_by(mo_sold) %>%
  summarise(n_sales = n(), avg_price = mean(sale_price))

ggplot(monthly, aes(x = mo_sold, y = n_sales)) +
  geom_line(color = "#4C72B0", linewidth = 1) +
  geom_point(color = "#4C72B0", size = 2.2) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(title = "The Ames Housing Market Peaks Every Summer",
       subtitle = "Number of Homes Sold by Month (2006-2010, pooled)",
       x = "Month", y = "Number of Sales")

## 8. VISUALIZATION 7 — LINE CHART: Median Sale Price Trend by Year Sold -----
yearly <- ames %>%
  group_by(yr_sold) %>%
  summarise(median_price = median(sale_price), n_sales = n())

ggplot(yearly, aes(x = yr_sold, y = median_price)) +
  geom_line(color = "#C44E52", linewidth = 1.1) +
  geom_point(size = 2.5, color = "#C44E52") +
  geom_text(aes(label = dollar(round(median_price,0))), vjust = -1, size = 3.2) +
  scale_y_continuous(labels = dollar_format(), limits = c(NA, NA)) +
  scale_x_continuous(breaks = yearly$yr_sold) +
  labs(title = "Median Sale Price Held Steady Through the 2008 Downturn",
       subtitle = "Median Sale Price by Year Sold (2006-2010)",
       x = "Year Sold", y = "Median Sale Price")

## 9. VISUALIZATION 8 — DENSITY / RIDGELINE: Price Distribution by Central Air
ggplot(ames, aes(x = sale_price, fill = central_air)) +
  geom_density(alpha = .55) +
  scale_x_continuous(labels = dollar_format()) +
  scale_fill_manual(values = c("N" = "#C44E52", "Y" = "#55A868"),
                     labels = c("No A/C","Has A/C"), name = NULL) +
  labs(title = "Homes With Central Air Sell for Substantially More",
       subtitle = "Sale Price Density by Central Air Conditioning",
       x = "Sale Price", y = "Density")

## 10. VISUALIZATION 9 — STACKED BAR: House Style Composition by Building Type
comp <- ames %>% count(bldg_type, house_style)

ggplot(comp, aes(x = bldg_type, y = n, fill = house_style)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "Single-Family Homes Show the Widest Mix of Architectural Styles",
       subtitle = "House Style Composition within Each Building Type",
       x = "Building Type", y = "Share of Homes", fill = "House Style") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

## 11. VISUALIZATION 10 — CORRELATION HEATMAP: Key Numeric Predictors --------
num_vars <- c("sale_price","gr_liv_area","total_bsmt_sf","garage_area",
              "overall_qual","year_built","full_bath","totrms_abvgrd")
corr_matrix <- cor(ames[, num_vars], use = "complete.obs")
corrplot(corr_matrix, method = "color", type = "upper", addCoef.col = "black",
         tl.col = "black", number.cex = .7,
         title = "Correlation Between Sale Price and Key Home Features",
         mar = c(0,0,2,0))

## 12. VISUALIZATION 11 — BAR CHART: Average Price by Garage Type ------------
garage_summary <- ames %>%
  group_by(garage_type) %>%
  summarise(avg_price = mean(sale_price), n = n()) %>%
  filter(n >= 5) %>%
  arrange(desc(avg_price))

ggplot(garage_summary, aes(x = reorder(garage_type, avg_price), y = avg_price)) +
  geom_col(fill = "#64B5CD") +
  geom_text(aes(label = dollar(round(avg_price,0))), hjust = -0.1, size = 3.2) +
  coord_flip() +
  scale_y_continuous(labels = dollar_format(), expand = expansion(mult = c(0,.18))) +
  labs(title = "Built-In Garages Add the Most Value",
       subtitle = "Average Sale Price by Garage Type",
       x = NULL, y = "Average Sale Price")

## 13. VISUALIZATION 12 — FACETED HISTOGRAM: Sale Price by Quality Tier ------
ames <- ames %>%
  mutate(quality_tier = case_when(
    overall_qual <= 4 ~ "Low (1-4)",
    overall_qual <= 6 ~ "Average (5-6)",
    overall_qual <= 8 ~ "Good (7-8)",
    TRUE ~ "Excellent (9-10)"
  ),
  quality_tier = factor(quality_tier,
                         levels = c("Low (1-4)","Average (5-6)","Good (7-8)","Excellent (9-10)")))

ggplot(ames, aes(x = sale_price, fill = quality_tier)) +
  geom_histogram(bins = 30, color = "white") +
  facet_wrap(~ quality_tier, scales = "free_y") +
  scale_x_continuous(labels = dollar_format()) +
  scale_fill_viridis_d(guide = "none") +
  labs(title = "Higher Quality Tiers Shift the Entire Price Distribution Upward",
       subtitle = "Sale Price Distribution Faceted by Quality Tier",
       x = "Sale Price", y = "Count")

##############################################################################
# END OF SCRIPT
##############################################################################
