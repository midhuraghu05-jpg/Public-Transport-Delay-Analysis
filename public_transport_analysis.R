# Public Transport Delay Analysis and Service Reliability Prediction
# Dataset: public_transport_delays.csv
# Note: the bundled dataset is synthetic and is intended for demonstration/learning.
# Run this script from the project folder in R or RStudio.

required_packages <- c("ggplot2", "dplyr", "caret", "randomForest")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}
library(ggplot2)
library(dplyr)
library(caret)
library(randomForest)

set.seed(123)
input_file <- "public_transport_delays.csv"
if (!file.exists(input_file)) {
  stop("Cannot find public_transport_delays.csv. Place it in the same folder as this R script.")
}
results_dir <- "Public_Transport_Results"
if (!dir.exists(results_dir)) dir.create(results_dir)

# 1. Load and inspect
data <- read.csv(input_file, stringsAsFactors = FALSE, na.strings = c("", "NA", "N/A"))
cat("Raw dataset dimensions:", nrow(data), "rows x", ncol(data), "columns\n")
write.csv(data, file.path(results_dir, "raw_data_copy.csv"), row.names = FALSE)

# 2. Data cleaning
for (col in names(data)) {
  if (is.character(data[[col]])) {
    data[[col]][trimws(data[[col]]) == ""] <- NA
  }
}
data <- data[!is.na(data$delayed), ]
data <- data[!duplicated(data$trip_id), ]

numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]
for (col in numeric_cols) {
  if (anyNA(data[[col]])) {
    med <- median(data[[col]], na.rm = TRUE)
    data[[col]][is.na(data[[col]])] <- med
  }
}
categorical_cols <- names(data)[vapply(data, is.character, logical(1))]
for (col in categorical_cols) {
  data[[col]][is.na(data[[col]])] <- "Unknown"
}
data$date <- as.Date(data$date)
data$delayed <- as.integer(data$delayed)
data$delay_status <- factor(ifelse(data$delayed == 1, "Delayed", "OnTime"),
                            levels = c("OnTime", "Delayed"))
data$departure_hour <- as.integer(data$departure_hour)
data$month <- as.integer(data$month)
write.csv(data, file.path(results_dir, "cleaned_transport_data.csv"), row.names = FALSE)

# 3. Summary statistics
overall_stats <- data.frame(
  Metric = c("Total Trips", "Average Arrival Delay (Minutes)",
             "Delayed Trip Percentage", "Overall Service Reliability (%)"),
  Value = c(nrow(data), mean(data$actual_arrival_delay_min),
            mean(data$delayed == 1) * 100, mean(data$delayed == 0) * 100)
)
write.csv(overall_stats, file.path(results_dir, "overall_summary.csv"), row.names = FALSE)

transport_summary <- data %>%
  group_by(transport_type) %>%
  summarise(trip_count = n(),
            average_delay_min = mean(actual_arrival_delay_min),
            delayed_percentage = mean(delayed == 1) * 100,
            reliability_pct = mean(delayed == 0) * 100,
            .groups = "drop")
write.csv(transport_summary, file.path(results_dir, "transport_type_summary.csv"), row.names = FALSE)

route_summary <- data %>%
  group_by(route_id) %>%
  summarise(trip_count = n(),
            average_delay_min = mean(actual_arrival_delay_min),
            reliability_pct = mean(delayed == 0) * 100,
            .groups = "drop") %>%
  arrange(desc(reliability_pct))
write.csv(route_summary, file.path(results_dir, "route_reliability.csv"), row.names = FALSE)

weather_summary <- data %>%
  group_by(weather) %>%
  summarise(trip_count = n(), average_delay_min = mean(actual_arrival_delay_min),
            delayed_percentage = mean(delayed == 1) * 100, .groups = "drop")
write.csv(weather_summary, file.path(results_dir, "weather_summary.csv"), row.names = FALSE)

peak_summary <- data %>%
  mutate(peak_label = ifelse(peak_hour == 1, "Peak hour", "Off-peak")) %>%
  group_by(peak_label) %>%
  summarise(trip_count = n(), average_delay_min = mean(actual_arrival_delay_min),
            delayed_percentage = mean(delayed == 1) * 100, .groups = "drop")
write.csv(peak_summary, file.path(results_dir, "peak_hour_summary.csv"), row.names = FALSE)

# 4. Graphs
p1 <- ggplot(transport_summary, aes(x = reorder(transport_type, average_delay_min),
                                    y = average_delay_min, fill = transport_type)) +
  geom_col(show.legend = FALSE) + coord_flip() +
  labs(title = "Average Arrival Delay by Transport Type",
       x = "Transport Type", y = "Average delay (minutes)") + theme_minimal()
ggsave(file.path(results_dir, "average_delay_by_transport.png"), p1, width = 8, height = 5, dpi = 150)

p2 <- ggplot(route_summary, aes(x = reorder(route_id, reliability_pct), y = reliability_pct)) +
  geom_col(fill = "#2A9D8F") + coord_flip() +
  labs(title = "Route-wise Service Reliability", x = "Route", y = "On-time trips (%)") +
  theme_minimal()
ggsave(file.path(results_dir, "route_reliability.png"), p2, width = 8, height = 6, dpi = 150)

p3 <- ggplot(weather_summary, aes(x = reorder(weather, average_delay_min),
                                  y = average_delay_min, fill = weather)) +
  geom_col(show.legend = FALSE) + coord_flip() +
  labs(title = "Average Arrival Delay by Weather", x = "Weather", y = "Average delay (minutes)") +
  theme_minimal()
