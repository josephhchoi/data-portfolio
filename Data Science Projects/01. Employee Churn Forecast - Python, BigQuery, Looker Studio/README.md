# Employee Churn Forecast Project

## Project Overview
This project aims to predict employee churn and identify high-risk employees using machine learning. By leveraging employee data, I developed a Random Forest model to forecast turnover and provide actionable insights for HR to improve retention strategies using Google Cloud platforms.

## Dataset
The project utilizes the following datasets:
- **CurrentEmployeeData**: Information on current employees
- **NewEmployeeData**: Data on new employees for prediction purposes

## Dataset Features
- **satisfaction_level**: Employee's job satisfaction level
- **last_evaluation**: Last performance evaluation score
- **number_project**: Number of projects assigned
- **average_montly_hours**: Average monthly working hours
- **time_spend_company**: Years spent at the company
- **Work_accident**: Whether the employee had a work accident
- **promotion_last_5years**: Whether the employee was promoted in the last 5 years
- **Departments**: Employee's department
- **salary**: Employee's salary level (low, medium, high)
- **Quit_the_Company**: Target variable indicating whether the employee left the company

## Project Workflow
1. Create a database in BigQuery
2. Import BigQuery data into Google Colab
3. Develop Model:
   - Evaluate various classification model
   - Select the final model based on evaluations
   - Train the model using the training set

4. Deploy Model:
   - Use the trained model to make predictions on the testing set
   - Use the trained model to make predictions on the new employee dataset
5. Export model's forecasted output back to BigQuery, then to Looker Studio
6. Develop an interactive dashboard to showcase key insights and metrics

## Key Questions and Insights
**What is the overall employee churn rate?** <br>
Based on the employee churn model, the churn rate is at 7%. As there are 100 new employees in the pilot program, 7 employees are predicted to quit and 93 employees are predicted to stay. 

**Which factor is the most influential in employee churn?** <br>
Low satisfaction level came out on top as the most impactful feature in employee retention. Employees who are not satisfied with their jobs are more likely to seek other opportunities. Low satisfaction can stem from various issues such as job fit, workplace culture, or lack of recognition. 

**Which departments have the highest turn rates?** <br>
Departments with the highest forecasted turnover rates are support, technical, and manufacturing. By identifying departments with the highest turnover rates, HR can develop targeted retention strategies to address the unique challenges faced by employees in these areas. This focused approach can lead to improved employee satisfaction, reduced turnover, and better overall organizational performance.

#### Dashboard Link: [Employee Churn Forecast - Dashboard](https://lookerstudio.google.com/reporting/1829e5bb-c4ca-41f8-9992-e8fd215dc4e4/page/p_jyr5tdgfjd)

![image](https://github.com/user-attachments/assets/28e69944-47a7-47d5-a3a8-27a352841452)








