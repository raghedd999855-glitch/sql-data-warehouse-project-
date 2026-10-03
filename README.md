# SQL Server Data Warehouse & Analytics Project

## 📌 Project Overview

This project demonstrates the design and implementation of a **Data Warehouse using SQL Server**, following a layered data architecture to transform raw source data into clean, structured, and analysis-ready datasets.

The project follows a **Bronze → Silver → Gold** architecture, where data is progressively transformed from its raw form into business-ready data models.

The main goal is to practice and demonstrate key **Data Engineering concepts**, including data ingestion, data transformation, data quality, dimensional modeling, and analytical data preparation.

---

## 🏗️ Data Warehouse Architecture

The project is organized into three main layers:

```text
Source Systems
      │
      ▼
┌───────────────┐
│ Bronze Layer  │
│ Raw Data      │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ Silver Layer  │
│ Cleaned &     │
│ Transformed   │
│ Data          │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ Gold Layer    │
│ Business-     │
│ Ready Data    │
└───────────────┘
```

### Bronze Layer

The Bronze layer stores data as it is received from the source systems with minimal transformation.

Its purpose is to preserve the original source data and provide a reliable starting point for the transformation process.

Main activities include:

* Loading data from source files.
* Preserving the original structure of the source data.
* Creating staging tables.
* Loading raw data into the Data Warehouse.
* Supporting repeatable data loading processes.

---

### Silver Layer

The Silver layer is responsible for **cleaning, standardizing, and transforming** the raw Bronze data.

Main transformations include:

* Removing unnecessary spaces using `TRIM()`.
* Standardizing categorical values.
* Handling missing and invalid values.
* Converting and validating dates.
* Handling invalid prices, quantities, and sales values.
* Removing duplicate records using `ROW_NUMBER()`.
* Creating consistent business-friendly values.
* Deriving additional attributes when required.
* Creating relationships between related source datasets.

The Silver layer provides cleaner and more reliable data for downstream analytical models.

---

### Gold Layer

The Gold layer contains **business-ready data designed for analysis and reporting**.

The data is modeled using dimensional modeling concepts, including:

* Dimension tables.
* Fact tables.
* Business-friendly attributes.
* Measures and transactional data.

The Gold layer is intended to provide a simplified and structured view of the data for analytical use cases.

---

## 🔄 ETL Process

The overall data flow can be summarized as:

```text
Source Data
    │
    ▼
Extract
    │
    ▼
Bronze
Raw Data Ingestion
    │
    ▼
Transform
    │
    ▼
Silver
Data Cleaning & Standardization
    │
    ▼
Transform & Model
    │
    ▼
Gold
Business-Ready Data
    │
    ▼
Analytics & Reporting
```

---

## 🧹 Data Quality

Data quality checks are performed throughout the transformation process to identify common data issues.

Examples include:

* NULL value checks.
* Duplicate record checks.
* Invalid date checks.
* Invalid numeric values.
* Unexpected categorical values.
* Primary key validation.
* Referential consistency checks.
* Record count validation.

The project separates data quality validation from the main transformation logic to make the ETL process easier to maintain and troubleshoot.

---

## ⭐ Dimensional Modeling

The Gold layer follows **dimensional modeling principles**.

### Dimension Tables

Dimension tables contain descriptive information used to provide context for business events.

Examples include:

* Customer information.
* Product information.
* Product categories.

### Fact Tables

Fact tables contain measurable business events and transactions.

Typical measures may include:

* Sales amount.
* Quantity.
* Price.

This structure allows analytical queries to efficiently combine business transactions with descriptive dimensions.

---

## 🗂️ Project Structure

```text
SQL-Data-Warehouse-Project/
│
├── datasets/
│
├── docs/
│
├── scripts/
│   │
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   ├── load_bronze.sql
│   │   └── ...
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   ├── load_crm_cust_info.sql
│   │   ├── load_crm_prd_info.sql
│   │   ├── load_crm_sales_details.sql
│   │   └── ...
│   │
│   └── gold/
│       ├── ddl_gold.sql
│       ├── dim_customers.sql
│       ├── dim_products.sql
│       └── ...
│
├── tests/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
└── README.md
```

> The folder structure may be adjusted as the project evolves.

---

## 🛠️ Technologies & Tools

* **Microsoft SQL Server**
* **SQL Server Management Studio (SSMS)**
* **SQL**
* **Git & GitHub**
* **Draw.io** for data warehouse architecture and diagrams

---

## 🔑 Key SQL Concepts Used

This project applies several SQL and Data Engineering concepts, including:

* `CREATE TABLE`
* `INSERT INTO ... SELECT`
* `TRUNCATE TABLE`
* `JOIN`
* `CASE`
* `ISNULL`
* `TRIM`
* `CAST` / `CONVERT`
* `ROW_NUMBER()`
* Window Functions
* Common Data Cleaning Techniques
* Stored Procedures
* Constraints
* Primary Keys
* Data Validation
* Dimensional Modeling

---

## 📊 Data Transformation Examples

### Standardizing Customer Attributes

Source values are transformed into consistent business-friendly values.

For example:

```text
M → Married
S → Single
F → Female
M → Male
```

Unexpected or missing values are handled using predefined rules.

### Removing Duplicate Records

Duplicate customer records are identified using:

```sql
ROW_NUMBER() OVER (
    PARTITION BY cst_id
    ORDER BY cst_creat_date DESC
)
```

The most recent valid record is retained.

### Handling Invalid Dates

Invalid date values from the source system are identified and converted to `NULL` rather than causing the transformation process to fail.

---

## ▶️ How to Run the Project

### 1. Create the Database

Create the required SQL Server database:

```sql
CREATE DATABASE DataWareHouse;
```

### 2. Create the Schemas

Create the required schemas:

```sql
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
```

### 3. Load the Bronze Layer

Run the Bronze DDL scripts first, followed by the Bronze loading procedures.

The Bronze layer should be populated directly from the provided source datasets.

### 4. Load the Silver Layer

Run the Silver transformation procedures.

The Silver layer cleans and standardizes the data received from Bronze.

### 5. Build the Gold Layer

Run the Gold layer scripts to create the analytical dimensions and fact structures.

### 6. Run Data Quality Checks

Execute the relevant validation scripts in the `tests` directory to verify the quality and consistency of the transformed data.

---

## 🎯 Project Objectives

The project was developed to gain practical experience in:

* Designing a layered Data Warehouse.
* Building ETL pipelines using SQL Server.
* Cleaning and transforming raw data.
* Implementing data quality checks.
* Applying dimensional modeling.
* Designing fact and dimension tables.
* Writing reusable SQL stored procedures.
* Organizing a Data Engineering project using Git and GitHub.

---

## 📚 What This Project Demonstrates

This project demonstrates practical knowledge of the following Data Engineering workflow:

**Raw Data → Data Ingestion → Data Cleaning → Data Transformation → Data Modeling → Data Quality → Analytics-Ready Data**

It also demonstrates the ability to organize SQL scripts into a maintainable project structure and document the data transformation process.

---

## 👩🏻‍💻 Author

**Raghad Alzahrani**

Computer Science Graduate | Aspiring Data Engineer

Interested in:

* Data Engineering
* Data Warehousing
* SQL
* Data Governance
* Data Quality
* Data Platforms
