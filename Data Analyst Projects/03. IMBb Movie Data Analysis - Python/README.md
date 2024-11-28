# IMDb Movie Data Analysis Project

## Project Objective
This project analyzes IMDb data (1916-2015) to uncover trends and patterns in genres, budgets, revenues, popularity, and ratings. It focuses on exploring genre popularity, financial performance, and movie ratings while testing hypotheses about factors driving movie success. Below are the key research questions and hypotheses driving this project:

**Research Questions**:  
> **Q1**: What are the most common genres based on the number of movies made?  
**Q2**: Which genres have the highest average budget, revenue, and profit?  
**Q3**: Which genres are the most popular on average?

**Research Hypotheses**:  
> **H1**: Popular movies result in higher profit and revenue.  
**H2**: Larger budgets lead to higher revenue and profit.  
**H3**: Larger budgets are associated with greater popularity.

## Project Workflow

### **1. Initial Exploration**  
- **Assessed raw dataset** to understand structure, key features, and necessary cleaning/preprocessing steps 

### **2. Data Cleaning & Pre-Processing**  
- Dropped unnecessary and duplicate rows to ensure data quality 
- Transformed `release_date` to datetime format for time-based analysis
- Added a `profit` column for financial insights (`revenue - budget`)
- Split `genres` into individual rows to improve flexibility in analysis

### **3. Exploratory Data Analysis**  
- Visualized data to answer research questions and validate hypotheses
  
## Key Analysis and Insights

### 1. **Research Insights**:
  - **Common Genres**: Drama, Comedy, and Thriller dominate production, reflecting audience preferences for storytelling and entertainment
  - **Financial Trends**: Adventure, Fantasy, Action, and Animation have the highest budgets, revenues, and profits, highlighting their box office strength
  - **Popularity**: Adventure, Science Fiction, and Fantasy are considered the most popular genres, driven by strong audience appeal

![image](https://github.com/user-attachments/assets/405c2e6b-59be-4c4b-a055-45436a09b676)


### 2. **Hypotheses Validation**:
- Popular movies **consistently generate higher revenues and profits**, confirming their value.  
- Larger budgets **drive higher revenue and profit** but show diminishing returns at extreme scales.  
- Budgets **positively influence popularity**, especially for blockbuster genres.

![image](https://github.com/user-attachments/assets/5f88365c-e169-4b2e-825d-ef6994902a6e)

### 3. **Profitability Trends Over Time**:
- **Thriving Genres**:  
   - Adventure: High profits sustained across decades, driven by blockbuster franchises.  
   - Fantasy: Growing profitability, particularly in recent years.  
- **Struggling Genres**:  
   - Documentary: Minimal profits and low growth.  
   - TV Movie: Consistently underperforming.
- **Mixed Trends**:  
   - Music: Fluctuates with profit peaks tied to popular releases.  
   - History: Sporadic profit spikes but lacks consistent success.
 
![image](https://github.com/user-attachments/assets/4d7fcc8e-4a1e-4188-99ec-ceee6210b773)

