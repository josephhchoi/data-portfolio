# Data Cleaning Automation

## About the Project
This project's objective is to streamline the data cleaning process for the US household income dataset. Through the creation of stored procedures and automation, the project ensures data integrity and consistency by removing duplicates and standardizing data fields.

## Regarding Dataset
**Dataset Location**: Available in the 'Dataset' folder

## Project Workflow
- **Data Cleaning Steps**:
    - Remove duplicates from the dataset based on specific criteria
    - Standardize data fields such as state names and types to ensure consistency
- **Stored Procedures Steps**:
    - Create a copy table (us_household_income_cleaned) to store cleaned data
    - Copy data from the original table into the copy table
    - Implement data cleaning queries within the stored procedure, including removing duplicates and standardizing fields
- **Debugging and Performance Check**:
    - Perform debugging or check the performance of the stored procedure by analyzing row numbers and distinct values in relevant fields
- **Creating Event**:
    - Create an event (run_data_cleaning) scheduled to run the stored procedure (copy_and_data_clean) at regular intervals (every 2 minutes in this case) to ensure ongoing data cleanliness and consistency
