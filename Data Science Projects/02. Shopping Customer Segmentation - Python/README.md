# Shopping Customer Segmentation Project

## Problem Statement:
The marketing team needs to better understand the target customers to develop effective marketing strategies. Identifying distinct customer groups based on demographics and purchasing behavior is needed for developing marketing efforts and optimizing customer engagement.

## Project Objective:
The objective of this project is to perform customer segmentation using an unsupervised machine learning technique, KMeans clustering, on the mall customer dataset. By dividing the customer base into meaningful segments based on demographic and behavioral characteristics, the project identifies target groups for marketing campaigns. This analysis will help inform strategic decisions and improve customer satisfaction and retention.

## Dataset Features:
- **CustomerID**: Unique identifier for each customer
- **Gender**: Gender of the customer
- **Age**: Age of the customer
- **Annual Income (k$)**: Annual income in thousands
- **Spending Score (1-100)**: Score based on spending behavior

## Project Workflow:
1. Google Colab (Python):
    - **EDA**: Conducted exploratory data analysis using Python to understand the data and its distribution
    - **Model Development**: Developed the KMeans clustering model to identify customer segments
    - **Data Visualization**: Created visualizations to illustrate key insights and segmentations
    - **Key Findings and Recommendations**: Derived key findings and formulated marketing strategy recommendations based on the analysis/model output

2. Slide Deck (PPT):
    - Summarized the workflow, insights, and recommendations from the project analysis and model in a presentation format

## Key Findings:
Five distinct clusters were identified:
- **Avg Income, Avg Spending**: Largest group with moderate income and spending
- **High Income, High Spending**: High-income, high-spending customers
- **Low Income, High Spending**: Prioritize shopping despite lower income
- **High Income, Low Spending**: High-income, low-spending, possibly saving
- **Low Income, Low Spending**: Low income and low spending
 
Younger customers tend to spend more, while older customers spend less. High spenders are typically younger.

## Marketing Strategy Recommendations:
To effectively target each customer cluster, specific strategies should be employed:
- **High Income, High Spending**: Premium loyalty programs and exclusive deals
- **Low Income, High Spending**: Discounts, installment plans, or cashback offers
- **High Income, Low Spending**: Promote savings, investments, and high-end products
- **Low Income, Low Spending**: Value-for-money products and frequent small purchase rewards
- **Avg Income, Avg Spending**: Maintain loyalty with consistent value, personalized recommendations, and moderate rewards. Increase spending with new products and promotions
- **Younger Customers**: Use social media, influencers, and mobile-friendly shopping for engagement
