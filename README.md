# Public Transport Delay Analysis and Service Reliability Prediction

## Project Overview

Public transport services may experience delays due to traffic congestion, weather conditions, peak hours, routes, and special events. These delays affect passenger convenience and service reliability.

This project uses R Programming to analyse public transport trip records, identify delay patterns, evaluate service reliability, and predict whether a trip is likely to be delayed using a Random Forest classification model.

## Objectives

- Analyse public transport delay patterns.
- Compare average arrival delays across transport types.
- Evaluate service reliability across different routes.
- Study the relationship between weather conditions and delays.
- Compare peak-hour and off-peak travel delays.
- Build a Random Forest model to predict delay status.
- Evaluate model performance using accuracy and a confusion matrix.

## Technologies Used

- **Programming Language:** R
- **IDE:** RStudio
- **Libraries:** ggplot2, dplyr, caret, randomForest
- **Dataset Format:** CSV

## Dataset Description

The dataset contains 2,000 trip records and 24 columns.

Important attributes include:

- Trip ID and date
- Scheduled departure and arrival times
- Transport type and route ID
- Origin and destination stations
- Weather conditions
- Temperature, humidity, wind speed and precipitation
- Traffic congestion and event information
- Holiday and peak-hour indicators
- Actual arrival delay in minutes
- Delayed status (0 = On-time, 1 = Delayed)

**Dataset note:** The dataset included in this repository is a synthetic demonstration dataset prepared for this project because the original dataset was not available with the presentation.

## Project Workflow

1. Load the CSV dataset into R.
2. Clean missing values and remove duplicate trip IDs.
3. Calculate summary statistics.
4. Perform exploratory data analysis.
5. Generate graphs using ggplot2.
6. Split the dataset into training and testing sets.
7. Train a Random Forest classification model.
8. Evaluate predictions using accuracy, sensitivity, specificity and a confusion matrix.
9. Export analysis results and graphs.

## Visualizations

The project generates the following graphs:

- Average Arrival Delay by Transport Type
- Route-wise Service Reliability
- Weather Impact on Arrival Delay
- Peak-hour vs Off-peak Analysis
- Distribution of Arrival Delays
- Random Forest Feature Importance

## Model Evaluation

A Random Forest classifier with 300 trees is used to predict whether a trip is on-time or delayed.

Model performance is compared with a majority-class baseline. The model's accuracy alone is not sufficient to establish predictive usefulness; the confusion matrix and class-wise performance must also be considered.

## How to Run the Project

1. Install R or RStudio.
2. Download or clone this repository.
3. Open the project folder in RStudio.
4. Open `public_transport_analysis.R`.
5. Run the script.
6. View the generated graphs, cleaned dataset, summary tables and model evaluation files in the `Public_Transport_Results` folder.

Install the required packages if necessary:

```r
install.packages(c("ggplot2", "dplyr", "caret", "randomForest"))
```

## Expected Output

- Cleaned transport dataset
- Summary statistics
- Transport-wise and route-wise comparisons
- Weather and peak-hour analysis
- Delay distribution graph
- Random Forest predictions
- Confusion matrix and model evaluation
- Feature importance results

## Conclusion

This project demonstrates how R Programming and machine learning can be used to analyse public transport delays and service reliability. The analysis helps identify patterns in trip delays and provides a foundation for further improvements in public transport planning.

## Author

**Mariya Suji Midhuna R**  
**Register Number:** 717825Z132  
**Department:** MCA
