# E-Commerce Data Pipeline
> ELT Pipeline for Brazilian E-Commerce Analytics (2016-2018)

This project implements an ELT pipeline that extracts, loads, and transforms e-commerce data to support revenue and delivery performance analysis for a Latin American e-commerce platform (2016–2018).

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [Dataset Description](#dataset-description)
- [Modeling Approach](#modeling-approach)
- [Evaluation Metrics](#evaluation-metrics)
- [Results](#results)
- [How to Run](#how-to-run)
- [Architecture Diagram](#architecture-diagram)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)

---

## Problem Statement

A major Latin American e-commerce platform needs to understand their business performance across two critical dimensions:

### Revenue Analysis
- **Monthly revenue trends** across 2016-2018
- **Top 10 revenue-generating product categories** and their order volumes
- **Bottom 10 revenue-generating categories** for optimization opportunities
- **Revenue distribution by state** to identify regional performance

### Delivery Performance Analysis
- **Delivery time accuracy**: Difference between estimated and actual delivery dates
- **Monthly delivery performance** trends (real vs. estimated delivery times)
- **State-level delivery efficiency** metrics
- **Impact of public holidays** on 2017 daily order volume (not on delivery times)
- **Freight value vs. product weight** correlation analysis

The solution requires building a **reusable ELT (Extract, Load, Transform) pipeline** that can be executed periodically to generate these insights.

---

## Dataset Description

### Data Sources

#### 1. Olist E-Commerce Dataset
A Brazilian e-commerce public dataset containing **100,000 anonymized orders** from 2016-2018. The dataset includes:

- **99,441 orders** with status, timestamps, and delivery information
- **112,650 order items** with product details and shipping information
- **103,886 payment records** with payment methods and values
- **99,224 customer reviews** with ratings and comments
- **32,951 products** with categories, dimensions, and weights
- **99,441 customers** with geographic information
- **3,095 sellers** with location data
- **1,000,163 geolocation records** for mapping
- **71 product categories** with Portuguese-to-English translations

**Key Tables:**
- `olist_orders`: Order lifecycle timestamps and status
- `olist_order_items`: Product details per order
- `olist_order_payments`: Payment information
- `olist_products`: Product catalog with categories
- `olist_customers`: Customer geographic data
- `olist_sellers`: Seller information
- `product_category_name_translation`: Category translations

#### 2. Public Holidays API
- **Source**: [date.nager.at API](https://date.nager.at)
- **Data**: Brazil's public holidays for 2017
- **Purpose**: Correlate holiday periods with order volumes and delivery performance

### Data Schema
See `images/data_schema.png` for the complete database schema visualization.

---

## Modeling Approach

This project implements an **ELT (Extract, Load, Transform) pipeline** architecture:

### 1. Extract Phase (`src/extract.py`)
- **CSV Data Extraction**: Reads 9 CSV files from the `dataset/` folder
- **API Data Extraction**: Fetches Brazil public holidays via REST API
- **Data Validation**: Ensures data integrity and proper data types
- **Output**: Dictionary of pandas DataFrames ready for loading

### 2. Load Phase (`src/load.py`)
- **Database Creation**: Initializes SQLite database (`olist.db`)
- **Table Creation**: Maps CSV files to database tables
- **Data Loading**: Uses SQLAlchemy to load DataFrames into SQLite
- **Schema Management**: Replaces each table on load (`if_exists="replace"`); no indexes are created

### 3. Transform Phase (`src/transform.py`)

#### SQL-Based Transformations
Seven SQL queries perform complex aggregations and joins:

1. **Revenue by Month/Year**: Aggregates revenue by month across 2016-2018
2. **Revenue per State**: Top 10 states by total revenue
3. **Top 10 Revenue Categories**: Highest revenue categories with order counts
4. **Top 10 Least Revenue Categories**: Lowest revenue categories for optimization
5. **Global Order Status**: Distribution of orders by status
6. **Delivery Date Difference**: Average delivery delay by state
7. **Real vs. Estimated Delivery Time**: Monthly comparison of actual vs. estimated delivery times

#### Pandas-Based Transformations
Two transformations use pandas for complex data manipulation:

1. **Freight Value vs. Weight Relationship**: Analyzes correlation between product weight and shipping costs
2. **Orders per Day with Holidays**: Daily order counts with holiday indicators for 2017

### 4. Visualization Phase (`src/plots.py`)
- **Revenue Visualizations**: Line charts, bar charts, treemaps
- **Delivery Performance**: Time series, bar charts, scatter plots
- **Category Analysis**: Pie charts and treemaps
- **Holiday Impact**: Time series with holiday markers

---

## Evaluation Metrics

### Data Quality Metrics
- **Data Completeness**: All 9 CSV files loaded successfully
- **Record Counts**: Validated against expected dataset sizes
  - Orders: 99,441
  - Order Items: 112,650
  - Payments: 103,886
  - Products: 32,951
  - Customers: 99,441

### Query Accuracy Metrics
- **Unit Tests**: All SQL queries validated against expected JSON results
- **Tolerance**: Floating-point comparisons within 0.1 tolerance
- **Schema Validation**: Column names and data types verified

### Business Metrics Calculated
1. **Revenue Metrics**
   - Total revenue by month/year
   - Revenue per state (top 10)
   - Revenue per product category (top/bottom 10)

2. **Delivery Metrics**
   - Average of estimated minus actual delivery date (days) by state
   - Real vs. estimated delivery time (monthly)
   - Delivery performance trends

3. **Operational Metrics**
   - Order status distribution
   - Orders per day with holiday correlation
   - Freight cost vs. weight correlation

---

## Results

### Revenue Insights
- **2017**: December is the peak (~R$1.08M). April, June, and November are below the previous month.
- **2018**: August is the peak (~R$1.32M). September through December are R$12,875.18, R$347.95, R$0.00, and R$0.00.
- **State distribution**: Top 10 states by revenue are identified; results show concentration patterns.
- **Category performance**: High- and low-performing product categories are identified.

### Delivery Insights
- **Delivery accuracy**: State-level metrics show variation in delivery performance.
- **Time trends**: Monthly comparison of actual vs. estimated delivery times.
- **Holiday impact**: 2017 daily order volume shifts around public holidays. Delivery times are not joined to the holiday calendar.
- **Shipping costs**: Relationship between product weight and freight value is analyzed.

### Visualizations Generated
- Revenue trends by month/year (line + bar charts)
- Revenue distribution by state (treemap)
- Top/bottom revenue categories (pie charts and treemaps)
- Delivery performance metrics (bar charts, time series)
- Order patterns with holiday markers (time series)
- Freight value vs. weight scatter plot

Visualizations are produced in the Jupyter notebook and written to the `images/` directory.

---

## How to Run

### Prerequisites
- Python 3.9, 3.10, 3.11, or 3.12
- Windows, Linux, or macOS
- Git (for cloning the repository)

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd Sprint_01-Marissa_Singh
```

### Step 2: Set Up Virtual Environment

**Windows (PowerShell):**
```powershell
# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# If you get an execution policy error, run:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Linux/macOS:**
```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate
```

### Step 3: Install Dependencies
```bash
# Upgrade pip
python -m pip install --upgrade pip

# Install requirements
pip install -r requirements.txt
```

### Step 4: Download Dataset
1. Download the dataset from [this link](https://drive.google.com/file/d/1HIy4LNNQESuXUj-u_mNJTCGCRrCeSbo-/view?usp=share_link)
2. Extract the `dataset` folder from the `.zip` file
3. Place the `dataset` folder in the project root directory

**Verify dataset structure:**
```
dataset/
├── olist_customers_dataset.csv
├── olist_geolocation_dataset.csv
├── olist_order_items_dataset.csv
├── olist_order_payments_dataset.csv
├── olist_order_reviews_dataset.csv
├── olist_orders_dataset.csv
├── olist_products_dataset.csv
├── olist_sellers_dataset.csv
└── product_category_name_translation.csv
```

### Step 5: Run Tests
```bash
# Run all tests
pytest tests/

# Run specific test files
pytest tests/test_extract.py
pytest tests/test_transform.py
```

### Step 6: Execute the Pipeline

**Option A: Jupyter Notebook**
```bash
# Start Jupyter Notebook
jupyter notebook

# Open and run: "elt_pipeline.ipynb"
# Execute all cells in order
```

**Option B: Python Script**
```python
from src import config
from src.extract import extract
from src.load import load
from src.transform import run_queries
from sqlalchemy import create_engine
from pathlib import Path

# Create database
Path(config.SQLITE_BD_ABSOLUTE_PATH).touch()
ENGINE = create_engine(f"sqlite:///{config.SQLITE_BD_ABSOLUTE_PATH}", echo=False)

# Extract
csv_dataframes = extract(
    config.DATASET_ROOT_PATH,
    config.get_csv_to_table_mapping(),
    config.PUBLIC_HOLIDAYS_URL
)

# Load
load(csv_dataframes, ENGINE)

# Transform
query_results = run_queries(ENGINE)
```

### Step 7: View Results
- **Database**: SQLite database at `olist.db`
- **Visualizations**: Rendered in the Jupyter notebook
- **Images**: Output written to `images/`

### Optional: Code formatting
```bash
# Format code with Black
black --line-length=88 .
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         DATA SOURCES                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐         ┌──────────────────────────┐     │
│  │  CSV Files      │         │  Public Holidays API     │     │
│  │  (9 datasets)   │         │  (date.nager.at)         │     │
│  └──────────────────┘         └──────────────────────────┘     │
│           │                              │                      │
└───────────┼──────────────────────────────┼──────────────────────┘
            │                              │
            ▼                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EXTRACT PHASE                                │
│                    (src/extract.py)                             │
├─────────────────────────────────────────────────────────────────┤
│  • Read CSV files using pandas                                  │
│  • Fetch API data using requests                                │
│  • Validate and clean data                                      │
│  • Return dictionary of DataFrames                              │
└─────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     LOAD PHASE                                  │
│                     (src/load.py)                               │
├─────────────────────────────────────────────────────────────────┤
│  • Create SQLite database (olist.db)                           │
│  • Map CSV files to database tables                             │
│  • Load DataFrames using SQLAlchemy                             │
│  • Replace tables on each load (no indexes)                      │
└─────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   TRANSFORM PHASE                               │
│                   (src/transform.py)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────┐  ┌──────────────────────────┐    │
│  │  SQL Transformations    │  │  Pandas Transformations   │    │
│  ├────────────────────────┤  ├──────────────────────────┤    │
│  │ • Revenue queries      │  │ • Freight vs Weight      │    │
│  │ • Delivery queries     │  │ • Orders & Holidays      │    │
│  │ • Category analysis    │  │                          │    │
│  │ • State analysis       │  │                          │    │
│  └────────────────────────┘  └──────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                 VISUALIZATION PHASE                              │
│                 (src/plots.py)                                  │
├─────────────────────────────────────────────────────────────────┤
│  • Revenue visualizations (line, bar, treemap)                  │
│  • Delivery performance charts                                  │
│  • Category analysis (pie charts)                              │
│  • Holiday impact analysis                                     │
└─────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      OUTPUT                                     │
├─────────────────────────────────────────────────────────────────┤
│  • SQLite database (olist.db)                                   │
│  • Visualizations (images/)                                     │
│  • Query results (DataFrames)                                    │
│  • Jupyter notebook report                                      │
└─────────────────────────────────────────────────────────────────┘
```

### Pipeline Flow
1. **Extract** → Data from CSV files and API
2. **Load** → Data into SQLite database
3. **Transform** → SQL queries and pandas operations
4. **Visualize** → Generate charts and reports

---

## Project Structure

```
Sprint_01-Marissa_Singh/
├── dataset/                          # CSV data files (download separately)
│   ├── olist_customers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   └── product_category_name_translation.csv
├── images/                           # Generated visualizations
│   ├── data_schema.png
│   ├── freight_value_weight_relationship.png
│   └── orders_per_day_and_holidays.png
├── queries/                          # SQL query files
│   ├── delivery_date_difference.sql
│   ├── global_amount_order_status.sql
│   ├── real_vs_estimated_delivered_time.sql
│   ├── revenue_by_month_year.sql
│   ├── revenue_per_state.sql
│   ├── top_10_least_revenue_categories.sql
│   └── top_10_revenue_categories.sql
├── src/                              # Source code
│   ├── __init__.py
│   ├── config.py                    # Configuration and paths
│   ├── extract.py                   # Extract phase
│   ├── load.py                      # Load phase
│   ├── transform.py                 # Transform phase
│   └── plots.py                     # Visualization functions
├── tests/                            # Unit tests
│   ├── __init__.py
│   ├── query_results/                # Expected query results (JSON)
│   ├── test_extract.py
│   └── test_transform.py
├── ASSIGNMENT.md                     # Project instructions
├── elt_pipeline.ipynb               # Main Jupyter notebook
├── README.md                         # This file
├── README_og.md                      # Original README
├── requirements.txt                  # Python dependencies
└── olist.db                          # Generated SQLite database (after running)
```

---

## Technologies Used

- **Python 3.9+**: Core programming language
- **Pandas**: Data manipulation and analysis
- **SQLAlchemy**: Database ORM and connection management
- **SQLite**: Lightweight database engine
- **Requests**: HTTP library for API calls
- **Matplotlib**: Static plotting library
- **Seaborn**: Statistical data visualization
- **Plotly**: Interactive visualizations
- **Jupyter**: Interactive notebook environment
- **Pytest**: Testing framework
- **Black**: Code formatter

---

## License

This project is part of an educational course assignment.

---

## Author

Marissa Singh

---

## Acknowledgments

- Olist for providing the public e-commerce dataset
- date.nager.at for the public holidays API
- AnyoneAI for the project framework and guidance