ggsave(file.path(results_dir, "weather_impact.png"), p3, width = 8, height = 5, dpi = 150)

p4 <- ggplot(data, aes(x = factor(peak_hour, levels = c(0,1),
                                  labels = c("Off-peak", "Peak hour")),
                       y = actual_arrival_delay_min, fill = factor(peak_hour))) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Peak-hour vs Off-peak Arrival Delay", x = "Period", y = "Arrival delay (minutes)") +
  theme_minimal()
ggsave(file.path(results_dir, "peak_vs_offpeak.png"), p4, width = 7, height = 5, dpi = 150)

p5 <- ggplot(data, aes(x = actual_arrival_delay_min)) +
  geom_histogram(bins = 30, fill = "#457B9D", color = "white") +
  labs(title = "Distribution of Arrival Delays", x = "Arrival delay (minutes)", y = "Number of trips") +
  theme_minimal()
ggsave(file.path(results_dir, "arrival_delay_distribution.png"), p5, width = 8, height = 5, dpi = 150)

# 5. Train/test split and Random Forest model
# Exclude actual delay minutes from predictors to reduce target leakage.
predictor_cols <- c("transport_type", "route_id", "origin_station", "destination_station",
                    "weather", "temperature", "humidity", "wind_speed", "precipitation",
                    "event", "traffic_congestion", "holiday", "peak_hour", "weekday",
                    "season", "month", "departure_hour")
model_data <- data[, c(predictor_cols, "delay_status")]
for (col in predictor_cols) {
  if (is.character(model_data[[col]])) model_data[[col]] <- as.factor(model_data[[col]])
}
model_data <- droplevels(model_data)
train_idx <- createDataPartition(model_data$delay_status, p = 0.80, list = FALSE)
train_data <- model_data[train_idx, , drop = FALSE]
test_data <- model_data[-train_idx, , drop = FALSE]

# Align factor levels with training data; unknown levels in test data become the most common training level.
for (col in predictor_cols) {
  if (is.factor(train_data[[col]]) && is.factor(test_data[[col]])) {
    missing_levels <- setdiff(levels(test_data[[col]]), levels(train_data[[col]]))
    if (length(missing_levels) > 0) {
      test_data[[col]] <- as.character(test_data[[col]])
      test_data[[col]][test_data[[col]] %in% missing_levels] <- as.character(names(sort(table(train_data[[col]]), decreasing = TRUE))[1])
      test_data[[col]] <- factor(test_data[[col]], levels = levels(train_data[[col]]))
    } else {
      test_data[[col]] <- factor(test_data[[col]], levels = levels(train_data[[col]]))
    }
  }
}
rf_model <- randomForest(delay_status ~ ., data = train_data, ntree = 300, importance = TRUE)
predictions <- predict(rf_model, newdata = test_data, type = "class")
cm <- confusionMatrix(predictions, test_data$delay_status, positive = "Delayed")
baseline_class <- names(which.max(table(train_data$delay_status)))
baseline_predictions <- factor(rep(baseline_class, nrow(test_data)), levels = levels(test_data$delay_status))
baseline_accuracy <- mean(baseline_predictions == test_data$delay_status)

model_metrics <- data.frame(
  Method = c("Random Forest classifier", "Majority-class baseline"),
  Accuracy = c(as.numeric(cm$overall["Accuracy"]), baseline_accuracy),
  Sensitivity = c(as.numeric(cm$byClass["Sensitivity"]), NA_real_),
  Specificity = c(as.numeric(cm$byClass["Specificity"]), NA_real_)
)
write.csv(model_metrics, file.path(results_dir, "model_evaluation.csv"), row.names = FALSE)
write.csv(data.frame(Actual = test_data$delay_status, Predicted = predictions),
          file.path(results_dir, "test_predictions.csv"), row.names = FALSE)
write.csv(as.data.frame(cm$table), file.path(results_dir, "confusion_matrix.csv"), row.names = FALSE)
write.csv(importance(rf_model), file.path(results_dir, "feature_importance.csv"), row.names = TRUE)

png(file.path(results_dir, "confusion_matrix.png"), width = 900, height = 700)
fourfoldplot(cm$table, color = c("#E9C46A", "#2A9D8F"),
             main = "Random Forest Confusion Matrix")
dev.off()

png(file.path(results_dir, "feature_importance.png"), width = 1000, height = 750)
varImpPlot(rf_model, main = "Random Forest Feature Importance")
dev.off()

# 6. Final report and console summary
final_report <- data.frame(
  Metric = c("Total Trips", "Average Arrival Delay (Minutes)",
             "Delayed Trip Percentage", "Overall Service Reliability (%)",
             "Random Forest Accuracy (%)", "Majority-Class Baseline Accuracy (%)"),
  Value = c(nrow(data), mean(data$actual_arrival_delay_min),
            mean(data$delayed == 1) * 100, mean(data$delayed == 0) * 100,
            as.numeric(cm$overall["Accuracy"]) * 100, baseline_accuracy * 100)
)
write.csv(final_report, file.path(results_dir, "final_report.csv"), row.names = FALSE)
saveRDS(rf_model, file.path(results_dir, "random_forest_model.rds"))
cat("\n--- Final Report ---\n")
print(final_report)
cat("\nConfusion matrix:\n")
print(cm$table)
cat("\nNote: Results are calculated from the bundled synthetic demonstration dataset.\n")
