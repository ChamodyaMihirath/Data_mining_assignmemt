# 🛒 Online Retail II Data Warehouse

A complete Data Warehousing and Business Intelligence project developed using the **Online Retail II** dataset. This project demonstrates the design and implementation of a data warehouse, ETL pipeline, and OLAP analysis using **Python**, **MySQL**, and **SQL**.

---

## 📌 Project Overview

The objective of this project is to transform raw retail transaction data into a structured data warehouse that supports business intelligence and decision-making.

The project includes:

- Data Extraction from Excel
- Data Cleaning and Transformation
- Star Schema Design
- ETL Pipeline Development
- MySQL Data Warehouse Implementation
- OLAP Analysis
- Exploratory Data Analysis (EDA)

---

## 🛠 Technologies Used

- Python
- Pandas
- NumPy
- MySQL
- SQLAlchemy
- MySQL Connector
- Jupyter Notebook
- MySQL Workbench

---

## 📂 Project Structure

```
OnlineRetailII-DW/
│
├── data/
│   └── raw/
│       └── Online Retail II.xlsx
│
├── notebooks/
│   └── EDA.ipynb
│
├── src/
│   └── etl.py
│
├── sql/
│   ├── schema.sql
│   └── olap_queries.sql
│
├── diagrams/
│   └── star_schema.png
│
├── README.md
├── requirements.txt
└── .gitignore
```

---

## 📊 Dataset

**Dataset:** Online Retail II

The dataset contains transactional records from a UK-based online retailer.

### Dataset Statistics

| Attribute | Value |
|------------|-------|
| Total Records | 1,067,371 |
| Total Columns | 8 |
| Countries | 43 |
| Products | 5,305 |
| Customers | 5,942 |
| Unique Invoices | 536,228 |
| Date Range | 2009-12-01 to 2011-12-09 |

---

## 🔍 Exploratory Data Analysis (EDA)

The EDA phase included:

- Dataset overview
- Missing value analysis
- Duplicate detection
- Cancelled invoice analysis
- Invalid quantity detection
- Invalid price detection
- Sales amount analysis
- Country distribution
- Product analysis
- Customer analysis

### Data Quality Findings

- Duplicate Records: **34,335**
- Cancelled Invoices: **19,494**
- Invalid Prices (≤ 0): **6,207**
- Invalid Quantities (≤ 0): **22,950**

---

## 🏗 Data Warehouse Design

The project follows a **Star Schema** consisting of one fact table and three dimension tables.

### Fact Table

- FACT_SALES

### Dimension Tables

- DIM_CUSTOMER
- DIM_PRODUCT
- DIM_TIME

---

## ⭐ Star Schema

```
             DIM_CUSTOMER
                    |
                    |
DIM_PRODUCT ---- FACT_SALES ---- DIM_TIME
```

---

## 🔄 ETL Process

The ETL pipeline performs the following tasks:

### Extract

- Read both Excel worksheets
- Merge datasets

### Transform

- Rename columns
- Remove duplicate records
- Remove cancelled invoices
- Remove invalid transactions
- Handle missing customer IDs
- Calculate SalesAmount
- Prepare dimension tables

### Load

- Load DIM_CUSTOMER
- Load DIM_PRODUCT
- Load DIM_TIME
- Load FACT_SALES

---

## 📈 OLAP Analysis

The project includes several OLAP operations:

1. Roll-up Analysis
2. Grouping Sets (MySQL Equivalent)
3. Year-over-Year Comparison using LAG()
4. Running Total Analysis
5. Product Revenue Ranking
6. Slice and Dice Analysis

These queries support business decision-making by providing multi-dimensional insights into sales performance.

---

## ▶️ How to Run

### 1. Clone the Repository

```bash
git clone https://github.com/ChamodyaMihirath/Data_mining_assignmemt.git
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Create the Database

Execute:

```
sql/schema.sql
```

using MySQL Workbench.

### 4. Update Database Connection

Inside `src/etl.py`:

```python
self.engine = create_engine(
    "mysql+mysqlconnector://root:@localhost/retail_dw"
)
```

Modify the username and password if necessary.

### 5. Run ETL

```bash
python src/etl.py
```

### 6. Execute OLAP Queries

Run:

```
sql/olap_queries.sql
```

using MySQL Workbench.

---

## 📊 Data Warehouse Validation

After the ETL process:

| Table | Records |
|--------|---------|
| DIM_CUSTOMER | 5,879 |
| DIM_PRODUCT | 4,918 |
| DIM_TIME | 604 |
| FACT_SALES | 1,007,913 |

---

## 🎯 Learning Outcomes

This project demonstrates practical experience in:

- Data Warehousing
- ETL Pipeline Development
- Database Design
- Star Schema Modeling
- SQL Querying
- OLAP Operations
- Business Intelligence
- Data Cleaning
- Data Analysis using Python

---

## 👨‍💻 Author

**Chamodya Mihirath**

BSc (Hons) Computer Science Undergraduate

University of Kelaniya

Sri Lanka

---

## 📄 License

This project was developed for educational purposes as part of the **Data Warehousing and Business Intelligence** coursework at the University of Kelaniya.
